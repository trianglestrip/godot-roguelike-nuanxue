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

## 编辑器试玩（真实 Hitbox / Hurtbox）

- 用 Godot 打开本仓库，运行主场景 `scenes/bootstrap/main.tscn`（已在 `project.godot` 设为启动场景）。
- **WASD** 移动，**Space** 冲刺（短暂无敌，关闭 `Hurtbox`），**J** 近战挥击（生成 `SwingHitbox` / `Hitbox2D`）。
- 右侧 **木桩** 带 `Hurtbox2D`，受击扣血；攻击判定与层掩码见 `simulation/combat_layers.gd` 与 `project.godot` 的 `layer_names`。
