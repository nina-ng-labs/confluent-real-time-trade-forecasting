-- ============================================================
-- Real-Time Trading Anomaly Detection
-- Rolling statistics + z-score
-- ============================================================

CREATE MATERIALIZED TABLE anomaly_detection AS
SELECT
    *,
    CASE
        WHEN ABS(z_score) > 2.0 THEN 'ANOMALY'
        ELSE 'NORMAL'
    END AS anomaly_status
FROM (
    SELECT
        *,
        (trade_count - avg_count)
            / NULLIF(stddev_count, 0) AS z_score
    FROM (
        SELECT
            *,
            AVG(trade_count) OVER (
                PARTITION BY symbol
                ORDER BY window_time
                ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
            ) AS avg_count,

            STDDEV_POP(trade_count) OVER (
                PARTITION BY symbol
                ORDER BY window_time
                ROWS BETWEEN 20 PRECEDING AND CURRENT ROW
            ) AS stddev_count

        FROM (
            SELECT
                symbol,
                window_end AS ts,
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
);
