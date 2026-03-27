# 暖雪风格迁移路线图

本文档是 **可执行的迁移清单**，与 [`design.md`](design.md)（现状）和 [`idea.md`](idea.md)（五行与暖雪式目标）配合使用。按阶段推进，每阶段有 **验收标准**，便于分 PR 合并。

**即时战斗专项** 以 [`task.md`](task.md) 为准；[`idea.md`](idea.md) 描述 **暖雪式操作 + 五武器**；即时场景含 [`../assets/data/realtime_monsters.json`](../assets/data/realtime_monsters.json)（含木桩 `dummy_*`）。

**不必保留完整回合制逻辑**：无需双模式并行；可直接移除回合节拍、整段 `apply_player_action` 驱动链与 `waiting_for_player_input`，仅复用地图生成、数据与 UI 等仍适用的部分。

**进度快照**：主菜单已切入 [`scenes/realtime/realtime_game.tscn`](../scenes/realtime/realtime_game.tscn)；`Engine.max_fps`/`project` 限 **60 FPS**；无头测试见 [`automation/run_all.ps1`](../automation/run_all.ps1)（即时脚本使用 `preload` 以保证无 `global_script_class_cache` 时仍可编译）。

---

## 里程碑依赖关系

```mermaid
flowchart LR
  A[阶段A 实时骨架] --> B[阶段B 连续移动]
  B --> C[阶段C 动作战斗]
  C --> D[阶段D AI实时化]
  D --> E[阶段E 暖雪体验与五行数据]
```

---

## 阶段 A：实时主循环骨架

**目标**：不再以「单次玩家输入 = 整回合」为唯一节拍；游戏世界在 `_process` / `_physics_process` 中持续更新。

| 任务 | 说明 |
|------|------|
| A1 | 主流程改为即时制；**不**要求保留回合制入口或双模式开关，可直接替换主场景 / `game.gd`。 |
| A2 | 玩家实体改为 `CharacterBody2D`（或等价）每帧移动；碰撞先用格子地图采样（中心点/四角）判定阻挡。 |
| A3 | 敌人每帧或固定 `delta` 更新意图占位；先可简化为「朝玩家方向每帧移动」验证循环。 |
| A4 | **删除或重写** `apply_player_action` 的回合推进语义；拾取、开门等改为即时事件，**不再**用「玩家一动 → 敌动一圈」驱动全局时间。 |
| A5 | `game.gd`：**移除** `waiting_for_player_input` 对主循环的冻结；效果队列与 `await` 链按即时制拆分或重写。 |

**验收**：

- [ ] 不按键盘时，敌人/环境逻辑仍按帧或按时间更新（**非**「等玩家走一步」）。
- [ ] 开门、拾取为即时触发，**不**依赖回合结束。

**关键文件**：[`src/world.gd`](../src/world.gd)、[`scenes/game/game.gd`](../scenes/game/game.gd)

---

## 阶段 B：去掉「一步一格」的移动语义

**目标**：逻辑与表现以连续坐标为主，格子地图作为背景与碰撞查询。

| 任务 | 说明 |
|------|------|
| B1 | 玩家位置用 `Vector2` 世界坐标驱动；[`MoveAction`](../src/actions/move_action.gd) 不再是主移动路径。 |
| B2 | [`scenes/actor/actor.gd`](../scenes/actor/actor.gd)：实体跟随父节点或根运动体坐标，而非仅 `grid_pos * TILE_SIZE` 逐步跳格。 |
| B3 | 敌人沿 [`Pathfinding`](../src/pathfinding.gd) 路径时，改为「朝下一格方向连续移动」或引入 Navigation（后置）。 |
| B4 | 约定多单位占格规则：保留一格一怪或改为纯物理挤压，并统一掉落与寻路。 |

**验收**：

- [ ] WASD 按住可平滑移动，无「松手才走一步」的回合感。
- [ ] 与墙体/障碍碰撞正确，无穿模（在当前简化碰撞下）。

**关键文件**：[`src/actions/move_action.gd`](../src/actions/move_action.gd)、[`scenes/actor/actor.gd`](../scenes/actor/actor.gd)、[`src/pathfinding.gd`](../src/pathfinding.gd)

