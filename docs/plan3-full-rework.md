# 方案三：激进改造（Full Rework）执行计划

本文档在分支 `rework/plan3-full-rework` 上维护，与 `docs/deep-research-report.md` 中「方案三」一致：**几乎重写核心架构**，目标为暖雪式实时顶视角、事件驱动技能/圣物、数据驱动与可插拔模块。

---

## 1. 目标与边界

| 维度 | 目标 |
|------|------|
| 架构 | 组件化/ECS 化角色与敌人；**禁止**业务模块互相直接引用具体类，通过 **EventBus、接口、数据 ID** 通信。 |
| 战斗 | 全实时；Hitbox/Hurtbox、Dash/无敌帧、Hit Stop、镜头反馈。 |
| 技能/圣物 | JSON/Resource 全数据化；事件类型（击中/击杀/冲刺等）驱动效果。 |
| 关卡 | 房间流、波次、精英/Boss 掉落与难度曲线（可分期交付）。 |
| 工程 | 成熟插件承担非玩法核心（AI 行为树、相机、测试）；自研集中在「暖雪式规则与数据管线」。 |

**不做或后置**：联网对战、完整 Mod SDK（仅预留数据与脚本加载点）、与暖雪 1:1 复刻全部流派。

---

## 2. 解耦性设计（分层）

```
┌─────────────────────────────────────────────────────────┐
│  Presentation（表现）  UI / VFX / 音频触发               │
├─────────────────────────────────────────────────────────┤
│  Gameplay（玩法编排）  房间状态机、波次、掉落、难度        │
├─────────────────────────────────────────────────────────┤
│  Domain（领域）        技能定义、圣物槽规则、伤害上下文      │
├─────────────────────────────────────────────────────────┤
│  Simulation（模拟）    移动、碰撞层、受击、Buff 时间轴      │
├─────────────────────────────────────────────────────────┤
│  Infrastructure（基建） ECS/组件宿主、事件总线、存档、资源加载 │
└─────────────────────────────────────────────────────────┘
```

**硬规则**

1. **EventBus**（单例 `EventBus`）：跨系统「事实」只通过结构化 `Dictionary` 或强类型 DTO 广播（如 `combat_hit`、`enemy_killed`）。表现层可监听，但**不得**在回调里写玩法数值公式（应调用 Domain 服务）。
2. **数据与逻辑分离**：技能/圣物/敌人数值以 **Resource + JSON** 为源；运行时只读 **ID**，脚本侧用工厂根据 ID 生成 `SkillRuntime` / `RelicRuntime`。
3. **ECS/组件边界**：物理与渲染相关组件留在 Simulation；技能条件判定读 **组件快照或事件载荷**，不直接 `get_node()` 深扒场景树。
4. **第三方插件**：只依赖其 **公开 API**；用一层 **Adapter**（薄封装）接入，便于替换（例如行为树从 LimboAI 换为 Beehave 时只改 Adapter）。

---

## 3. 参考库与分工（做什么 + 为何能解耦）

以下均为 **Godot 4** 生态常见选择；实际以许可证与团队熟悉度为准，版本锁定后写入 `addons/` 或通过子模块管理。

