# MeoUI

MeoUI 是 MeoArch 共用的 Qt Quick / QML Material Design 3 设计系统。它拥有可复用的主题 token、组件、控件、模式和布局；Plasma/KDE 集成属于 `meo-kde`，具体应用流程属于各应用仓库。

## 目录 / Layout

- `MeoTheme.qml`、`MeoWindowMetrics.qml`：共享主题与窗口尺寸契约。
- `components/`、`widgets/`、`patterns/`：可复用的公开 QML 交付物。
- `showcase/`：MeoUI 的完整可运行展示与覆盖入口。
- `runtime/`：运行时 C++/头文件接口；`assets/`：源资源。
- `validation/`：版本控制的验证源码、测试和清单，不是验证结果目录。
- `docs/`：与已交付代码绑定的公开契约、组件规范和使用说明。
- `examples/`、`tools/`、`packaging/`：受代码维护的示例、工具和打包定义。
- `CMakeLists.txt`、`CMakePresets.json`、`qmldir`：构建与模块配置。
- `main.cpp`：根级 Showcase 程序入口；`.agents/`、`.codex/`：现有本地工具配置。
- `docs/releases/`：随代码保留的发布历史；`out/`、`artifacts/`：既有生成内容，不能作为新输出入口。

根目录只新增入口文档、源码目录及必要的构建/发布配置。不要新增零散的 `plan.md`、`项目架构（第一版）`、审计副本或临时截图。已有的 `out/` 与 `artifacts/` 保持不动；它们不是新输出的目的地。旧根目录测试脚本、错误的 Showcase 报告和空占位文件已分别归档或送入回收站。

## 文件与记录边界 / File policy

代码绑定、需要随实现一起维护的公共契约放在 `docs/`。计划、审计、决策记录、Agent 工作日志和历史报告一律放在：

`/home/shekong/Documents/Obsidian Vault/MeoArch/Projects/meo-ui/`

该项目记录目录必须有面向读者的 `README.md`，说明当前记录的目的和索引。不要把这些过程性资料复制回仓库。

记录目录使用统一的编号结构：`00-inbox/`（临时收集）、`01-overview/`（范围与事实）、`02-decisions/`（已确认决定）、`03-work/`（计划和交接）、`04-validation/`（验证结论）和 `99-archive/`（已替代记录）。项目根 `README.md` 是人类入口；记录文件使用 `YYYY-MM-DD--short-topic.md`，不要使用含混的“第一版”式文件名。

持久生成物一律放在：

`/home/shekong/Projects/outputs/meo-ui/{build,install,validation,packages,tmp}/`

`build/` 放配置和编译结果，`install/` 放暂存安装树，`packages/` 放待发布包及校验资料，`validation/` 放可复查验证证据，`tmp/` 仅作可丢弃工作区。`validation/` 的每次运行使用 UTC 标识 `YYYY-MM-DDTHHMMSSZ-short-label`，例如 `2026-08-26T104500Z-showcase/`，并在该运行目录放一个 `README.md`、日志、覆盖清单和截图/其他证据。`tmp/` 可丢弃，不能作为验收证据。

## Showcase 是交付门槛 / Showcase gate

任何影响 MeoUI 交付物的改动（token、QML、C++、资源、公开契约、构建或打包）都必须刷新 Showcase；不得只改组件而保留过时示例。刷新后必须：

1. 运行 `tools/verify-showcase-coverage.py`：它对 `qmldir` 中公开 **QML export** 到 Catalog 和直接示例的映射实施 100% 门禁；这个百分比不自动涵盖 token、C++ runtime API、资源或行为质量。
2. 对全部交付范围刷新 Showcase，并在本次 validation 记录中保留可读的交付清单：说明每个改动的 token、QML、runtime/API、资源和可见行为如何在 Showcase 或相应证据中被呈现；没有可视化演示的项目必须明确说明理由，不能留下未说明缺口。
3. 构建并实际运行 `MeoShowcaseDemo`，而不是仅通过静态检查或编译。
4. 将构建/运行日志、QML 覆盖结果、交付清单和可复查的视觉证据保存到 `/home/shekong/Projects/outputs/meo-ui/validation/<UTC-run-id>/`。

编译、离屏检查和截图分别只能证明其实际覆盖的范围；不要把它们表述成未执行的真实交互验收。

## Read first

先阅读 [AGENTS.md](AGENTS.md)，再按需要阅读 `docs/` 中与目标代码直接相关的契约。使用者应通过 `MeoUI 1.0` 导入公共模块，而不是复制私有组件到应用中。
