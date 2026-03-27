# 五行技能与特效规格（即时原型）

本文档与 [`idea.md`](idea.md) 对齐；**操作键位与《暖雪》PC 参考一致**：**空格瞬身、R 收剑、右键飞剑**；**怒气大招为 F**。

**数据** 以 [`src/realtime/realtime_stance_defs.gd`](../src/realtime/realtime_stance_defs.gd) 为准；旧 Q/E 表 `realtime_skill_defs.gd` 仅作历史参考。

---

## 1. 操作

| 输入 | 行为 |
|------|------|
| WASD | 移动 |
| 鼠标左键 | 当前五行 + 分支的 **近战普攻** |
| 鼠标右键 | **发射飞剑**（场上最多 7；五行对应不同像素条资源） |
| **R** | **收剑**：飞剑飞回玩家（路径伤害）+ **五行返范围爆发**（CD 见姿态表） |
| **空格** | **瞬身 / 闪避**（与 Shift 均可） |
| **F** | **怒气大招**（怒气满） |
| Tab / Shift+Tab | 切五行 |
| Z | 远程流 ↔ 近战流 |

---

## 2. 五系武器意象与普攻类型（文档向）

| 系 | 武器名 | basic_style | 普攻 |
|----|--------|-------------|------|
| 金 | 飞羽弓 | ranged_bow | 箭矢投射物 |
| 木 | 藤鞭 | melee_whip | 近战横扫（略远） |
| 水 | 寒霜法杖 | ranged_staff | 冰弹投射物 |
| 火 | 双刀与火珠 | ranged_fireball | 火珠投射物 |
| 土 | 盾锤 | melee_hammer | 近战重击（慢、高伤） |

---

## 3. 收剑 / 怒气与特效 ID

`return_*`、`rage_*`、各 `left_style` / `proj_speed` 与 `VfxKind` 以 `realtime_stance_defs.gd` 为准。

**飞剑像素**：`assets/realtime/projectiles/flying_sword_{metal,wood,water,fire,earth}.png`（横条 4 帧）。

异常状态与敌人逻辑见 `RealtimeEnemy.apply_skill_status`。

---

## 4. 木桩

`assets/data/realtime_monsters.json` 中 `id` 以 `dummy_` 开头为高血量训练木桩，`RealtimeEnemy.is_training_dummy = true`，不追击，用于测试五行克制与 DoT。

---

## 5. 自动化

改键或改飞剑资源后运行 `.\automation\run_all.ps1`；`phase_wuxing_visuals` 会校验姿态与飞剑场景。
