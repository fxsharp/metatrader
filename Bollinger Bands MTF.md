# Bollinger Bands MTF

Bollinger Bands with multiple timeframe support.
Features:
* Can show up to 2 timeframes.
* Shows Slow MA.
* Alerts.

## Inputs:
<dl>
<dt>MAPeriod</dt>
<dd>The period of the moving average.</dd>

<dt>Timeframe</dt>
<dd>
Comma-separated list of timeframes in minutes.
Up to two timeframes are used,
after ignoring timeframe smaller than or equal to
the current timeframe.

`0` is the current timeframe of the chart,
and is never ignored.

For example, when
this parameter is set to `0,5,15,60,240`
and the current timeframe is `M15`.
The first `0` is valid,
but following `5` and `15` are ignored
because they are less than or equal to the current timeframe.
In this case, `0` and `60` are the used values.
</dd>

<dt>ATR</dt>
<dd>
When this is not <code>0</code>,
ATR of the period is used
instead of the standard deviations.
</dd>

<dt>Fibonacci</dt>
<dd>
When <code>true</code>, the Fibonacci scale is used.
The 3 bands are 1.613, 2.618, and 4.236.</dd>

<dt>AlertRatio</dt>
<dd>
When this is greater than <code>0</code>,
alerts are shown when:

* The price touches the specified ratio.
* The price touches the moving average
first time after it touched the ratio.

For example, when set to `2`,
alerts are shown when the prices touches
the 2nd band,
and when it is back to the moving average.
</dl>
