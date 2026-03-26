# ⏰ 时光机 (NostalgiaBox)

> 怀旧杀时间神器 · 带你穿越回青春

[![Build](https://github.com/nostalgiabox/ios/actions/workflows/build.yml/badge.svg)](https://github.com/nostalgiabox/ios/actions)

iOS 上专为 80/90 后用户打造的怀旧复刻类 App，提供经典游戏、复古播放器、电子宠物等功能，重温那些没有智能手机却最纯粹的快乐时光。

---

## ✨ 功能特色

### 🎮 经典游戏
- **魔塔系列** — 黄金大陆、暗黑森林等经典魔塔复刻
- **像素RPG** — 像素勇者、龙之谷等复古角色扮演
- **跑酷游戏** — 跳跳像素人、方块跑酷等无尽挑战
- **休闲益智** — 宠物小精灵、2048怀旧版等

### 📻 复古播放器
支持 MP4 / AVI / MP3 / FLV / WMV / MKV / MOV / WAV 等主流格式，一键播放本地文件。

### 🐣 电子宠物
当年电子鸡的复刻版，养成与怀旧并存。

### 📅 怀旧日历
看看 2000 年代的今天发生了什么，重温那些年的今天。

---

## 🛠 技术栈

- **UI框架：** SwiftUI
- **项目生成：** XcodeGen
- **最低 iOS：** 15.0
- **构建工具：** Xcode 15.0+

---

## 📦 快速开始

### 环境要求
- macOS 14+ (Sonoma 或更高)
- Xcode 15.0+
- XcodeGen (`brew install xcodegen`)

### 构建步骤

```bash
# 克隆项目
git clone https://github.com/nostalgiabox/ios.git
cd ios

# 生成 Xcode 项目
xcodegen generate

# 打开项目
open NostalgiaBox.xcodeproj

# 在 Xcode 中选择模拟器并运行 (Cmd+R)
```

---

## 📁 项目结构

```
NostalgiaBox/
├── App/
│   ├── NostalgiaBoxApp.swift      # App 入口
│   └── Info.plist                 # 应用配置
├── Sources/
│   ├── AppState.swift             # 全局状态管理
│   └── Views/
│       ├── ContentView.swift      # 主容器 + TabBar
│       ├── Home/
│       │   └── HomeView.swift     # 首页
│       ├── Games/
│       │   └── GamesView.swift    # 游戏中心
│       ├── Player/
│       │   └── PlayerView.swift   # 复古播放器
│       └── Settings/
│           └── SettingsView.swift # 设置页
├── Resources/
│   └── LaunchScreen.storyboard    # 启动屏
├── Assets.xcassets/               # 资源目录
├── demo.html                      # Web Demo（可直接浏览器预览）
└── project.yml                    # XcodeGen 配置
```

---

## 🎨 设计规范

### 品牌色
| 名称 | 色值 | 用途 |
|---|---|---|
| Primary (Coral Red) | `#FF6B6B` | 主色调、按钮、强调 |
| Secondary | `#FF8E53` | 渐变、辅助强调 |
| Background | `#FFFFFF` / `#F5F5F7` | 背景色 |
| Text Primary | `#333333` | 主要文字 |
| Text Secondary | `#888888` | 次要文字 |

### 字体
- 系统字体 (San Francisco) 为主
- 标题：Bold / Large Title
- 正文：Regular / Body
- 辅助：Caption / Footnote

---

## 💰 内购定价

- **免费版：** 体验基础功能，限制部分游戏
- **完整版 ($2.99 / ¥18)：** 解锁全部游戏、播放器高清格式、电子宠物、怀旧日历、无广告

---

## 🔒 隐私与合规

- 不收集任何个人身份信息
- 使用 Sign in with Apple 登录
- 用户数据仅存储在设备本地
- 符合 Apple App Store 审核标准

详见：[隐私政策](https://nostalgiabox.app/privacy) | [用户协议](https://nostalgiabox.app/terms)

---

## 🚀 CI/CD

项目使用 GitHub Actions 进行持续构建：

- **Push / PR to main：** 自动触发 `xcodebuild` 构建
- 验证项目能够成功编译

---

## 📱 App Store

即将上架 App Store，敬请期待。

官网：[nostalgiabox.app](https://nostalgiabox.app)

---

## 📄 License

Copyright © 2026 NostalgiaBox. All rights reserved.
