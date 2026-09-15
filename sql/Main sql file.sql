SELECT VERSION();
SELECT 1 AS server_test;
SELECT CURRENT_USER() AS connected_user;

CREATE DATABASE marketing_attribution;
SHOW DATABASES;
USE marketing_attribution;
SELECT DATABASE();

CREATE TABLE touchpoints (
    user_id INT NOT NULL,
    touch_order INT NOT NULL,
    journey_length INT NOT NULL,
    channel VARCHAR(50) NOT NULL,
    timestamp DATETIME NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    converted TINYINT NOT NULL,
    revenue DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (user_id, touch_order)
);
CREATE TABLE users_summary (
    user_id INT NOT NULL,
    journey_length INT NOT NULL,
    converted TINYINT NOT NULL,
    revenue DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (user_id)
);
SHOW TABLES;
DESCRIBE touchpoints;
DESCRIBE users_summary;
ALTER TABLE touchpoints
MODIFY user_id VARCHAR(20) NOT NULL;
ALTER TABLE users_summary
MODIFY user_id VARCHAR(20) NOT NULL;

DESCRIBE touchpoints;
DESCRIBE users_summary;

USE marketing_attribution;

TRUNCATE TABLE touchpoints;
SELECT COUNT(*) AS rows_before_import
FROM touchpoints;
SELECT COUNT(*) AS current_rows
FROM touchpoints;
TRUNCATE TABLE touchpoints;
SELECT COUNT(*) AS current_rows
FROM touchpoints;

SHOW VARIABLES LIKE 'secure_file_priv';
SELECT COUNT(*) AS current_rows
FROM touchpoints;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/touchpoints.csv'
INTO TABLE touchpoints
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, touch_order, journey_length, channel, timestamp, cost, converted, revenue);

SELECT COUNT(*) AS touchpoint_rows
FROM touchpoints;
SELECT *
FROM touchpoints
LIMIT 10;

SELECT COUNT(*) AS total_users
FROM users_summary;
TRUNCATE TABLE users_summary;
SELECT COUNT(*) AS total_users
FROM users_summary;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_summary.csv'
INTO TABLE users_summary
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(user_id, journey_length, converted, revenue);
SELECT COUNT(*) AS total_users
FROM users_summary;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_summary.csv'
INTO TABLE users_summary
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(user_id, journey_length, converted, revenue);

TRUNCATE TABLE users_summary;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_summary.csv'
INTO TABLE users_summary
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, journey_length, converted, revenue);

SELECT COUNT(*) AS total_users
FROM users_summary;

SELECT 
    (SELECT COUNT(*) FROM touchpoints) AS touchpoint_rows,
    (SELECT COUNT(*) FROM users_summary) AS user_rows;
    
    SELECT
    SUM(user_id IS NULL) AS null_user_id,
    SUM(touch_order IS NULL) AS null_touch_order,
    SUM(journey_length IS NULL) AS null_journey_length,
    SUM(channel IS NULL) AS null_channel,
    SUM(timestamp IS NULL) AS null_timestamp,
    SUM(cost IS NULL) AS null_cost,
    SUM(converted IS NULL) AS null_converted,
    SUM(revenue IS NULL) AS null_revenue
FROM touchpoints;

SELECT
    SUM(user_id IS NULL) AS null_user_id,
    SUM(journey_length IS NULL) AS null_journey_length,
    SUM(converted IS NULL) AS null_converted,
    SUM(revenue IS NULL) AS null_revenue
FROM users_summary;

SELECT
    user_id,
    touch_order,
    COUNT(*) AS duplicate_count
FROM touchpoints
GROUP BY user_id, touch_order
HAVING COUNT(*) > 1;

SELECT
    user_id,
    COUNT(*) AS duplicate_count
FROM users_summary
GROUP BY user_id
HAVING COUNT(*) > 1;

SELECT DISTINCT converted
FROM touchpoints
ORDER BY converted;
SELECT DISTINCT converted
FROM users_summary
ORDER BY converted;

SELECT
    SUM(cost < 0) AS negative_cost_rows,
    SUM(revenue < 0) AS negative_revenue_rows
FROM touchpoints;
SELECT
    SUM(revenue < 0) AS negative_revenue_rows
FROM users_summary;

