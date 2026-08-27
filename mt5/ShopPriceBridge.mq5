#property copyright "Shop Price Board"
#property link      ""
#property version   "1.10"
#property indicator_chart_window
#property indicator_plots 0
#property description "Writes live gold / silver / euro ticks for the shop price board."

input string InpGold   = "XAUUSD";
input string InpSilver = "XAGUSD";
input string InpEuro   = "EURUSD";
input int    InpEveryMs = 50;

string goldSym, silverSym, euroSym;
string lastJson = "";

int OnInit()
{
   EventSetMillisecondTimer(MathMax(16, InpEveryMs));
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
   WritePrices();
   return rates_total;
}

void OnTimer()
{
   WritePrices();
}

void OnTick()
{
   WritePrices();
}

bool IsReady(const string symbol)
{
   if(symbol == "")
      return false;
   if(!SymbolSelect(symbol, true))
      return false;
   MqlTick tick;
   if(!SymbolInfoTick(symbol, tick))
      return false;
   return (tick.bid > 0 && tick.ask > 0);
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
   string golds[] = {InpGold, "XAUUSD", "GOLD", "XAUUSDm", "XAUUSD.a", "XAUUSD."};
   string silvers[] = {InpSilver, "XAGUSD", "SILVER", "XAGUSDm", "XAGUSD.a"};
   string euros[] = {InpEuro, "EURUSD", "EURUSDm", "EURUSD.a"};
   goldSym = FirstReady(golds);
   silverSym = FirstReady(silvers);
   euroSym = FirstReady(euros);
}

bool ReadTick(const string symbol, double &bid, double &ask, double &mid)
{
   bid = 0;
   ask = 0;
   mid = 0;
   if(symbol == "")
      return false;
   MqlTick tick;
   if(!SymbolInfoTick(symbol, tick))
      return false;
   if(tick.bid <= 0 || tick.ask <= 0)
      return false;
   bid = tick.bid;
   ask = tick.ask;
   mid = (tick.bid + tick.ask) / 2.0;
   return true;
}

string IsoNow()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   return StringFormat("%04d-%02d-%02dT%02d:%02d:%02dZ",
                       dt.year, dt.mon, dt.day, dt.hour, dt.min, dt.sec);
}

string TickJson(const string key, const double bid, const double ask, const double mid)
{
   if(mid <= 0)
      return StringFormat("\"%s\":0,\"%sBid\":0,\"%sAsk\":0", key, key, key);
   return StringFormat("\"%s\":%.5f,\"%sBid\":%.5f,\"%sAsk\":%.5f",
                       key, mid, key, bid, key, ask);
}

void WritePrices()
{
   if(goldSym == "" || silverSym == "" || euroSym == "")
      ResolveSymbols();

   double goldBid, goldAsk, goldMid;
   double silverBid, silverAsk, silverMid;
   double euroBid, euroAsk, euroMid;
   ReadTick(goldSym, goldBid, goldAsk, goldMid);
   ReadTick(silverSym, silverBid, silverAsk, silverMid);
   ReadTick(euroSym, euroBid, euroAsk, euroMid);

   if(goldMid <= 0 && silverMid <= 0 && euroMid <= 0)
      return;

   string sig = StringFormat("%.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f %.5f",
                             goldMid, goldBid, goldAsk,
                             silverMid, silverBid, silverAsk,
                             euroMid, euroBid, euroAsk);
   if(sig == lastJson)
      return;
   lastJson = sig;

   string json = StringFormat(
      "{%s,%s,%s,\"source\":\"mt5\",\"at\":\"%s\",\"symbols\":{\"gold\":\"%s\",\"silver\":\"%s\",\"euro\":\"%s\"}}",
      TickJson("gold", goldBid, goldAsk, goldMid),
      TickJson("silver", silverBid, silverAsk, silverMid),
      TickJson("euro", euroBid, euroAsk, euroMid),
      IsoNow(), goldSym, silverSym, euroSym
   );

   int h = FileOpen("shop-board.tmp", FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(h == INVALID_HANDLE)
   {
      Comment("Shop board: cannot write shop-board.tmp");
      return;
   }
   FileWriteString(h, json);
   FileClose(h);
   if(!FileMove("shop-board.tmp", FILE_COMMON, "shop-board.json", FILE_COMMON | FILE_REWRITE))
   {
      int out = FileOpen("shop-board.json", FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON | FILE_SHARE_READ | FILE_SHARE_WRITE);
      if(out == INVALID_HANDLE)
      {
         Comment("Shop board: cannot write shop-board.json");
         return;
      }
      FileWriteString(out, json);
      FileClose(out);
   }

   Comment("LIVE  ",
           goldSym, " ", DoubleToString(goldMid, 2), "  |  ",
           silverSym, " ", DoubleToString(silverMid, 2), "  |  ",
           euroSym, " ", DoubleToString(euroMid, 5));
}
