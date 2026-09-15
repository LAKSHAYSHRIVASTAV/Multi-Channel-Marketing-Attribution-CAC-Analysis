USE marketing_attribution;

-- =========================================================
-- STEP 8: CUSTOMER JOURNEY & ATTRIBUTION ANALYSIS
-- =========================================================


-- 1. First-Touch Channel for Every User
WITH first_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order
        ) AS rn
    FROM touchpoints
)
SELECT
    channel,
    COUNT(*) AS users_acquired
FROM first_touch
WHERE rn = 1
GROUP BY channel
ORDER BY users_acquired DESC;


-- 2. Last-Touch Channel for Converted Users
WITH last_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order DESC
        ) AS rn
    FROM touchpoints
    WHERE converted = 1
)
SELECT
    channel,
    COUNT(*) AS converted_users
FROM last_touch
WHERE rn = 1
GROUP BY channel
ORDER BY converted_users DESC;


-- 3. First-Touch Conversions
WITH first_touch AS (
    SELECT
        t.user_id,
        t.channel,
        ROW_NUMBER() OVER (
            PARTITION BY t.user_id
            ORDER BY t.touch_order
        ) AS rn
    FROM touchpoints t
)
SELECT
    f.channel,
    COUNT(*) AS conversions
FROM first_touch f
JOIN users_summary u
    ON f.user_id = u.user_id
WHERE f.rn = 1
  AND u.converted = 1
GROUP BY f.channel
ORDER BY conversions DESC;


-- 4. Last-Touch Conversions
WITH last_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order DESC
        ) AS rn
    FROM touchpoints
)
SELECT
    l.channel,
    COUNT(*) AS conversions
FROM last_touch l
JOIN users_summary u
    ON l.user_id = u.user_id
WHERE l.rn = 1
  AND u.converted = 1
GROUP BY l.channel
ORDER BY conversions DESC;


-- 5. First-Touch Revenue
WITH first_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order
        ) AS rn
    FROM touchpoints
)
SELECT
    f.channel,
    ROUND(SUM(u.revenue), 2) AS attributed_revenue
FROM first_touch f
JOIN users_summary u
    ON f.user_id = u.user_id
WHERE f.rn = 1
  AND u.converted = 1
GROUP BY f.channel
ORDER BY attributed_revenue DESC;


-- 6. Last-Touch Revenue
WITH last_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order DESC
        ) AS rn
    FROM touchpoints
)
SELECT
    l.channel,
    ROUND(SUM(u.revenue), 2) AS attributed_revenue
FROM last_touch l
JOIN users_summary u
    ON l.user_id = u.user_id
WHERE l.rn = 1
  AND u.converted = 1
GROUP BY l.channel
ORDER BY attributed_revenue DESC;


-- 7. First-Touch vs Last-Touch Comparison
WITH first_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order
        ) AS rn
    FROM touchpoints
),
last_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order DESC
        ) AS rn
    FROM touchpoints
),
first_stats AS (
    SELECT
        f.channel,
        COUNT(*) AS first_touch_conversions,
        ROUND(SUM(u.revenue), 2) AS first_touch_revenue
    FROM first_touch f
    JOIN users_summary u
        ON f.user_id = u.user_id
    WHERE f.rn = 1
      AND u.converted = 1
    GROUP BY f.channel
),
last_stats AS (
    SELECT
        l.channel,
        COUNT(*) AS last_touch_conversions,
        ROUND(SUM(u.revenue), 2) AS last_touch_revenue
    FROM last_touch l
    JOIN users_summary u
        ON l.user_id = u.user_id
    WHERE l.rn = 1
      AND u.converted = 1
    GROUP BY l.channel
)
SELECT
    COALESCE(f.channel, l.channel) AS channel,
    COALESCE(f.first_touch_conversions, 0) AS first_touch_conversions,
    COALESCE(l.last_touch_conversions, 0) AS last_touch_conversions,
    COALESCE(f.first_touch_revenue, 0) AS first_touch_revenue,
    COALESCE(l.last_touch_revenue, 0) AS last_touch_revenue
FROM first_stats f
LEFT JOIN last_stats l
    ON f.channel = l.channel

UNION

SELECT
    l.channel,
    COALESCE(f.first_touch_conversions, 0),
    COALESCE(l.last_touch_conversions, 0),
    COALESCE(f.first_touch_revenue, 0),
    COALESCE(l.last_touch_revenue, 0)
FROM last_stats l
LEFT JOIN first_stats f
    ON l.channel = f.channel
WHERE f.channel IS NULL

ORDER BY last_touch_revenue DESC;


-- 8. Journey Length Distribution
SELECT
    journey_length,
    COUNT(*) AS users,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM users_summary
GROUP BY journey_length
ORDER BY journey_length;


-- 9. Complete Attribution Summary
WITH first_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order
        ) AS rn
    FROM touchpoints
),
last_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order DESC
        ) AS rn
    FROM touchpoints
)
SELECT
    f.channel,
    COUNT(*) AS first_touch_users,
    SUM(
        CASE
            WHEN u.converted = 1 THEN 1
            ELSE 0
        END
    ) AS first_touch_conversions,
    ROUND(
        SUM(
            CASE
                WHEN u.converted = 1 THEN u.revenue
                ELSE 0
            END
        ),
        2
    ) AS first_touch_revenue,
    COUNT(
        CASE
            WHEN l.channel = f.channel
             AND u.converted = 1
            THEN 1
        END
    ) AS also_last_touch_conversions
FROM first_touch f
JOIN users_summary u
    ON f.user_id = u.user_id
LEFT JOIN last_touch l
    ON f.user_id = l.user_id
   AND l.rn = 1
WHERE f.rn = 1
GROUP BY f.channel
ORDER BY first_touch_revenue DESC;