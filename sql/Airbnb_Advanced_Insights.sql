----- Best Value Listings (Price vs. Quality)
WITH best_value AS (
    SELECT 
        r.city, 
        r.property_name, 
        r.rating, 
        r.number_of_reviews,
        CAST(p.price_amount AS FLOAT) AS price_usd
    FROM dbo.v_ratings_ready r
    INNER JOIN dbo.v_price_ready p ON r.property_url = p.property_url
    WHERE p.price_currency = 'USD'
      AND r.rating >= 4.9
      AND r.number_of_reviews >= 50
)
SELECT TOP 15
    city, 
    property_name, 
    price_usd, 
    rating, 
    number_of_reviews,
    CAST(price_usd / rating AS DECIMAL(10,0)) AS price_per_rating_point
FROM best_value
ORDER BY price_per_rating_point ASC;
----Top 10 Listings by Quality Score
SELECT TOP 10
    city,
    property_name,
    rating,
    number_of_reviews,
    price_amount,
    price_currency,
    CAST(rating * LOG(1.0 + number_of_reviews) AS DECIMAL(10,2)) AS quality_score
FROM dbo.v_ratings_ready
ORDER BY quality_score DESC;
----Price vs. Rating Correlation
WITH corr_data AS (
    SELECT 
        r.city,
        CAST(r.rating AS FLOAT) AS x,
        CAST(p.price_amount AS FLOAT) AS y
    FROM dbo.v_ratings_ready r
    INNER JOIN dbo.v_price_ready p ON r.property_url = p.property_url
    WHERE p.price_currency = 'USD'
)
SELECT
    city,
    COUNT(*) AS n,
    CAST(
        (COUNT(*) * SUM(x*y) - SUM(x)*SUM(y)) 
        / NULLIF(SQRT((COUNT(*)*SUM(x*x) - SUM(x)*SUM(x)) * (COUNT(*)*SUM(y*y) - SUM(y)*SUM(y))), 0)
    AS DECIMAL(6,3)) AS correlation_price_rating
FROM corr_data
GROUP BY city
HAVING COUNT(*) >= 10
ORDER BY correlation_price_rating DESC;