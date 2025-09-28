# EasyAlert

<div align="center">

![EasyAlert](https://img.shields.io/badge/iOS-13%2B-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)
![SPM](https://img.shields.io/badge/SPM-Supported-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

**一个轻量、灵活、可扩展的 iOS 弹窗组件库** 🚀

支持自定义内容视图、带按钮的消息弹窗、ActionSheet、可拖拽的交互式底部弹窗、Toast，以及与 SwiftUI 的无缝集成。

</div>

## 📋 目录

- [✨ 特性](#-特性)
- [🚀 快速开始](#-快速开始)
- [📱 使用示例](#-使用示例)
- [🎨 自定义与扩展](#-自定义与扩展)
- [📖 API 文档](#-api-文档)
- [🔧 示例工程](#-示例工程)
- [📋 版本要求](#-版本要求)
- [🤝 贡献指南](#-贡献指南)

## ✨ 特性

<table>
<tr>
<td width="50%">

**🎯 核心功能**
- 🎨 **Alert**: 基础弹窗类，支持任意 `UIView` 或 `UIViewController` 内容
- 🔘 **ActionAlert**: 带动作按钮的弹窗，支持 `.default`、`.cancel`、`.destructive` 样式
- 📝 **MessageAlert**: 消息弹窗，内置标题与正文样式，支持富文本
- 📋 **ActionSheet**: 底部动作选择器，支持分组展示和 Cancel 动作

</td>
<td width="50%">

**🚀 高级特性**
- 👆 **InteractiveSheet**: 交互式底部弹窗，支持拖拽关闭
- 🎭 **背景与交互**: 毛玻璃/纯色/自定义遮罩，支持点击背景关闭
- 🔄 **生命周期**: 完整的 `willShow/didShow/willDismiss/didDismiss` 回调
- 🎯 **SwiftUI 集成**: `.easyAlert` 修饰符、`Environment(\.alert)`、`AlertHostingController`
- 🍞 **Toast**: 简洁易用的提示消息，自动计算时长

</td>
</tr>
</table>

## 🚀 快速开始

### 📦 安装

**Swift Package Manager** (推荐)

1. 在 Xcode 中：`File` > `Add Packages…`
2. 输入仓库地址：`https://github.com/zhwayne/EasyAlert.git`
3. 选择 `EasyAlert` 目标并添加到项目

**Package.swift**：

```swift
dependencies: [
    .package(url: "https://github.com/zhwayne/EasyAlert.git", from: "0.3.16")
]
```

> **📋 系统要求**：iOS 13+ | Swift 5.9+ | Xcode 15+

### ⚡ 30秒上手

**基础弹窗**：

```swift
import EasyAlert

// 创建自定义内容
let content = UIView()
content.backgroundColor = .systemBackground
content.layer.cornerRadius = 16
content.frame = CGRect(x: 0, y: 0, width: 300, height: 180)

// 显示弹窗
let alert = Alert(content: content)
alert.backdrop.allowDismissWhenBackgroundTouch = true
alert.show() // 或指定宿主: alert.show(in: someView)
```

**消息弹窗**：

```swift
let alert = MessageAlert(title: "提示", message: "这是一个简单的消息弹窗")
let confirm = Action(title: "确定", style: .default)
alert.addAction(confirm)
alert.show()
```

## 📱 使用示例

### 1️⃣ 消息弹窗

#### 基础用法

```swift
let alert = MessageAlert(title: "确认删除", message: "此操作不可撤销，确定要删除吗？")
let cancel = Action(title: "取消", style: .cancel)
let confirm = Action(title: "删除", style: .destructive) { _ in
    // 处理删除逻辑
    print("用户确认删除")
}
alert.addAction(cancel)
alert.addAction(confirm)
alert.show()
```

#### 富文本支持

```swift
let title = NSAttributedString(string: "⚠️ 重要提示", attributes: [
    .foregroundColor: UIColor.systemOrange,
    .font: UIFont.boldSystemFont(ofSize: 18)
])
let message = NSAttributedString(string: "这是一个包含富文本的消息弹窗")
MessageAlert(title: title, message: message).show()
```

#### 自定义样式

```swift
var config = MessageAlert.Configuration.global
config.titleConfiguration.alignment = .left
config.messageConfiguration.alignment = .left
config.titleConfiguration.font = UIFont.systemFont(ofSize: 20, weight: .bold)

let alert = MessageAlert(
    title: "自定义样式", 
    message: "左对齐的标题和内容", 
    configuration: config
)
alert.show()
```

### 2️⃣ SwiftUI 集成

#### 使用 AlertHostingController

```swift
import SwiftUI
import EasyAlert

let content = AlertHostingController { alert in
    VStack(spacing: 16) {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
            .font(.system(size: 48))
        
        Text("操作成功")
            .font(.title2)
            .fontWeight(.semibold)
        
        Text("您的操作已完成")
            .foregroundColor(.secondary)
        
        Button("关闭") { 
            alert?.dismiss()
        }
        .buttonStyle(.borderedProminent)
    }
    .padding(24)
    .frame(width: 300)
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16))
}

Alert(content: content).show()
```

#### 使用 .easyAlert 修饰符

```swift
struct DemoView: View {
    @State private var showAlert = false
    @State private var showActionSheet = false

    var body: some View {
        VStack(spacing: 20) {
            Button("显示弹窗") { showAlert = true }
                .buttonStyle(.borderedProminent)
            
            Button("显示 ActionSheet") { showActionSheet = true }
                .buttonStyle(.bordered)
        }
        .easyAlert(isPresented: $showAlert, allowDismissWhenBackgroundTouch: true) { alert in
            VStack(spacing: 12) {
                Text("SwiftUI 弹窗")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("这是使用修饰符创建的弹窗")
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Button("取消") { alert?.dismiss() }
                        .buttonStyle(.bordered)
                    
                    Button("确定") { 
                        // 处理确定逻辑
                        alert?.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .frame(width: 280)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
```

#### 环境变量支持

```swift
struct ContentView: View {
    @Environment(\.alert) private var alert
    
    var body: some View {
        Button("关闭弹窗") {
            Task { await alert?.dismiss() }
        }
    }
}
```

### 3️⃣ ActionSheet

#### 基础用法

```swift
let sheet = ActionSheet()
sheet.addAction(Action(title: "拍照", style: .default) { _ in
    // 处理拍照逻辑
})
sheet.addAction(Action(title: "从相册选择", style: .default) { _ in
    // 处理相册选择逻辑
})
sheet.addAction(Action(title: "删除", style: .destructive) { _ in
    // 处理删除逻辑
})
sheet.addAction(Action(title: "取消", style: .cancel))
sheet.show()
```

#### 自定义外观

```swift
var config = ActionSheet.Configuration.global
config.cancelSpacing = 12
config.cornerRadius = 16
config.contentInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

// 自定义按钮视图
config.makeActionView = { style in
    MyCustomSheetActionView(style: style)
}

// 自定义布局
config.makeActionLayout = { 
    MyCustomSheetActionLayout() 
}

let customSheet = ActionSheet(configuration: config)
customSheet.addActions([
    Action(title: "选项一", style: .default),
    Action(title: "选项二", style: .default),
    Action(title: "危险操作", style: .destructive),
    Action(title: "取消", style: .cancel)
])
customSheet.show()
```

### 4️⃣ 交互式底部弹窗

#### 基础拖拽弹窗

```swift
let content = AlertHostingController { alert in
    VStack(spacing: 16) {
        Text("可拖拽下滑关闭")
            .font(.headline)
        
        Text("向下拖拽或点击完成按钮关闭")
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        
        Button("完成") { 
            Task { await alert?.dismiss() }
        }
        .buttonStyle(.borderedProminent)
    }
    .padding(.bottom, 20)
    .background(.regularMaterial)
}

let sheet = InteractiveSheet(content: content)
sheet.show()
```

### 5️⃣ Toast 提示

#### 基础用法

```swift
// 自动计算显示时长
Toast.show("保存成功！")

// 自定义显示时长
Toast.show("正在处理...", duration: 3.0)

// 持续显示（需手动关闭）
Toast.show("加载中...", duration: .infinity)
Task { 
    // 处理完成后关闭
    await Toast.dismiss() 
}
```

#### 位置与样式

```swift
// 底部显示
Toast.show("操作完成", position: .bottom)

// 居中显示
Toast.show("重要提示", position: .center)

// 自定义交互范围
Toast.show("重要消息", interactionScope: .none)
```

## 🎨 自定义与扩展

### 🎭 背景与交互

#### 背景样式

```swift
let alert = MessageAlert(title: "提示", message: "内容")

// 毛玻璃效果
alert.backdrop.dimming = .blur(style: .dark, radius: 10)

// 纯色背景
alert.backdrop.dimming = .color(UIColor.black.withAlphaComponent(0.5))

// 自定义视图背景
let customView = UIView()
customView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
alert.backdrop.dimming = .view(customView)

// 交互配置
alert.backdrop.allowDismissWhenBackgroundTouch = true
alert.backdrop.interactionScope = .none  // .none / .dimming / .all
alert.show()
```

### 🔄 生命周期监听

```swift
let alert = MessageAlert(title: "标题", message: "内容")

// 添加生命周期监听器
alert.addListener(LifecycleCallback(
    willShow: { 
        print("弹窗即将显示")
        // 可以在这里进行一些准备工作
    },
    didShow: { 
        print("弹窗已显示")
        // 可以在这里进行一些显示后的操作
    },
    willDismiss: { 
        print("弹窗即将关闭")
        // 可以在这里进行一些清理工作
    },
    didDismiss: { 
        print("弹窗已关闭")
        // 可以在这里进行一些关闭后的操作
    }
))

alert.show()
```

### 🎨 自定义 Action 视图与布局

#### 自定义按钮视图

```swift
class MyCustomActionView: UIView {
    // 实现自定义按钮样式
}

// 配置自定义视图
var config = MessageAlert.Configuration.global
config.makeActionView = { style in
    MyCustomActionView(style: style)
}
```

#### 自定义布局

```swift
class MyCustomActionLayout: ActionLayout {
    // 实现自定义布局逻辑
}

// 配置自定义布局
config.makeActionLayout = { 
    MyCustomActionLayout() 
}

let alert = MessageAlert(
    title: "标题", 
    message: "内容", 
    configuration: config
)
alert.show()
```

### 🎯 全局配置

```swift
// 设置全局默认配置
var globalConfig = MessageAlert.Configuration.global
globalConfig.titleConfiguration.font = UIFont.boldSystemFont(ofSize: 18)
globalConfig.messageConfiguration.font = UIFont.systemFont(ofSize: 16)
globalConfig.actionConfiguration.spacing = 12

MessageAlert.Configuration.global = globalConfig
```

## 📖 API 文档

### 核心类

| 类名 | 描述 | 主要功能 |
|------|------|----------|
| `Alert` | 基础弹窗类 | 自定义内容、背景配置、动画控制 |
| `ActionAlert` | 带动作的弹窗 | 动作按钮管理、样式配置 |
| `MessageAlert` | 消息弹窗 | 标题、正文、富文本支持 |
| `ActionSheet` | 动作选择器 | 底部弹出、分组显示 |
| `InteractiveSheet` | 交互式弹窗 | 拖拽关闭、智能协作 |
| `Toast` | 提示消息 | 自动时长、多位置显示 |

### 协议与配置

| 类型 | 描述 |
|------|------|
| `Alertable` | 弹窗基础协议 | 显示、隐藏、状态管理 |
| `ActionAlertable` | 动作弹窗协议 | 动作按钮管理 |
| `AlertHosting` | 宿主协议 | UIView/UIViewController 支持 |
| `AlertBackdrop` | 背景配置 | 毛玻璃、纯色、自定义遮罩 |

### 常用方法

```swift
// 显示弹窗
alert.show()
alert.show(in: viewController)

// 关闭弹窗
await alert.dismiss()

// 添加动作
alert.addAction(action)
alert.addActions([action1, action2])

// 生命周期监听
alert.addListener(LifecycleCallback(...))
```

## 🔧 示例工程

打开 `Example/EasyAlert` 运行示例 App，查看完整的功能演示：

### 📱 功能展示
- ✅ **消息弹窗**：基础用法、富文本、自定义样式
- ✅ **SwiftUI 集成**：修饰符、环境变量、自定义内容
- ✅ **ActionSheet**：系统样式、自定义外观、分组显示
- ✅ **交互式弹窗**：拖拽关闭、滚动协作、高级配置
- ✅ **Toast 提示**：多位置、自定义样式、时长控制

### 🎯 最佳实践
- 弹窗层级管理
- 内存优化技巧
- 动画性能调优
- 无障碍支持

## 📋 版本要求

| 平台 | 版本要求 |
|------|----------|
| **iOS** | 13.0+ |
| **Swift** | 5.9+ |
| **Xcode** | 15.0+ |
| **SPM** | 6.0+ |

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 🐛 报告问题
- 使用 [Issues](https://github.com/your-repo/EasyAlert/issues) 报告 Bug
- 提供详细的复现步骤和环境信息
- 附上相关的代码片段和截图

### 💡 功能建议
- 在 [Discussions](https://github.com/your-repo/EasyAlert/discussions) 提出新功能想法
- 描述使用场景和预期效果
- 参与社区讨论和投票

### 🔧 代码贡献
1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add amazing feature'`
4. 推送分支：`git push origin feature/amazing-feature`
5. 创建 Pull Request

### 📝 文档改进
- 完善 API 文档
- 添加使用示例
- 翻译多语言文档

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为 EasyAlert 做出贡献的开发者们！

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

[English Documentation](#english-documentation) | [示例工程](#示例工程) | [快速开始](#快速开始)

</div>
