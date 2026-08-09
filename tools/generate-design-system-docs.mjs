#!/usr/bin/env node
/**
 * Generate the human-facing MeoUI Design System reference from the QML module
 * manifest and source. The generated reference lives outside this repository
 * by user decision; this script is the versioned, repeatable source of it.
 */
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const output = path.resolve(process.env.MEOUI_DESIGN_SYSTEM_DIR
    || "/home/shekong/Documents/Obsidian Vault/Meo UI/design system");
const clean = process.argv.includes("--clean");
const cmake = fs.readFileSync(path.join(root, "CMakeLists.txt"), "utf8");
const sourcePaths = [...cmake.matchAll(/^\s*((?:components|widgets|patterns)\/Meo[\w]+\.qml)\s*$/gm)]
    .map((match) => match[1]);

if (!sourcePaths.length) throw new Error("No exported Meo QML types found in CMakeLists.txt.");
if (clean && fs.existsSync(output)) fs.rmSync(output, { recursive: true, force: true });
fs.mkdirSync(output, { recursive: true });

const m3 = "https://m3.material.io/components";
const categoryRules = [
    [/Button|FAB|Chip|Checkbox|Switch|Radio|Slider|Stepper|Selection|Filter|Range/, "Actions & selection", `${m3}/buttons`],
    [/Text(Field|Area)?|Date|Time|Dropdown|Search/, "Text & input", `${m3}/text-fields`],
    [/Navigation|Tabs|Breadcrumbs|PageIndicator/, "Navigation", `${m3}/navigation-drawer`],
    [/Dialog|Sheet|Menu|Tooltip|Snackbar|Banner|Progress|Loading|Skeleton|StateLayer|Motion/, "Feedback & overlays", `${m3}/dialog`],
    [/Card|List|DataTable|Carousel|Media|Avatar|Badge|Divider/, "Content & data", `${m3}/cards`],
    [/Layout|Scaffold|PageHost|EmptyState|GroupedList|SegmentedList/, "Layouts & patterns", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    [/Shape|Icon/, "Primitives", "https://m3.material.io/foundations/interaction/states/overview"],
];

const special = {
    MeoSplitButton: ["Actions & selection", "An action paired with a related-actions menu.", `${m3}/split-button`],
    MeoButtonGroup: ["Actions & selection", "A connected group of related actions.", `${m3}/button-groups`],
    MeoNavigationSuite: ["Layouts & patterns", "An adaptive navigation composition that selects a navigation pattern for available space.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    MeoAppLayout: ["Layouts & patterns", "An application-level adaptive layout composition.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    MeoListDetailLayout: ["Layouts & patterns", "A list-detail canonical layout composition.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
    MeoFeedLayout: ["Layouts & patterns", "A feed canonical layout composition.", "https://m3.material.io/foundations/layout/canonical-examples/overview"],
};

function write(relative, contents) {
    const file = path.join(output, relative);
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, contents.trimEnd() + "\n");
}

function categoryFor(name) {
    if (special[name]) return special[name];
    for (const [pattern, category, reference] of categoryRules) {
        if (pattern.test(name)) return [category, reference, `A reusable ${name} QML control or composition.`];
    }
    return ["MeoUI extensions", m3, `A reusable ${name} QML control or composition.`];
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
    const [category, reference, intro] = categoryFor(name);
    return { name, file, category, reference, intro, ...apiFor(file) };
}).sort((a, b) => a.name.localeCompare(b.name));

const grouped = Object.groupBy(components, ({ category }) => category);
const indexRows = Object.entries(grouped).sort(([a], [b]) => a.localeCompare(b)).map(([category, entries]) =>
    `## ${category}\n\n${entries.map(({ name }) => `- [${name}](components/${name}.md)`).join("\n")}`,
).join("\n\n");

write("README.md", `# MeoUI Design System

This is the human-readable, source-verified design-system reference for MeoUI. It is generated from the authoritative Qt Quick/QML module in \`${root}\`; source code wins when it conflicts with this documentation.

## Agent entry points

- Project router: \`${root}/.agents/skills/meoui/SKILL.md\`
- General design critique: \`${root}/.agents/skills/impeccable/SKILL.md\`
- Official design baseline: [Material Design 3](${m3}/)

## Contents

- [Token reference](references/tokens.md)
- [Architecture and ownership](references/architecture.md)
- [UI workflow](references/workflow.md)
- [M3 alignment boundary](references/m3-alignment.md)
- [Every exported component](references/components.md)

This reference documents implemented behavior only. Unimplemented ideas belong in a separately labelled proposal, never in an implementation guide.

Generated from ${components.length} exported QML types. Regenerate with:

\`node tools/generate-design-system-docs.mjs --clean\`
`);

write("references/components.md", `# Exported MeoUI components

Each page below contains the source path, a concise intent, the current public QML properties/signals extracted from source, and the relevant official Material 3 design reference. A Material link is design guidance; the actual QML component API remains authoritative.

${indexRows}
`);

for (const component of components) {
    const props = component.properties.length
        ? `| Property | Type | Source default/expression |\n| --- | --- | --- |\n${component.properties.map(({ name, type, value }) => `| \`${name}\` | \`${type}\` | ${value ? `\`${value.replaceAll("|", "\\|")}\`` : "—"} |`).join("\n")}`
        : "No public QML `property` declarations were found by the generator; inspect the source for inherited Qt API.";
    const signals = component.signals.length ? component.signals.map((signal) => `- \`${signal}\``).join("\n") : "No custom QML signals declared in this file.";
    write(`references/components/${component.name}.md`, `# ${component.name}

## Intent

${component.intro}

- Category: ${component.category}
- Source: [\`${component.file}\`](file://${root}/${component.file})
- Material 3 reference: [official guidance](${component.reference})
- Alignment status: **implemented MeoUI component**. Follow the source contract; do not infer missing properties from another Material implementation.

## Public QML properties

${props}

## Custom signals

${signals}

## Usage guardrail

Prefer this exported type over a private duplicate when its contract fits. Keep parent layout ownership outside the component, consume \`MeoTheme\` tokens, and check relevant interaction, theme, scaling, localization, and reduced-motion states.
`);
}

