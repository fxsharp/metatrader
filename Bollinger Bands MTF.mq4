//
// Bollinger Bands MTF.mq4
//
// Bollinger Bands with multiple timeframe.
//
#property copyright "Copyright (c) 2020 fxsharp"
#property link      "https://github.com/fxsharp/metatrader"

extern int MAPeriod = 21;
extern string TimeFrame = "0,60,240,1440,10080,43200";
extern int ATR = 0;
extern bool Fibonacci = false;
extern double AlertRatio = 0;

#property indicator_chart_window
#property indicator_buffers 16

#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_color2 DeepSkyBlue
#property indicator_width2 2
#property indicator_color3 DeepSkyBlue
#property indicator_style3 STYLE_DOT
#property indicator_color4 Yellow
#property indicator_color5 DeepSkyBlue
#property indicator_style5 STYLE_DOT
#property indicator_color6 DeepSkyBlue
#property indicator_width6 2
#property indicator_color7 Blue
#property indicator_width7 2

#property indicator_color9 Blue
#property indicator_width9 2
#property indicator_color10 DeepSkyBlue
#property indicator_width10 2
#property indicator_color11 DeepSkyBlue
#property indicator_style11 STYLE_DOT
#property indicator_color12 Yellow
#property indicator_color13 DeepSkyBlue
#property indicator_style13 STYLE_DOT
#property indicator_color14 DeepSkyBlue
#property indicator_width14 2
#property indicator_color15 Blue
#property indicator_width15 2

int max(int v1, int v2) { return v1 > v2 ? v1 : v2; }

class CTimeframe {
public:
   CTimeframe() {}
   CTimeframe(int minutes) : minutes_(minutes) {}

   int Minutes() const { return minutes_; }
   void SetMinutes(int minutes) {
      minutes_ = minutes;
      name_ = NULL;
   }

   string ToString() {
      if (name_ != NULL)
         return name_;
      int minutes = minutes_ ? minutes_ : Period();
      minutes = AddUnit(minutes, PERIOD_MN1, "MN");
      minutes = AddUnit(minutes, PERIOD_W1, "W");
      minutes = AddUnit(minutes, PERIOD_D1, "D");
      minutes = AddUnit(minutes, PERIOD_H1, "H");
      if (minutes)
         name_ += "M" + minutes;
      return name_;
   }

private:
   int AddUnit(int minutes, int unit, const string name) {
      if (minutes < unit)
         return minutes;
      int n = minutes / unit;
      name_ += name + n;
      minutes -= unit * n;
      return minutes;
   }

   int minutes_;
   string name_;
};

class CBollingerBand {
public:
   int Minutes() const { return timeframe_.Minutes(); }
   void SetMinutes(int minutes) { timeframe_.SetMinutes(minutes); }

   static int Add(int minutes) {
      int band_index = ArraySize(bands);
      ArrayResize(bands, band_index + 1);
      bands[band_index].SetMinutes(minutes);
      bands[band_index].Init(band_index * 8);
      return band_index;
   }

   void Init(int index_base = 0) {
      string prefix = "Band(";
      int tfsrc = timeframe_.Minutes();
      if (tfsrc != 0 && tfsrc > Period()) {
         string tfname = timeframe_.ToString() + ",";
         prefix = StringConcatenate(prefix, tfname);
      }
      prefix = StringConcatenate(prefix, MAPeriod);
      string name = prefix + ")";
      prefix = prefix + ",";
      if (Fibonacci) {
         string f1 = "1.613";
         string f2 = "2.618";
         string f3 = "4.236";
      } else {
         f1 = "1";
         f2 = "2";
         f3 = "3";
      }
      InitIndex(index_base + 6, BandBufferL3, StringConcatenate(prefix, "-", f3, ")"));
      InitIndex(index_base + 5, BandBufferL2, StringConcatenate(prefix, "-", f2, ")"));
      InitIndex(index_base + 4, BandBufferL1, StringConcatenate(prefix, "-", f1, ")"));
      InitIndex(index_base + 3, MABuffer, name);
      InitIndex(index_base + 2, BandBufferU1, StringConcatenate(prefix, "+", f1, ")"));
      InitIndex(index_base + 1, BandBufferU2, StringConcatenate(prefix, "+", f2, ")"));
      InitIndex(index_base + 0, BandBufferU3, StringConcatenate(prefix, "+", f3, ")"));

      SetIndexStyle(index_base + 7, DRAW_NONE);
      SetIndexBuffer(index_base + 7, WidthBuffer);
      if (ATR > 0)
         SetIndexLabel(index_base + 7, StringConcatenate("ATR(", tfname, ATR, ")"));
      else
         SetIndexLabel(index_base + 7, StringConcatenate("StdDev(", tfname, MAPeriod, ")"));
   }

