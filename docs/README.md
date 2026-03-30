# 万剑肉鸽 · 文档索引

本目录整理 **Godot 4.6 桌面端** 万剑剑阵 + 肉鸽玩法的核心规格与实现路线。

| 文档 | 说明 |
|------|------|
| [plan.md](./plan.md) | 技术阶段 + **§ 十四 玩法与体验**（形态差异化、剑意深度、敌人与节奏、Meta、手感与主题） |
| [skills.md](./skills.md) | 词条五维度、稀有度/分桶、数值哲学、流派 Synergy、Modifier 与验收 |

**阅读顺序建议：** 先通读 `plan.md` 建立全局视图，再做技能与数值迭代时以 `skills.md` 为单一事实来源（可与 `Data/` 下表格对照）。

---

## 与仓库目录的对应关系（计划）

```
/project
├── Main.tscn
├── Global/Game.gd          # 单例：池、事件、全局数值
├── Player/
├── SwordArray/             # 剑阵核心 + Sword.tscn
├── Enemies/
├── Skills/
├── Effects/
├── UI/
├── Levels/
└── Data/                   # 技能表、词条表、配置
```

实现过程中若计划变更，请同步更新 `plan.md`；技能与词条的增删改请同步 `skills.md` 与 `Data/`。
