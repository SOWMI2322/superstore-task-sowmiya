create database superstore;
rename table cleaned_superstore to superstore;


-- =========================================================
-- 1. Total Sales, Profit, Quantity
-- =========================================================
SELECT 
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM superstore;


-- =========================================================
-- 2. Monthly Sales Trend (YYYY-MM)
-- =========================================================
SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
    SUM(Sales) AS Monthly_Sales
FROM superstore
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY Month;


-- =========================================================
-- 3. Year-over-Year (YoY) Sales Comparison
-- =========================================================
SELECT 
    YEAR(order_date) AS Year,
    SUM(Sales) AS Total_Sales
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY Year;



-- =========================================================
-- 4. Top 10 Products by Sales
-- =========================================================
SELECT 
    Product_Name,
    SUM(Sales) AS Total_Sales
FROM superstore
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 10;


-- =========================================================
-- 5. Top 10 Customers by Revenue
-- =========================================================
SELECT 
    Customer_Name,
    SUM(Sales) AS Revenue
FROM superstore
GROUP BY Customer_Name
ORDER BY Revenue DESC
LIMIT 10;


-- =========================================================
-- 6. Category-wise Profit Margin
-- Profit Margin = SUM(Profit) / SUM(Sales)
-- =========================================================
SELECT 
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    (SUM(Profit) / SUM(Sales)) * 100 AS Profit_Margin_Percent
FROM superstore
GROUP BY Category;


-- =========================================================
-- 7. Region Performance (Sales + Profit)
-- =========================================================
SELECT 
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY Region
ORDER BY Total_Sales DESC;


-- =========================================================
-- 8. Discount Impact on Profitability
-- Using correlation-style bucket comparison
-- =========================================================
SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount BETWEEN 0.01 AND 0.20 THEN 'Low Discount (0–20%)'
        WHEN Discount BETWEEN 0.21 AND 0.40 THEN 'Medium Discount (21–40%)'
        ELSE 'High Discount (>40%)'
    END AS Discount_Bucket,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    AVG(Profit) AS Avg_Profit
FROM superstore
GROUP BY Discount_Bucket
ORDER BY Discount_Bucket;


-- =========================================================
-- 9. Profit Loss Analysis (Items with Negative Profit)
-- =========================================================
SELECT 
    Order_ID,
    Product_Name,
    Sales,
    Profit
FROM superstore
WHERE Profit < 0
ORDER BY Profit;


-- =========================================================
-- 10. Segment Contribution Percentage
-- =========================================================
SELECT 
    Segment,
    SUM(Sales) AS Segment_Sales,
    (SUM(Sales) / (SELECT SUM(Sales) FROM superstore)) * 100 AS Contribution_Percent
FROM superstore
GROUP BY Segment;


-- =========================================================
-- 11. Shipping Time (Ship Date - Order Date)
-- =========================================================
SELECT
    Order_ID,
    DATEDIFF(Ship_Date, Order_Date) AS Shipping_Days
FROM superstore;


-- =========================================================
-- 12. Identify Outlier Orders (High Sales OR High Loss)
--     High Sales: > 95th percentile
--     High Loss: Profit < -100 OR Profit < 5th percentile
-- =========================================================

-- High Sales Outliers
SELECT *
FROM superstore
WHERE Sales > (
    SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY Sales)
);

-- High Loss Outliers (Negative Profit)
SELECT *
FROM superstore
WHERE Profit < (
    SELECT PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY Profit)
);