   void InitIndex(int index, double& buffer[], const string label) {
      SetIndexBuffer(index, buffer);
      SetIndexLabel(index, label);
      SetIndexStyle(index, DRAW_LINE);
      SetIndexDrawBegin(index, MAPeriod);
   }

   static void TickAll() {
      for (int i = 0; i < ArraySize(bands); i++)
         bands[i].Tick();
   }

   void Tick() {
      int counted_bars = IndicatorCounted();
      int ibarLim = Bars - counted_bars;
      string symbol = Symbol();
      int ibar = ibarLim - 1;
      int ibarsrc;
      int tfsrc = timeframe_.Minutes();
      if (tfsrc == 0 || tfsrc <= Period()) {
         tfsrc = 0;
         ibarsrc = ibar;
      } else {
         datetime tm = Time[ibar];
         ibarsrc = iBarShift(symbol, tfsrc, tm);
         datetime tmsrc = iTime(symbol, tfsrc, ibarsrc);
         if (tmsrc != tm)
            ibar = iBarShift(symbol, 0, tmsrc);
      }
      for (; ibar >= 0; ) {
         double ma = iMA(symbol, tfsrc, MAPeriod, 0, MODE_SMA, PRICE_CLOSE, ibarsrc);

         double value, value1, value2, value3;
         if (ATR > 0)
            value = iATR(symbol, tfsrc, ATR, ibarsrc);
         else
            value = iStdDev(symbol, tfsrc, MAPeriod, 0, MODE_SMA, PRICE_CLOSE, ibarsrc);

         if (Fibonacci) {
            value1 = value * 1.613;
            value2 = value * 2.618;
            value3 = value * 4.236;
         } else {
            value1 = value;
            value2 = value * 2;
            value3 = value * 3;
         }

         ibarsrc--;
         if (tfsrc > 0) {
            if (ibarsrc < 0)
               tmsrc = Time[0] + 1;
            else
               tmsrc = iTime(symbol, tfsrc, ibarsrc);
         }
         double u1 = ma + value1;
         double l1 = ma - value1;
         double u2 = ma + value2;
         double l2 = ma - value2;
         double u3 = ma + value3;
         double l3 = ma - value3;
         for (; ; ) {
            MABuffer[ibar] = ma;
            BandBufferU1[ibar] = u1;
            BandBufferL1[ibar] = l1;
            BandBufferU2[ibar] = u2;
            BandBufferL2[ibar] = l2;
            BandBufferU3[ibar] = u3;
            BandBufferL3[ibar] = l3;
            WidthBuffer[ibar] = value;

            ibar--;
            if (ibar < 0 || tfsrc <= 0 || Time[ibar] >= tmsrc)
               break;
         }
      }

      if (AlertRatio > 0 && !IsTesting() && !IsOptimization())
         TickAlert(AlertRatio, ma, value);
   }

   void TickAlert(double min_ratio, double ma, double value) {
      double price = Close[0];
      double ratio = (price - ma) / value;
      bool is_out = fabs(ratio) >= min_ratio;
      if (is_out == was_out_)
         return;
      if (is_out) {
         ShowAlert(StringConcatenate("Out of band ", min_ratio, ": ", ratio));
         was_out_ = true;
      } else if (last_ratio_ * ratio < 0) {
         ShowAlert(StringConcatenate("First touch to MA after ", min_ratio, ": ", ratio));
         was_out_ = false;
      }
      last_ratio_ = ratio;
   }

   void ShowAlert(string msg) {
      Alert(Symbol(), ",", timeframe_.ToString(), ": ", msg);
   }

private:
   CTimeframe timeframe_;
   double MABuffer[];
   double BandBufferU1[];
   double BandBufferU2[];
   double BandBufferU3[];
   double BandBufferL1[];
   double BandBufferL2[];
   double BandBufferL3[];
   double WidthBuffer[];
   double last_ratio_;
   bool was_out_;
};

CBollingerBand bands[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   string args[];
   int nargs = StringSplit(TimeFrame, ',', args);
   for (int i = 0; i < nargs; i++) {
      string arg = args[i];
      int minutes = StrToInteger(arg);
      if (minutes > 0 && minutes <= Period())
         continue;
      if (CBollingerBand::Add(minutes) >= 1)
         break;
   }
   if (ArraySize(bands) == 0)
      CBollingerBand::Add(0);
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
   CBollingerBand::TickAll();
   return(0);
}
//+------------------------------------------------------------------+