SELECT
    MIN(journey_length) AS min_journey_length,
    MAX(journey_length) AS max_journey_length,
    COUNT(DISTINCT journey_length) AS unique_journey_lengths
FROM touchpoints;

SELECT
    MIN(journey_length) AS min_journey_length,
    MAX(journey_length) AS max_journey_length,
    COUNT(DISTINCT journey_length) AS unique_journey_lengths
FROM users_summary;

SELECT
    MIN(touch_order) AS min_touch_order,
    MAX(touch_order) AS max_touch_order
FROM touchpoints;
SELECT COUNT(*) AS invalid_touch_orders
FROM touchpoints
WHERE touch_order < 1;

SELECT COUNT(DISTINCT t.user_id) AS missing_users
FROM touchpoints t
LEFT JOIN users_summary u
    ON t.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS inconsistent_users
FROM (
    SELECT
        t.user_id,
        MAX(t.journey_length) AS touchpoint_journey_length,
        u.journey_length AS summary_journey_length
    FROM touchpoints t
    JOIN users_summary u
        ON t.user_id = u.user_id
    GROUP BY t.user_id, u.journey_length
    HAVING MAX(t.journey_length) <> u.journey_length
) AS inconsistencies;

SELECT COUNT(*) AS inconsistent_journeys
FROM (
    SELECT
        user_id,
        MAX(touch_order) AS max_touch_order,
        MAX(journey_length) AS journey_length
    FROM touchpoints
    GROUP BY user_id
    HAVING MAX(touch_order) <> MAX(journey_length)
) AS journey_check;

SELECT COUNT(*) AS inconsistent_conversions
FROM (
    SELECT
        t.user_id,
        MAX(t.converted) AS touchpoint_converted,
        u.converted AS summary_converted
    FROM touchpoints t
    JOIN users_summary u
        ON t.user_id = u.user_id
    GROUP BY t.user_id, u.converted
    HAVING MAX(t.converted) <> u.converted
) AS conversion_check;


-- =====================================================
-- STEP 5: DATA QUALITY CHECKS
-- =====================================================

-- 1. Check NULL values in touchpoints
SELECT
    SUM(user_id IS NULL) AS null_user_id,
    SUM(touch_order IS NULL) AS null_touch_order,
    SUM(journey_length IS NULL) AS null_journey_length,
    SUM(channel IS NULL) AS null_channel,
    SUM(timestamp IS NULL) AS null_timestamp,
    SUM(cost IS NULL) AS null_cost,
    SUM(converted IS NULL) AS null_converted,
    SUM(revenue IS NULL) AS null_revenue
FROM touchpoints;


-- 2. Check duplicate touchpoints
SELECT
    user_id,
    touch_order,
    timestamp,
    channel,
    COUNT(*) AS duplicate_count
FROM touchpoints
GROUP BY user_id, touch_order, timestamp, channel
HAVING COUNT(*) > 1;


-- 3. Check invalid numeric/business values
SELECT
    SUM(cost < 0) AS negative_cost,
    SUM(journey_length <= 0) AS invalid_journey_length,
    SUM(converted NOT IN (0,1)) AS invalid_converted,
    SUM(revenue < 0) AS negative_revenue
FROM touchpoints;


-- 4. Check touchpoint journey/order consistency
SELECT
    user_id,
    MAX(journey_length) AS stated_journey_length,
    COUNT(*) AS actual_touchpoints
FROM touchpoints
GROUP BY user_id
HAVING MAX(journey_length) <> COUNT(*);


-- 5. Check users_summary against touchpoints
SELECT
    COUNT(DISTINCT t.user_id) AS touchpoint_users,
    COUNT(DISTINCT u.user_id) AS summary_users,
    COUNT(DISTINCT CASE
        WHEN u.user_id IS NULL THEN t.user_id
    END) AS users_missing_from_summary
FROM touchpoints t
LEFT JOIN users_summary u
    ON t.user_id = u.user_id;
    
    SELECT
    COUNT(*) AS total_users
FROM users_summary;
SELECT
    COUNT(*) AS converted_users
FROM users_summary
WHERE converted = 1;
-- STEP 6: BUSINESS KPI ANALYSIS
-- =========================================================

-- 3. Overall Conversion Rate
SELECT
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM users_summary;


-- 4. Total Revenue
SELECT
    ROUND(SUM(revenue), 2) AS total_revenue
