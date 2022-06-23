SELECT *
FROM cust_dimen

SELECT *
FROM orders_dimen

SELECT *
FROM prod_dimen

select *
from shipping_dimen

SELECT *
FROM market_fact

-- for cust_dimen table, cust_id column will be arranged
UPDATE dbo.cust_dimen 
SET Cust_id = TRIM('Cust_' from Cust_id)
FROM dbo.cust_dimen

--- changed type of cust_id to integer from nvarchar from design section 




-- for orders_dimen table, ord_id column will be arranged
UPDATE dbo.orders_dimen 
SET Ord_id = TRIM('Ord_' from Ord_id)
FROM dbo.orders_dimen

-- type of Ord_id was changed with command
alter table orders_dimen
ALTER COLUMN Ord_id int;



-- for prod_dimen table, prod_id column will be arranged
UPDATE dbo.prod_dimen 
SET Prod_id = TRIM('Prod_' from Prod_id)
FROM dbo.prod_dimen

-- type of prod_id was changed with command
alter table prod_dimen
ALTER COLUMN prod_id int;




-- for shipping_dimen table, Ship_id column will be arranged
UPDATE dbo.shipping_dimen 
SET ship_id = TRIM('SHP_' from Ship_id)
FROM dbo.shipping_dimen

-- type of ship_id was changed with command
alter table shipping_dimen
ALTER COLUMN ship_id int;



-- for market_fact table, Ship_id column will be arranged
UPDATE dbo.market_fact
SET Cust_id = TRIM('Cust_' from Cust_id), 
	Ord_id = TRIM('Ord_' from Ord_id),
	Prod_id = TRIM('Prod_' from Prod_id),	
	Ship_id = TRIM('SHP_' from Ship_id)
FROM dbo.market_fact
--- changed types of cust_id, prod_id, ord_id, ship_id to integer from nvarchar from design section 

select *
from shipping_dimen

-- Since there is a column with the similar name in the orders_dimen table, 
-- We changed the name of Order_ID(in Shipping_dimen table) into Cargo_track_id avoid confusion




-- 1. Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”,
-- “prod_dimen”, “shipping_dimen”, Create a new table, named as “combined_table”
SELECT m.*, c.Customer_Name, c.Province, c.Region, c.Customer_Segment, o.Order_Date, o.Order_Priority, 
       p.Product_Category, p.Product_Sub_Category, s.Cargo_Track_id, s.Ship_Date, s.Ship_Mode
INTO combined_table
FROM market_fact m
LEFT JOIN cust_dimen c
ON m.Cust_id = C.Cust_id
LEFT JOIN orders_dimen o
ON M.Ord_id = o.Ord_id
LEFT JOIN prod_dimen p
ON m.Prod_id = p.Prod_id
LEFT JOIN shipping_dimen s
ON m.Ship_id = s.Ship_id


SELECT * 
FROM combined_table



-- 2. Find the top 3 customers who have the maximum count of orders.
SELECT TOP 3 Cust_id, Customer_Name,  COUNT(Ord_id) count_of_order
FROM combined_table
GROUP BY Cust_id, Customer_Name
ORDER BY count_of_order DESC


-- 3. Create a new column at combined_table as DaysTakenForDelivery that
-- contains the date difference of Order_Date and Ship_Date.

ALTER TABLE combined_table
ADD DaysTakenForDelivery int 

SELECT *, DATEDIFF(DAY, order_date, Ship_Date) DaysTakenForDelivery
FROM combined_table

UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(DAY, order_date, Ship_Date)
FROM combined_table 


-- 4. Find the customer whose order took the maximum time to get delivered.

SELECT TOP 1 Cust_id, Customer_Name, DaysTakenForDelivery max_delivery
FROM combined_table
ORDER BY max_delivery DESC


-- 5. Count the total number of unique customers in January and how many of them
-- came back every month over the entire year in 2011

WITH tbl AS (
SELECT DISTINCT Cust_id, Order_Date
FROM combined_table
WHERE MONTH(Order_Date) = '01' 
)
SELECT COUNT(Cust_id) loyal_cust_count
FROM tbl
WHERE MONTH(Order_Date) IN ('01', '02','03','04','05','06','07','08','09','10','11','12') AND
		YEAR(Order_Date) = 2011



-- 6. Write a query to return for each user the time elapsed between the first 
-- purchasing and the third purchasing, in ascending order by Customer ID.

SELECT distinct Cust_id, Order_date, 
		ROW_NUMBER() OVER(PARTITION BY Cust_id ORDER BY Order_date) row_numbers
FROM combined_table
ORDER  BY 1



WITH tbl AS (
SELECT distinct Cust_id, Order_date, 
		ROW_NUMBER() OVER(PARTITION BY Cust_id ORDER BY Order_date) row_numbers
FROM combined_table
),  tbl2 as (
SELECT Cust_id, Order_date
FROM tbl
WHERE row_numbers = 1
), tbl3 as (
SELECT Cust_id, Order_date
FROM tbl
WHERE row_numbers = 3
)
SELECT  tbl2.Cust_id, datediff(day, tbl2.Order_Date, tbl3.Order_Date) date_
FROM tbl2, tbl3
WHERE tbl2.Cust_id = tbl3.Cust_id
ORDER BY 1














