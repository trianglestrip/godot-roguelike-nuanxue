# 无头自动化测试（即时战斗迁移）

使用 **Godot 4.6.x 控制台版** 无窗口运行测试场景，通过 **进程退出码** 判断成败：`0` 成功，非 `0` 失败。

## 前置条件

- Windows 上已安装或可访问 Godot：`Godot_v4.6.1-stable_win64_console.exe`
- 默认路径：`D:\project\godot\Godot_v4.6.1-stable_win64_console.exe`  
  若不同，请设置环境变量 **`GODOT_BIN`** 指向你的控制台可执行文件。

## 目录结构

```
automation/
  config.ps1          # Godot 路径与工程根目录
  run_all.ps1         # 依次运行 phase_a ~ phase_e、phase_wuxing_visuals、phase_wuxing_combat、phase_integration
  phases/
    phase_a/          # 阶段 A 测试场景 + run_test.ps1
    phase_b/
    ...
    phase_wuxing_combat/  # 五行伤害演算 + 木桩/杂兵 TTK 边界
```

## 运行方式

在项目根目录（`godot-roguelike-nuanxue`）打开 PowerShell：

```powershell
cd D:\project\nuanxue\godot-roguelike-nuanxue
.\automation\run_all.ps1
```

仅运行某一阶段：

```powershell
.\automation\phases\phase_a\run_test.ps1
```

## 命令说明

各阶段目录下 `run_test.ps1` 等价于（以阶段 A 为例）：

```text
"%GODOT_BIN%" --path "<工程根目录>" --headless res://automation/phases/phase_a/test_phase_a.tscn
```

`run_all.ps1` 会依次调用 `phases/phase_a` … `phase_e` 的 `run_test.ps1`。

测试脚本在 `_ready` 末尾调用 `SceneTree.quit(exit_code)`，将结果返回给 CI 或本地脚本。

## 与 Autoload 的说明

无头运行任意 `res://` 场景时，工程仍会加载 `project.godot` 中的 **Autoload**（如 `World`），因此控制台可能出现初始化日志；若退出时提示 `ObjectDB instances leaked`，多为单例与测试场景生命周期并存所致，**以进程退出码为准** 判断测试是否通过。后续若需完全隔离，可考虑独立最小工程或使用 `--script` 专用入口（需另行设计）。

## 扩展断言

各阶段实现功能后，编辑对应目录下的 `test_phase_*.gd`：

- 增加对 `ProjectSettings`、Autoload、`class_name` 注册类型或场景分组的检查。
- 保持 **无头可运行**：不要依赖显卡特性；避免打开主菜单联网或长按等待。

## 与 task.md 对应

任务勾选与断言细化见 [`docs/task.md`](../docs/task.md)。

## 当前断言摘要（与即时原型对齐）

| 阶段 | 断言内容 |
|------|----------|
| phase_a | `gameplay/realtime_enabled == true`，且存在 `res://scenes/realtime/realtime_game.tscn` |
| phase_integration | 挂载即时场景跑 2 帧：`TileSprites` 子节点数、敌人组数量、玩家/敌 `VisualSprite` 纹理、碰撞 layer/mask、近战 `MeleeHitbox` mask |
| phase_wuxing_combat | 五行×双分支姿态表键完整性；与 `realtime_player` 一致的 **近战/收剑返/怒气** 伤害演算；对木桩 JSON 的 **TTK 区间**（便于调数值） |
| phase_b | `realtime_player.gd` 基类为 `CharacterBody2D`，且即时场景内 `Player` 为 `CharacterBody2D` |
| phase_c | 即时场景 `Player` 下存在 `MeleeHitbox` |
| phase_d | `realtime_enemy.gd` 基类为 `CharacterBody2D`，场景内 `Enemy` 含 `set_target` |
| phase_e | 即时场景内存在 `Camera2D` 与 `HUDLayer` |

**说明**：脚本中尽量避免依赖 `class_name` 的静态解析（无头/CI 与编辑器缓存行为可能不一致），场景脚本使用 `CharacterBody2D` 等原生类型注解。

## 最近一次验证

在仓库根目录执行 `.\automation\run_all.ps1`，五阶段均为 **退出码 0**（Godot 4.6.1 stable console，`--headless`）。若你本地失败，请检查 `GODOT_BIN` 与工程路径。
