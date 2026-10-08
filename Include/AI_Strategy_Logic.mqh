//+------------------------------------------------------------------+
//| AI_Strategy_Logic.mqh                                            |
//| AI决策策略逻辑 - 多时间框架综合分析                                |
//+------------------------------------------------------------------+
#property copyright "AI Trading Panel"
#property version   "1.0"

class CStrategyLogic
{
private:
    string m_symbol;             // 交易品种
    
public:
    CStrategyLogic();
    ~CStrategyLogic();
    
    // 初始化
    bool Init(string symbol);
    
    // 多时间框架分析
    struct TimeframeSignal {
        ENUM_TIMEFRAMES timeframe;
        int trend_score;          // 趋势分数 0-100
        int momentum_score;       // 动量分数 0-100
        string signal;            // 信号: BUY, SELL, NEUTRAL
    };
    
    // 获取趋势分数 (0-100)
    int GetTrendScore(ENUM_TIMEFRAMES tf);
    
    // 获取动量分数 (0-100)
    int GetMomentumScore(ENUM_TIMEFRAMES tf);
    
    // 获取波动分数 (0-100)
    int GetVolatilityScore(ENUM_TIMEFRAMES tf);
    
    // 获取结构分数 (0-100)
    int GetStructureScore(ENUM_TIMEFRAMES tf);
    
    // 综合AI决策分数 (0-100)
    int GetAIDecisionScore(ENUM_TIMEFRAMES tf);
    
    // 获取所有时间框架的信号
    string GetMultiTimeframeSignal(int &scores[]);
    
    // 获取信号描述
    string GetSignalDescription(int score);
    
    // 获取多时间框架共振强度
    int GetMultiTimeframeConsensus();
    
private:
    // MA趋势判断
    int AnalyzeMATrend(ENUM_TIMEFRAMES tf);
    
    // RSI判断
    int AnalyzeRSI(ENUM_TIMEFRAMES tf);
    
    // MACD判断
    int AnalyzeMACD(ENUM_TIMEFRAMES tf);
    
    // Stochastic判断
    int AnalyzeStochastic(ENUM_TIMEFRAMES tf);
    
    // ATR波动判断
    int AnalyzeATR(ENUM_TIMEFRAMES tf);
    
    // K线形态判断
    int AnalyzeCandlePattern(ENUM_TIMEFRAMES tf);
};

//+------------------------------------------------------------------+
//| 构造函数                                                          |
//+------------------------------------------------------------------+
CStrategyLogic::CStrategyLogic()
{
    m_symbol = NULL;
}

CStrategyLogic::~CStrategyLogic()
{
}

//+------------------------------------------------------------------+
//| 初始化                                                            |
//+------------------------------------------------------------------+
bool CStrategyLogic::Init(string symbol)
{
    m_symbol = symbol;
    return true;
}

//+------------------------------------------------------------------+
//| MA趋势判断 (0-100)                                                |
//+------------------------------------------------------------------+
int CStrategyLogic::AnalyzeMATrend(ENUM_TIMEFRAMES tf)
{
    // 获取移动平均线数据
    double ma20 = iMA(m_symbol, tf, 20, 0, MODE_SMA, PRICE_CLOSE);
    double ma50 = iMA(m_symbol, tf, 50, 0, MODE_SMA, PRICE_CLOSE);
    double close = iClose(m_symbol, tf, 0);
    
    int score = 50;  // 基础分数
    
    // 金叉 - 看多
    if(ma20 > ma50)
    {
        if(close > ma20)
            score = 80;  // 强多
        else
            score = 65;  // 中性偏多
    }
    // 死叉 - 看空
    else if(ma20 < ma50)
    {
        if(close < ma20)
            score = 20;  // 强空
        else
            score = 35;  // 中性偏空
    }
    
    return score;
}

