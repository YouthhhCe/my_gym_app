# my_gym_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



健身伴侣 (Gym Pal)一款简洁、高效、无干扰的健身辅助工具，旨在帮助你专注于每一次训练。它包含了精准的组间休息计时器和便捷的训练日志两大核心功能。这个项目是作为Flutter初学者的第一个完整应用而创建的，它涵盖了从UI设计、功能实现到数据持久化的完整开发流程。✨ 主要功能 (Features)<table align="center"><tr><td align="center" width="50%"><img src="https://storage.googleapis.com/agent-blue-gcs-prod-files/agent-blue-gcs-bucket-prod/2025/08/10/d8370505-user-fL1rGv2u3L87F63x9x9X_timer_mockup.png" alt="计时器页面截图" width="250"/><br /><strong>精准组间休息计时器</strong></td><td align="center" width="50%"><img src="https://storage.googleapis.com/agent-blue-gcs-prod-files/agent-blue-gcs-bucket-prod/2025/08/11/735626a5-user-fL1rGv2u3L87F63x9x9X_calendar_mockup_v2.png" alt="日志页面截图" width="250"/><br /><strong>便捷训练日志</strong></td></tr></table>计时器一键预设： 内置多个常用休息时长（60s, 90s, 120s），点击即可快速启动。自定义时长： 通过点击“+”号按钮，可以从底部弹出的iOS风格滚动选择器中精确设置时间。动态操作： 根据计时器状态，智能显示“开始”、“暂停”与“重置”按钮。沉浸式显示： 采用巨大化的等宽数字字体，确保视觉清晰。日志直观日历： 采用标准的月度日历视图，可轻松浏览和选择日期。事件标记： 有训练记录的日期下方会自动出现醒目的圆点标记。添加与删除：点击右下角的“+”按钮，即可为选中日期添加新的训练记录。在日志卡片上向左滑动，会优雅地滑出一个“删除”按钮，点击即可删除。数据持久化： 所有日志数据都会被安全地保存在手机本地，App重启后不会丢失。📂 项目结构 (Project Structure)项目采用功能驱动 (Feature-First) 的目录结构，确保了代码的高内聚、低耦合，易于维护和扩展。lib/
├── main.dart                 # App唯一的入口文件

├── app/                      # App全局配置与组件
│   └── widgets/              # 全局可复用的通用组件
│       └── main_scaffold.dart # 包含底部导航栏的主框架

├── features/                 # 核心功能区 (按功能划分)
│   ├── timer/                # “计时器”功能的所有代码
│   │   └── views/            #   - 计时器的主界面
│   │       └── timer_screen.dart
│   │
│   └── calendar_log/         # “日历日志”功能的所有代码
│       └── views/            #   - 日历日志的主界面
│           └── calendar_log_screen.dart
│
└── core/                     # 核心共享区 (被多个功能共同调用)
    └── services/             # 服务层 (处理具体“脏活”)
        └── local_storage_service.dart # 本地存储服务
🚀 如何运行 (Getting Started)克隆仓库git clone https://github.com/你的用户名/my_gym_app.git
cd my_gym_app
安装依赖flutter pub get
运行App确保你已连接一个模拟器或真实设备。在VS Code中按 F5 或在终端中运行：flutter run
🛠️ 技术栈 (Tech Stack)框架: Flutter语言: Dart核心库:table_calendar: 用于构建功能强大的日历视图。flutter_slidable: 实现优雅的“左滑显示操作”列表项。shared_preferences: 用于将数据持久化到本地存储。google_fonts: 轻松使用丰富的Google字体库。intl: 用于国际化和日期格式化。🔮 未来计划 (Future Plans)[ ] 日志自定义： 允许用户自定义训练部位的标签和颜色。[ ] 数据统计： 以图表形式展示训练频率和部位分布。[ ] 云端同步： 引入用户系统，将数据安全地同步到云端。[ ] 主题切换： 支持浅色/深色模式切换。