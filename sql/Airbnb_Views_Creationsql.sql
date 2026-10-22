USE Airbnb;
GO

CREATE OR ALTER VIEW dbo.v_airbnb_cleaned AS
SELECT
    city,
    property_name,
    price_raw,
    price_amount,
    price_currency,
    rating,
    number_of_reviews,
    superhost,
    guest_favorite,
    price_suspicious,
    -- تصليح العمود الوحيد اللي جاي نص:
    CAST(CASE 
        WHEN reviews_outlier_flag IN ('True','true','TRUE','1') THEN 1 
        WHEN reviews_outlier_flag IN ('False','false','FALSE','0') THEN 0
        ELSE NULL 
    END AS BIT) AS reviews_outlier_flag,
    price_parse_failed,
    price_is_per_night,
    property_url,
    listing_id,
    property_name_key
FROM dbo.airbnb_cleaned;
GO
----------------------
CREATE OR ALTER VIEW dbo.v_price_ready AS
SELECT *
FROM dbo.v_airbnb_cleaned
WHERE price_amount IS NOT NULL
  AND (price_suspicious = 0 OR price_suspicious IS NULL);
GO

CREATE OR ALTER VIEW dbo.v_ratings_ready AS
SELECT *
FROM dbo.v_airbnb_cleaned
WHERE rating IS NOT NULL
  AND (reviews_outlier_flag = 0 OR reviews_outlier_flag IS NULL);
GO

CREATE OR ALTER VIEW dbo.v_master AS 
SELECT * FROM dbo.v_airbnb_cleaned;
GO

--