FROM users_summary;


-- 5. Total Marketing Spend
SELECT
    ROUND(SUM(cost), 2) AS total_marketing_spend
FROM touchpoints;


-- 6. Average Revenue per User
SELECT
    ROUND(AVG(revenue), 2) AS average_revenue_per_user
FROM users_summary;


-- 7. Average Journey Length
SELECT
    ROUND(AVG(journey_length), 2) AS average_journey_length
FROM users_summary;


-- 8. Complete KPI Summary
SELECT
    COUNT(*) AS total_users,
    SUM(converted) AS converted_users,
    ROUND(100.0 * SUM(converted) / COUNT(*), 2) AS conversion_rate_pct,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS average_revenue_per_user,
    ROUND(AVG(journey_length), 2) AS average_journey_length
FROM users_summary;


-- 9. Marketing Spend + Revenue + ROAS

SELECT
    ROUND(m.total_marketing_spend, 2) AS total_marketing_spend,
    ROUND(r.total_revenue, 2) AS total_revenue,
    ROUND(
        r.total_revenue / NULLIF(m.total_marketing_spend, 0),
        2
    ) AS overall_roas
FROM
    (
        SELECT SUM(cost) AS total_marketing_spend
        FROM touchpoints
    ) m
CROSS JOIN
    (
        SELECT SUM(revenue) AS total_revenue
        FROM users_summary
    ) r;
    
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


DESCRIBE touchpoints;


-- =========================================================
-- STEP 7: FIRST-TOUCH VS LAST-TOUCH ATTRIBUTION
-- =========================================================

WITH first_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order ASC
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

first_summary AS (
    SELECT
        f.channel,
        COUNT(*) AS first_touch_users,
        SUM(u.converted) AS first_touch_conversions,
        ROUND(SUM(u.revenue), 2) AS first_touch_revenue
    FROM first_touch f
    JOIN users_summary u
        ON f.user_id = u.user_id
    WHERE f.rn = 1
    GROUP BY f.channel
),

last_summary AS (
    SELECT
        l.channel,
        COUNT(*) AS last_touch_users,
        SUM(u.converted) AS last_touch_conversions,
        ROUND(SUM(u.revenue), 2) AS last_touch_revenue
    FROM last_touch l
    JOIN users_summary u
        ON l.user_id = u.user_id
    WHERE l.rn = 1
    GROUP BY l.channel
)

SELECT
    COALESCE(f.channel, l.channel) AS channel,

    COALESCE(f.first_touch_users, 0) AS first_touch_users,
    COALESCE(f.first_touch_conversions, 0) AS first_touch_conversions,
    COALESCE(f.first_touch_revenue, 0) AS first_touch_revenue,

    COALESCE(l.last_touch_users, 0) AS last_touch_users,
    COALESCE(l.last_touch_conversions, 0) AS last_touch_conversions,
    COALESCE(l.last_touch_revenue, 0) AS last_touch_revenue

FROM first_summary f

LEFT JOIN last_summary l
    ON f.channel = l.channel

ORDER BY first_touch_revenue DESC;

-- =========================================================
-- STEP 8.1: MARKETING SPEND BY CHANNEL
-- =========================================================

SELECT
    channel,
    COUNT(*) AS touchpoints,
    ROUND(SUM(cost), 2) AS marketing_spend
FROM touchpoints
GROUP BY channel
ORDER BY marketing_spend DESC;

-- =========================================================
-- STEP 8.2: CAC BY CHANNEL
-- =========================================================

WITH last_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order DESC
        ) AS rn
    FROM touchpoints
),

channel_spend AS (
    SELECT
        channel,
        ROUND(SUM(cost), 2) AS marketing_spend
    FROM touchpoints
    GROUP BY channel
),

channel_conversions AS (
    SELECT
        l.channel,
        COUNT(DISTINCT l.user_id) AS last_touch_conversions
    FROM last_touch l
    JOIN users_summary u
        ON l.user_id = u.user_id
    WHERE l.rn = 1
      AND u.converted = 1
    GROUP BY l.channel
)

SELECT
    s.channel,
    s.marketing_spend,
    COALESCE(c.last_touch_conversions, 0) AS last_touch_conversions,

    CASE
        WHEN COALESCE(c.last_touch_conversions, 0) = 0
        THEN NULL
        ELSE ROUND(
            s.marketing_spend / c.last_touch_conversions,
            2
        )
    END AS cac

