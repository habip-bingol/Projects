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
WHERE MONTH(Order_Date) IN 
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



-- 7. Write a query that returns customers who purchased both product 11 and 
-- product 14, as well as the ratio of these products to the total number of 
-- products purchased by the customer.

SELECT Cust_id, prod_id, SUM(Order_Quantity) total_product_amount
FROM combined_table
WHERE Cust_id IN (  SELECT Cust_id 
					FROM combined_table
					WHERE Prod_id = 11 
					INTERSECT
					SELECT Cust_id
					FROM combined_table
					WHERE Prod_id = 14
					)
GROUP BY Cust_id, prod_id
ORDER BY 1


WITH tbl AS(
SELECT Cust_id, prod_id, SUM(Order_Quantity) total_product_amount
FROM combined_table
WHERE Cust_id IN (  SELECT Cust_id 
					FROM combined_table
					WHERE Prod_id = 11 
					INTERSECT
					SELECT Cust_id
					FROM combined_table
					WHERE Prod_id = 14
					)
GROUP BY Cust_id, prod_id

), tbl2 AS(
SELECT DISTINCT  Cust_id, SUM(total_product_amount) over(PaRTITION BY Cust_id) total_amount
FROM tbl
), tbl3 AS (
SELECT DISTINCT  Cust_id, SUM(total_product_amount) over(PARTITION BY Cust_id) prod11_14_total_amount
FROM tbl
WHERE prod_id = 11 or Prod_id = 14
)
SELECT tbl2.Cust_id,  CAST (1.0*(prod11_14_total_amount/total_amount) AS numeric (10,3)) ratio_of_prod_11_14
FROM tbl2, tbl3
WHERE tbl2.Cust_id = tbl3.Cust_id


---- Customer Segmentation

