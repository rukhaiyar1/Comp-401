# Comp-401
# MA-Crossover Expert Advisor

**Author:** Harshal Rukhaiyar  
**Inspired By:** TrustfulTrading.com  
**Platform:** MetaTrader 5 (MT5)

## Overview

The `MA-Crossover` is a MetaTrader 5 Expert Advisor designed to implement a Moving Average Crossover trading strategy. The EA makes trading decisions based on the crossing points between fast and slow moving averages. It features customizable periods for the moving averages, stop-loss, and take-profit settings.

## Project Files

- **MA-Crossover.mq5:** The main Expert Advisor code file.
- **README.md:** This guide explaining the project, its purpose, and how to use it.

## Strategy

The EA monitors two moving averages: a fast-moving average (default period: 18) and a slow-moving average (default period: 50). When the fast-moving average crosses the slow-moving average upwards, it triggers a "buy" signal. When the fast-moving average crosses the slow-moving average downwards, it triggers a "sell" signal.

**Additional Features:**
- **Break-Even Stop:** The EA moves the stop loss to break-even after a specified profit level is reached, ensuring profits are locked in while providing extra cushion pips.

## Installation

1. **Copy the Code:**  
   Download the `MA-Crossover.mq5` file and copy it to the "Experts" folder within the MT5 data directory:
   - In MT5, go to `File` > `Open Data Folder`
   - Navigate to `MQL5` > `Experts`
   - Copy `MA-Crossover.mq5` into this folder

2. **Compile the Code:**  
   - Open `MetaEditor` via MT5 and navigate to `MA-Crossover.mq5` in the "Experts" directory.
   - Click on the "Compile" button to build the executable file for the EA.

3. **Attach to a Chart:**  
   - In MT5, find `MA-Crossover` under the `Navigator` panel within the `Expert Advisors` section.
   - Drag and drop it onto the chart of the currency pair or instrument you want to trade.

## Configuration and Usage

The EA provides customizable input parameters:
- **InpFastPeriod (Default: 18):** Fast moving average period
- **InpSlowPeriod (Default: 50):** Slow moving average period
- **InpStopLoss (Default: 200 points):** Stop loss value in points
- **INpTakeprofit (Default: 100 points):** Take profit value in points
- **InpLotSize (Default: 1.0):** Lot size for trading positions
- **InpMAMethodFast (Default: SMMA):** Moving average method for the fast MA
- **InpMAMethodSlow (Default: SMMA):** Moving average method for the slow MA

**Steps to Use the EA:**
1. Attach the EA to a chart.
2. Configure the input parameters to your desired values.
3. Enable automated trading in MT5.
4. The EA will now monitor moving averages and place trades based on the specified strategy.

## Note

**Disclaimer:** Trading in the financial markets carries a significant risk and should be undertaken with caution. Make sure to backtest the EA thoroughly and trade in a demo account before using it with real money.

## Contribution

Contributions to improve this project are welcome. Feel free to create pull requests or report issues through GitHub.

Happy Trading!

