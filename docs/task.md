# 即时战斗迁移任务清单

本文档与 [`ROADMAP.md`](ROADMAP.md) 对齐。**即时场景** 已含 **暖雪式操作（左键普攻+垫步、空格闪避）、五行切换（1–5）、五武器意象、Q/E、木桩、`PixelOperatorSC` 中文** 等（见 [`idea.md`](idea.md)、[`../src/realtime/`](../src/realtime/)、[`../assets/data/realtime_monsters.json`](../assets/data/realtime_monsters.json)）。与 **五套装备槽、完整 ElementalStance 数据管线** 等仍可能未接，按里程碑推进。

**原则：不必保留回合制逻辑。** 不需要「实时 / 回合」双模式并行；可删除或整体替换 `apply_player_action` 节拍、`waiting_for_player_input`、`current_turn` 驱动、`Monster.energy` 与回合同步的多动等。**保留**仍有用且与格子无关的模块即可（如 BSP 生成、CSV 物品、`Damage` 数据、背包 UI 等），按阶段重写主循环与战斗。

---

## 执行状态（最近一次）

| 项目 | 状态 |
|------|------|
| 无头自动化 | `.\automation\run_all.ps1` **全部通过**（`Godot_v4.6.1-stable_win64_console.exe --headless`，退出码 0） |
| 即时主入口 | [`project.godot`](../project.godot) 主场景为 [`scenes/realtime/realtime_game.tscn`](../scenes/realtime/realtime_game.tscn)；创意说明见 [`idea.md`](idea.md) |
| 配置 | [`project.godot`](../project.godot)：`[gameplay] realtime_enabled=true`；`run/max_fps=60`；2D 像素对齐（减轻格子闪烁） |
| 无头脚本解析 | 即时相关脚本对 `RealtimeWuxing` / 怪物数据等使用 **`preload`**，避免仅依赖编辑器生成的 `global_script_class_cache`（CI/无头可编译） |
| 原型内容 | **地图**：`Arena` 网格。**敌人/木桩**：`RealtimeEnemy` + JSON（`dummy_*` 木桩）。**战斗**：左键普攻（近战/箭/法杖/火球依 `basic_style`）、空格闪避、Q/E；[`realtime_bullet.gd`](../src/realtime/realtime_bullet.gd)。**UI**：`PixelOperatorSC` + 五行 HUD。**设计**：[`idea.md`](idea.md)、[`wuxing_skills_spec.md`](wuxing_skills_spec.md) |
| 尚未接入即时流程 | 旧 `World` 仍由 Autoload 初始化；BSP/地图/背包/D20/`game.gd` 回合链 **未**与新场景对接，后续按阶段删除或桥接 |

自动化验证见 [`../automation/README.md`](../automation/README.md)：**退出码 0 为通过**。

- Godot 可执行文件默认：`D:\project\godot\Godot_v4.6.1-stable_win64_console.exe`（可用环境变量 `GODOT_BIN` 覆盖）
- 根目录运行全部阶段：`.\automation\run_all.ps1`
- 单阶段：`.\automation\phases\phase_a\run_test.ps1`

---

## 总览

| 阶段 | 目标 | 自动化目录 |
|------|------|------------|
| A | 实时主循环骨架 | `automation/phases/phase_a/` |
| B | 连续移动（去格子步进主路径） | `automation/phases/phase_b/` |
| C | 命中框 / 动作战斗（替代 D20 主路径） | `automation/phases/phase_c/` |
| D | AI 按时间与冷却工作 | `automation/phases/phase_d/` |
| E | 暖雪式通用打磨（**无五行**） | `automation/phases/phase_e/` |
| Wx-V | 五行立绘/相位/挥砍等视觉断言 | `automation/phases/phase_wuxing_visuals/` |
| Wx-C | **五行伤害与木桩 TTK 区间**（调 `realtime_stance_defs` / `realtime_monsters`） | `automation/phases/phase_wuxing_combat/` |

---

## 阶段 A：实时主循环骨架

- [x] **A1** 主流程改为即时制：主菜单进入 [`realtime_game.tscn`](../scenes/realtime/realtime_game.tscn)；旧回合场景未再接入口。
- [x] **A2** 玩家用 `CharacterBody2D` 在 `_physics_process` 中移动（[`realtime_player.gd`](../src/realtime/realtime_player.gd)）。
- [x] **A3** 敌人每帧在 `_physics_process` 中追击玩家（[`realtime_enemy.gd`](../src/realtime/realtime_enemy.gd)）。
- [ ] **A4** **删除或重写** 全局 `World.apply_player_action` 回合语义，并将掉落/开门等接入即时流程（当前 Autoload 仍会初始化旧 `World`，即时场景未使用其回合链）。
- [x] **A5** 新即时场景 **无** `waiting_for_player_input` / `_flush_effects_queue`（与旧 `game.gd` 独立）。

