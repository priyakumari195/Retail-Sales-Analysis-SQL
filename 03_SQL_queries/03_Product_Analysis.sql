/*
==========================================
Retail Sales Analysis
File : 03_Product
_Analysis

Author : Priya Kumari
Database : classicmodels

Description:
Executive Sales KPIs
==========================================
*/

-- Q1. Top-selling products
-- Which products generate the highest total sales?

WITH details AS
(
SELECT
	productCode,
	SUM(quantityOrdered * priceEach) as total_sales
FROM orderdetails
GROUP BY productCode
)
SELECT
    p.productCode,
    p.Productname,
    total_Sales
FROM products p
JOIN  details d
ON p.productCode = d.productcode
ORDER BY d.total_sales desc;


-- Q2. Most ordered products
-- Which products have the highest number of orders?

SELECT
    od.productcode,
    productName,
    count(orderNumber) as no_of_orders
FROM orderdetails AS od
JOIN products  AS p
ON od.productCode = p.productCode
GROUP BY od.productcode , p.productName
ORDER by Count(orderNumber) desc;
    

-- Q3. Highest quantity sold
-- Which products have sold the most units?
SELECT
    od.productCode,
    p.productName,
    SUM(quantityOrdered) AS total_unit
FROM orderdetails AS od 
JOIN products AS p
ON od.productCode = p.productCode
GROUP BY od.productCode
ORDER BY SUM(quantityOrdered) desc;


-- Q4. Product contribution to total sales
-- Which products contribute the highest percentage of total sales?

WITH sales_details AS
(
SELECT
    od.productCode,
    p.productName,
    SUM(quantityOrdered * priceEach) as total_Sales
FROM orderdetails AS od
JOIN products AS p
ON od.productCode = p.productCode
GROUP by od.productCode , p.productName
), 
product_details AS
(
SELECT 
    SUM(total_Sales) AS company_total_sales
FROM sales_details
)
SELECT  
    productCode,
    productname,
    total_sales,
    (total_sales/ company_total_sales) * 100 AS sales_percentage
FROM sales_details 
CROSS JOIN product_details
ORDER BY sales_percentage DESC;
  

-- Q5. Above-average products
-- Which products generate sales above the average product sales?
WITH product_sales AS
(
SELECT 
    od. productCode,
    productName,
    SUM(quantityOrdered * priceEach) AS total_sales
FROM orderdetails AS od
JOIN products AS p
ON od.productCode = p.productCode
GROUP BY od.productCode , p.productName
),
average_product_details AS
(
SELECT 
    AVG(total_sales) AS avg_product_sales
FROM product_sales
)
SELECT
    productCode,
    productName,
    total_sales
FROM product_sales
CROSS JOIN  average_product_details
WHERE total_Sales > avg_product_sales 
ORDER BY total_sales desc;
    

-- Q6. Product-line performance
-- Which product lines generate the highest total sales?
SELECT
    productline,
    SUM(quantityOrdered * priceEach) AS total_sales
FROM orderdetails AS od
JOIN products AS p
    ON od.productCode = p.productCode
GROUP BY productline
ORDER BY total_sales DESC;



-- Q7. Top 3 Products Within Each Product Line
-- For each product line, identify the top 3 products by total sales revenue.
WITH product_Details AS
(
SELECT
    od.productCode,
    productline,
    productName,
    SUM(quantityOrdered * priceEach) AS total_sales
FROM orderDetails AS od 
JOIN products AS P
ON od.productCode = p.productCode
GROUP BY productCode  , p.productLine
),
displays AS
(
SELECT 
    productLine,
    productName,
    total_sales,
    RANK()
    OVER(PARTITION BY productline ORDER BY total_sales desc) AS P_rank
FROM product_details
)
SELECT *
FROM displays
WHERE P_rank <= 3;
    

	
-- Q8. Products Performing Above Their Product-Line Average
-- Identify products whose total sales are higher than the average product sales within their own product line.

WITH product_sales AS
(
SELECT 
    od.productCode,
    productLine,
    productName,
    SUM(quantityOrdered * priceEach) AS total_Sales
FROM orderdetails  AS od 
JOIN products AS p
ON od.productCode = p.productCode
GROUP BY od.productcode, p.productLine
),
product_sales_with_average AS
(
SELECT 
	productline,
    productName,
    total_sales,
    AVG(total_sales) OVER(partition by productline ) AS avg_product_sales
FROM product_Sales
)
SELECT *
FROM product_sales_with_average  
WHERE total_Sales  > avg_product_sales;


-- Q9. Product Revenue Contribution Within Each Product Line 
-- For every product, calculate what percentage of its product line's total revenue it contributes.

WITH product_Sales AS
(
SELECT 
   od.productCode,
   productLine,
   productName,
   SUM(quantityOrdered * priceEach) AS total_Sales
FROM orderDetails AS od
JOIN products AS p
ON od.productCode = p.productCode
GROUP BY od.productCode, p.productLine, p.productName
)
SELECT 
    productName,
    productLine,
    total_Sales,
	(total_Sales / SUM(total_sales) OVER(PARTITION BY productLine) )* 100 AS percentage_contribution
FROM  product_sales;

