CREATE TABLE Superstore (
    Row_ID INT,
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(255),
    Segment VARCHAR(50),
    Country VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100),
    Postal_Code INT,
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100),
    Product_Name VARCHAR(MAX),
    Sales FLOAT,
    Quantity INT,
    Discount FLOAT,
    Profit FLOAT
);
BULK INSERT Superstore
FROM "D:\Task\cleaned_superstore.csv"
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


-----1----

SELECT SUM(Sales) AS Total_Sales,SUM(Profit) AS Total_Profit,SUM(Quantity) AS Total_Quantity
FROM Superstore;


----2---



SELECT FORMAT(Order_Date, 'yyyy-MM') AS Month,SUM(Sales) AS Monthly_Sales
FROM Superstore
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Month;



--3--

SELECT YEAR(Order_Date) AS Year, SUM(Sales) AS Sales_By_Year
FROM Superstore
GROUP BY YEAR(Order_Date)
ORDER BY Year;



--4--

SELECT TOP 10 Product_Name,SUM(Sales) AS Total_Sales
FROM Superstore
GROUP BY Product_Name
ORDER BY Total_Sales DESC;

---5---



SELECT TOP 10 Customer_ID,Customer_Name,SUM(Sales) AS Total_Sales
FROM Superstore
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC;


--6--

SELECT Category, SUM(Sales)  AS Total_Sales,SUM(Profit) AS Total_Profit,
    CASE WHEN SUM(Sales) = 0 THEN 0
         ELSE ROUND( (SUM(Profit) / SUM(Sales)) * 100.0, 2 )
    END AS Profit_Margin_Percent
FROM Superstore
GROUP BY Category
ORDER BY Profit_Margin_Percent DESC;

--7--



SELECT Region,SUM(Sales)  AS Total_Sales,SUM(Profit) AS Total_Profit
FROM Superstore
GROUP BY Region
ORDER BY Total_Sales DESC;


--8--


SELECT Discount_Bucket,
    COUNT(*) AS Orders,
    ROUND(AVG(Discount) * 100.0, 2) AS Avg_Discount_Percent,
    ROUND(AVG(Profit), 2) AS Avg_Profit,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM (SELECT *,CASE
            WHEN Discount = 0 THEN '0%'
            WHEN Discount > 0 AND Discount <= 0.10 THEN '0.01-10%'
            WHEN Discount > 0.10 AND Discount <= 0.25 THEN '10.01-25%'
            WHEN Discount > 0.25 AND Discount <= 0.50 THEN '25.01-50%'
            ELSE '>50%'
        END AS Discount_Bucket
    FROM Superstore) t
GROUP BY Discount_Bucket
ORDER BY Discount_Bucket;

--9--


SELECT Product_Name,
    SUM(Sales)  AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Superstore
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


--10--

WITH totals AS (
    SELECT SUM(Sales) AS Grand_Total FROM Superstore
)
SELECT
    s.Segment,
    SUM(s.Sales) AS Segment_Sales,
    ROUND( (SUM(s.Sales) / t.Grand_Total) * 100.0, 2) AS Contribution_Percent
FROM Superstore s
CROSS JOIN totals t
GROUP BY s.Segment, t.Grand_Total
ORDER BY Contribution_Percent DESC;

--11--
SELECT
    Order_ID,
    DATEDIFF(day, Order_Date, Ship_Date) AS Shipping_Days
FROM Superstore;

--12--

SELECT
    s.Order_ID,
    s.Product_Name,
    s.Sales,
    s.Profit
FROM Superstore s
CROSS JOIN (
    SELECT
        AVG(Sales) AS Mean_Sales,
        STDEV(Sales) AS Stdev_Sales,
        AVG(Profit) AS Mean_Profit,
        STDEV(Profit) AS Stdev_Profit
    FROM Superstore
) stats
WHERE 
    s.Sales > (stats.Mean_Sales + 3 * stats.Stdev_Sales)
    OR
    s.Profit < (stats.Mean_Profit - 3 * stats.Stdev_Profit)
ORDER BY s.Sales DESC;
