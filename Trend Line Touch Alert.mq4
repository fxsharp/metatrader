//
// Trend Line Touch Alert.mq4
//
#property copyright "Copyright (c) 2020 fxsharp"
#property link      "https://github.com/fxsharp/metatrader"
#property version   "1.00"
#property strict
#property indicator_chart_window

class CRangeAlert {
public:
   void Tick(datetime time, double price) {
      if (time <= suppress_until_)
         return;

      if (time != current_time_) {
         current_time_ = time;
         current_price_ = price;
         UpdateFromObjects();
         return;
      }

      if (price == current_price_)
         return;
      current_price_ = price;

      if (price >= max_price_) {
         Alert("Touches upper line: ", max_name_);
      } else if (price <= min_price_) {
         Alert("Touches lower line: ", min_name_);
      } else {
         return;
      }
      suppress_until_ = current_time_;
   }

   void UpdateFromObjects() {
      min_price_ = DBL_MIN;
      max_price_ = DBL_MAX;
      int count = ObjectsTotal();
      for (int i = 0; i < count; ++i) {
         string name = ObjectName(i);
         int type = ObjectType(name);
         switch (type) {
         case OBJ_HLINE:
            Update(ObjectGetDouble(0, name, OBJPROP_PRICE1), name);
            break;
         case OBJ_TREND:
            UpdateFromTrendLine(name, 0);
            break;
         case OBJ_CHANNEL:
            UpdateFromTrendLine(name, 0);
            UpdateFromTrendLine(name, 1);
            break;
         default:
#ifdef _DEBUG
            PrintFormat("Object \"%s\" ignored (type=%d)", name, type);
#endif
            break;
         }
      }

      if (min_price_ == DBL_MIN && max_price_ == DBL_MAX)
         suppress_until_ = current_time_;
   }

   void UpdateFromTrendLine(string name, int line_id) {
      Update(ObjectGetValueByTime(0, name, current_time_, line_id), name);
   }

   void Update(double price, string name) {
      if (price >= current_price_) {
         if (price < max_price_) {
            max_price_ = price;
            max_name_ = name;
         }
         return;
      }
      if (price > min_price_) {
         min_price_ = price;
         min_name_ = name;
      }
   }

private:
   datetime current_time_;
   datetime suppress_until_;
   double current_price_;
   double min_price_;
   double max_price_;
   string min_name_;
   string max_name_;
};

CRangeAlert range_alert;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
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
                const int &spread[]) {
   range_alert.Tick(time[0], close[0]);
   return(rates_total);
}
//+------------------------------------------------------------------+
