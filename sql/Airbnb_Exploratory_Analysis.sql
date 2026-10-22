SELECT 
    'Master (All Data)' AS dataset, 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN price_amount IS NULL THEN 1 ELSE 0 END) AS missing_prices,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings,
    SUM(CASE WHEN price_suspicious = 1 THEN 1 ELSE 0 END) AS suspicious_prices,
    SUM(CASE WHEN reviews_outlier_flag = 1 THEN 1 ELSE 0 END) AS outlier_reviews
FROM dbo.v_master;

---City Performance & Quality Ranking
SELECT
    city,
    COUNT(*) AS listings_count,
    CAST(AVG(CAST(rating AS FLOAT)) AS DECIMAL(5,3)) AS avg_rating,
    CAST(100.0 * SUM(CASE WHEN rating >= 4.9 THEN 1 ELSE 0 END)
         / NULLIF(SUM(CASE WHEN rating IS NOT NULL THEN 1 ELSE 0 END), 0) 
         AS DECIMAL(5,1)) AS pct_4_9_plus,
    CAST(AVG(CAST(number_of_reviews AS FLOAT)) AS DECIMAL(10,0)) AS avg_reviews
FROM dbo.v_ratings_ready
GROUP BY city
ORDER BY pct_4_9_plus DESC, avg_rating DESC;

---Price Comparison by City (USD Only)

WITH usd_base AS (
    SELECT city, price_amount
    FROM dbo.v_price_ready
    WHERE price_currency = 'USD'
),
aggs AS (
    SELECT
        city,
        COUNT(*) AS n,
        AVG(CAST(price_amount AS FLOAT)) AS mean_usd,
        MIN(price_amount) AS min_usd,
        MAX(price_amount) AS max_usd
    FROM usd_base
    GROUP BY city
),
med AS (
    SELECT DISTINCT
        city,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(price_amount AS FLOAT))
            OVER (PARTITION BY city) AS median_usd
    FROM usd_base
)
SELECT
    a.city,
    a.n AS usd_listings,
    CAST(m.median_usd AS DECIMAL(10,0)) AS median_price_usd,
    CAST(a.mean_usd AS DECIMAL(10,0)) AS mean_price_usd,
    a.min_usd,
    a.max_usd
FROM aggs a
JOIN med m ON a.city = m.city
WHERE a.n >= 10
ORDER BY m.median_usd DESC;
-----Impact of Superhost & Guest Favorite Badges
SELECT
    CASE superhost WHEN 1 THEN 'Superhost' ELSE 'Regular' END AS host_type,
    CASE guest_favorite WHEN 1 THEN 'Guest Favorite' ELSE 'Not Favorite' END AS favorite_status,
    COUNT(*) AS listings,
    CAST(AVG(CAST(rating AS FLOAT)) AS DECIMAL(5,3)) AS avg_rating,
    CAST(100.0 * AVG(CASE WHEN rating >= 4.9 THEN 1.0 ELSE 0.0 END) AS DECIMAL(5,1)) AS pct_4_9_plus,
    CAST(AVG(CAST(number_of_reviews AS FLOAT)) AS DECIMAL(10,0)) AS avg_reviews
FROM dbo.v_ratings_ready
GROUP BY superhost, guest_favorite
ORDER BY avg_rating DESC;
----
