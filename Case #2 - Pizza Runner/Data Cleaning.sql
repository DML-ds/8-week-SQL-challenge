SET search_path = pizza_runner;
--Cleaning the Data

--Customer_orders Table: cleaning the Null values, replacing them with " ".
CREATE TEMP TABLE customers_orders_temp AS
SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' THEN null
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras IS NULL or extras LIKE 'null' THEN null
	ELSE extras
	END AS extras,
	order_time
FROM pizza_runner.customer_orders;


--runner_orders Table: 
/*
remove the minutes in the duration column
remove the km in the distance column
replace the nulls with null
*/
CREATE TEMP TABLE runner_orders_temp AS
SELECT order_id, runner_id,
CASE
	WHEN pickup_time LIKE 'null' THEN null
    ELSE pickup_time
    END AS pickup_time,
CASE
	WHEN distance LIKE 'null' THEN null
    WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
    ELSE distance
    END AS distance,
CASE
	WHEN duration LIKE 'null' THEN null
    WHEN duration LIKE '%mins' THEN TRIM('%mins' FROM duration)
    WHEN duration LIKE '%minute' THEN TRIM('%minute' FROM duration)
    WHEN duration LIKE '%minutes' THEN TRIM('%minutes' FROM duration)
    ELSE duration
    END AS duration,
CASE
	WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN ' '
    ELSE cancellation
    END AS cancellation
FROM
	pizza_runner.runner_orders;
    
--change the data type of the columns
ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::TIMESTAMP,
ALTER COLUMN distance TYPE NUMERIC USING distance::NUMERIC,
ALTER COLUMN duration TYPE INTEGER USING duration::INTEGER;