-- Q10. High-Volume but Low-Revenue Products
-- Identify products that have above-average quantity sold but below-average revenue.
WITH product_Details AS
(
SELECT 
    od.productCode,
    productLine,
    productName,
    SUM(quantityOrdered) AS quantitySold,
    SUM(quantityOrdered * priceEach) AS total_Sales
FROM orderDetails  AS od
JOIN products AS p
ON od.productCode = p.productCode
GROUP BY od.productCode, p.productLine,  p.productName
),
details AS
(
SELECT
    AVG(quantitySold) AS avg_quantitySold,
    AVG(total_Sales) AS avg_total_Sales
FROM product_details
)
SELECT 
    productName,
    productLine,
    quantitySold,
    total_Sales
FROM product_details    
CROSS JOIN details 
WHERE quantitySold > avg_quantitySold
AND   total_Sales < avg_total_Sales
;



-- Q11. Product Sales by Year
-- Calculate total sales for each product for every year, showing how each product's revenue changes over time.


SELECT
    od.productCode,
    productName,
	YEAR(orderDate) AS sales_year,
    SUM(quantityOrdered * priceEach) AS total_Sales
FROM orders AS o 
JOIN orderdetails AS od
   ON o.orderNumber = od.orderNumber
JOIN products AS p 
   ON od.productCode = p.productCode
GROUP BY od.productCode , p.productName, YEAR(orderDate)
ORDER BY sales_year;



-- Q12. Year-over-Year Product Performance
-- For each product, calculate its yearly sales and compare it with the previous year's sales, including the percentage change.
WITH year_sales AS
(
SELECT
    od.productCode,
    productName,
	YEAR(orderDate) AS sales_year,
    SUM(quantityOrdered * priceEach) AS total_Sales
FROM orders AS o 
JOIN orderdetails AS od
   ON o.orderNumber = od.orderNumber
JOIN products AS p 
   ON od.productCode = p.productCode
GROUP BY od.productCode , p.productName, YEAR(orderDate)
),
previous_year_details AS
(
SELECT
    productCode,
    productName,
	sales_year,
    total_Sales AS current_year_sales,
    LAG(total_Sales) OVER(PARTITION BY productCode ORDER BY sales_year) AS previous_year_sales
FROM year_Sales
)
SELECT 
	productCode,
    productName,
	sales_year,
    current_year_sales,
    previous_year_sales,
    ROUND(((current_year_sales - previous_year_sales) / previous_year_sales) *100 ,2) AS YOY_percentage_change
FROM previous_year_details
ORDER BY productCode,
         sales_year;




-- Q13. Products With Declining Sales
-- Identify products whose sales decreased compared with the previous year.
WITH current_year_sales AS
(
SELECT
    od.productCode,
    productName,
	YEAR(orderDate) AS sales_year,
    SUM(quantityOrdered * priceEach) AS total_Sales
FROM orders AS o 
JOIN orderdetails AS od
   ON o.orderNumber = od.orderNumber
JOIN products AS p 
   ON od.productCode = p.productCode
GROUP BY od.productCode , p.productName, YEAR(orderDate)
),
previous_year_sales AS
(
SELECT 
    productCode,
    productName,
    sales_year,
	LAG(total_Sales) OVER(PARTITION BY productCode ORDER BY sales_year) AS previous_year_Sales,
    total_Sales AS current_year_sales
FROM current_year_Sales
)
SELECT * ,
          ( current_year_sales - previous_year_sales   ) AS sales_change
FROM previous_year_Sales
WHERE current_year_Sales < previous_year_Sales
ORDER BY sales_year;


-- Q14. Best Product by Revenue Growth
-- Identify the product with the highest year-over-year revenue growth during the available sales period.
WITH year_sales AS
(
    SELECT
        od.productCode,
        productName,
        YEAR(orderDate) AS sales_year,
        SUM(quantityOrdered * priceEach) AS total_Sales
    FROM orders AS o 
    JOIN orderdetails AS od
        ON o.orderNumber = od.orderNumber
    JOIN products AS p 
        ON od.productCode = p.productCode
    GROUP BY od.productCode, p.productName, YEAR(orderDate)
),
previous_year_details AS
(
    SELECT
        productCode,
        productName,
        sales_year,
        total_Sales AS current_year_sales,
        LAG(total_Sales) OVER(
            PARTITION BY productCode ORDER BY sales_year
        ) AS previous_year_sales
    FROM year_sales
),
YOY_change AS
(
    SELECT 
        productCode,
        productName,
        sales_year,
        current_year_sales,
        previous_year_sales,
        CASE 
            WHEN previous_year_sales IS NULL 
                 OR previous_year_sales = 0 THEN NULL
            ELSE ROUND(
                ((current_year_sales - previous_year_sales) * 100.0)
                / previous_year_sales,2)
        END AS yoy_percentage_change    
    FROM previous_year_details
),
ranked_growth AS
(
    SELECT *,
        RANK() OVER(
            ORDER BY yoy_percentage_change DESC) AS yoy_rank
    FROM YOY_change
    WHERE previous_year_sales IS NOT NULL
)
SELECT *
FROM ranked_growth
WHERE yoy_rank = 1;
