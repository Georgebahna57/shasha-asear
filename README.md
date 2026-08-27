# Live Price Board

Standalone shop screen. Not part of Sandouk Nemr.

Gold and silver are **USD per troy ounce**. You set only the bid/ask spread.

## Live ticks

With MetaTrader 5 the board follows the same quotes as the terminal (`XAUUSD`, `XAGUSD`, `EURUSD`) on every tick:

- The indicator writes bid / ask as soon as the quote changes
- The shop screen polls that file about 12 times per second
- Numbers flash green / red like an exchange board
- Shop **Bid** = live bid − your discount
- Shop **Ask** = live ask + your premium

If MT5 is closed, a slower public feed is used (about once a second). That fallback is not tick-by-tick.

## Live app

https://georgebahna57.github.io/shasha-asear/

## Install as a Windows program

1. Double-click `install-app.bat`
2. Open **شاشة أسعار** from the Start menu or Desktop
3. It opens in its own window, not as a browser tab

Keep MetaTrader 5 running if you want tick-by-tick prices.

You can also install the online app from Edge/Chrome: open the live link → **Install app**.

## Android

### Install the APK
1. Copy `ShashaAsear-debug.apk` to the phone
2. On the phone: allow install from this source
3. Open **شاشة أسعار**

The phone uses the live internet feed (not MetaTrader). Landscape or portrait both work.

### Add to Home Screen (no APK)
Open https://georgebahna57.github.io/shasha-asear/ in Chrome → **Add to Home screen**.

### Rebuild the APK
```bash
npm install
npm run android:apk
```
The file is written to `android/app/build/outputs/apk/debug/app-debug.apk`.

## MetaTrader 5 (recommended)

1. In MT5: **File → Open Data Folder**
2. Copy `mt5\ShopPriceBridge.mq5` into `MQL5\Indicators\`
3. In MetaEditor, compile it
4. Add **Gold / Silver / Euro** to Market Watch
5. Drop **ShopPriceBridge** on any chart
6. If your broker uses other names (`GOLD`, `XAUUSDm`…), set them in the indicator inputs
7. Double-click `start-board.bat` and keep that window open
8. The shop screen opens at `http://127.0.0.1:8765/`

The footer says **LIVE** and **MetaTrader 5 ticks** when it is connected.