write("references/tokens.md", `# Verified tokens

## Authority

- Theme, semantic roles, typography, motion, scale and dynamic-color behavior: [\`MeoTheme.qml\`](file://${root}/MeoTheme.qml)
- Density-independent geometry and state opacity: [\`runtime/meotokens.h\`](file://${root}/runtime/meotokens.h)

## Canonical metric families

| Family | Tokens |
| --- | --- |
| Spacing | \`space2\`, \`space4\`, \`space8\`, \`space12\`, \`space16\`, \`space24\`, \`space32\`, \`space40\`, \`space48\` |
| Shape | \`shapeExtraSmall\`, \`shapeSmall\`, \`shapeMedium\`, \`shapeLarge\`, \`shapeLargeIncreased\`, \`shapeExtraLarge\`, \`shapeExtraLargeIncreased\`, \`shapeExtraExtraLarge\`, \`shapeFull\` |
| Icon size | \`iconSizeXS\`, \`iconSizeS\`, \`iconSizeM\`, \`iconSizeL\`, \`iconSizeXL\` |
| Button height | \`buttonHeightXS\`, \`buttonHeightS\`, \`buttonHeightM\`, \`buttonHeightL\`, \`buttonHeightXL\` |
| State layer | hover **0.10**, focus **0.12**, pressed **0.14**, dragged **0.16** |

Use semantic colors and content pairs such as \`primary/contentOnPrimary\`, \`surface/contentOnSurface\`, and \`error/contentOnError\`. Theme scaling is already applied by \`MeoTheme\`; do not multiply a token twice. Use existing motion durations/easings and honor \`reduceMotion\`.
`);

write("references/architecture.md", `# Architecture and ownership

MeoUI is a dynamically loaded QML module with URI \`MeoUI\` version \`1.0\`, defined by [\`CMakeLists.txt\`](file://${root}/CMakeLists.txt). Consumers import the module; they do not copy individual controls.

- Parent/container owns placement, margins, panes, navigation composition, and adaptive layout.
- Component owns its visual treatment, interaction state, and intrinsic-size contract.
- Hit target, visual container, and glyph size are independent dimensions.
- \`MeoIcon\` is the bundled Material Symbols Rounded renderer; do not substitute emoji or unrelated icon sets.
`);

write("references/workflow.md", `# UI workflow

For every non-trivial UI change:

\`Understand → Design → Implement → Run → Inspect → Critique → Polish → Verify\`

Read the target component, \`MeoTheme.qml\`, and a comparable use before editing. Check only applicable states, but include light/dark, scaling, long/localized content and reduced motion when relevant. Build success is partial evidence; visually inspect a runtime surface for visual changes.
`);

write("references/m3-alignment.md", `# Material 3 alignment boundary

MeoUI follows [Material Design 3](${m3}/) as design guidance, adapted to Qt Quick/QML and KDE desktop architecture. It is not a CSS, DOM, React, Flutter, or Compose implementation.

## Rules

1. Use official M3 component/foundation guidance for behavior, states, semantic color roles, accessibility, adaptive layouts, and purposeful motion.
2. Use MeoUI source for actual QML API, runtime behavior, and platform integration.
3. A Meo-specific composite or extension is not automatically an official M3 component. Document it as a MeoUI extension rather than claiming Material implementation parity.
4. Do not promote unimplemented GTK, Libadwaita, or other platform work into an implementation guide.

Official review starting points: [states](https://m3.material.io/foundations/interaction/states/overview), [canonical layouts](https://m3.material.io/foundations/layout/canonical-examples/overview), and [split buttons](${m3}/split-button).
`);

console.log(`Generated ${components.length} component references in ${output}`);
