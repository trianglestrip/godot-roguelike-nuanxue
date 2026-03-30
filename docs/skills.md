# 万剑肉鸽 · 技能与词条（Skills & Modifiers）

> 与 [plan.md](./plan.md) 中的「阶段 3」对应；**实现时优先 Modifier 叠加**，避免把每种组合写死在 `if-else` 里。数据驱动：技能/词条主表建议放在 **`Data/`**（CSV、JSON 或 Godot Resource）。

---

## 一、设计原则

1. **一个技能一种行为**，数值与触发频率可由资源覆盖。  
2. **词条 = Modifier**：对「伤害、冷却、范围、弹道、异常状态、子弹时间」等做乘算/加算/覆写，统一走注册表。  
3. **局内成长**：清房间 / 三选一 / 商店 只改「玩家状态 + Modifier 列表 + 解锁标记」，不写散落的特例全局变量。  

---

## 二、技能基类约定（GDScript 示例）

与引擎版本一致：**Godot 4.x** 可用 `RefCounted` 或 `Resource` 做数据载体，`Node` 只做表现与冷却表现。

```gdscript
class_name SkillBase
extends RefCounted

var id: StringName
var display_name: String
var cooldown: float = 1.0
var base_damage: float = 10.0
# 由 Modifier 汇总后的最终值在 runtime 再算，不要写死在 cast 里

func cast(_ctx: Dictionary) -> void:
    push_warning("SkillBase.cast 未实现: %s" % id)
```

- **`_ctx`** 建议包含：`player`、`game`、`aim_position`、`sword_array`、`rng` 等，避免技能直接单例写死全局。  
- **主动技能**：由输入或 UI 触发 `cast`。  
- **被动技能**：注册到 `Game` 或 `Player` 的「事件总线」，如 `on_enemy_killed`、`on_sword_hit`。  

### 运行时 Modifier 注册（落地约定）

不建议把「局内已选词条」只散落在多个 bool 里。推荐由 **`RunState` / `PlayerRunData`（`Resource` 或纯 Node 子系统）** 持有 Modifier 列表，并提供：

- `apply_modifier(mod: ModifierDef, source: StringName)`：写入列表、按 `exclusive_group` 处理互斥、触发 `modifiers_changed`。  
- `remove_modifier(id: StringName)` / `remove_modifiers_from_source(source)`：用于遗物到期、临时 BUFF 结束、调试。  

`SkillBase` 本体可保持**无状态或仅配置**；真正叠加结果在 **`resolve_stat(stat_id, context)`** 中读取：  
`context` 建议带 `scope`（见下表），以便同一词条在「只影响剑阵半径」与「影响玩家移速」上走不同分支。

---

## 三、Modifier 作用域（必读）

策划填表与程序解析时，每条 Modifier 必须带 **`scope`**（或等价字段），避免「改全局伤害却链式误伤 UI 逻辑」。

| scope | 含义 | 典型 `target_stat` 示例 |
|-------|------|-------------------------|
| `run_global` | 整局数值（难度、掉落倍率等） | `gold_mult`、`xp_mult` |
| `player` | 玩家本体 | `move_speed`、`max_hp`、`dash_cd` |
| `sword_array` | 剑阵管理器（全体飞剑共享） | `orbit_radius`、`orbit_speed`、`shared_damage_mult` |
| `per_sword` | 单把飞剑实例 | `pierce_remaining`、`solo_target_bias`（每剑独立目标偏好） |

- **第一期简化**：可只实现 `player` + `sword_array` 两档，所有飞剑共用剑阵倍率。  
- **第二期**：`per_sword` 用于独立穿透计数、单独锁敌等。  

与 [plan.md](./plan.md) 中「信号改 `SwordArray` 全局倍率」的 MVP 路线一致，后续再把 `resolve_stat` 做全。

---

## 四、剑意相关技能（与 plan 对齐）

| 行为 | 剑意消耗 | 备注 |
|------|----------|------|
| 地刺剑阵 | 约 30 | AOE + 减速 |
| 万剑归宗 | 约 100 | 全屏爆发 |

环绕剑阵为默认形态，可不耗剑意或仅大招段耗。

---

## 五、局内三选一（奖励房间）

每次清完指定房间或进入奖励房，在以下类型中 **随机 3 条** 供选择（具体权重表放 `Data/`）：

1. **飞剑数量 +1**（不超过全局 cap，见 plan 对象池上限）  
2. **飞剑伤害 / 攻击频率 / 索敌或伤害范围**（用 Modifier）  
3. **随机词条**（一条 Modifier）  
4. **解锁新剑阵形态**（解锁标记 + 可能附赠首次冷却缩减）  