FROM channel_spend s

LEFT JOIN channel_conversions c
    ON s.channel = c.channel

ORDER BY cac ASC;

-- #Step 8.3-. ROAS by Channel

SELECT
    channel,
    ROUND(SUM(cost), 2) AS marketing_spend,
    ROUND(SUM(CASE
        WHEN converted = 1 THEN revenue
        ELSE 0
    END), 2) AS attributed_revenue,
    ROUND(
        SUM(CASE
            WHEN converted = 1 THEN revenue
            ELSE 0
        END) / NULLIF(SUM(cost), 0),
        2
    ) AS roas
FROM touchpoints
GROUP BY channel
ORDER BY roas DESC;

-- STEP 9: Correct Channel Efficiency Summary

WITH last_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order DESC
        ) AS rn
    FROM touchpoints
),

channel_spend AS (
    SELECT
        channel,
        COUNT(*) AS touchpoints,
        ROUND(SUM(cost), 2) AS marketing_spend
    FROM touchpoints
    GROUP BY channel
),

channel_attribution AS (
    SELECT
        l.channel,
        COUNT(*) AS conversions,
        ROUND(SUM(u.revenue), 2) AS attributed_revenue
    FROM last_touch l
    JOIN users_summary u
        ON l.user_id = u.user_id
    WHERE l.rn = 1
      AND u.converted = 1
    GROUP BY l.channel
)

SELECT
    s.channel,
    s.touchpoints,
    s.marketing_spend,
    COALESCE(a.conversions, 0) AS conversions,
    COALESCE(a.attributed_revenue, 0) AS attributed_revenue,

    ROUND(
        s.marketing_spend /
        NULLIF(a.conversions, 0),
        2
    ) AS cac,

    ROUND(
        a.attributed_revenue /
        NULLIF(s.marketing_spend, 0),
        2
    ) AS roas

FROM channel_spend s

LEFT JOIN channel_attribution a
    ON s.channel = a.channel

ORDER BY roas DESC;

-- STEP 10: First-Touch vs Last-Touch Attribution

