//
// High Low Lines.mq4
//
// Shows high and low prices of yesterday, this week, and last week.
//
#property copyright "Copyright (c) 2020 fxsharp"
#property link      "https://github.com/fxsharp/metatrader"

int ArrowHigh = 115;
int ArrowLow = ArrowHigh;
int LastArrowHigh = ArrowHigh;
int LastArrowLow = LastArrowHigh;

#property indicator_chart_window
#property indicator_buffers 12

#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_color6 Lime
#property indicator_color7 Red
#property indicator_color8 Lime
#property indicator_color9 Red
#property indicator_color10 Lime
#property indicator_color11 Red
#property indicator_color12 Lime
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1
#property indicator_width9 1
#property indicator_width10 1
#property indicator_width11 1
#property indicator_width12 1

int min(int v1, int v2) { return v1 < v2 ? v1 : v2; }

class CHighLowLines {
public:
   static void Add(int index, string name, int period, int shift, int arrow_high, int arrow_low) {
      high_low_lines[index].Init(index * 2, name, period, shift, arrow_high, arrow_low);
   }

   void Init(int index, string name, int period, int shift, int arrow_high, int arrow_low) {
      period_ = period;
      shift_ = shift;
      SetIndexBuffer(index, HighBuffer);
      SetIndexBuffer(index + 1, LowBuffer);
      SetIndexLabel(index, name + " High");
      SetIndexLabel(index + 1, name + " Low");
      SetIndexStyle(index, DRAW_ARROW);
      SetIndexStyle(index + 1, DRAW_ARROW);
      SetIndexArrow(index, arrow_high);
      SetIndexArrow(index + 1, arrow_low);
   }

   bool IsInitialized() const { return period_ > 0; }

   static void TickAll() {
      for (int i = 0; i < ArraySize(high_low_lines); i++)
         high_low_lines[i].Tick();
   }

   void Tick() {
      if (!IsInitialized())
         return;
      int counted_bars = IndicatorCounted();
      int ibar = Bars - counted_bars;
      for (--ibar; ibar >= 0; ) {
         datetime time = Time[ibar];
         int ibar_in_period = iBarShift(NULL, period_, time);
         double high = iHigh(NULL, period_, ibar_in_period + shift_);
         double low = iLow(NULL, period_, ibar_in_period + shift_);

         datetime time_min = iTime(NULL, period_, ibar_in_period);
         int ibar_lim = iBarShift(NULL, 0, time_min);
         if (ibar_in_period > 0) {
            datetime time_lim = iTime(NULL, period_, ibar_in_period - 1);
            int ibar_min = iBarShift(NULL, 0, time_lim);
         } else {
            ibar_min = 0;
         }
         for (int i = ibar_min; i < ibar_lim; ++i) {
            HighBuffer[i] = high;
            LowBuffer[i] = low;
         }
         ibar = min(ibar_min - 1, ibar - 1);
      }
   }

private:
   double HighBuffer[];
   double LowBuffer[];
   int period_;
   int shift_;
};

CHighLowLines high_low_lines[12];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   int period = Period();
   if (period < PERIOD_D1) {
      CHighLowLines::Add(0, "Today's", PERIOD_D1, 0, ArrowHigh, ArrowLow);
      CHighLowLines::Add(1, "Yesterday's", PERIOD_D1, 1, LastArrowHigh, LastArrowLow);
   }
   if (period < PERIOD_W1) {
      CHighLowLines::Add(2, "This week's", PERIOD_W1, 0, ArrowHigh, ArrowLow);
      CHighLowLines::Add(3, "Last Week's", PERIOD_W1, 1, LastArrowHigh, LastArrowLow);
   }
   CHighLowLines::Add(4, "This month's", PERIOD_MN1, 0, ArrowHigh, ArrowLow);
   CHighLowLines::Add(5, "Last month's", PERIOD_MN1, 1, LastArrowHigh, LastArrowLow);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   CHighLowLines::TickAll();
   return(0);
}
//+------------------------------------------------------------------+

