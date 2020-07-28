//
// Trend Line Touch Alert.mq4
//
#property copyright "Copyright (c) 2020 fxsharp"
#property link      "https://github.com/fxsharp/metatrader"
#property version   "1.00"
#property strict
#property indicator_chart_window

class CDrawingObject {
public:
   CDrawingObject(string name)
      : name_(name),
        type_(ObjectType(name)) {}

   int Type() const { return type_; }
   string Name() const { return name_; }

   double Price1() const { return ObjectGetDouble(0, name_, OBJPROP_PRICE1); }

   double ValueByTime(datetime time, int line_id = 0) const {
      return ObjectGetValueByTime(0, name_, time, line_id);
   }

private:
   int type_;
   string name_;
};

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
         Alert(Symbol(), " UP: ", price, " touches \"", max_name_, "\"");
      } else if (price <= min_price_) {
         Alert(Symbol(), " DOWN: ", price, " touches \"", min_name_, "\"");
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
         CDrawingObject obj(ObjectName(i));
         switch (obj.Type()) {
         case OBJ_HLINE:
            Update(obj.Price1(), obj.Name());
            break;
         case OBJ_TREND:
            Update(obj.ValueByTime(current_time_), obj.Name());
            break;
         case OBJ_CHANNEL:
            Update(obj.ValueByTime(current_time_, 0), obj.Name());
            Update(obj.ValueByTime(current_time_, 1), obj.Name());
            break;
         default:
#ifdef _DEBUG
            PrintFormat("Object \"%s\" ignored (type=%d)", obj.Name(), obj.Type());
#endif
            break;
         }
      }
#ifdef _DEBUG
      PrintFormat("Updated: min=%lf, max=%lf", min_price_, max_price_);
#endif

      if (min_price_ == DBL_MIN && max_price_ == DBL_MAX)
         suppress_until_ = current_time_;
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
   datetime suppress_until_;
   datetime current_time_;
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
