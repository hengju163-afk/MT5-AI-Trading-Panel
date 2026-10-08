//+------------------------------------------------------------------+
//| AI_Trade_Engine.mqh                                              |
//| MT5交易引擎 - 处理买卖、平仓、风险管理                              |
//+------------------------------------------------------------------+
#property copyright "AI Trading Panel"
#property version   "1.0"

class CTradeEngine
{
private:
    CTrade m_trade;              // 交易对象
    string m_symbol;             // 交易品种
    double m_lot;                // 手数
    int    m_stop_loss;          // 止损点数
    int    m_take_profit;        // 止盈点数
    double m_max_risk;           // 最大风险比例
    
public:
    CTradeEngine();
    ~CTradeEngine();
    
    // 初始化
    bool Init(string symbol, double lot, int sl, int tp, double max_risk);
    
    // 买入
    bool BuyOrder(double price, string comment="");
    
    // 卖出
    bool SellOrder(double price, string comment="");
    
    // 平所有多单
    bool CloseAllBuy();
    
    // 平所有空单
    bool CloseAllSell();
    
    // 平所有仓位
    bool CloseAll();
    
    // 平部分仓位
    bool ClosePartial(double lot);
    
    // 修改止损
    bool ModifyStopLoss(ulong ticket, double new_sl);
    
    // 修改止盈
    bool ModifyTakeProfit(ulong ticket, double new_tp);
    
    // 获取当前持仓信息
    double GetBuyVolume();
    double GetSellVolume();
    double GetTotalVolume();
    double GetBuyPrice();
    double GetSellPrice();
    double GetFloatingProfit();
    
    // 获取账户信息
    double GetBalance();
    double GetEquity();
    double GetMarginUsed();
    double GetMarginFree();
    double GetMarginLevel();
    
    // 风控检查
    bool CheckRisk(double entry_price, double sl_price);
    
private:
    // 计算风险金额
    double CalculateRisk(double entry_price, double sl_price, double lot);
};

//+------------------------------------------------------------------+
//| 构造函数                                                          |
//+------------------------------------------------------------------+
CTradeEngine::CTradeEngine()
{
    m_symbol = NULL;
    m_lot = 0.1;
    m_stop_loss = 50;
    m_take_profit = 100;
    m_max_risk = 0.02;  // 2%
}

CTradeEngine::~CTradeEngine()
{
}

//+------------------------------------------------------------------+
//| 初始化                                                            |
//+------------------------------------------------------------------+
bool CTradeEngine::Init(string symbol, double lot, int sl, int tp, double max_risk)
{
    m_symbol = symbol;
    m_lot = lot;
    m_stop_loss = sl;
    m_take_profit = tp;
    m_max_risk = max_risk;
    
    // 设置交易魔术数字、偏差等参数
    m_trade.SetExpertMagicNumber(123456);
    m_trade.SetMarginMode();
    m_trade.LogLevel(0);
    
    return true;
}

//+------------------------------------------------------------------+
//| 买入                                                              |
//+------------------------------------------------------------------+
bool CTradeEngine::BuyOrder(double price, string comment="")
{
    if(!CheckRisk(price, price - m_stop_loss * Point()))
        return false;
    
    double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
    double sl = ask - m_stop_loss * Point();
    double tp = ask + m_take_profit * Point();
    
    if(m_trade.Buy(m_lot, m_symbol, ask, sl, tp, comment))
    {
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| 卖出                                                              |
//+------------------------------------------------------------------+
bool CTradeEngine::SellOrder(double price, string comment="")
{
    if(!CheckRisk(price, price + m_stop_loss * Point()))
        return false;
    
    double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
    double sl = bid + m_stop_loss * Point();
    double tp = bid - m_take_profit * Point();
    
    if(m_trade.Sell(m_lot, m_symbol, bid, sl, tp, comment))
    {
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| 平所有多单                                                        |
//+------------------------------------------------------------------+
bool CTradeEngine::CloseAllBuy()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY)
            continue;
        
        m_trade.PositionClose(PositionGetTicket());
    }
    return true;
}

//+------------------------------------------------------------------+
//| 平所有空单                                                        |
//+------------------------------------------------------------------+
bool CTradeEngine::CloseAllSell()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        if(PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL)
            continue;
        
        m_trade.PositionClose(PositionGetTicket());
    }
    return true;
}

//+------------------------------------------------------------------+
//| 平所有仓位                                                        |
//+------------------------------------------------------------------+
bool CTradeEngine::CloseAll()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        m_trade.PositionClose(PositionGetTicket());
    }
    return true;
}

