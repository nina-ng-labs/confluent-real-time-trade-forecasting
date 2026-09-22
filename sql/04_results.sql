-- ============================================================
-- Query Latest Forecasts
-- ============================================================

SELECT
    symbol,
    current_count,
    forecast_count,
    upper_bound
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY symbol
            ORDER BY `$rowtime` DESC
        ) AS row_num
    FROM trades_forecast
)
WHERE row_num = 1;


-- ============================================================
-- Query Detected Anomalies
-- ============================================================

SELECT *
FROM anomaly_detection
WHERE anomaly_status = 'ANOMALY';
