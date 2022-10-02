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

