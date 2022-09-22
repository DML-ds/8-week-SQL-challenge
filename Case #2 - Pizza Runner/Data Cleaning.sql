SET search_path = pizza_runner;
--Cleaning the Data

--Customer_orders Table: cleaning the Null values, replacing them with " ".
SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras IS NULL or extras LIKE 'null' THEN ' '
	ELSE extras
	END AS extras,
	order_time
FROM customer_orders;


--runner_orders Table: 
/*
remove the minutes in the duration column
remove the km in the distance column
replace the nulls with ' '
*/

SELECT order_id, runner_id,
CASE
	WHEN pickup_time LIKE 'null' THEN ' '
    ELSE pickup_time
    END AS pickup_time,
CASE
	WHEN distance LIKE 'null' THEN ' '
    WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
    ELSE distance
    END AS distance,
CASE
	WHEN duration LIKE 'null' THEN ' '
    WHEN duration LIKE '%mins' THEN TRIM('%mins' FROM duration)
    WHEN duration LIKE '%minute' THEN TRIM('%minute' FROM duration)
    WHEN duration LIKE '%minutes' THEN TRIM('%minutes' FROM duration)
    ELSE duration
    END AS duration,
CASE
	WHEN cancellation IS NULL OR LIKE 'null' THEN ' '
    ELSE cancellation
    END AS cancellation
FROM
	runner_orders;
    
--change the data type of the columns
ALTER TABLE runner_orders
ALTER COLUMN pickup_time DATETIME;

ALTER TABLE runner_orders
ALTER COLUMN distance FLOAT;

ALTER TABLE runner_orders
ALTER COLUMN duration INT;

