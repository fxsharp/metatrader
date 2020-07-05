# MetaTrader Custom Indicators

## Bollinger Bands MTF

Bollinger Bands with multiple timeframe support.

Features:
* Can show up to 2 timeframes.
* Slow MA.
* Alerts.

### Inputs:
<dl>
<dt>MAPeriod</dt>
<dd>The period of the moving average.</dd>

<dt>Timeframe</dt>
<dd>Comma-separated list of timeframes in minutes.

Up to two timeframes are used,
after ignoring timeframe smaller than or equal to
the current timeframe.

`0` indicates the current timeframe of the chart,
and is never ignored.

For example, when the current timeframe is `M15` and
this parameter is set to `0,5,15,60,240`.
In this case, `M15` and `H1` are used.
`5` and `15` are ignored because they are less than or equal to the current timeframe.
First two items are then `0` and `60`.</dd>

<dt>ATR</dt>
<dd>
When this value is `0`,
the standard deviations are used.
This is the standard definition of
Bollinger Band.

When this value is not `0`,
ATR of the period is used instead.</dd>

<dt>Fibonacci</dt>
<dd>
When `true`, the Fibonacci scale is used.
The 3 bands are 1.613, 2.618, and 4.236.</dd>

<dt>AlertRatio</dt>
<dd>
When set to a value greater than `0`,
alerts are shown when:

* The price touches the ratio.
* The price touches the moving average
first time after it touched the ratio.

For example, when set to `2`,
alerts are shown when the prices touches
the 2nd band,
and when it is back to the moving average.
</dl>

## High Low Lines

Shows high and low prices of
yesterday,
this week,
and last week.
