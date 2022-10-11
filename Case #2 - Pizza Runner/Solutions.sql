--1. How many pizzas were ordered?
SELECT COUNT(order_id) as total_pizza_ordered
FROM
	customers_orders_temp;
  

--2. How many unique customer orders were made?
SELECT 
	COUNT(DISTINCT order_id) as unique_orders
FROM
	customers_orders_temp;
  

--3. How many successful orders were delivered by each runner?
SELECT runner_id, 
	COUNT(order_id) as successful_orders
FROM 
	runner_orders_temp
WHERE 
	distance != 0
GROUP BY 
	runner_id
ORDER BY
	runner_id;
  

--4. How many of each type of pizza was delivered?
SELECT 
	p.pizza_name, 
	COUNT(r.order_id) as pizza_delivered
FROM 
	runner_orders_temp as r JOIN customers_orders_temp as c
	ON r.order_id = c.order_id
	JOIN pizza_names as p
	ON c.pizza_id = p.pizza_id
WHERE 
	distance != 0
GROUP BY 
	p.pizza_name;
	
	
--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
	c.customer_id,
	p.pizza_name,
	count(p.pizza_name) AS num_pizza_ordered
FROM
	customers_orders_temp as c JOIN pizza_names as p
	ON c.pizza_id = p.pizza_id
GROUP BY
	c.customer_id,
	p.Pizza_name
ORDER BY
	c.customer_id;
	
	
--6. What was the maximum number of pizzas delivered in a single order?
WITH pizza_count_cte as(
SELECT
	c.order_id,
	count(pizza_id) as order_per_customer
FROM
	customers_orders_temp as c JOIN runner_orders_temp as r
	ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY
	c.order_id
ORDER BY
	c.order_id
)
SELECT
	MAX(order_per_customer) as max_pizza_delivered
FROM
	pizza_count_cte;




--6. What was the maximum number of pizzas delivered in a single order?
WITH pizza_count_cte as(
SELECT
	c.order_id,
	COUNT(r.order_id) as pizza_count,
	RANK() OVER(ORDER BY COUNT(r.order_id)DESC)
FROM
	customers_orders_temp as c JOIN runner_orders_temp as r
	ON c.order_id = r.order_id
WHERE
	distance != 0
GROUP BY
	c.order_id
)
SELECT
	order_id,
	pizza_count
FROM
	pizza_count_cte
WHERE
	rank = 1


--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
CREATE view delivered_order AS
SELECT * FROM customers_orders_temp
JOIN runner_orders_temp
using (order_id)
WHERE distance IS NOT null;

SELECT
	customer_id,
	COUNT(
		CASE
			WHEN exclusions <> null or extras <> null THEN 1
		END) AS pizza_change,
	COUNT(
		CASE
			WHEN exclusions is null or extras is null THEN 1
		END) AS no_pizza_change
FROM
	delivered_order
GROUP BY
	customer_id
ORDER BY
	customer_id;







--9. How many pizzas were delivered that had both exclusions and extras?
SELECT 
	hour(order_time) AS 'hour',
    	count(order_id) AS 'num_pizza_ordered',
    	round(100*count(order_id) /sum(count(order_id)) over(), 2) AS 'volume_ordered'
FROM 
	pizza_runner.customers_orders_temp
GROUP BY 
	1
ORDER BY
	1;
	
	
--9. 
