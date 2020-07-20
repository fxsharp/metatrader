# Trend Line Touch Alert

This MetaTrader 4 custom indicator
shows alerts when the price touches trendlines you drew on the chart.
While this is a custom indicator,
it doesn't draw any indicators.

Following types of lines are supported:
* Horizontal line.
* Trendline.
* Equidistant channel.

Note, this custom indicator checks trendlines you drew on the chart
when the current bar shifts in the current timeframe,
or when the current timeframe is changed.
In order to get alerts right after you drew trendlines and before the next bar appears,
please change timeframe.
