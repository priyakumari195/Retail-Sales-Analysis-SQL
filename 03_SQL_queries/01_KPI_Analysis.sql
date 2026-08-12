/*
==========================================
Retail Sales Analysis
File : 01_KPI_Analysis.sql

Author : Priya Kumari
Database : classicmodels

Description:
Executive Sales KPIs
==========================================
*/

-- KPI 1 : Total Sales (quantityOrdered * priceEach)
WITH total as
(
SELECT 
   orderNumber,
   SUM(quantityOrdered * priceEach)AS sales
FROM orderdetails
GROUP BY orderNumber
)
SELECT
SUM(sales) as total_sales
FROM total;

-- KPI 2 : Total Orders( Unique Orders)
SELECT 
    COUNT(distinct(orderNumber)) as Total_Orders
FROM orders;

-- KPI 3 : Total Customers who placed orders
SELECT 
    COUNT(DISTINCT(customerNumber)) as total_customers
FROM orders ;
-- KPI 4 : Average Order Value (Formula = total sales / total orders) 

SELECT
    SUM(od.quantityOrdered * od.priceEach)
    / COUNT(DISTINCT o.orderNumber) AS avg_order_value
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber;
    
-- KPI 5 : Average sales per customer ( Formula = total sales / customer who placed orders)

SELECT
    SUM(od.quantityOrdered * od.priceEach)
    / COUNT(DISTINCT o.customerNumber) AS avg_sales_per_customer
FROM orders o
JOIN orderdetails od
    ON o.orderNumber = od.orderNumber;  
    
-- KPI 6 : Total Quantity Sold
SELECT
   SUM(quantityOrdered)  as Total_quantity_sold
FROM orderdetails;

-- KPI 7 : Average Products Per Order ( Formula = total quantity sold / total orders)

SELECT 
    SUM(quantityOrdered) 
    /
	COUNT(DISTINCT(orderNumber)) as avg_product_per_order
FROM orderDetails;

-- KPI 8 : Highest Single Order Value 

with revenue as
(
SELECT 
    orderNumber,
	SUM(quantityOrdered * priceEach ) as sales
	FROM orderDetails
	GROUP by orderNumber
)
SELECT
   MAX(sales) as Highest_single_order_value
FROM revenue
;