WITH first_touch AS (
    SELECT
        user_id,
        channel,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY touch_order ASC
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

first_touch_analysis AS (
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

last_touch_analysis AS (
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

    COALESCE(f.first_touch_conversions, 0)
        AS first_touch_conversions,

    COALESCE(f.first_touch_revenue, 0)
        AS first_touch_revenue,

    COALESCE(l.last_touch_conversions, 0)
        AS last_touch_conversions,

    COALESCE(l.last_touch_revenue, 0)
        AS last_touch_revenue

FROM first_touch_analysis f

LEFT JOIN last_touch_analysis l
    ON f.channel = l.channel

UNION

SELECT
    l.channel,

    COALESCE(f.first_touch_conversions, 0)
        AS first_touch_conversions,

    COALESCE(f.first_touch_revenue, 0)
        AS first_touch_revenue,

    COALESCE(l.last_touch_conversions, 0)
        AS last_touch_conversions,

    COALESCE(l.last_touch_revenue, 0)
        AS last_touch_revenue

FROM last_touch_analysis l

LEFT JOIN first_touch_analysis f
    ON l.channel = f.channel

ORDER BY last_touch_revenue DESC;
-- STEP 11.1: Conversion Rate by Journey Length

SELECT
    journey_length,
    COUNT(*) AS total_users,
    SUM(converted) AS converted_users,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_user
FROM users_summary
GROUP BY journey_length
ORDER BY journey_length;
-- STEP 11.2: Revenue Efficiency by Journey Length

SELECT
    journey_length,

    COUNT(*) AS total_users,

    SUM(converted) AS converted_users,

    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue) / NULLIF(SUM(converted), 0),
        2
    ) AS revenue_per_converted_user

FROM users_summary

GROUP BY journey_length

ORDER BY revenue_per_converted_user DESC;

-- STEP 11.3: Conversion Lift by Journey Length

WITH journey_metrics AS (
    SELECT
        journey_length,
        COUNT(*) AS total_users,
        SUM(converted) AS converted_users,
        ROUND(
            100.0 * SUM(converted) / COUNT(*),
            2
        ) AS conversion_rate_pct
    FROM users_summary
    GROUP BY journey_length
)

SELECT
    journey_length,
    total_users,
    converted_users,
    conversion_rate_pct,

    ROUND(
        conversion_rate_pct -
        FIRST_VALUE(conversion_rate_pct) OVER (
            ORDER BY journey_length
        ),
        2
    ) AS conversion_lift_vs_1_touch

FROM journey_metrics

ORDER BY journey_length;
-- STEP 11.4 FINAL: Customer Journey Performance Summary

WITH journey_metrics AS (
    SELECT
        journey_length,
        COUNT(*) AS total_users,
        SUM(converted) AS converted_users,

        ROUND(
            100.0 * SUM(converted) / COUNT(*),
            2
        ) AS conversion_rate_pct,

        ROUND(SUM(revenue), 2) AS total_revenue,

        ROUND(
            AVG(revenue),
            2
        ) AS avg_revenue_per_user,

        ROUND(
            SUM(revenue) /
            NULLIF(SUM(converted), 0),
            2
        ) AS revenue_per_converted_user

    FROM users_summary

    GROUP BY journey_length
),

overall_revenue AS (
    SELECT
        SUM(revenue) AS total_company_revenue
    FROM users_summary
)

SELECT
    j.journey_length,

    j.total_users,

    j.converted_users,

    j.conversion_rate_pct,

    ROUND(
        j.conversion_rate_pct -
        FIRST_VALUE(j.conversion_rate_pct) OVER (
            ORDER BY j.journey_length
        ),
        2
    ) AS conversion_lift_vs_1_touch,

    j.total_revenue,

    j.avg_revenue_per_user,

    j.revenue_per_converted_user,

    ROUND(
        100.0 * j.total_users /
        SUM(j.total_users) OVER (),
        2
    ) AS user_share_pct,

    ROUND(
        100.0 * j.total_revenue /
        NULLIF(o.total_company_revenue, 0),
        2
    ) AS revenue_share_pct,

    RANK() OVER (
        ORDER BY j.conversion_rate_pct DESC
    ) AS conversion_rate_rank,

    RANK() OVER (
        ORDER BY j.revenue_per_converted_user DESC
    ) AS revenue_efficiency_rank

FROM journey_metrics j

CROSS JOIN overall_revenue o

ORDER BY j.journey_length;

-- ============================================================
-- STEP 7: FINAL BUSINESS INSIGHTS
-- Multi-Channel Marketing Attribution & CAC Analysis
-- ============================================================


-- ============================================================
-- 1. CHANNEL PERFORMANCE SUMMARY
-- ============================================================

SELECT
    channel,
    COUNT(*) AS touchpoints,
    ROUND(SUM(cost), 2) AS marketing_spend,
    SUM(converted) AS conversions,
    ROUND(
        SUM(CASE
            WHEN converted = 1 THEN revenue
            ELSE 0
        END), 2
    ) AS attributed_revenue,
    ROUND(
        SUM(cost) / NULLIF(SUM(converted), 0),
        2
    ) AS cac,
    ROUND(
        SUM(CASE
            WHEN converted = 1 THEN revenue
            ELSE 0
        END) / NULLIF(SUM(cost), 0),
        2
    ) AS roas
FROM touchpoints
GROUP BY channel
ORDER BY roas DESC;


-- ============================================================
-- 2. CHANNEL RANKING BY ROAS
-- ============================================================

SELECT
    channel,
    ROUND(SUM(cost), 2) AS marketing_spend,
    ROUND(
        SUM(CASE
            WHEN converted = 1 THEN revenue
            ELSE 0
        END), 2
    ) AS attributed_revenue,
    ROUND(
        SUM(CASE
            WHEN converted = 1 THEN revenue
            ELSE 0
        END) / NULLIF(SUM(cost), 0),
        2
    ) AS roas,
    RANK() OVER (
        ORDER BY
            SUM(CASE
                WHEN converted = 1 THEN revenue
                ELSE 0
            END) / NULLIF(SUM(cost), 0) DESC
    ) AS roas_rank
FROM touchpoints
GROUP BY channel
ORDER BY roas_rank;
-- ============================================================
-- 3. CHANNEL CAC RANKING
-- ============================================================

SELECT
    channel,
    ROUND(SUM(cost), 2) AS marketing_spend,
    SUM(converted) AS conversions,
    ROUND(
        SUM(cost) / NULLIF(SUM(converted), 0),
        2
    ) AS cac,
    RANK() OVER (
        ORDER BY
            SUM(cost) / NULLIF(SUM(converted), 0)
    ) AS cac_rank
FROM touchpoints
GROUP BY channel
ORDER BY cac_rank;


-- ============================================================
-- 4. MARKETING SPEND DISTRIBUTION
-- ============================================================

SELECT
    channel,
    ROUND(SUM(cost), 2) AS marketing_spend,
    ROUND(
        100.0 * SUM(cost) /
        NULLIF(
            (SELECT SUM(cost) FROM touchpoints),
            0
        ),
        2
    ) AS spend_share_pct
FROM touchpoints
GROUP BY channel
ORDER BY spend_share_pct DESC;


-- ============================================================
-- 5. REVENUE CONTRIBUTION BY CHANNEL
-- ============================================================

SELECT
    channel,
    ROUND(
        SUM(CASE
            WHEN converted = 1 THEN revenue
            ELSE 0
        END), 2
    ) AS attributed_revenue,
    ROUND(
        100.0 *
        SUM(CASE
            WHEN converted = 1 THEN revenue
            ELSE 0
        END)
        /
        NULLIF(
            (
                SELECT SUM(
                    CASE
                        WHEN converted = 1 THEN revenue
                        ELSE 0
                    END
                )
                FROM touchpoints
            ),
            0
        ),
        2
    ) AS revenue_share_pct
FROM touchpoints
GROUP BY channel
ORDER BY revenue_share_pct DESC;


-- ============================================================
-- 6. CONVERSION PERFORMANCE BY CHANNEL
-- ============================================================

SELECT
    channel,
    COUNT(DISTINCT user_id) AS users,
    COUNT(*) AS touchpoints,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) /
        NULLIF(COUNT(*), 0),
        2
    ) AS touchpoint_conversion_rate_pct