**UI 落地**：可用 **`GridContainer`** 或 `HBoxContainer` **动态生成** 3 个选项按钮（图标 + 标题 + 简述）；点击后调用 `offer.apply(run_state)`，再 `queue_free` 面板或切回游戏输入。  

选中后：`run_state.apply_modifier(...)` 或执行 `SkillGrant` 资源描述的一次性效果。

### 稀有度与选项构成（上瘾度）

- 三选一每条带 **`rarity`**：`common` / `rare` / `epic`（或等价三档），由 `Data/loot_weights.json` 控制出现率；偶尔出彩蛋选项增加直播与重复游玩动力。  
- **构成建议**：同一屏三条尽量覆盖 **不同类型成长**（例：一条偏剑阵数值、一条偏剑意、一条偏生存/机动），减少「三条全废」感；具体用 **标签** `tags: ["sword_array","sword_charge","player","enemy"]` 在生成时做桶抽。  
- 商店可塞 **固定高价稀有**，与局内金币循环配合（见 [plan § 十四](./plan.md)）。

---

## 六、词条（Modifier）示例

### 设计维度（策划填表时勾选，对应 `category` 字段）

| 维度 | 典型内容 | 备注 |
|------|----------|------|
| **A. 直接强化剑阵** | 飞剑数量 +X、攻速%、伤害%、穿透次数、碰撞/索敌范围、轨道转速或半径 | 与 `scope: sword_array` / `per_sword` 配合 |
| **B. 机制性（改行为）** | **分裂**、**连锁**、元素附魔（火DOT/冰减速/雷溅射）、**回响**（残留剑气二段伤）、**掠夺**（击杀概率额外剑意/金币） | 多用 `on_hit` / `on_kill` 事件 + 子行为 ID |
| **C. 剑意轴** | 上限、获取效率、消耗减免、「满剑意自动大招一次」类唯一词条 | 慎做自动无限大，需 `exclusive_group` |
| **D. 玩家本体** | 移速、闪避 CD、生命/护甲、闪避剑气波、受伤剑阵反击 | `scope: player` |
| **E. 对敌/环境** | 对精英·BOSS 增伤、击杀爆炸、延长某形态持续时间等 | 可读 `enemy.is_elite` 或全局 `kill_explosion_radius` |

### 示例表（产品清单，可与上表合并进总表）

以下为**产品设计清单**，实现时每一条对应一条 Modifier 资源或表行。

| 词条 ID | 效果概述 | Modifier 类型建议 |
|---------|----------|-------------------|
| `burn` | 飞剑附带点燃 | `on_hit` → 施加 `dot_fire` |
| `slow` | 冰伤减速 | `on_hit` → 施加 `slow` |
| `chain` | 雷伤链式 | `on_hit` → `spawn_chain`（限制链数/范围） |
| `split` | 命中概率分裂临时飞剑 | `on_hit` → `spawn_temp_sword`（池化） |
| `echo` | 命中留剑气造成二段伤 | `on_hit` → `spawn_ground_aoe`（短时） |
| `plunder` | 击杀概率额外剑意/金币 | `on_kill` → `bonus_drop` |
| `lifesteal` | 吸血 | `on_damage_dealt` → `heal_percent` |
| `retal_on_hit` | 受击时射出飞剑 | `on_player_hurt` → `spawn_temp_sword` |
| `crit` | 暴击 + 暴伤 + 闪光 | `damage` → `crit_chance` + `crit_mult` |
| `pierce` | 穿透 N 怪 | `per_sword` → `pierce_count` |
| `orbit_radius` / `orbit_speed` | 剑阵半径/转速 | `sword_array` → `additive` |

### 叠加规则（建议）

- **同类 Modifier**：  
  - 伤害类：加算基础后再乘算「独立乘区」若需要（避免指数爆炸，需在表中标注 `stack_mode`: `additive` / `multiplicative` / `refresh`）。  
  - 固定次数类（穿透、链数）：通常加算并设上限。  
- **冲突**：同一 `slot`（如「唯一：光环」）后获得的覆盖或取最高 —— 由表字段 `exclusive_group` 控制。  

### 全局数值哲学（防膨胀，与策划共识）

- **加法为主**：例如多个「飞剑数量 +1」在平面层 **相加**，再受全局 cap 限制。  
- **乘法为辅、乘区有限**：「飞剑伤害 +20%」类可在单独乘区连乘；**暴击伤害 +50%** 等与暴击结果相乘，但 **独立乘区种类要少**（详见上表 `stack_mode`），避免指数曲线。  
- 文档与表必须写明 **先加后乘** 顺序（可在 `docs/Data/FORMULAS.md` 将来单开一页，此处原则先行）。  

### 叠加规则（精确定义，与策划对齐）

在表或 Resource 中显式标注每条 Modifier 的算法，避免程序拍脑袋：

