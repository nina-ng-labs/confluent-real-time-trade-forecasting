-- ============================================================
-- Real-Time Trade Enrichment
-- Confluent AI Developer Day 2026
-- ============================================================

-- Inspect the user stream
SELECT *
FROM `sample_data_users`;

-- Inspect the stock-trade stream
SELECT *
FROM `sample_data_stock_trades`;

-- Enrich stock trades with user attributes.
CREATE TABLE `trades_enriched` AS
SELECT
    t.userid,
    t.symbol,
    t.side,
    t.quantity,
    t.price,
    t.account,
    u.regionid,
    u.gender
FROM `sample_data_stock_trades` AS t
JOIN `sample_data_users` AS u
    ON t.userid = u.userid;

-- Inspect enriched streaming records
SELECT *
FROM `trades_enriched`;