**本阶段自动化**：[`test_phase_a.gd`](../automation/phases/phase_a/test_phase_a.gd) 校验 `gameplay/realtime_enabled` 与即时场景存在。

---

## 阶段 B：连续移动

- [x] **B1**（原型）即时玩家位移为速度 + `move_and_slide`，**不**经 `MoveAction`。
- [ ] **B2** 旧 [`Actor`](../scenes/actor/actor.gd) 与地图格子表现对齐即时体（待接 BSP 地图后做）。
- [ ] **B3** 敌人沿 A* 路径连续移动或 Navigation。
- [ ] **B4** 多单位占格/碰撞规则与掉落一致。

**本阶段自动化**：校验 `realtime_player.gd` 基类为 `CharacterBody2D` 且场景中 `Player` 节点存在。

---

## 阶段 C：动作战斗

- [x] **C1**（原型）`MeleeHitbox`（`Area2D`）+ 敌人 `Hurtbox`，`take_damage` 扣血。
- [ ] **C2** 完整攻击状态机（前摇/活跃帧/后摇/i-frame）。
- [ ] **C3** 远程飞行物每帧移动。
- [ ] **C4** 与旧掉落/死亡/ `Damage` 资源表对接。

**本阶段自动化**：场景中 `Player/MeleeHitbox` 存在。

---

## 阶段 D：AI 实时化

- [x] **D**（占位）敌人每物理帧索敌移动，**非**回合步进；`set_target` 供后续 BT/冷却扩展。
- [ ] **D1–D4** 行为树预算、`Monster.energy` 拆除、视野降频等与 [`monster_ai.gd`](../src/monster_ai.gd) 深度整合。

**本阶段自动化**：`realtime_enemy.gd` + 场景中敌人含 `set_target`。

---

## 阶段 E：暖雪式通用体验（不含五行）

- [x] **E1**（原型）`Camera2D` 挂玩家，平滑开启。
- [x] **E2**（原型）`HUDLayer` + 生命/提示 Label（技能仅为文案占位）。
- [ ] **E3** 全屏背包/菜单时 `process_mode` 暂停策略。

**本阶段自动化**：场景中 `Camera2D` 与 `HUDLayer` 存在。

---

## 执行顺序

1. 改代码或断言后运行 `.\automation\run_all.ps1`。
2. 将新验收点写入对应 `automation/phases/phase_*/test_phase_*.gd`。

## 五行技能与特效（进行中）

设计文档：[`wuxing_skills_spec.md`](wuxing_skills_spec.md)、[`idea.md`](idea.md)。

| 任务 | 状态 |
|------|------|
| 暖雪式：左键近战、右键远程、空格收剑、Shift 闪避、Tab 切五行、Z 切分支 | 已完成 |
| 姿态表 `realtime_stance_defs.gd`（五系×双分支）+ 五行飞剑 `realtime_flying_sword`（暖雪式 R 收剑、空格闪、F 怒） | 已完成 |
| 五系木桩 `dummy_*` + 降速 + 血量调整 | 已完成 |
| 中文：`PixelOperatorSC` 主题 + HUD/敌人头顶 Label | 已完成 |
| 旧表 `realtime_skill_defs.gd`（可选参考） | 保留 |
| 差异化 `realtime_skill_vfx.gd`（smoothstep 淡出） | 已完成 |
| 五行立绘/染色 + 攻击相位两帧 + 挥砍/枪口/闪避特效（`realtime_wuxing_visuals.gd`） | 已完成 |
| 旧 `realtime_bullet.gd`（拖尾） | 保留可选 |
| 自动化 `phase_wuxing_visuals`（立绘、相位、神木近战、子弹） | 已完成 |
| 自动化 `phase_wuxing_combat`（姿态表键、伤害演算、木桩/杂兵 TTK 边界） | 已完成 |
| 敌人异常与被动（金/木/火） | 已完成 |
| 各系 **独立武器模型、逐帧攻击动画资源** | 部分（仍用 `player-4/25/31` + 相位帧） |
| `ElementalStance` Resource、CSV、武器槽异构 | 未做 |
| GPUParticles2D / Shader；闪避无敌帧与敌人攻击判定对齐 | 未做 |
| 玩家受击与土被动减伤 | 未做 |

---

## 与 `idea.md` 的关系

即时场景为 **暖雪式 + 五行武器原型**。**装备五套、完整 Resource 管线** 以 [`idea.md`](idea.md) 里程碑为准。
