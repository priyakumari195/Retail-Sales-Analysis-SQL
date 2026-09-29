/*
==========================================
Retail Sales Analysis
File : 02_Customer_Analysis

Author : Priya Kumari
Database : classicmodels

Description:
Executive Sales KPIs
==========================================
*/
-- 1: Who are the top 10 customers by sales?
SELECT 
	c.customerNumber,
    customerName,
    SUM(quantityOrdered * priceEach) AS sales
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
JOIN orderdetails od
    ON o.orderNumber =od.orderNumber
GROUP BY customerNumber
ORDER BY SUM(quantityOrdered * priceEach) DESC
limit 10 ;

-- 2: Which customers have placed the most orders?
SELECT
    c.customerNumber,
    customerName,
    COUNT(orderNumber) AS total_orders   
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber , customerName
ORDER BY total_orders DESC;

-- 3: Which customers have made no recent purchases?
SELECT
    c.customerNumber,
    customerName,
    MAX(o.orderDate) AS last_order
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
GROUP BY C.customerNumber, c.customerName
HAVING MAX(o.orderDate) <
    (
       SELECT
          DATE_SUB(MAX(orderDate), INTERVAL 6 MONTH)
	   FROM orders
	);
    
    
-- 4: Which customers contribute the highest percentage of total sales?
WITH customer_details AS
(
    SELECT
        c.customerNumber,
        c.customerName,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales
    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY
        c.customerNumber,
        c.customerName
),
company_sales AS
(
    SELECT
        SUM(total_sales) AS company_total_sales
    FROM customer_details
)
SELECT
    cd.customerNumber,
    cd.customerName,
    cd.total_sales,
    (cd.total_sales / cs.company_total_sales) * 100 AS sales_percentage
FROM customer_details cd
CROSS JOIN company_sales cs
ORDER BY sales_percentage DESC;
    
-- 5: What is the average order value by customer?

WITH requirements AS
(
SELECT
   o.customerNumber,
   o.orderNumber,
   SUM(od.quantityOrdered * od.priceEach) AS order_value
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber
GROUP BY o.customerNumber,o.orderNumber
)
SELECT
   customerNumber,
   AVG(order_value) AS avg_ordervalue
 FROM requirements
   GROUP BY customerNumber
;

-- 6: Which customers are above the average customer sales?
WITH customer_details AS
(
    SELECT
        c.customerNumber,
        c.customerName,
        AVG(od.quantityOrdered * od.priceEach) AS avg_customer_sales
    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
    JOIN orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY
        c.customerNumber,
        c.customerName
)
SELECT
	 customerNumber,
     customerName,
     avg_customer_sales
FROM customer_details
ORDER BY avg_customer_sales desc
LIMIT 1;



-- 7: Which customers are high-value but low-frequency?
WITH DETAILS AS
(
SELECT 
    o.customerNumber,
    COUNT(DISTINCT(o.orderNumber)) AS total_orders,
    SUM(quantityOrdered * priceEach) AS  total_sales
FROM orders AS o
JOIN  orderdetails AS od
ON o.ordernumber = od.ordernumber
GROUP BY o.customerNumber
), 
avg_details AS
(
SELECT
   
    AVG(total_sales) AS avg_totalsales,
    AVG(total_orders) AS avg_totalorders
FROM details
)
SELECT
    c.customerNumber,
    c.customerName,
    total_sales,
    total_orders
FROM customers c
JOIN details d
CROSS JOIN avg_details  ad
WHERE total_sales > avg_totalsales
AND total_orders< avg_totalorders
ORDER BY total_Sales desc,
         total_orders asc;


-- 8: Which customers are potentially at risk?
SELECT 
	c.customerNumber,
    customerName,
    MAX(orderdate)  
from customers C
JOIN orders o 
ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber , c.customerName
HAVING max(orderDate) <
    (
       SELECT 
          date_sub(MAX(orderdate),  INTERVAL 6 month)
		FROM orders
	)
;


-- 9: What is the average order value for each customer?
WITH requirement AS
(
    SELECT 
        c.customerNumber,
        SUM(quantityOrdered * priceEach) AS total_sales,
        COUNT(DISTINCT o.orderNumber) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customerNumber = o.customerNumber
    JOIN orderdetails od 
        ON o.orderNumber = od.orderNumber
    GROUP BY c.customerNumber
)
SELECT
    customerNumber,
    total_sales,
    total_orders,
    total_sales / total_orders AS average_order_value
FROM requirement;