--- 1. Create a “view” that keeps visit logs of customers on a monthly basis. 
-- (For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW VISIT_LOGS AS 
SELECT DISTINCT Cust_id, YEAR(Order_Date) YEAR_, MONTH(Order_Date) MONTH_,
		COUNT(Order_Date) OVER(PARTITION BY Cust_id, YEAR(Order_Date), MONTH(Order_Date) ) count_of_visit
FROM combined_table

SELECT * 
FROM VISIT_LOGS
ORDER BY 1


-- 2. Create a “view” that keeps the number of monthly visits by users. 
-- (Show separately all months from the beginning business)

CREATE VIEW VISIT_LOGS_MONTHLY AS 
SELECT DISTINCT Cust_id,  MONTH(Order_Date) MONTH_,
		COUNT(Order_Date) OVER(PARTITION BY Cust_id, MONTH(Order_Date) ) count_of_visit
FROM combined_table

SELECT * 
FROM VISIT_LOGS_MONTHLY
ORDER BY 1,2

------ OPTIONAL  
SELECT DISTINCT Cust_id,  DATENAME (M, Order_Date) MONTH_,
		COUNT(Order_Date) OVER(PARTITION BY Cust_id, MONTH(Order_Date) ) count_of_visit
FROM combined_table




-- 3. For each visit of customers, create the next month of the visit as a separate column.


WITH tbl AS (
SELECT DISTINCT  Cust_id, Order_Date, 
		ROW_NUMBER() over(PARTITION BY Cust_id ORDER BY Order_Date) Rows_
FROM combined_table
)
SELECT DISTINCT Cust_id, Order_Date, 
		LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit
FROM tbl
ORDER BY 1




----- buraya bakýlacak

WITH tbl AS (
SELECT DISTINCT  Cust_id, Order_Date, 
		ROW_NUMBER() over(PARTITION BY Cust_id ORDER BY Order_Date) Rows_
FROM combined_table
), tbl2 AS (
SELECT DISTINCT Cust_id, Order_Date, 
		LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit
FROM tbl
)
SELECT *
INTO next_visit_tbl
FROM tbl2



select *
from next_visit_tbl
order by 1

SELECT distinct ct.*, nvt.next_visit
INTO Combined_table_2
FROM combined_table ct
LEFT JOIN next_visit_tbl nvt
ON ct.Cust_id = nvt.Cust_id
ORDER BY Cust_id


-- alternative
SELECT DISTINCT Cust_id, Order_Date, 
		LEAD(MONTH(Order_Date)) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit
FROM (
		SELECT DISTINCT  Cust_id, Order_Date, 
				ROW_NUMBER() over(PARTITION BY Cust_id ORDER BY Order_Date) Rows_
		FROM combined_table
		) A



-- 4. Calculate the monthly time gap between two consecutive visits by each  customer.

WITH tbl AS (
SELECT DISTINCT  Cust_id, Order_Date, 
		ROW_NUMBER() over(PARTITION BY Cust_id ORDER BY Order_Date) Rows_
FROM combined_table
), tbl2 AS (
SELECT DISTINCT Cust_id, Order_Date, 
		LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit
FROM tbl
)
SELECT  *, DATEDIFF(MONTH, Order_Date, next_visit) monthly_time_gap
FROM tbl2
ORDER BY 1


-- 5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
-- For example: 
-- Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
-- Labeled as regular if the customer has made a purchase every month.   Etc...



WITH tbl AS (
SELECT DISTINCT  Cust_id, Order_Date, 
		ROW_NUMBER() over(PARTITION BY Cust_id ORDER BY Order_Date) Rows_
FROM combined_table
), tbl2 AS (
SELECT DISTINCT Cust_id, Order_Date, 
		LEAD(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) next_visit, Rows_
FROM tbl
), tbl3 AS (
SELECT  *, DATEDIFF(MONTH, Order_Date, next_visit) monthly_time_gap
FROM tbl2
), tbl4 AS (
SELECT DISTINCT Cust_id, 
		AVG(monthly_time_gap) OVER(PARTITION BY Cust_id) avg_monthly_time_gap, 
		COUNT(Rows_) OVER(PARTITION BY Cust_id) Rows_count
FROM tbl3
), tbl5 AS (
SELECT Cust_id, avg_monthly_time_gap , Rows_count
FROM tbl4
WHERE Rows_count >= 3  AND avg_monthly_time_gap > 0
), tbl6 AS (
SELECT Cust_id, CAST ((1.0*Rows_count/avg_monthly_time_gap) AS decimal(10,3)) loyalty_score
FROM tbl5
)
SELECT * , CAST (ROUND(AVG(loyalty_score) over(), 2) AS decimal (5,2)) avg_loyalty_score
--INTO loyalty_table
FROM tbl6


--- We found that the avg of loyalty score is 2.01
--- Now we classify the cust_id acoording to loyaly score


SELECT Cust_id, loyalty_score, 
		CASE 
			WHEN loyalty_score >= 2 THEN 'Loyal'
			WHEN 2 > loyalty_score AND loyalty_score >= 1 THEN 'Normal'
			ELSE 'Churn'
		END Customer_category
INTO Customer_Category
FROM loyalty_table

SELECT *
FROM Customer_Category

-- Month-Wise Retention Rate
-- Find month-by-month customer retention ratei since the start of the business.



-- We already created the table below in previous section 
select *
from next_visit_tbl
order by 1

SELECT MONTH(Order_Date), COUNT(*)
FROM next_visit_tbl
GROUP BY MONTH(Order_Date)
ORDER BY 1


SELECT MONTH(next_visit), COUNT(*)
FROM next_visit_tbl
GROUP BY MONTH(next_visit)
ORDER BY 1

SELECT *
FROM Customer_Category


--- We assumed that Loyal and Normal categories should be retained
SELECT MONTH(nvt.Order_Date) MONTH_, COUNT(nvt.Cust_id) month_wise_retained_cust
INTO retained_cust_table
FROM next_visit_tbl nvt, Customer_Category cc
WHERE nvt.Cust_id = cc.Cust_id AND
		(cc.Customer_category = 'Normal' OR  cc.Customer_category =  'Loyal')
GROUP BY  MONTH(nvt.Order_Date)
ORDER BY 1


SELECT MONTH(nvt.Order_Date) MONTH_, COUNT(nvt.Cust_id) month_wise_all_cust
INTO all_customers
FROM next_visit_tbl nvt, Customer_Category cc
WHERE nvt.Cust_id = cc.Cust_id 	
GROUP BY  MONTH(nvt.Order_Date)
ORDER BY 1


SELECT r.*, a.month_wise_all_cust, 
		CAST((1.0*r.month_wise_retained_cust/a.month_wise_all_cust)  AS DECIMAL (10,2)) month_wise_retention_rate
FROM retained_cust_table r, all_customers a
WHERE r.MONTH_ = a.MONTH_

