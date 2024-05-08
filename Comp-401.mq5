//+------------------------------------------------------------------+
//|                                                 MA-Crossover.mq5 |
//|                                Copyright 2024, Harshal Rukhaiyar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Harshal Rukhaiyar"
//inspired by trustfultrading.com
//+------------------------------------------------------------------+
//| Include Variables                                |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Input Variables                                |
//+------------------------------------------------------------------+

input int InpFastPeriod = 18; // fast period
input int InpSlowPeriod = 50; // slow period
input int InpStopLoss = 200;  // stop loss in points
input int INpTakeprofit = 100; // take profit in points
static input double InpLotSize = 1.0; // Lot size
input ENUM_MA_METHOD InpMAMethodFast = MODE_SMMA; //Fast MA choice
input ENUM_MA_METHOD InpMAMethodSlow = MODE_SMMA; //Slow MA choice

//+------------------------------------------------------------------+
//| Global Variables                                |
//+------------------------------------------------------------------+
int fastHandle;
int slowHandle;
double fastBuffer[];
double slowBuffer[];
datetime openTimeBuy = 0;
datetime openTimeSell =0;
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                               |
//+------------------------------------------------------------------+
int OnInit(){
   // check user input
   if(InpFastPeriod <= 0){
      Alert("Fast Period <= 0");
      return INIT_PARAMETERS_INCORRECT ;
   } 
   if(InpSlowPeriod <= 0){
      Alert("Slow Period <= 0");
      return INIT_PARAMETERS_INCORRECT ;
   }
   if(InpFastPeriod >= InpSlowPeriod){
      Alert("Fast Period >= Slow Period");
      return INIT_PARAMETERS_INCORRECT ;
   }
   
   if(InpStopLoss <= 0){
      Alert("Take profit <= 0");
      return INIT_PARAMETERS_INCORRECT ;
   } 
   
   if(INpTakeprofit <= 0){
      Alert("Fast Period <= 0");
      return INIT_PARAMETERS_INCORRECT ;
   } 
   
   // create handles
   fastHandle= iMA(_Symbol,PERIOD_CURRENT,InpFastPeriod,0,InpMAMethodFast,PRICE_CLOSE);
   if(fastHandle == INVALID_HANDLE){
      Alert("Failed to create fast handle");
      return INIT_FAILED;
   }
   slowHandle = iMA(_Symbol,PERIOD_CURRENT,InpSlowPeriod,0,InpMAMethodSlow,PRICE_CLOSE);
   if(slowHandle == INVALID_HANDLE){
      Alert("Failed to create slow handle");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(fastBuffer,true);
   ArraySetAsSeries(slowBuffer,true);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   if(fastHandle != INVALID_HANDLE){IndicatorRelease(fastHandle);}
   if(slowHandle != INVALID_HANDLE){IndicatorRelease(slowHandle);} 
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   int values = CopyBuffer(fastHandle,0,0,2,fastBuffer);
   if(values != 2){
      Print("Not enough data for fast moving average");
      return;
   }
   values = CopyBuffer(slowHandle,0,0,2,slowBuffer);
   if(values != 2){
      Print("Not enough data for slow moving average");
      return;
   }
   
   Comment("fast[0]:",fastBuffer[0],"\n",
           "fast[1]:",fastBuffer[1],"\n",
           "slow[0]:",slowBuffer[0],"\n",
           "slow[1]:",slowBuffer[1],"\n");
   
   // check for cross buy
   if(fastBuffer[1] <= slowBuffer[1] && fastBuffer[0] > slowBuffer[0] && openTimeBuy != iTime(_Symbol,PERIOD_CURRENT,0)){
      
      openTimeBuy = iTime(_Symbol,PERIOD_CURRENT,0);
      double ask  = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double sl   = ask - InpStopLoss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double tp   = ask + INpTakeprofit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,InpLotSize,ask,sl,tp,"Cross EA");
      CheckBreakEvenStop();
      
     
   }
   
   // check for sell buy
   if(fastBuffer[1] >= slowBuffer[1] && fastBuffer[0] < slowBuffer[0] && openTimeSell != iTime(_Symbol,PERIOD_CURRENT,0)){
      
      openTimeSell = iTime(_Symbol,PERIOD_CURRENT,0);
      double bid   = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double sl    = bid + InpStopLoss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double tp    = bid - INpTakeprofit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,InpLotSize,bid,sl,tp,"Cross EA");
      CheckBreakEvenStop();
      
   }
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
void CheckBreakEvenStop()
{
    double breakevenTriggerPips = 10.0; // Profit in pips before we move the stop loss to breakeven
    double extraPips = 1.0; // Extra cushion pips 

    // Check each position for the current symbol
    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0) // Make sure the ticket is valid
        {
            if (PositionSelectByTicket(ticket)) // Select the position to get its details
            {
                double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                double currentProfit = PositionGetDouble(POSITION_PROFIT);
                long positionType = PositionGetInteger(POSITION_TYPE);

                // Determine the current price based on whether it's a buy or sell
                double currentPrice = (positionType == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);

                // Calculate the new stop loss price which includes the extra cushion
                double newStopLossPrice = (positionType == POSITION_TYPE_BUY) ? openPrice + (extraPips * _Point) : openPrice - (extraPips * _Point);

                // Check if the current profit is sufficient to move the stop loss to break-even
                if((positionType == POSITION_TYPE_BUY && currentProfit >= breakevenTriggerPips * _Point) ||
                   (positionType == POSITION_TYPE_SELL && currentProfit >= breakevenTriggerPips * _Point))
                {
                    // Modify the position to set the new stop loss price
                    trade.PositionModify(ticket, newStopLossPrice, PositionGetDouble(POSITION_TP));
                }
            }
        }
    }
}

