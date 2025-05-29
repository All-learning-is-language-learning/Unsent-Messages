# Unsent-Messages

------

## UI 开发笔记

使用 `godot-ink` 插件实现 ink 支持，需要使用 `mono` 版本的 godot 。

### 已实现内容

- 简单的标题界面
- Ink 文档解析的对话框
- 可控速度打字机效果
- 根据 ink 标签变换背景、角色，淡入淡出，支持连续标签解析
- 切换角色表情
- 存读档功能
- 画面震动效果
- 回忆闪回效果

### 使用指南

在 `Dialogue` 节点 `ink_story` 属性中导入 ink 文档。

每对话动画渲染完成后展示下一句按钮，段落最后一句渲染完成后展示选项。

标签切换背景/角色用法：
```ink
# background:a      —— 更换为 a 背景
# character:knight  —— 添加/显示 knight
# character:!knight —— 隐藏/移除 knight
# character:!all    —— 清除所有角色
# character:a:b     —— 把 a 角色的材质更换为 b 角色材质（不改变角色名）
# shake             —— 画面震动效果
# memory:a,b,c,.... —— 闪回 a, b, c 背景
# state:1           —— 修改留言系统状态为 1
# message:open/close—— 打开/关闭留言系统
```

在 `game` 场景的 `bg_texture` 和 `character_textures` 字典中添加材质，通过 `game.gd` 中的 `fade_time` 字段控制淡入淡出时间。

存档位置为 `user://save1.json` ；开始游戏时若存档存在，直接读取存档。

### TODO

- [ ] 结束界面

以上：马志远。
