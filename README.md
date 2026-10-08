# MT5 AI智能决策交易面板

## 项目简介
MT5平台上的AI智能决策面板系统，集成多时间框架分析、实时数据抓取、自动信号生成和一键交易执行功能。

## 核心功能
- ✅ 实时数据抓取：直接从MT5获取Tick、K线、账户信息、持仓数据
- ✅ 多时间框架分析：M1、M5、M15、M30、H1、H4、D1
- ✅ AI决策引擎：基于趋势、动量、波动、结构四大因子
- ✅ 智能交易面板：买卖下单、平仓、风险管理
- ✅ 胜率统计：实时显示信号成功率、盈亏统计
- ✅ 风控系统：止损、单笔风险控制、最大回撤管理

## 项目结构
```
MT5-AI-Trading-Panel/
├── Experts/
│   └── AI_Trade_Decision.mq5          # 主EA程序（面板入口）
├── Include/
│   ├── AI_Trade_Engine.mqh            # 交易引擎
│   ├── AI_UI_Engine.mqh               # UI界面引擎
│   ├── AI_Strategy_Logic.mqh          # 策略决策逻辑
│   ├── AI_Signal_Stats.mqh            # 信号统计模块
│   └── AI_Risk_Management.mqh         # 风控管理模块
├── Scripts/
│   └── setup.py                       # 配置脚本
└── README.md
```

## 快速开始
1. 将Experts文件夹中的AI_Trade_Decision.mq5拷贝到MT5的Experts目录
2. 将Include文件夹中的所有.mqh文件拷贝到MT5的Include目录
3. 在MetaEditor中编译AI_Trade_Decision.mq5
4. 在MT5图表上拖拽EA运行

## 配置说明
在EA参数中设置：
- InpSymbol: 交易品种（如EURUSD）
- InpLotSize: 固定手数
- InpStopLoss: 止损点数
- InpTakeProfit: 止盈点数
- InpMaxRisk: 单笔最大风险比例
- InpEnableAutoTrade: 是否启用自动交易

## AI决策逻辑
综合评分 = 趋势权重(35%) + 动量权重(30%) + 波动权重(15%) + 结构权重(20%)

**决策输出：**
- > 70: 强多信号 🟢
- 50-70: 看多信号 🟢
- 40-50: 中性观望 ⚪
- 30-40: 看空信号 🔴
- < 30: 强空信号 🔴

## 技术指标
- 趋势: 移动平均线(MA20, MA50)
- 动量: RSI、MACD、Stochastic
- 波动: ATR、Bollinger Bands
- 结构: 支撑压力、高低点、K线形态

## 风险提示
- ⚠️ 本系统仅供学习研究使用
- ⚠️ 过去表现不代表未来收益
- ⚠️ 请在模拟账户充分测试后再用真实账户
- ⚠️ 设置合理的止损和风险比例
- ⚠️ 不建议过度杠杆交易

## 更新日志
- v1.0: 2026-10-08 项目初始化，完成核心框架搭建

## 许可证
MIT License

## 联系方式
如有问题或建议，欢迎提Issue或联系开发者。
