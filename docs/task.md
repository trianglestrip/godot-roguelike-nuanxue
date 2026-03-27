# 方案三 · 分阶段任务与自动化验收

本文档与 [plan3-full-rework.md](plan3-full-rework.md) 对齐，按阶段推进；**每个阶段结束时必须在控制台跑通自动化测试**（失败则不得合并/不得进入下一阶段）。

---

## 自动化测试约定（Console）

### 环境

- **Godot 4.6.x 控制台版**（无界面自动化）：默认路径 `D:\project\godot\Godot_v4.6.1-stable_win64_console.exe`（可在 `tools/run_tests.ps1` 或环境变量中覆盖）。
  - Windows PowerShell 覆盖：`$env:GODOT = "D:\path\to\Godot_v4.x_console.exe"`
- 项目根目录即仓库根（含 `project.godot`）。

### 统一入口（已实现：阶段 0 / A / B）

| 路径 | 作用 |
|------|------|
| `tests/automation/run_all.gd` | 总入口：依次执行阶段 0、A、B 测试，失败则 `quit(1)` |
| `tests/automation/phase_0_tests.gd` | 阶段 0 烟测 |
| `tests/automation/phase_a_tests.gd` | 阶段 A：Schema、DataLoader、EventBus |
| `tests/automation/phase_b_tests.gd` | 阶段 B：伤害、冲刺无敌、层、HitStop、CameraAdapter |
| `simulation/hitbox_2d.gd`、`simulation/hurtbox_2d.gd` | 真实 Area2D 碰撞（试玩场景 `scenes/bootstrap/main.tscn`） |
| `tools/run_tests.ps1` | 封装 Godot；参数 `-Phase all`（默认）、`0`、`a`、`b` |

### 推荐命令

在仓库根目录执行（PowerShell，多条命令请分开执行）：

```powershell
Set-Location "d:\project\nuanxue\godot-roguelike-nuanxue"
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_tests.ps1 -Phase all
```

仅跑某一阶段（内部会传 `-- --test-phase=...`）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_tests.ps1 -Phase 0
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_tests.ps1 -Phase a
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\run_tests.ps1 -Phase b
```

或直接调用 Godot：

```powershell
& "D:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --path . -s "res://tests/automation/run_all.gd" -- --test-phase=a
```

- 成功：进程退出码 **0**。
- 失败：非 0，并在日志中 `push_error` 失败说明。

### 阶段完成判定

1. 本阶段「交付物」所列项全部完成。  
2. 执行上述命令（或 `tools/run_tests.ps1`）**通过**。  
3. 若有手动验收项，在阶段内勾选表中注明。

---

## 阶段 0 — 工程骨架与目录落地

**目标**：建立 `res://` 目录结构、`data/` 与逻辑层物理分离；主场景可启动；测试管线可跑通（空测或烟测）。

| 交付物 | 说明 |
|--------|------|
| `project.godot` | 主场景、必要 autoload（如 `EventBus`） |
| 空目录占位 | 见 plan3「文件结构设计」各功能子文件夹 |
| `data/` | 仅放示例 JSON（如 `data/_example/placeholder.json`），**无脚本** |
| `tests/automation/run_all.gd` | 至少 1 个烟测：启动即退出码 0 |
| `tools/run_tests.ps1` | 调用 Godot 执行 `run_all.gd` |

**控制台测试**：执行「推荐命令」，退出码 0。

---

## 阶段 A — 基建：事件总线、数据校验、可选 ECS/GUT

**目标**：EventBus 信号契约稳定；数据加载经校验器；引入 GUT 或自研最小断言框架；核心逻辑不依赖场景树具体路径。

| 交付物 | 说明 |
|--------|------|
| `core/event_bus.gd`（或等价） | 文档化信号与载荷结构 |
| `domain/data_loader.gd` + `domain/schema_validator.gd` | 只负责读 `data/` 与校验，不含战斗表现 |
| `addons/gut/`（若采用） | 单元测试目录指向 `tests/unit/` |
| 示例数据 | `data/skills/` 或 `data/relics/` 下最小合法 JSON |

**控制台测试**：`run_all.gd` 执行：Schema 校验通过示例 JSON；EventBus 可实例化并发信号（无场景亦可）。

---

## 阶段 B — 实时战斗核心

**目标**：移动、冲刺、无敌帧；Hitbox/Hurtbox 与碰撞层；Hit Stop 单一入口；Domain 内伤害上下文结构体与单元测试。

| 交付物 | 说明 |
|--------|------|
| `simulation/` | 移动、碰撞、受击、时间缩放服务 |
| `domain/damage_context.gd`（或等价） | 纯数据 + 规则函数，可单测 |
| `presentation/camera_adapter.gd` | 订阅事件，不反向依赖 Domain |

**控制台测试**：伤害计算、无敌帧窗口、层掩码相关单元测试全部通过（不依赖渲染）。

---

## 阶段 C — 技能与圣物引擎

**目标**：技能/圣物全部由 `data/` 驱动；运行时仅 ID + Resource；事件订阅实现效果。

| 交付物 | 说明 |
|--------|------|
| `data/skills/*.json`、`data/relics/*.json` | 与 Schema 一致 |
| `domain/skill_runtime.gd`、`domain/relic_runtime.gd` | 解释数据并挂接 EventBus |
| 四槽圣物 | 槽位映射表在 Domain，数据在 `data/` |

**控制台测试**：加载全部 JSON；模拟事件序列（hit/kill）断言属性变化与冷却。

---

## 阶段 D — 关卡与成长

**目标**：房间/波次状态机；精英标记；掉落与 `enemy_killed` 挂钩。

| 交付物 | 说明 |
|--------|------|
| `gameplay/room_flow.gd`（或等价） | 编排波次，不直接写数值 |
| `data/waves/`、`data/drops/` | 波次与掉落表 |

**控制台测试**：用假时间轴或纯数据模拟跑完一场「房间清怪 → 下一波」断言状态迁移。

---

## 阶段 E — 打磨与工具链

**目标**：调试命令、热加载（仅开发版）、性能基线；全量回归。

| 交付物 | 说明 |
|--------|------|
| 开发菜单或控制台 | 热加载 `data/`（可选） |
| `tools/run_tests.ps1` | 与 CI 一致 |

**控制台测试**：执行全量 `run_all.gd` +（若有）GUT 全量；退出码 0。

---

## 任务追踪表（维护时勾选）

| 阶段 | 目录/基建 | 控制台测试 | 完成日期 |
|------|-----------|------------|----------|
| 0 | ☑ | ☑ | 2026-03 |
| A | ☑ | ☑ | 2026-03 |
| B | ☑ | ☑ | 2026-03 |
| C | ☐ | ☐ | |
| D | ☐ | ☐ | |
| E | ☐ | ☐ | |

---

*与 `plan3-full-rework.md` 同步更新；实现细节以仓库代码为准。*
