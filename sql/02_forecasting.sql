-- ============================================================
-- Real-Time Trade Forecasting
-- 10-second tumbling windows + ML_FORECAST
-- ============================================================

CREATE MATERIALIZED TABLE trades_forecast AS
SELECT
    symbol,
    ts,
    trade_count AS current_count,
    forecast[1].forecast_value AS forecast_count,
    forecast[1].upper_bound AS upper_bound
FROM (
    SELECT
        symbol,
        window_end AS ts,
        trade_count,
        ML_FORECAST(
            CAST(trade_count AS DOUBLE),
            window_end,
            JSON_OBJECT(
                'minTrainingSize' VALUE 10,
                'horizon' VALUE 5
            )
        ) OVER (
            PARTITION BY symbol
            ORDER BY window_time
        ) AS forecast
    FROM (
        SELECT
            symbol,
            window_end,
            window_time,
            COUNT(*) AS trade_count
        FROM TABLE(
            TUMBLE(
                TABLE trades_enriched,
                DESCRIPTOR($rowtime),
                INTERVAL '10' SECONDS
            )
        )
        GROUP BY
            symbol,
            window_start,
            window_end,
            window_time
    )
)
WHERE CARDINALITY(forecast) >= 1;
