# Live Price Board

Standalone shop screen. Not part of Sandouk Nemr.

Gold and silver are **USD per troy ounce**. You set only the buy/sell spread.

## Quick open

Double-click `index.html` (uses the public internet feed).

## MetaTrader 5 (recommended)

The board can read the same live quotes you see in MT5 (`XAUUSD`, `XAGUSD`, `EURUSD`).

1. In MT5: **File → Open Data Folder**
2. Copy `mt5\ShopPriceBridge.mq5` into `MQL5\Indicators\`
3. In MetaEditor, compile it
4. Add **Gold / Silver / Euro** to Market Watch
5. Drop **ShopPriceBridge** on any chart
6. If your broker uses other names (`GOLD`, `XAUUSDm`…), set them in the indicator inputs
7. Double-click `start-board.bat` and keep that window open
8. The shop screen opens at `http://127.0.0.1:8765/`

The footer says **MetaTrader 5** when it is connected. If MT5 is closed, it falls back to the internet feed.

Buy / sell on the board are still your settings: live MT5 price minus/plus your spread.