| `stack_mode` | 含义 |
|--------------|------|
| `additive` | 同类加算到「平面」再参与后续公式，如 `base + Σflat` |
| `multiplicative` | 乘区连乘，如 `Π(1 + bonus_i)`，需限制乘区数量防爆炸 |
| `independent` | 「独立乘区」：单独一层乘法，常用于稀有遗物 |
| `refresh` | 不叠层，仅刷新持续时间（DOT/临时攻速圈等） |
| `max` / `min` | 同 ID 取最值 |

---

## 七、数据表与 JSON（策划友好）

### 1. 技能表 / 词条表（CSV 仍可保留）

下列字段建议在 **JSON** 中与 CSV **二选一为主数据源**（Godot 下 JSON 解析成本低，嵌套 `params` 更自然）。

### 2. `data/skills.json`（示例结构）

```json
{
  "version": 1,
  "skills": [
    {
      "id": "orbit_speed_up",
      "type": "passive",
      "modifiers": [{ "target": "orbit_speed", "scope": "sword_array", "stack_mode": "additive", "value": 0.15 }]
    }
  ]
}
```

### 3. `data/modifiers.json` 或关卡 `rooms_*.json` 引用

房间奖励可直接 **`reference_modifier_id`**，或内联 `ModifierDef` 对象；三选一 UI 只读 ID，从总表展开描述文案。

### 4. 技能树（可选，后期）

若要做「多层解锁」，可用 **邻接表**：`skill_id → prereq_ids[]`，由 `RunData.unlocked_skill_nodes` 记录；**仍由 JSON 驱动**，避免硬编码树形。

---

## 八、数据表字段建议（最小集 · CSV 列）

### 技能表 `skills`

| 列 | 说明 |
|----|------|
| id | 唯一 ID |
| name | 显示名 |
| type | active / passive / stance |
| cooldown | 秒 |
| sword_cost | 剑意消耗（0 表示无） |
| script_path | 或 behavior_key 映射到工厂 |

### 词条表 `modifiers`

| 列 | 说明 |
|----|------|
| id | 唯一 ID |
| scope | run_global / player / sword_array / per_sword |
| target_stat | damage / cooldown / radius / pierce / ... |
| stack_mode | additive / multiplicative / independent / refresh / max / min |
| exclusive_group | 可空 |
| params | JSON：如 `{ "chance": 0.15, "mult": 2.0 }` |
| category | `array_direct` / `array_mechanic` / `sword_charge` / `player` / `enemy`（可选，用于三选一分桶） |
| rarity | `common` / `rare` / `epic`（可选，用于权重） |

---

## 九、与代码目录的对应

- **`Skills/`**：`SkillBase` 子类、被动注册、冷却组件。  
- **`Data/`**：`skills.csv`、`modifiers.csv`、波次与房间权重。  
- **`Global/Game.gd`**：对象池上限、当前层数、难度 —— 与 Modifier 的「局内全局」部分可读同一 Resource。  

---

## 十、验收清单（技能线）

- [ ] 至少 1 个主动 + 2 个被动可重复获得且不报错  
- [ ] 三选一从表驱动，新增一行表即可出新选项（无需改核心 UI 代码）  
- [ ] 暴击 / 穿透 / 点燃等同帧多目标时无重复遍历性能坑（与 plan 中 ShapeCast 降频一致）  
- [ ] 剑意消耗与不足时的反馈（音效、飘字、禁用按钮）  
- [ ] 三选一 **稀有度与分桶**（剑阵/剑意/玩家）在表中可配，不出现连续多局完全同质选项  

本篇与 **plan.md** 同步迭代；涉及「多少词条、多少技能算 1.0」的数值目标可在 `Data/` 注释或 `README` 中另行约定。

---

## 十一、流派与协同（重玩性）

让玩家每局能「认准一个方向凑构筑」，词条之间应有 **Synergy**，避免唯一最优解：

| 流派倾向 | 关键词条方向 | 体验目标 |
|----------|----------------|----------|
| **飞剑数量流** | 数量 +1、分裂、连锁、略补攻速 | 幕布式割草 |
| **暴击流** | 暴击率、暴伤、暴击回剑意/触发分裂等 | 节奏点杀、大数字 |
| **剑意爆发流** | 获取、上限、大招增伤/减耗、满剑意迸发类词条 | 经常「清屏」窗口 |
| **地刺控场流** | 地刺范围、减速强度、持续、范围伤 | 包围下反打 |
| **防御反击流** | 闪避 CD、完美闪避奖剑意、受击/闪避反击飞剑 | 高风险高回报 |

实现提示：给 Modifier 打 **`synergy_tags`**（如 `multihit`、`crit`、`stance_spike`），任务或图鉴可引用；不必第一期做全，先满足 2～3 条清晰流派再扩展。