| 参考 | 仓库 / 文档 | 在本项目中承担 | 解耦方式 |
|------|-------------|----------------|----------|
| **GECS** | https://github.com/csprance/gecs | 实体、组件、查询；玩家/敌人/子弹统一实体模型 | 玩法逻辑只注册 System，不继承庞大 `CharacterBody2D` 上帝类；与场景节点通过 **同步适配器** 绑定 |
| **Godot ECS（备选）** | https://github.com/godothub/godot-ecs | 纯 GDScript、偏轻量、含序列化思路 | 若 GECS 过重可选用；同样用 Adapter 隔离 |
| **LimboAI** | https://github.com/limbonaut/limboai | 敌人 AI、Boss 阶段切换 | AI 只输出 **意图**（移动向量、技能 ID），由 Simulation 执行；不内嵌伤害公式 |
| **Beehave（备选）** | https://github.com/bitbrain/beehave | 行为树 / 状态机替代方案 | 与 LimboAI 二选一，通过 **同一 `IAiBrain` 接口** 封装 |
| **Phantom Camera** | https://github.com/ramokz/phantom-camera | 跟随、震动、冲击反馈镜头 | 仅订阅战斗事件调「震动/FOV」；不反向依赖技能系统 |
| **GUT** | https://github.com/bitwes/Gut | 单元测试与回归（事件载荷、数据表加载） | 测 Domain 与数据解析，避免依赖完整场景 |
| **Godot 官方** | Physics 2D、Area2D、Layer/Mask | Hitbox/Hurtbox、无敌帧与碰撞过滤 | 用 **项目设置中的层** 约定文档化，避免魔法数字散落 |
| **JSON / Resource** | 内置 `JSON`、`Resource` | 技能、圣物、波次表 | 校验层单独模块（如 `Schema` 或自定义校验函数），与运行时解耦 |

**说明**

- **ECS 是否必选**：方案三推荐 **ECS 或强约束组合节点** 二选一；若团队更熟场景树组合，可用「节点 + 组件脚本」模拟，但仍保持 **事件与数据驱动** 同一套边界。
- **飞剑/弹幕**：优先 **Simulation 内投射物实体** + 碰撞层；不必单独框架，除非引入物理引擎插件（一般不需要）。

---

## 4. 分阶段里程碑（建议顺序）

### 阶段 A — 基建清零与可运行空壳

- 执行 `scripts/clean_for_plan3_rework.ps1`（先 `-WhatIf` 或备份确认），得到 `EventBus` + 空主场景。
- 引入 GECS（或备选）与 GUT；主场景能启动、单测能跑。

### 阶段 B — 实时战斗核心

- 角色移动、冲刺、无敌帧；Hitbox/Hurtbox、伤害上下文结构体。
- EventBus 事件与 Phantom Camera 震动联动（Adapter）。
- Hit Stop：时间缩放服务，**单一入口**（避免各处改 `Engine.time_scale`）。

### 阶段 C — 技能与圣物引擎

- JSON → Resource 管线；`on_cast` / `on_hit` / `on_kill` 等订阅 EventBus。
- 四槽圣物：**槽位仅影响属性映射表**，逻辑在 Domain 单模块。

### 阶段 D — 关卡与成长

- 房间图、波次、精英标记；掉落表与 EventBus `enemy_killed` 挂钩。

### 阶段 E — 打磨与扩展

- 本地多人（若做）：输入设备抽象 + 分屏或同屏，**不**与技能引擎耦合。
- 调试控制台：热加载 JSON（仅开发版）。

---

## 5. 工时量级（与调研报告对齐）

与 `deep-research-report.md` 中方案三一致：**约 100–150+ 人日**（视飞剑复杂度、Boss 数量与数据工具深度而定）。本计划通过插件减负，主要风险在 **数据管线与事件一致性**，建议阶段 C 安排专项联调与自动化测试。

---

## 6. 仓库内脚本与分支

| 路径 | 说明 |
|------|------|
| `scripts/clean_for_plan3_rework.ps1` | 备份 `src`/`scenes`/`automation` 至 `_plan3_archive/<时间戳>/`，写入最小桩并更新 `project.godot` |
| `scripts/plan3/bootstrap/` | 清理后复制的模板（`event_bus.gd`、`main.tscn`、`project.godot.snippet`） |
| 分支 `rework/plan3-full-rework` | 方案三开发与评审用主线 |

---

## 7. 风险与对策

| 风险 | 对策 |
|------|------|
| ECS 与 Godot 节点双轨同步复杂 | 单一 `EntityView` 桥接；每帧或事件驱动同步，文档化规则 |
| 事件泛滥难以调试 | 开发版 EventBus 日志与 `trace_id`（一次攻击链共享 ID） |
| 插件停更 | Adapter 层 + 接口隔离；核心 Domain 不依赖插件类型 |

---

*文档版本：与方案三分支同步迭代。*