FROM touchpoints
GROUP BY channel
ORDER BY touchpoint_conversion_rate_pct DESC;
-- ============================================================
-- 7. FIRST-TOUCH VS LAST-TOUCH COMPARISON
-- ============================================================

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

    COUNT(DISTINCT f.user_id) AS first_touch_users,

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

    COUNT(DISTINCT l.user_id) AS last_touch_users,

    SUM(
        CASE
            WHEN u.converted = 1 THEN 1
            ELSE 0
        END
    ) AS last_touch_conversions,

    ROUND(
        SUM(
            CASE
                WHEN u.converted = 1 THEN u.revenue
                ELSE 0
            END
        ),
        2
    ) AS last_touch_revenue

FROM first_touch f

JOIN users_summary u
    ON f.user_id = u.user_id

LEFT JOIN last_touch l
    ON f.user_id = l.user_id
    AND l.rn = 1

WHERE f.rn = 1

GROUP BY f.channel
ORDER BY first_touch_revenue DESC;


-- ============================================================
-- 8. JOURNEY LENGTH PERFORMANCE
-- ============================================================

SELECT
    journey_length,
    COUNT(*) AS total_users,
    SUM(converted) AS converted_users,

    ROUND(
        100.0 * SUM(converted) /
        NULLIF(COUNT(*), 0),
        2
    ) AS conversion_rate_pct,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        AVG(revenue),
        2
    ) AS avg_revenue_per_user,

    ROUND(
        AVG(
            CASE
                WHEN converted = 1 THEN revenue
                ELSE NULL
            END
        ),
        2
    ) AS avg_revenue_per_converted_user

FROM users_summary
GROUP BY journey_length
ORDER BY journey_length;
-- ============================================================
-- 9. JOURNEY LENGTH: CONVERSION LIFT
-- ============================================================

WITH journey_metrics AS (

    SELECT
        journey_length,

        COUNT(*) AS total_users,

        SUM(converted) AS converted_users,

        ROUND(
            100.0 * SUM(converted) /
            NULLIF(COUNT(*), 0),
            2
        ) AS conversion_rate_pct

    FROM users_summary
    GROUP BY journey_length
)

SELECT
    journey_length,
    total_users,
    converted_users,
    conversion_rate_pct,

    ROUND(
        conversion_rate_pct -
        FIRST_VALUE(conversion_rate_pct) OVER (
            ORDER BY journey_length
        ),
        2
    ) AS conversion_lift_vs_shortest_journey

