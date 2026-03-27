# nuanxue · `rework/plan3-full-rework`

本分支为**方案三：激进改造（Full Rework）**规划与工程骨架；已实现 **阶段 0 / A / B**（阶段 C 之前），并通过无界面自动化测试。

- [调研与差距分析](docs/deep-research-report.md)
- [Full Rework 执行计划](docs/plan3-full-rework.md)
- [分阶段任务与控制台测试](docs/task.md)

## 自动化测试（Windows）

默认使用 `D:\project\godot\Godot_v4.6.1-stable_win64_console.exe`（可在 `tools/run_tests.ps1` 或环境变量 `GODOT` 中修改）。

```powershell
Set-Location "d:\project\nuanxue\godot-roguelike-nuanxue"
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_tests.ps1 -Phase all
```

退出码 `0` 表示通过；`-Phase` 可取 `all`、`0`、`a`、`b`。
