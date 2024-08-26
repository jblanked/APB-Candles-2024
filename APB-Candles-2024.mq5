//+------------------------------------------------------------------+
//|                                             APB-Candles-2024.mq5 |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#property version   "1.00"
#property indicator_chart_window

#include <jb-indicator.mqh>
#include <APB-Candles-2024.mqh>

#ifdef __MQL5__
#property indicator_buffers 5
#property indicator_plots 5
#property indicator_color1 clrMagenta, clrLime
#else
#property indicator_buffers 4
#property indicator_color1 clrMagenta
#property indicator_color2 clrLime
#property indicator_color3 clrLime
#property indicator_color4 clrMagenta
#endif

//--- indicator buffers
double BufferOpen[];
double BufferHigh[];
double BufferLow[];
double BufferClose[];
double BufferColor[];

CIndicator indi;
CAPBCandles *apb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
#ifdef __MQL5__
//--- indicator buffer mapping
   if(!indi.createBuffer("APB Candles", DRAW_COLOR_CANDLES, STYLE_SOLID, indicator_color1, 2, 0, BufferOpen, true, INDICATOR_DATA))
     {
      return INIT_FAILED;
     }

   if(!indi.createBuffer("High", DRAW_NONE, STYLE_SOLID, indicator_color1, 2, 1, BufferHigh, true, INDICATOR_DATA))
     {
      return INIT_FAILED;
     }

   if(!indi.createBuffer("Low", DRAW_NONE, STYLE_SOLID, indicator_color1, 2, 2, BufferLow, true, INDICATOR_DATA))
     {
      return INIT_FAILED;
     }

   if(!indi.createBuffer("Close", DRAW_NONE, STYLE_SOLID, indicator_color1, 2, 3, BufferClose, true, INDICATOR_DATA))
     {
      return INIT_FAILED;
     }

   if(!indi.createBuffer("Color", DRAW_NONE, STYLE_SOLID, indicator_color1, 2, 4, BufferColor, true, INDICATOR_COLOR_INDEX))
     {
      return INIT_FAILED;
     }

#else

   if(!indi.createBuffer("High", DRAW_HISTOGRAM, STYLE_SOLID, indicator_color1, 1, 0, BufferHigh, true, INDICATOR_DATA)) // top wick of bearish candles
     {
      return INIT_FAILED;
     }

   if(!indi.createBuffer("Low", DRAW_HISTOGRAM, STYLE_SOLID, indicator_color2, 1, 1, BufferLow, true, INDICATOR_DATA)) // top wick of bullish candles
     {
      return INIT_FAILED;
     }

   if(!indi.createBuffer("Open", DRAW_HISTOGRAM, STYLE_SOLID, indicator_color3, 3, 2, BufferOpen, true, INDICATOR_DATA)) // body of bullish candle
     {
      return INIT_FAILED;
     }

   if(!indi.createBuffer("Close", DRAW_HISTOGRAM, STYLE_SOLID, indicator_color4, 3, 3, BufferClose, true, INDICATOR_DATA)) // body of bearish candles
     {
      return INIT_FAILED;
     }

#endif
//--- set chart defaults
   ChartSetInteger(0, CHART_SHOW_VOLUMES, false);         // get rid of volume
   ChartSetInteger(0, CHART_MODE, CHART_LINE);            // make it a line chart
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrNONE);   // set color as none
//---
   apb = new CAPBCandles(_Symbol, PERIOD_CURRENT, Bars(_Symbol, PERIOD_CURRENT));
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   apb.run(rates_total);

   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;

   for(int i = start; i < rates_total; i++)
     {

      if(i < 0 || i >= ArraySize(apb.BufferClose))
        {
         continue;
        }

      BufferClose[i] = apb.BufferClose[i];
      BufferOpen[i] = apb.BufferOpen[i];
      BufferHigh[i] = apb.BufferHigh[i];
      BufferLow[i] = apb.BufferLow[i];
      BufferColor[i] = apb.BufferColor[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   indi.deletePointer(apb);
  }
//+------------------------------------------------------------------+