FROM journey_metrics
ORDER BY journey_length;


-- ============================================================
-- 10. EXECUTIVE KPI SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS total_users,

    SUM(converted) AS total_converted_users,

    ROUND(
        100.0 * SUM(converted) /
        NULLIF(COUNT(*), 0),
        2
    ) AS overall_conversion_rate_pct,

    ROUND(
        SUM(revenue),
        2
    ) AS total_revenue,

    ROUND(
        AVG(revenue),
        2
    ) AS average_revenue_per_user,

    ROUND(
        AVG(
            CASE
                WHEN converted = 1 THEN revenue
                ELSE NULL
            END
        ),
        2
    ) AS average_revenue_per_converted_user,

    ROUND(
        AVG(journey_length),
        2
    ) AS average_journey_length

FROM users_summary;
-- ============================================================
-- 11. FINAL PAID CHANNEL INVESTMENT ANALYSIS
-- ============================================================

SELECT
    channel,

    ROUND(SUM(cost), 2) AS marketing_spend,

    SUM(converted) AS conversions,

    ROUND(
        SUM(cost) / NULLIF(SUM(converted), 0),
        2
    ) AS cac,

    ROUND(
        SUM(
            CASE
                WHEN converted = 1 THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS attributed_revenue,

    ROUND(
        SUM(
            CASE
                WHEN converted = 1 THEN revenue
                ELSE 0
            END
        )
        /
        NULLIF(SUM(cost), 0),
        2
    ) AS roas,

    CASE
        WHEN SUM(cost) = 0 THEN 'No Paid Spend'
        WHEN
            SUM(
                CASE
                    WHEN converted = 1 THEN revenue
                    ELSE 0
                END
            ) / NULLIF(SUM(cost), 0) >= 10
            THEN 'High Efficiency'

        WHEN
            SUM(
                CASE
                    WHEN converted = 1 THEN revenue
                    ELSE 0
                END
            ) / NULLIF(SUM(cost), 0) >= 5
            THEN 'Good Efficiency'

        ELSE 'Needs Optimization'
    END AS investment_category

FROM touchpoints
GROUP BY channel
ORDER BY roas DESC;
-- ============================================================
-- 12. FINAL CHANNEL SCORECARD
-- ============================================================

SELECT
    channel,

    ROUND(SUM(cost), 2) AS marketing_spend,

    SUM(converted) AS conversions,

    ROUND(
        SUM(cost) / NULLIF(SUM(converted), 0),
        2
    ) AS cac,

    ROUND(
        SUM(
            CASE
                WHEN converted = 1 THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS attributed_revenue,

    ROUND(
        SUM(
            CASE
                WHEN converted = 1 THEN revenue
                ELSE 0
            END
        ) / NULLIF(SUM(cost), 0),
        2
    ) AS roas,

    CASE
        WHEN SUM(cost) = 0
            THEN 'Organic / Unpaid'

        WHEN
            SUM(
                CASE
                    WHEN converted = 1 THEN revenue
                    ELSE 0
                END
            ) / NULLIF(SUM(cost), 0) >= 10
            THEN 'Scale'

        WHEN
            SUM(
                CASE
                    WHEN converted = 1 THEN revenue
                    ELSE 0
                END
            ) / NULLIF(SUM(cost), 0) >= 5
            THEN 'Maintain / Optimize'

        ELSE 'Review Spend'
    END AS management_action

FROM touchpoints
GROUP BY channel
ORDER BY
    CASE
        WHEN SUM(cost) = 0 THEN 3
        WHEN
            SUM(
                CASE
                    WHEN converted = 1 THEN revenue
                    ELSE 0
                END
            ) / NULLIF(SUM(cost), 0) >= 10
            THEN 1
        WHEN
            SUM(
                CASE
                    WHEN converted = 1 THEN revenue
                    ELSE 0
                END
            ) / NULLIF(SUM(cost), 0) >= 5
            THEN 2
        ELSE 3
    END,
    roas DESC;

USE marketing_attribution;
SHOW TABLES;
DESCRIBE touchpoints;

DESCRIBE users_summary;
SELECT * 
FROM touchpoints
LIMIT 5;
SELECT *
FROM users_summary
LIMIT 5;