//+------------------------------------------------------------------+
//| RSI判断 (0-100)                                                   |
//+------------------------------------------------------------------+
int CStrategyLogic::AnalyzeRSI(ENUM_TIMEFRAMES tf)
{
    double rsi = iRSI(m_symbol, tf, 14, PRICE_CLOSE);
    
    int score = 50;
    
    if(rsi > 70)
        score = 75;      // 超买 - 看多强
    else if(rsi > 60)
        score = 65;      // 看多
    else if(rsi > 50)
        score = 55;      // 轻微看多
    else if(rsi > 40)
        score = 45;      // 轻微看空
    else if(rsi > 30)
        score = 35;      // 看空
    else
        score = 25;      // 超卖 - 看空强
    
    return score;
}

//+------------------------------------------------------------------+
//| MACD判断 (0-100)                                                  |
//+------------------------------------------------------------------+
int CStrategyLogic::AnalyzeMACD(ENUM_TIMEFRAMES tf)
{
    double macd = iMACD(m_symbol, tf, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
    double macd_signal = iMACD(m_symbol, tf, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
    double macd_histogram = iMACD(m_symbol, tf, 12, 26, 9, PRICE_CLOSE, MODE_HISTOGRAM, 0);
    
    int score = 50;
    
    // MACD在信号线上方 - 看多
    if(macd > macd_signal)
    {
        if(macd_histogram > 0)
            score = 70;  // 强多
        else
            score = 55;  // 看多
    }
    // MACD在信号线下方 - 看空
    else
    {
        if(macd_histogram < 0)
            score = 30;  // 强空
        else
            score = 45;  // 看空
    }
    
    return score;
}

//+------------------------------------------------------------------+
//| Stochastic判断 (0-100)                                            |
//+------------------------------------------------------------------+
int CStrategyLogic::AnalyzeStochastic(ENUM_TIMEFRAMES tf)
{
    double k = iStochastic(m_symbol, tf, 14, 3, 3, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 0);
    double d = iStochastic(m_symbol, tf, 14, 3, 3, MODE_SMA, STO_LOWHIGH, MODE_SIGNAL, 0);
    
    int score = 50;
    
    if(k > 80)
        score = 70;      // 超买
    else if(k > 60)
        score = 60;      // 看多
    else if(k > 40)
        score = 50;      // 中性
    else if(k > 20)
        score = 40;      // 看空
    else
        score = 30;      // 超卖
    
    return score;
}

//+------------------------------------------------------------------+
//| ATR波动判断 (0-100)                                               |
//+------------------------------------------------------------------+
int CStrategyLogic::AnalyzeATR(ENUM_TIMEFRAMES tf)
{
    double atr = iATR(m_symbol, tf, 14);
    double atr_avg = iATR(m_symbol, tf, 14) / iClose(m_symbol, tf, 0);
    
    // 波动越大，分数越高（表示机会越大）
    int score = 50;
    
    if(atr_avg > 0.02)  // 波动大于2%
        score = 70;
    else if(atr_avg > 0.015)
        score = 60;
    else if(atr_avg > 0.01)
        score = 50;
    else if(atr_avg > 0.005)
        score = 40;
    else
        score = 30;
    
    return score;
}

//+------------------------------------------------------------------+
//| K线形态判断 (0-100)                                               |
//+------------------------------------------------------------------+
int CStrategyLogic::AnalyzeCandlePattern(ENUM_TIMEFRAMES tf)
{
    double open = iOpen(m_symbol, tf, 0);
    double close = iClose(m_symbol, tf, 0);
    double high = iHigh(m_symbol, tf, 0);
    double low = iLow(m_symbol, tf, 0);
    double prev_close = iClose(m_symbol, tf, 1);
    
    int score = 50;
    double body = MathAbs(close - open);
    double range = high - low;
    
    // 大阳线 - 看多
    if(close > open && body > range * 0.7)
        score = 70;
    // 大阴线 - 看空
    else if(close < open && body > range * 0.7)
        score = 30;
    // 锤子线 - 看多
    else if(low < open && close > open && (high - close) < body * 0.3)
        score = 65;
    // 上吊线 - 看空
    else if(high > open && close < open && (close - low) < body * 0.3)
        score = 35;
    // 十字星 - 中性
    else if(body < range * 0.1)
        score = 50;
    
    return score;
}

//+------------------------------------------------------------------+
//| 获取趋势分数                                                      |
//+------------------------------------------------------------------+
int CStrategyLogic::GetTrendScore(ENUM_TIMEFRAMES tf)
{
    return AnalyzeMATrend(tf);
}

//+------------------------------------------------------------------+
//| 获取动量分数                                                      |
//+------------------------------------------------------------------+
int CStrategyLogic::GetMomentumScore(ENUM_TIMEFRAMES tf)
{
    int rsi_score = AnalyzeRSI(tf);
    int macd_score = AnalyzeMACD(tf);
    int stoch_score = AnalyzeStochastic(tf);
    
    // 权重: RSI 40% + MACD 35% + Stochastic 25%
    return (int)(rsi_score * 0.40 + macd_score * 0.35 + stoch_score * 0.25);
}

//+------------------------------------------------------------------+
//| 获取波动分数                                                      |
//+------------------------------------------------------------------+
int CStrategyLogic::GetVolatilityScore(ENUM_TIMEFRAMES tf)
{
    return AnalyzeATR(tf);
}

//+------------------------------------------------------------------+
//| 获取结构分数                                                      |
//+------------------------------------------------------------------+
int CStrategyLogic::GetStructureScore(ENUM_TIMEFRAMES tf)
{
    return AnalyzeCandlePattern(tf);
}

//+------------------------------------------------------------------+
//| AI综合决策分数 (权重组合)                                         |
//+------------------------------------------------------------------+
int CStrategyLogic::GetAIDecisionScore(ENUM_TIMEFRAMES tf)
{
    int trend_score = GetTrendScore(tf);       // 趋势 35%
    int momentum_score = GetMomentumScore(tf); // 动量 30%
    int volatility_score = GetVolatilityScore(tf); // 波动 15%
    int structure_score = GetStructureScore(tf);   // 结构 20%
    
    int total_score = (int)(trend_score * 0.35 + 
                           momentum_score * 0.30 + 
                           volatility_score * 0.15 + 
                           structure_score * 0.20);
    
    return MathMin(100, MathMax(0, total_score));
}

//+------------------------------------------------------------------+
//| 获取信号描述                                                      |
//+------------------------------------------------------------------+
string CStrategyLogic::GetSignalDescription(int score)
{
    if(score > 70)
        return "🟢 强多信号";
    else if(score > 50)
        return "🟢 看多信号";
    else if(score > 40)
        return "⚪ 中性观望";
    else if(score > 20)
        return "🔴 看空信号";
    else
        return "🔴 强空信号";
}

//+------------------------------------------------------------------+
//| 获取多时间框架信号                                                |
//+------------------------------------------------------------------+
string CStrategyLogic::GetMultiTimeframeSignal(int &scores[])
{
    ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, 
                                    PERIOD_M30, PERIOD_H1, PERIOD_H4, 
                                    PERIOD_D1};
    
    int size = ArraySize(timeframes);
    ArrayResize(scores, size);
    
    for(int i = 0; i < size; i++)
    {
        scores[i] = GetAIDecisionScore(timeframes[i]);
    }
    
    return "AI Decision Scores Updated";
}

//+------------------------------------------------------------------+
//| 多时间框架共振强度 (0-100)                                         |
//+------------------------------------------------------------------+
int CStrategyLogic::GetMultiTimeframeConsensus()
{
    ENUM_TIMEFRAMES timeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, 
                                    PERIOD_M30, PERIOD_H1, PERIOD_H4, 
                                    PERIOD_D1};
    
    int size = ArraySize(timeframes);
    int buy_count = 0, sell_count = 0;
    double avg_score = 0;
    
    for(int i = 0; i < size; i++)
    {
        int score = GetAIDecisionScore(timeframes[i]);
        avg_score += score;
        
        if(score > 55)
            buy_count++;
        else if(score < 45)
            sell_count++;
    }
    
    avg_score = avg_score / size;
    
    // 共振强度 = 同向的时间框架数量 / 总时间框架数 * 100
    int consensus = MathMax(buy_count, sell_count) * 100 / size;
    
    return consensus;
}
