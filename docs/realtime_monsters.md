# 即时模式怪物数据说明

数据文件：[`assets/data/realtime_monsters.json`](../assets/data/realtime_monsters.json)

## 字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一 ID，供存档/调试 |
| `display_name` | string | 头顶飘字（含类型/元素提示） |
| `character_tile` | string | `CharacterTiles` 图集名，如 `pest-17` |
| `hp` | int | 生命值 |
| `physical_def` | int | 物理减伤（先减再算五行克制） |
| `magic_def` | int | 魔法减伤 |
| `armor_kind` | `"physical"` \| `"magic"` | 护甲倾向（影响何种攻击更有效，当前为数值化防御） |
| `element` | `"metal"`\|`"wood"`\|`"water"`\|`"fire"`\|`"earth"` | 五行属性，用于克制倍率 |
| `attack_kind` | `"physical"` \| `"magic"` | 敌人攻击类型（预留：反伤/护盾） |
| `speed_scale` | float | 移动速度倍率（相对基础 95） |

## 五行克制（当前简化）

在 [`realtime_wuxing.gd`](../src/realtime/realtime_wuxing.gd) 中：`克制` 造成 **×1.25**，`被克` **×0.8**，同系 **×1.0**。后续可与 [`idea.md`](idea.md) 完整表合并。

## 资源与动画帧

- 当前使用工程内 **character_tiles** 精灵名作为「站立帧」。
- 若需多帧动画：可用 `tools/` 下脚本从条带图切帧，或外采 CC0 素材后按 `character_tiles.json` 同样流程导入。

## Python 生成占位图

五行技能/UI 图标：`tools/generate_wuxing_icons.py`（依赖 Pillow：`pip install pillow`）。
