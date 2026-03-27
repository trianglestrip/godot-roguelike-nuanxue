# 暖雪式即时战斗 · 美术资源清单（UI / 技能特效）

本文档与 [`idea.md`](idea.md)、[`wuxing_skills_spec.md`](wuxing_skills_spec.md) 对齐；**数据与特效 ID** 以 [`../src/realtime/realtime_stance_defs.gd`](../src/realtime/realtime_stance_defs.gd)、[`../src/realtime/realtime_skill_vfx.gd`](../src/realtime/realtime_skill_vfx.gd) 为准。

**说明**：当前场景中 HUD 多为 `Label` 文本（见 [`../src/realtime/realtime_game.gd`](../src/realtime/realtime_game.gd)）。下表为**建议落地的条图、图标与特效序列**；占位图可由脚本一键生成，便于你对照替换正式像素画。

---

## 1. 占位图生成（Python）

依赖：[Pillow](https://pillow.readthedocs.io/)

```text
pip install Pillow
```

在项目根目录执行：

```text
python automation/generate_res_placeholders.py
```

脚本会写入（相对仓库根）**`assets/realtime/ui/hud/`** 与 **`assets/realtime/vfx/spritesheets/`** 下的 PNG。重新运行会覆盖同名文件。

---

## 2. HUD：血条、怒气、剑返 CD、护盾与五行

### 2.1 条图组件（建议 9-slice 或固定高度拉伸）

| 资源 ID | 用途 | 建议尺寸（逻辑像素） | 文件路径 |
|--------|------|---------------------|----------|
| HP 条底 | 生命槽背景、暗底边框 | 160×14 | [`../assets/realtime/ui/hud/bar_hp_bg.png`](../assets/realtime/ui/hud/bar_hp_bg.png) |
| HP 条填充 | 当前生命（红系，可随百分比裁剪宽度） | 156×10 | [`../assets/realtime/ui/hud/bar_hp_fill.png`](../assets/realtime/ui/hud/bar_hp_fill.png) |
| 怒气条底 | 怒气槽背景 | 160×12 | [`../assets/realtime/ui/hud/bar_rage_bg.png`](../assets/realtime/ui/hud/bar_rage_bg.png) |
| 怒气条填充 | R 大招资源（金/琥珀色） | 156×8 | [`../assets/realtime/ui/hud/bar_rage_fill.png`](../assets/realtime/ui/hud/bar_rage_fill.png) |
| 剑返 CD 底 | 空格「收剑返」冷却 | 120×10 | [`../assets/realtime/ui/hud/bar_return_cd_bg.png`](../assets/realtime/ui/hud/bar_return_cd_bg.png) |
| 剑返 CD 填充 | 冷却进度（可由右向左消减或顺时针） | 116×6 | [`../assets/realtime/ui/hud/bar_return_cd_fill.png`](../assets/realtime/ui/hud/bar_return_cd_fill.png) |
| 护盾条底 | `shield_hp` 叠加显示（可选） | 140×10 | [`../assets/realtime/ui/hud/bar_shield_bg.png`](../assets/realtime/ui/hud/bar_shield_bg.png) |
| 护盾条填充 | 护盾剩余 | 136×6 | [`../assets/realtime/ui/hud/bar_shield_fill.png`](../assets/realtime/ui/hud/bar_shield_fill.png) |
| 当前五行高亮框 | 套在五行图标外的选中框 | 26×26 | [`../assets/realtime/ui/hud/element_slot_selected.png`](../assets/realtime/ui/hud/element_slot_selected.png) |

**视觉示意（占位）**

![HP 条底](../assets/realtime/ui/hud/bar_hp_bg.png) ![HP 填充](../assets/realtime/ui/hud/bar_hp_fill.png)

![怒气底](../assets/realtime/ui/hud/bar_rage_bg.png) ![怒气填充](../assets/realtime/ui/hud/bar_rage_fill.png)

![剑返 CD 底](../assets/realtime/ui/hud/bar_return_cd_bg.png) ![剑返 CD 填充](../assets/realtime/ui/hud/bar_return_cd_fill.png)

![护盾底](../assets/realtime/ui/hud/bar_shield_bg.png) ![护盾填充](../assets/realtime/ui/hud/bar_shield_fill.png)

![五行选中框](../assets/realtime/ui/hud/element_slot_selected.png)

### 2.2 五行图标（游戏中已引用）

代码中路径模式：`res://assets/realtime/ui/icon_{metal|wood|water|fire|earth}.png`（见 `realtime_game.gd`）。

| 元素 | 中文 | 主色参考（RGB 约） | 文件 |
|------|------|-------------------|------|
| 金 | 金 | 209,214,224 | [`../assets/realtime/ui/icon_metal.png`](../assets/realtime/ui/icon_metal.png) |
| 木 | 木 | 115,199,107 | [`../assets/realtime/ui/icon_wood.png`](../assets/realtime/ui/icon_wood.png) |
| 水 | 水 | 107,158,242 | [`../assets/realtime/ui/icon_water.png`](../assets/realtime/ui/icon_water.png) |
| 火 | 火 | 242,115,89 | [`../assets/realtime/ui/icon_fire.png`](../assets/realtime/ui/icon_fire.png) |
| 土 | 土 | 184,140,97 | [`../assets/realtime/ui/icon_earth.png`](../assets/realtime/ui/icon_earth.png) |

![金](../assets/realtime/ui/icon_metal.png) ![木](../assets/realtime/ui/icon_wood.png) ![水](../assets/realtime/ui/icon_water.png) ![火](../assets/realtime/ui/icon_fire.png) ![土](../assets/realtime/ui/icon_earth.png)

### 2.3 HUD 还需预留的文案区（可无独立贴图）

- **流派名**：如「锐金流」「神木流」—— 使用 [`../assets/fonts/pixel_operator/PixelOperatorSC.ttf`](../assets/fonts/pixel_operator/PixelOperatorSC.ttf) 等像素字即可。
- **剩余敌人数量 / 调试信息**：当前用 `HPLabel` 文本；若要做图标，可增 `ui/hud/icon_enemy_count.png`（本文未生成，可自行加脚本扩展）。

---

## 3. 飞剑 / 弹道（按五行）

右键飞剑贴图已存在于工程，便于你对齐风格统一重绘。

| 五行 | 文件 |
|------|------|
| 金 | [`../assets/realtime/projectiles/flying_sword_metal.png`](../assets/realtime/projectiles/flying_sword_metal.png) |
| 木 | [`../assets/realtime/projectiles/flying_sword_wood.png`](../assets/realtime/projectiles/flying_sword_wood.png) |
| 水 | [`../assets/realtime/projectiles/flying_sword_water.png`](../assets/realtime/projectiles/flying_sword_water.png) |
| 火 | [`../assets/realtime/projectiles/flying_sword_fire.png`](../assets/realtime/projectiles/flying_sword_fire.png) |
| 土 | [`../assets/realtime/projectiles/flying_sword_earth.png`](../assets/realtime/projectiles/flying_sword_earth.png) |

![金飞剑](../assets/realtime/projectiles/flying_sword_metal.png) ![木](../assets/realtime/projectiles/flying_sword_wood.png) ![水](../assets/realtime/projectiles/flying_sword_water.png) ![火](../assets/realtime/projectiles/flying_sword_fire.png) ![土](../assets/realtime/projectiles/flying_sword_earth.png)

**美术建议**：单枚精灵约 16～32px 高；可加 2～4 帧「拖尾/旋转」作 `AnimatedSprite2D`，与程序里 `proj_speed`、穿透等无关，纯表现。

---

## 4. 技能特效（`RealtimeSkillVfx.Kind`）与动画帧说明

程序内特效多为 **Canvas 几何绘制**（[`../src/realtime/realtime_skill_vfx.gd`](../src/realtime/realtime_skill_vfx.gd)）。下表给出 **替换为序列帧美术** 时的**动作描述**、**建议帧数**与 **占位条带路径**（横排：左→右 为时间顺序；单帧 64×64）。

### 4.1 枚举与条带文件

| Kind | 特效名称（示意） | 建议帧数 | 动画要点（给原画/动画） | 占位 spritesheet |
|------|------------------|---------|-------------------------|------------------|
| `BURST` | 通用爆发环 | 6～8 | 半透明圆环由内向外扩张后淡出 | [`../assets/realtime/vfx/spritesheets/burst_sheet.png`](../assets/realtime/vfx/spritesheets/burst_sheet.png) |
| `SLASH_ARC` | 斩击弧 | 8 | 2～3 道弧顺时针扫过，刃光渐隐 | [`../assets/realtime/vfx/spritesheets/slash_arc_sheet.png`](../assets/realtime/vfx/spritesheets/slash_arc_sheet.png) |
| `SHOCK_BURST` | 电击/锐金爆 | 10 | 放射状短线由中心向外闪，中心亮点收缩 | [`../assets/realtime/vfx/spritesheets/shock_burst_sheet.png`](../assets/realtime/vfx/spritesheets/shock_burst_sheet.png) |
| `VINE_SNARE` | 藤缠/神木 | 10 | 椭圆藤环绞紧 + 少量叶屑 | [`../assets/realtime/vfx/spritesheets/vine_snare_sheet.png`](../assets/realtime/vfx/spritesheets/vine_snare_sheet.png) |
| `POISON_CLOUD` | 毒雾 | 10～12 | 多团毒泡随机位移、聚合后消散 | [`../assets/realtime/vfx/spritesheets/poison_cloud_sheet.png`](../assets/realtime/vfx/spritesheets/poison_cloud_sheet.png) |
| `ICE_SPIKE` | 冰刺（放射） | 8 | 6～8 根冰刺从中心「长出」到满长 | [`../assets/realtime/vfx/spritesheets/ice_spike_sheet.png`](../assets/realtime/vfx/spritesheets/ice_spike_sheet.png) |
| `ICE_RING` | 冰环爆炸 | 8 | 双环扩张，内环亮、外环碎冰屑 | [`../assets/realtime/vfx/spritesheets/ice_ring_sheet.png`](../assets/realtime/vfx/spritesheets/ice_ring_sheet.png) |
| `FIRE_FAN` | 扇形火焰（预留） | 8 | 扇形火浪前推，边缘卷流 | [`../assets/realtime/vfx/spritesheets/fire_fan_sheet.png`](../assets/realtime/vfx/spritesheets/fire_fan_sheet.png) |
| `FIRE_NOVA` | 烈焰新星 | 10 | 2～3 圈火环依次扩散，中心黄白闪 | [`../assets/realtime/vfx/spritesheets/fire_nova_sheet.png`](../assets/realtime/vfx/spritesheets/fire_nova_sheet.png) |
| `STONE_SPIKE` | 地刺（玄金/磐石等） | 8 | 8 方向石锥刺出，石屑下落 | [`../assets/realtime/vfx/spritesheets/stone_spike_sheet.png`](../assets/realtime/vfx/spritesheets/stone_spike_sheet.png) |
| `STONE_RAIN` | 落石 | 10～12 | 矩形落石随机砸下，密度随时间降低 | [`../assets/realtime/vfx/spritesheets/stone_rain_sheet.png`](../assets/realtime/vfx/spritesheets/stone_rain_sheet.png) |

**条带预览（占位，整图为横向帧序列）**

![burst](../assets/realtime/vfx/spritesheets/burst_sheet.png)

![slash_arc](../assets/realtime/vfx/spritesheets/slash_arc_sheet.png)

![shock_burst](../assets/realtime/vfx/spritesheets/shock_burst_sheet.png)

![vine_snare](../assets/realtime/vfx/spritesheets/vine_snare_sheet.png)

![poison_cloud](../assets/realtime/vfx/spritesheets/poison_cloud_sheet.png)

![ice_spike](../assets/realtime/vfx/spritesheets/ice_spike_sheet.png)

![ice_ring](../assets/realtime/vfx/spritesheets/ice_ring_sheet.png)

![fire_fan](../assets/realtime/vfx/spritesheets/fire_fan_sheet.png)

![fire_nova](../assets/realtime/vfx/spritesheets/fire_nova_sheet.png)

![stone_spike](../assets/realtime/vfx/spritesheets/stone_spike_sheet.png)

![stone_rain](../assets/realtime/vfx/spritesheets/stone_rain_sheet.png)

### 4.2 五行 × 流派 → 使用的 Kind（收剑返 / 怒气）

与 [`../src/realtime/realtime_stance_defs.gd`](../src/realtime/realtime_stance_defs.gd) 中 `return_vfx`、`rage_vfx` 一致，便于你对同一 Kind 做「五行换色」或独立成套。

| 流派（branch_name_cn） | 空格收剑返 `return_vfx` | 怒气 `rage_vfx` |
|------------------------|-------------------------|-----------------|
| 锐金流 | `SHOCK_BURST` | `SHOCK_BURST` |
| 玄金流 | `STONE_SPIKE` | `SHOCK_BURST` |
| 青木流 | `POISON_CLOUD` | `POISON_CLOUD` |
| 神木流 | `VINE_SNARE` | `VINE_SNARE` |
| 寒水流 | `ICE_RING` | `ICE_RING` |
| 沧水流 | `ICE_SPIKE` | `ICE_SPIKE` |
| 烈炎流 | `FIRE_NOVA` | `FIRE_NOVA` |
| 焚天流 | `FIRE_NOVA` | `FIRE_NOVA` |
| 厚土流 | `STONE_RAIN` | `STONE_RAIN` |
| 磐石流 | `STONE_SPIKE` | `STONE_RAIN` |

**着色**：运行时传入 `RealtimeWuxing.element_color(current_element)` 与半径、时长；正式像素序列可先做灰度/中性色，再在引擎里 `modulate` 五行色，或每系单独出一套。

---

## 5. 目录小结（相对仓库根）

```text
assets/realtime/ui/hud/           # HUD 条、选中框（脚本可生成）
assets/realtime/ui/icon_*.png     # 五行 HUD 图标
assets/realtime/projectiles/      # 飞剑/弹道精灵
assets/realtime/vfx/spritesheets/ # 技能特效横向条带（脚本可生成）
automation/generate_res_placeholders.py
```

更新占位图后，在 Godot 中若未自动刷新，可对相应文件夹 **重新扫描** 或重启编辑器。
