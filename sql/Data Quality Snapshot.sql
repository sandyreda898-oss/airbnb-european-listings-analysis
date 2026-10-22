CREATE DATABASE Airbnb
GO
USE Airbnb;
GO
---
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'airbnb_cleaned'
ORDER BY ORDINAL_POSITION;
---
SELECT TOP 5 
    city, property_name, 
    price_amount, price_currency,
    rating, number_of_reviews,
    superhost, guest_favorite
FROM dbo.airbnb_cleaned;

SELECT COUNT(*) AS total_rows FROM dbo.airbnb_cleaned;