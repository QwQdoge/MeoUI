#!/usr/bin/env node
/**
 * Generate the source-verified, per-component API reference for the MeoUI
 * Obsidian vault. The bilingual editorial documentation in 01–04 is human
 * maintained and is deliberately never touched by this script.
 */
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const output = path.resolve(process.env.MEOUI_DESIGN_SYSTEM_DIR
    || "/home/shekong/Documents/Obsidian Vault/Meo UI/design system");
const referenceRoot = path.join(output, "05-component-reference");
const apiRoot = path.join(referenceRoot, "api");
const clean = process.argv.includes("--clean");
const cmake = fs.readFileSync(path.join(root, "CMakeLists.txt"), "utf8");
const sourcePaths = [...cmake.matchAll(/^\s*((?:components|widgets|patterns)\/Meo[\w]+\.qml)\s*$/gm)]
    .map((match) => match[1]);

if (!sourcePaths.length) throw new Error("No exported Meo QML types found in CMakeLists.txt.");
// Safety boundary: --clean may only replace generated component API files.
// It must never remove the vault root or its human-authored bilingual guides.
if (clean && fs.existsSync(apiRoot)) fs.rmSync(apiRoot, { recursive: true, force: true });
fs.mkdirSync(apiRoot, { recursive: true });

const m3 = "https://m3.material.io/components";
const categoryRules = [
    [/Button|FAB|Chip|Checkbox|Switch|Radio|Slider|Stepper|Selection|Filter|Range/, "操作与选择", "Actions & selection", `${m3}/buttons`],
    [/Text(Field|Area)?|Date|Time|Dropdown|Search/, "文本与输入", "Text & input", `${m3}/text-fields`],
    [/Navigation|Tabs|Breadcrumbs|PageIndicator/, "导航", "Navigation", `${m3}/navigation-drawer`],
    [/Dialog|Sheet|Menu|Tooltip|Snackbar|Banner|Progress|Loading|Skeleton|StateLayer|Motion/, "反馈与浮层", "Feedback & overlays", `${m3}/dialog`],
    [/Card|List|DataTable|Carousel|Media|Avatar|Badge|Divider/, "内容与数据", "Content & data", `${m3}/cards`],
    [/Layout|Scaffold|PageHost|EmptyState|GroupedList|SegmentedList/, "布局与模式", "Layouts & patterns", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    [/Shape|Icon/, "基础原语", "Primitives", "https://m3.material.io/foundations/interaction/states/overview"],
];
const special = {
    MeoSplitButton: ["操作与选择", "Actions & selection", "主操作与相关操作菜单的组合。", "An action paired with a related-actions menu.", `${m3}/split-button`],
    MeoButtonGroup: ["操作与选择", "Actions & selection", "一组视觉关联的操作。", "A connected group of related actions.", `${m3}/button-groups`],
    MeoNavigationSuite: ["布局与模式", "Layouts & patterns", "按可用空间选择导航模式的自适应组合。", "An adaptive navigation composition that selects a navigation pattern for available space.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    MeoAppLayout: ["布局与模式", "Layouts & patterns", "应用级自适应布局组合。", "An application-level adaptive layout composition.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    MeoListDetailLayout: ["布局与模式", "Layouts & patterns", "列表-详情规范布局组合。", "A list-detail canonical layout composition.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    MeoFeedLayout: ["布局与模式", "Layouts & patterns", "信息流规范布局组合。", "A feed canonical layout composition.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
};

function write(relative, contents) {
    const file = path.join(output, relative);
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, contents.trimEnd() + "\n");
}

function describe(name) {
    if (special[name]) {
        const [categoryZh, categoryEn, introZh, introEn, reference] = special[name];
        return { categoryZh, categoryEn, introZh, introEn, reference };
    }
    for (const [pattern, categoryZh, categoryEn, reference] of categoryRules) {
        if (pattern.test(name)) {
            return {
                categoryZh, categoryEn, reference,
                introZh: `可复用的 ${name} QML 控件或组合。`,
                introEn: `A reusable ${name} QML control or composition.`,
            };
        }
    }
    return {
        categoryZh: "MeoUI 扩展", categoryEn: "MeoUI extensions", reference: m3,
        introZh: `可复用的 ${name} QML 控件或组合。`,
        introEn: `A reusable ${name} QML control or composition.`,
    };
}

function apiFor(file) {
    const text = fs.readFileSync(path.join(root, file), "utf8");
    const properties = [...text.matchAll(/^\s*(readonly\s+)?property\s+([^\s]+)\s+(\w+)(?:\s*:\s*([^\n/]+))?/gm)]
        .map((match) => ({ name: match[3], type: `${match[1] ? "readonly " : ""}${match[2]}`, value: (match[4] || "").trim() }));
    const signals = [...text.matchAll(/^\s*signal\s+(\w+\([^)]*\))/gm)].map((match) => match[1]);
    return { properties, signals };
}

const components = sourcePaths.map((file) => {
    const name = path.basename(file, ".qml");
    return { name, file, ...describe(name), ...apiFor(file) };
}).sort((a, b) => a.name.localeCompare(b.name));

const grouped = Object.groupBy(components, ({ categoryEn }) => categoryEn);
const indexZh = Object.entries(grouped).sort(([a], [b]) => a.localeCompare(b)).map(([, entries]) =>
    `## ${entries[0].categoryZh}\n\n${entries.map(({ name }) => `- [[api/${name}|${name}]] | [[api/${name}.en|English]]`).join("\n")}`,
).join("\n\n");
const indexEn = Object.entries(grouped).sort(([a], [b]) => a.localeCompare(b)).map(([category, entries]) =>
    `## ${category}\n\n${entries.map(({ name }) => `- [[api/${name}|中文]] | [[api/${name}.en|${name}]]`).join("\n")}`,
).join("\n\n");

write("05-component-reference/README.md", `# 逐组件 API 参考\n\n这里是从 MeoUI 的 CMake 模块清单与 QML 源码提取的逐组件双语 API 参考。它补充而不替代 01–04 的人工编写规范；当文档和源码冲突时，以源码为准。\n\n- 覆盖：${components.length} 个已导出的 QML 类型\n- 每页包含：用途、类别、源码、M3 设计参照、实现边界、公开属性和自定义信号\n- 生成器：\`${root}/tools/generate-design-system-docs.mjs\`\n- 安全说明：\`--clean\` 只会重建本目录下的 \`api/\`，不会删除任何既有的双语规范。\n\n${indexZh}`);
write("05-component-reference/README.en.md", `# Per-component API reference\n\nThis is the source-derived bilingual API reference for every exported MeoUI component. It supplements, rather than replaces, the human-authored guides in 01–04; source wins if documentation conflicts with it.\n\n- Coverage: ${components.length} exported QML types\n- Each page: intent, category, source, M3 design reference, implementation boundary, public properties, and custom signals\n- Generator: \`${root}/tools/generate-design-system-docs.mjs\`\n- Safety: \`--clean\` rebuilds only \`api/\` in this directory; it never deletes the existing bilingual guides.\n\n${indexEn}`);

for (const component of components) {
    const props = component.properties.length
        ? `| 属性 / Property | 类型 / Type | 源码默认值或表达式 / Source default or expression |\n| --- | --- | --- |\n${component.properties.map(({ name, type, value }) => `| \`${name}\` | \`${type}\` | ${value ? `\`${value.replaceAll("|", "\\|")}\`` : "—"} |`).join("\n")}`
        : "未发现此文件声明的公开 QML `property`；请检查源码中的继承 Qt API。\n\nNo public QML `property` declarations were found; inspect the source for inherited Qt API.";
    const signals = component.signals.length ? component.signals.map((signal) => `- \`${signal}\``).join("\n") : "此文件没有声明自定义 QML 信号。\n\nNo custom QML signals are declared in this file.";
    const common = `- 类别 / Category: ${component.categoryZh} / ${component.categoryEn}\n- 源码 / Source: [\`${component.file}\`](file://${root}/${component.file})\n- Material 3: [官方设计参照 / official design guidance](${component.reference})\n- 实现边界 / Implementation boundary: 已实现的 MeoUI 组件；实际 QML API 以源码为准，不从其他 Material 实现推断缺失属性。 / Implemented MeoUI component; its source contract is authoritative—do not infer missing API from another Material implementation.`;
    write(`05-component-reference/api/${component.name}.md`, `# ${component.name}\n\n## 用途 / Intent\n\n${component.introZh}\n\n${component.introEn}\n\n${common}\n\n## 公开 QML 属性 / Public QML properties\n\n${props}\n\n## 自定义信号 / Custom signals\n\n${signals}\n\n## 使用边界 / Usage guardrail\n\n优先使用此导出类型，不要在业务侧复制私有实现。父级负责位置、边距和自适应布局；组件负责视觉、交互状态和固有尺寸。适用时检查亮/暗主题、缩放、长文本与本地化、键盘焦点、减弱动效。\n\nPrefer this exported type instead of duplicating its private implementation. Parents own placement, margins, and adaptive layout; the component owns visual treatment, interaction state, and intrinsic size. Check light/dark theme, scaling, long/localized text, keyboard focus, and reduced motion when applicable.`);
    write(`05-component-reference/api/${component.name}.en.md`, `# ${component.name}\n\n## Intent\n\n${component.introEn}\n\n${common}\n\n## Public QML properties\n\n${props}\n\n## Custom signals\n\n${signals}\n\n## Usage guardrail\n\nPrefer this exported type instead of duplicating its private implementation. Parents own placement, margins, and adaptive layout; the component owns visual treatment, interaction state, and intrinsic size. Check light/dark theme, scaling, long/localized text, keyboard focus, and reduced motion when applicable.`);
}

console.log(`Generated ${components.length} bilingual component references in ${apiRoot}`);
