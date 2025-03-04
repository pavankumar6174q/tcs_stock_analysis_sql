-- Creating the table

CREATE TABLE raw_tcs_stock (
    trade_date TEXT,
    series TEXT,
    open_price TEXT,
    high_price TEXT,
    low_price TEXT,
    prev_close TEXT,
    ltp TEXT,
    close_price TEXT,
    vwap TEXT,
    high_52w TEXT,
    low_52w TEXT,
    volume TEXT,
    trade_value TEXT,
    num_trades TEXT
);



SELECT * FROM raw_tcs_stock;


-- Checking the data types of each
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'raw_tcs_stock';



--Changing the data type of date from text to Date
ALTER TABLE raw_tcs_stock ALTER COLUMN trade_date TYPE DATE
USING TO_DATE(trade_date , 'DD-Mon-YYYY');



--Changing the other column data types from text
ALTER TABLE raw_tcs_stock 
ALTER COLUMN open_price TYPE DECIMAL(10,2) USING REPLACE(open_price, ',', '')::DECIMAL(10,2),
ALTER COLUMN high_price TYPE DECIMAL(10,2) USING REPLACE(high_price, ',', '')::DECIMAL(10,2),
ALTER COLUMN low_price TYPE DECIMAL(10,2) USING REPLACE(low_price, ',', '')::DECIMAL(10,2),
ALTER COLUMN prev_close TYPE DECIMAL(10,2) USING REPLACE(prev_close, ',', '')::DECIMAL(10,2),
ALTER COLUMN ltp TYPE DECIMAL(10,2) USING REPLACE(ltp, ',', '')::DECIMAL(10,2),
ALTER COLUMN close_price TYPE DECIMAL(10,2) USING REPLACE(close_price, ',', '')::DECIMAL(10,2),
ALTER COLUMN vwap TYPE DECIMAL(10,2) USING REPLACE(vwap, ',', '')::DECIMAL(10,2),
ALTER COLUMN high_52w TYPE DECIMAL(10,2) USING REPLACE(high_52w, ',', '')::DECIMAL(10,2),
ALTER COLUMN low_52w TYPE DECIMAL(10,2) USING REPLACE(low_52w, ',', '')::DECIMAL(10,2),
ALTER COLUMN volume TYPE BIGINT USING REPLACE(volume, ',', '')::BIGINT,
ALTER COLUMN trade_value TYPE DECIMAL(15,2) USING REPLACE(trade_value, ',', '')::DECIMAL(15,2),
ALTER COLUMN num_trades TYPE BIGINT USING REPLACE(num_trades, ',', '')::BIGINT;



--Verifying the changed data
SELECT column_name , data_type
FROM information_schema.columns
WHERE table_name = 'raw_tcs_stock';




-- ANALYSIS

select * from raw_tcs_stock;

-- Total Trading days

SELECT COUNT(trade_date) 
FROM raw_tcs_stock;




--Highest and Lowest Close Price

SELECT trade_date, close_price
FROM raw_tcs_stock
WHERE close_price = (SELECT MAX(close_price) FROM raw_tcs_stock)
OR close_price = (SELECT MIN(close_price) FROM raw_tcs_stock);




--Highest Volume

SELECT trade_date, volume
FROM raw_tcs_stock
WHERE volume = (SELECT MAX(volume) FROM raw_tcs_stock);




--Top 5 highest volume days

SELECT trade_date, volume
FROM raw_tcs_stock
ORDER BY volume DESC
LIMIT 5;



-- Biggest Single Day Price Jump

SELECT trade_date, close_price, prev_close,
ROUND(((close_price-prev_close)/prev_close) * 100,2) as percentage_change
FROM raw_tcs_stock
ORDER BY percentage_change DESC
LIMIT 1;



-- Biggest Single Day Price Drop

SELECT trade_date, close_price, prev_close,
ROUND(((close_price - prev_close)/prev_close)*100 , 2) as percentage_change
FROM raw_tcs_stock
ORDER BY percentage_change ASC
LIMIT 1;



-- Days when stock dropped more than 3%

SELECT trade_date, close_price, prev_close, 
ROUND(((close_price - prev_close) / prev_close) * 100, 2) AS percentage_change
FROM raw_tcs_stock
WHERE ((close_price - prev_close) / prev_close) * 100 < -3
ORDER BY percentage_change ASC;



-- Count Stock Up vs Down Days

SELECT 
COUNT(CASE WHEN close_price > prev_close THEN 1 END) AS Up_days,
COUNT(CASE WHEN close_price < prev_close THEN 1 END) AS Down_days
FROM raw_tcs_stock;



-- Percentage of Up days and Down days
SELECT COUNT(trade_date) as total_days,
ROUND((COUNT(CASE WHEN close_price > prev_close THEN 1 END) * 100)/COUNT(trade_date), 2) AS percent_up,
ROUND((COUNT(CASE WHEN close_price < prev_close THEN 1 END) * 100)/COUNT(trade_date),2) AS percent_down
FROM raw_tcs_stock;



-- Continuos Up days

SELECT trend, COUNT(*) AS streak_length 
FROM (
    SELECT trade_date, close_price, trend, 
           SUM(CASE WHEN trend = 'Up' THEN 0 ELSE 1 END) OVER (ORDER BY trade_date) AS streak_group
    FROM (
        SELECT trade_date, close_price, prev_close,
               CASE 
                   WHEN close_price > prev_close THEN 'Up' 
                   WHEN close_price < prev_close THEN 'Down' 
                   ELSE 'No Change' 
               END AS trend
        FROM raw_tcs_stock
    ) t
) streaks
WHERE trend != 'No Change'
GROUP BY trend, streak_group
ORDER BY streak_length DESC
LIMIT 1;


-- 7 days and 30 days moving averages

SELECT trade_date, close_price,
       ROUND(AVG(close_price) OVER (ORDER BY trade_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS ma_7,
       ROUND(AVG(close_price) OVER (ORDER BY trade_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS ma_30
FROM raw_tcs_stock;




-- VWAP trend analysis

SELECT trade_date, close_price, vwap,
       CASE 
           WHEN close_price > vwap THEN 'Above VWAP' 
           WHEN close_price < vwap THEN 'Below VWAP' 
           ELSE 'At VWAP'
       END AS vwap_trend
FROM raw_tcs_stock;


