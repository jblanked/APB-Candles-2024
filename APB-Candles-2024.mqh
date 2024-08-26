//+------------------------------------------------------------------+
//|                                             ABP-Candles-2024.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAPBCandles
  {

public:
                     CAPBCandles::CAPBCandles(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe,
      const int maximumBars = 5000
   )
     {
      this.m_symbol     = symbol;
      this.m_timeframe  = timeframe;
      this.maxCandles   = maximumBars;
      this.isSetAsSeries = false;
     }

                     CAPBCandles::CAPBCandles()
     {
      this.m_symbol     = _Symbol;
      this.m_timeframe  = ChartPeriod();
      this.maxCandles   = Bars(this.m_symbol, this.m_timeframe);
      this.isSetAsSeries = false;
     }

   void              run(int maximumBars)
     {

      if(!this.isSetAsSeries)
        {
         this.setAsSeries();
        }

#ifdef __MQL5__

      ::ArraySetAsSeries(rates, false);
      int copied =::CopyRates(this.m_symbol, this.m_timeframe, 0, maximumBars + 1, rates);
      if(!copied)
        {
         Print("Failed to get history data for the symbol ", this.m_symbol);
         return;
        }


      for(int i = 0; i < maximumBars; i++)
        {

         if(i >= ArraySize(BufferOpen) || i < 0)
           {
            continue;
           }

         APBClose = NormalizeDouble((this.rates[i].open + this.rates[i].high + this.rates[i].low + this.rates[i].close) / 4.0, (int)SymbolInfoInteger(this.m_symbol, SYMBOL_DIGITS));
         APBClose = (APBClose + this.rates[i].close) / 2.0;
         APBOpen  = i == 0 ? this.rates[i].open : (BufferOpen[i - 1] + BufferClose[i - 1]) / 2.0;
         APBHigh  = MathMax(this.rates[i].high, MathMax(APBOpen, APBClose));
         APBLow   = MathMin(this.rates[i].low, MathMin(APBOpen, APBClose));

         BufferHigh[i]  = APBHigh;
         BufferLow[i]   = APBLow;

         BufferOpen[i]  = APBOpen;
         BufferClose[i] = APBClose;

         if(APBOpen < APBClose)
           {
            BufferColor[i] = 1;  // Lime
           }
         else
           {
            BufferColor[i] = 0;  // Magenta
           }
#else
      ::ArraySetAsSeries(rates, true);
      ::CopyRates(this.m_symbol, this.m_timeframe, 0, maximumBars + 1, rates);

      for(int i = maximumBars - 1; i >= 0; i--)
        {

         if(i >= ArraySize(BufferOpen) || i < 0)
           {
            continue;
           }

         APBClose = NormalizeDouble((this.rates[i].open + this.rates[i].high + this.rates[i].low + this.rates[i].close) / 4.0, (int)SymbolInfoInteger(this.m_symbol, SYMBOL_DIGITS));
         APBClose = (APBClose + this.rates[i].close) / 2.0;
         APBOpen = i == 0 ? this.rates[i].open : (BufferOpen[i + 1] + (BufferClose[i + 1])) / 2.0;
         APBHigh = MathMax(this.rates[i].high, MathMax(APBOpen, APBClose));
         APBLow = MathMin(this.rates[i].low, MathMin(APBOpen, APBClose));

         BufferHigh[i]  = APBHigh;
         BufferLow[i]   = APBLow;

         BufferOpen[i]  = APBClose;
         BufferClose[i] = APBOpen;

         if(APBOpen < APBClose)
           {
            BufferLow[i]
               = APBHigh;
            BufferHigh[i] = APBLow;
           }
         else
           {
            BufferLow[i] = APBLow;
            BufferHigh[i] = APBHigh;
           }
#endif
        }
     }

   //--- indicator buffers
   double            BufferOpen[];
   double            BufferHigh[];
   double            BufferLow[];
   double            BufferClose[];
   double            BufferColor[];

private:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;

   MqlRates          rates[];
   int               maxCandles;
   bool              isSetAsSeries;

   double            APBOpen, APBHigh, APBLow, APBClose;

   void              setAsSeries(void)
     {

      ArrayInitialize(BufferOpen, EMPTY_VALUE);
      ArrayInitialize(BufferHigh, EMPTY_VALUE);
      ArrayInitialize(BufferLow, EMPTY_VALUE);
      ArrayInitialize(BufferClose, EMPTY_VALUE);
      ArrayInitialize(BufferColor, EMPTY_VALUE);

      ArraySetAsSeries(BufferOpen, true);
      ArraySetAsSeries(BufferHigh, true);
      ArraySetAsSeries(BufferLow, true);
      ArraySetAsSeries(BufferClose, true);
      ArraySetAsSeries(BufferColor, true);

      ArrayResize(BufferOpen, this.maxCandles + 3);
      ArrayResize(BufferHigh, this.maxCandles + 3);
      ArrayResize(BufferLow, this.maxCandles + 3);
      ArrayResize(BufferClose, this.maxCandles + 3);
      ArrayResize(BufferColor, this.maxCandles + 3);

      this.isSetAsSeries = true;
     }
  };
//+------------------------------------------------------------------+
