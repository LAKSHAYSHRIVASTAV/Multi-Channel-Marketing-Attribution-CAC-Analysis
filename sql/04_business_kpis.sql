USE marketing_attribution;

-- =====================================================
-- STEP 6: BASIC BUSINESS KPI ANALYSIS
-- =====================================================


-- 1. Total Users
SELECT
    COUNT(*) AS total_users
FROM users_summary;


-- 2. Converted Users
SELECT
    COUNT(*) AS converted_users
FROM users_summary
WHERE converted = 1;


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
    ROUND(SUM(t.cost), 2) AS total_marketing_spend,
    ROUND(SUM(u.revenue), 2) AS total_revenue,
    ROUND(
        SUM(u.revenue) / NULLIF(SUM(t.cost), 0),
        2
    ) AS overall_roas
FROM touchpoints t
CROSS JOIN (
    SELECT
        SUM(revenue) AS revenue
    FROM users_summary
) u;