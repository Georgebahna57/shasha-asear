# Live Price Board

Standalone shop screen. Not part of Sandouk Nemr.

Gold and silver are **USD per troy ounce**. You set only the bid/ask spread.

## Live ticks

The board follows live gold, silver, and euro bid/ask **on every tick**:

- On the shop PC, keep **MetaTrader 5** and `start-board.bat` open to match your broker
- The footer then says **LIVE** and **MetaTrader 5 ticks**
- Phone / website use the live market feed, which can differ slightly from the broker
- Shop **Bid** = live bid − your discount
- Shop **Ask** = live ask + your premium

## Live app

https://georgebahna57.github.io/shasha-asear/

## Install as a Windows program

1. Double-click `install-app.bat`
2. Open **شاشة أسعار** from the Start menu or Desktop
3. It opens in its own window, not as a browser tab

Keep the app open. Prices update on every live tick. MetaTrader 5 is not required.

You can also install the online app from Edge/Chrome: open the live link → **Install app**.

## Android

### Install the APK
Download from GitHub (works from any phone or PC):

https://github.com/Georgebahna57/shasha-asear/raw/main/ShashaAsear-debug.apk

1. Open that link on the phone (or copy the file to the phone)
2. Allow install from this source
3. Open **شاشة أسعار**

The phone uses the same live tick feed as the web app. Landscape or portrait both work.

### Add to Home Screen (no APK)
Open https://georgebahna57.github.io/shasha-asear/ in Chrome → **Add to Home screen**.

### Rebuild the APK
```bash
npm install
npm run android:apk
```
The file is written to `android/app/build/outputs/apk/debug/app-debug.apk`.

## MetaTrader 5 (to match the broker)

1. In MT5: **File → Open Data Folder**
2. Copy `mt5\ShopPriceBridge.mq5` into `MQL5\Indicators\`
3. In MetaEditor, compile it
4. Add **Gold / Silver / Euro** to Market Watch
5. Drop **ShopPriceBridge** on any chart
6. If your broker uses other names (`GOLD`, `XAUUSDm`…), set them in the indicator inputs
7. Double-click `start-board.bat` and keep that window open
8. The shop screen opens at `http://127.0.0.1:8765/`

The footer says **LIVE** and **MetaTrader 5 ticks** when it is connected.
