USE marketing_attribution;

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