---

## 阶段 C：动作战斗替代 D20 回合交换

**目标**：用命中框/ hurtbox 与时间轴替代 [`Combat`](../src/combat.gd) 中单次 `resolve_melee_attack` 的回合结算。

| 任务 | 说明 |
|------|------|
| C1 | 新增攻击判定：`Area2D` 扇形/矩形，或射线；与现有 `Combat` 解耦，保留 `Damage` / 抗性数据。 |
| C2 | 攻击状态机：前摇、活跃帧、后摇、冷却；可选无敌帧。 |
| C3 | 远程：飞行物每帧位移 + 碰撞；复用现有弹道演出思路但脱离「一次 Fire Action = 一整回合」。 |
| C4 | 受击硬直、死亡与掉落与实时循环对接。 |

**验收**：

- [ ] 近战挥击在「活跃帧」内击中敌人造成伤害，无需 D20 日志主导节奏。
- [ ] 远程命中判定稳定，与视野/迷雾规则无逻辑冲突（可简化先不做迷雾内限制）。

**关键文件**：[`src/combat.gd`](../src/combat.gd)、[`src/damage.gd`](../src/damage.gd)、[`src/actions/fire_action.gd`](../src/actions/fire_action.gd)

---

## 阶段 D：AI 适配实时

**目标**：[`MonsterAI`](../src/monster_ai.gd) 与能量系统服务于帧时间，而非玩家步进。

| 任务 | 说明 |
|------|------|
| D1 | 行为树 `tick` 增加冷却或「兴趣点」，避免每帧全树深搜。 |
| D2 | `RUNNING` 跨帧语义：追击/蓄力可持续多帧。 |
| D3 | [`Map.is_visible`](../src/map.gd) 驱动的追击条件可每 N 帧更新。 |
| D4 | 重构或弃用「能量满则一动」的 [`Monster.energy`](../src/monster.gd) 与回合同步（改为攻击间隔、技能 CD）。 |

**验收**：

- [ ] 多个敌人同时追击时不卡顿（可设性能预算）。
- [ ] 玩家站立不动时敌人行为符合预期（追击/攻击范围）。

**关键文件**：[`src/monster_ai.gd`](../src/monster_ai.gd)、[`src/monster.gd`](../src/monster.gd)

---

## 阶段 E：暖雪式体验与五行数据对接

**目标**：与 [`idea.md`](idea.md) 对齐：摄像机跟随、技能栏、资源条；五行切换与普攻/小/大/被动数据驱动。

| 任务 | 说明 |
|------|------|
| E1 | 摄像机平滑跟随玩家。 |
| E2 | UI：技能与资源条；鼠标普攻与快捷键技能。 |
| E3 | 定义 `ElementalStance` 类 Resource（或 CSV 扩展）：每系武器预制、技能 ID、FX 主题。 |
| E4 | 扩展 [`Equipment`](../src/equipment.gd) 或并行组件：切换系时切换武器显示与攻击数据。 |

**验收**：

- [ ] 至少两系可切换，且普攻/一技能在表现上可区分。
- [ ] 与掉落/背包的集成路径明确（可先占位词条）。

**关键文件**：[`src/equipment.gd`](../src/equipment.gd)、[`assets/data/`](../assets/data/)、新玩家控制器场景

---

## 风险与依赖（跨阶段）

| 风险 | 缓解 |
|------|------|
| `game.gd` 中 `_flush_effects_queue` 与 `await` 与实时冲突 | 演出与伤害逻辑分离；伤害即时应用，特效可滞后。 |
| 营养/休息强绑定回合 | 改为时间流逝、房间规则或移除（见 [`design.md`](design.md)）。 |
| 地图仍格子化 | 接受混合方案：渲染格子 + 连续碰撞采样，逐步再导航网格化。 |

---

## 文档与代码索引

| 文档 | 用途 |
|------|------|
| [`design.md`](design.md) | 当前模块与迁移标注 |
| [`idea.md`](idea.md) | 五行、暖雪式操作与武器创意 |
| 本文件 | 分阶段任务与验收 |

完成某一阶段后，在本文件对应章节勾选验收项，并在版本控制中附带简短说明（改了哪些入口与兼容策略）。