//+------------------------------------------------------------------+
//| 平部分仓位                                                        |
//+------------------------------------------------------------------+
bool CTradeEngine::ClosePartial(double lot)
{
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        double volume = PositionGetDouble(POSITION_VOLUME);
        if(volume >= lot)
        {
            m_trade.PositionClosePartial(PositionGetTicket(), lot);
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| 修改止损                                                          |
//+------------------------------------------------------------------+
bool CTradeEngine::ModifyStopLoss(ulong ticket, double new_sl)
{
    if(!PositionSelect(ticket))
        return false;
    
    double tp = PositionGetDouble(POSITION_TP);
    return m_trade.PositionModify(ticket, new_sl, tp);
}

//+------------------------------------------------------------------+
//| 修改止盈                                                          |
//+------------------------------------------------------------------+
bool CTradeEngine::ModifyTakeProfit(ulong ticket, double new_tp)
{
    if(!PositionSelect(ticket))
        return false;
    
    double sl = PositionGetDouble(POSITION_SL);
    return m_trade.PositionModify(ticket, sl, new_tp);
}

//+------------------------------------------------------------------+
//| 获取买入总量                                                      |
//+------------------------------------------------------------------+
double CTradeEngine::GetBuyVolume()
{
    double volume = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            volume += PositionGetDouble(POSITION_VOLUME);
    }
    return volume;
}

//+------------------------------------------------------------------+
//| 获取卖出总量                                                      |
//+------------------------------------------------------------------+
double CTradeEngine::GetSellVolume()
{
    double volume = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            volume += PositionGetDouble(POSITION_VOLUME);
    }
    return volume;
}

//+------------------------------------------------------------------+
//| 获取总持仓量                                                      |
//+------------------------------------------------------------------+
double CTradeEngine::GetTotalVolume()
{
    return GetBuyVolume() + GetSellVolume();
}

//+------------------------------------------------------------------+
//| 获取买入平均价格                                                  |
//+------------------------------------------------------------------+
double CTradeEngine::GetBuyPrice()
{
    double total_volume = 0;
    double total_price = 0;
    
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            double volume = PositionGetDouble(POSITION_VOLUME);
            double price = PositionGetDouble(POSITION_PRICE_OPEN);
            total_price += volume * price;
            total_volume += volume;
        }
    }
    
    if(total_volume == 0)
        return 0;
    
    return total_price / total_volume;
}

//+------------------------------------------------------------------+
//| 获取卖出平均价格                                                  |
//+------------------------------------------------------------------+
double CTradeEngine::GetSellPrice()
{
    double total_volume = 0;
    double total_price = 0;
    
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            double volume = PositionGetDouble(POSITION_VOLUME);
            double price = PositionGetDouble(POSITION_PRICE_OPEN);
            total_price += volume * price;
            total_volume += volume;
        }
    }
    
    if(total_volume == 0)
        return 0;
    
    return total_price / total_volume;
}

//+------------------------------------------------------------------+
//| 获取浮动盈亏                                                      |
//+------------------------------------------------------------------+
double CTradeEngine::GetFloatingProfit()
{
    double profit = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(!PositionSelect(i))
            continue;
        
        if(PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;
        
        profit += PositionGetDouble(POSITION_PROFIT);
    }
    return profit;
}

//+------------------------------------------------------------------+
//| 获取账户余额                                                      |
//+------------------------------------------------------------------+
double CTradeEngine::GetBalance()
{
    return AccountInfoDouble(ACCOUNT_BALANCE);
}

//+------------------------------------------------------------------+
//| 获取账户净值                                                      |
//+------------------------------------------------------------------+
double CTradeEngine::GetEquity()
{
    return AccountInfoDouble(ACCOUNT_EQUITY);
}

//+------------------------------------------------------------------+
//| 获取已用保证金                                                    |
//+------------------------------------------------------------------+
double CTradeEngine::GetMarginUsed()
{
    return AccountInfoDouble(ACCOUNT_MARGIN);
}

//+------------------------------------------------------------------+
//| 获���可用保证金                                                    |
//+------------------------------------------------------------------+
double CTradeEngine::GetMarginFree()
{
    return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
}

//+------------------------------------------------------------------+
//| 获取保证金水平                                                    |
//+------------------------------------------------------------------+
double CTradeEngine::GetMarginLevel()
{
    return AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
}

//+------------------------------------------------------------------+
//| 计算风险金额                                                      |
//+------------------------------------------------------------------+
double CTradeEngine::CalculateRisk(double entry_price, double sl_price, double lot)
{
    double risk_per_pip = lot * SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
    double pips = MathAbs(entry_price - sl_price) / Point();
    return risk_per_pip * pips;
}

//+------------------------------------------------------------------+
//| 风控检查                                                          |
//+------------------------------------------------------------------+
bool CTradeEngine::CheckRisk(double entry_price, double sl_price)
{
    double account_balance = GetBalance();
    double max_risk_amount = account_balance * m_max_risk;
    double risk_amount = CalculateRisk(entry_price, sl_price, m_lot);
    
    if(risk_amount > max_risk_amount)
    {
        Print("Risk too high. Risk: ", risk_amount, " Max allowed: ", max_risk_amount);
        return false;
    }
    
    return true;
}
