//
// High Low Lines.mq4
//
// Shows high and low prices of yesterday, this week, and last week.
//
#property copyright "Copyright (c) 2020 fxsharp"
#property link      "https://github.com/fxsharp/metatrader"

#property indicator_chart_window
#property indicator_buffers 0

class CHighLowLines {
public:
   static void Add(string name, int period, int shift, int style) {
      int index = ArraySize(high_low_lines);
      ArrayResize(high_low_lines, index + 1);
      high_low_lines[index].Init(name, period, shift, style);
   }

   void Init(string name, int period, int shift, int style) {
      name_ = name;
      period_ = period;
      shift_ = shift;
      style_ = style;
      Delete();
   }

   static void TickAll() {
      for (int i = 0; i < ArraySize(high_low_lines); i++)
         high_low_lines[i].Tick();
   }

   void Tick() {
      Update(name_ + " High", iHigh(NULL, period_, shift_));
      Update(name_ + " Low", iLow(NULL, period_, shift_));
   }

   void Update(string name, double price) {
      long chart = 0;
      if (ObjectSetDouble(chart, name, OBJPROP_PRICE, price))
         return;
      ObjectCreate(chart, name, OBJ_HLINE, 0, 0, price);
      ObjectSetInteger(chart, name, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(chart, name, OBJPROP_STYLE, style_);
   }

   ~CHighLowLines() {
      Delete();
   }

   static void DeleteAll() {
      for (int i = 0; i < ArraySize(high_low_lines); i++)
         high_low_lines[i].Delete();
   }

   void Delete() {
      ObjectDelete(name_ + " High");
      ObjectDelete(name_ + " Low");
   }

private:
   string name_;
   int period_;
   int shift_;
   int style_;
};

CHighLowLines high_low_lines[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   CHighLowLines::Add("Yesterday's", PERIOD_D1, 1, STYLE_DASH);
   CHighLowLines::Add("This week's", PERIOD_W1, 0, STYLE_DASHDOT);
   CHighLowLines::Add("Last Week's", PERIOD_W1, 1, STYLE_DOT);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   CHighLowLines::DeleteAll();
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

