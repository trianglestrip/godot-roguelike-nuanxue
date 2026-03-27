extends Node
## 占位单例：全局事件总线。方案三全量改造中由技能/圣物/战斗模块仅通过此处解耦通信。

signal combat_hit(data: Dictionary)
signal enemy_killed(data: Dictionary)
signal player_dashed(data: Dictionary)
