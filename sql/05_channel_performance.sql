USE marketing_attribution;

-- =========================================================
-- STEP 7: CHANNEL PERFORMANCE ANALYSIS
-- =========================================================


-- 1. Channel Spend
SELECT
    channel,
    ROUND(SUM(cost), 2) AS total_spend
FROM touchpoints
GROUP BY channel
ORDER BY total_spend DESC;


-- 2. Channel Conversions
SELECT
    channel,
    SUM(converted) AS total_conversions
FROM touchpoints
GROUP BY channel
ORDER BY total_conversions DESC;


-- 3. Channel Revenue
SELECT
    channel,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM touchpoints
GROUP BY channel
ORDER BY total_revenue DESC;


-- 4. Channel Conversion Rate
SELECT
    channel,
    COUNT(*) AS total_touchpoints,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM touchpoints
GROUP BY channel
ORDER BY conversion_rate_pct DESC;


-- 5. Channel ROAS
SELECT
    channel,
    ROUND(SUM(cost), 2) AS total_spend,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        SUM(revenue) / NULLIF(SUM(cost), 0),
        2
    ) AS roas
FROM touchpoints
GROUP BY channel
ORDER BY roas DESC;


-- 6. Complete Channel Performance Summary
SELECT
    channel,
    COUNT(*) AS total_touchpoints,
    ROUND(SUM(cost), 2) AS total_spend,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        SUM(revenue) / NULLIF(SUM(cost), 0),
        2
    ) AS roas
FROM touchpoints
GROUP BY channel
ORDER BY roas DESC;


-- 7. Rank Channels by ROAS
SELECT
    channel,
    ROUND(
        SUM(revenue) / NULLIF(SUM(cost), 0),
        2
    ) AS roas,
    DENSE_RANK() OVER (
        ORDER BY
            SUM(revenue) / NULLIF(SUM(cost), 0) DESC
    ) AS roas_rank
FROM touchpoints
GROUP BY channel;


-- 8. Rank Channels by Revenue
SELECT
    channel,
    ROUND(SUM(revenue), 2) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(revenue) DESC
    ) AS revenue_rank
FROM touchpoints
GROUP BY channel;


-- 9. High-Spend / Low-Return Channels
SELECT
    channel,
    ROUND(SUM(cost), 2) AS total_spend,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        SUM(revenue) / NULLIF(SUM(cost), 0),
        2
    ) AS roas
FROM touchpoints
GROUP BY channel
HAVING
    SUM(cost) > (
        SELECT AVG(channel_spend)
        FROM (
            SELECT SUM(cost) AS channel_spend
            FROM touchpoints
            GROUP BY channel
        ) x
    )
    AND
    SUM(revenue) / NULLIF(SUM(cost), 0) < 1
ORDER BY total_spend DESC;