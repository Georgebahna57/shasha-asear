#property copyright "Shop Price Board"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
#property description "Writes live gold / silver / euro quotes for the shop price board."

input string InpGold   = "XAUUSD";
input string InpSilver = "XAGUSD";
input string InpEuro   = "EURUSD";
input int    InpEveryMs = 400;

string goldSym, silverSym, euroSym;

int OnInit()
{
   EventSetMillisecondTimer(MathMax(200, InpEveryMs));
   ResolveSymbols();
   WritePrices();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
}

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
   return rates_total;
}

void OnTimer()
{
   WritePrices();
}

bool IsReady(const string symbol)
{
   if(symbol == "")
      return false;
   if(!SymbolSelect(symbol, true))
      return false;
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   return (bid > 0 && ask > 0);
}

string FirstReady(string &names[])
{
   for(int i = 0; i < ArraySize(names); i++)
   {
      if(IsReady(names[i]))
         return names[i];
   }
   return "";
}

void ResolveSymbols()
{
   string golds[] = {InpGold, "XAUUSD", "GOLD", "XAUUSDm", "XAUUSD.a"};
   string silvers[] = {InpSilver, "XAGUSD", "SILVER", "XAGUSDm", "XAGUSD.a"};
   string euros[] = {InpEuro, "EURUSD", "EURUSDm", "EURUSD.a"};
   goldSym = FirstReady(golds);
   silverSym = FirstReady(silvers);
   euroSym = FirstReady(euros);
}

double Mid(const string symbol)
{
   if(symbol == "")
      return 0;
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   if(bid <= 0 || ask <= 0)
      return 0;
   return (bid + ask) / 2.0;
}

string IsoNow()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   return StringFormat("%04d-%02d-%02dT%02d:%02d:%02dZ",
                       dt.year, dt.mon, dt.day, dt.hour, dt.min, dt.sec);
}

void WritePrices()
{
   if(goldSym == "" || silverSym == "" || euroSym == "")
      ResolveSymbols();

   double gold = Mid(goldSym);
   double silver = Mid(silverSym);
   double euro = Mid(euroSym);

   string json = StringFormat(
      "{\"gold\":%.5f,\"silver\":%.5f,\"euro\":%.5f,\"source\":\"mt5\",\"at\":\"%s\",\"symbols\":{\"gold\":\"%s\",\"silver\":\"%s\",\"euro\":\"%s\"}}",
      gold, silver, euro, IsoNow(), goldSym, silverSym, euroSym
   );

   int h = FileOpen("shop-board.json", FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(h == INVALID_HANDLE)
   {
      Comment("Shop board: cannot write shop-board.json");
      return;
   }
   FileWriteString(h, json);
   FileClose(h);

   Comment("Shop board  ",
           goldSym, " ", DoubleToString(gold, 2), "  |  ",
           silverSym, " ", DoubleToString(silver, 2), "  |  ",
           euroSym, " ", DoubleToString(euro, 5));
}
