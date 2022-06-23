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
