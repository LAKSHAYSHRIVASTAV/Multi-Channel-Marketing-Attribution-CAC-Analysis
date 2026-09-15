USE marketing_attribution;

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