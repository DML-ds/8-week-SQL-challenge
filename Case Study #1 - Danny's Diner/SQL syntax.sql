/*--------------------------
CREATED BY - DAMILARE OROGUN
DATE - 09/11/2022
CREATED ON - PGADMIN4
--------------------------*/

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
 -------------------------------------- 
 --CASE STUDY QUESTIONS AND SOLUTIONS--
 --------------------------------------
 
-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	sales.customer_id,
	SUM(menu.price) AS Total_sales
FROM
	sales JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY
	customer_id
ORDER BY 
	customer_id;
	
  
  
-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
	COUNT(DISTINCT(order_date)) AS count_visit
FROM
	sales
GROUP BY
	customer_id;
	
	
	
-- 3. What was the first item from the menu purchased by each customer?	
WITH order_cte AS(
SELECT
	sales.customer_id,
	menu.product_name,
	sales.order_date,
		DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS ranking
FROM sales JOIN menu
	ON sales.product_id = menu.product_id
)
SELECT
	customer_id,
	product_name
FROM
	order_cte
WHERE
	ranking = 1
GROUP BY
	customer_id,
	product_name;
	
	
	
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	menu.product_name,
	COUNT(sales.product_id) AS most_purchased
FROM
	menu JOIN sales
	ON menu.product_id = sales.product_id
GROUP BY
	menu.product_name
ORDER BY
	most_purchased DESC
FETCH
	FIRST 1 ROWS ONLY;
	
	
    
-- 5. Which item was the most popular for each customer?
WITH most_ordered_cte AS(
SELECT
	sales.customer_id,
	menu.product_name,
	COUNT(sales.product_id) as order_count,
		DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY count(sales.customer_id) DESC) as ranking
FROM sales JOIN menu
ON sales.product_id = menu.product_id
GROUP BY
	sales.customer_id,
	menu.product_name
)
SELECT
	customer_id,
	product_name,
	order_count
FROM
	most_ordered_cte
WHERE
	ranking = 1
    
    
 -- 6. Which item was purchased first by the customer after they became a member?
WITH member_order_cte AS(
SELECT
	sales.customer_id,
	members.join_date,
	sales.order_date,
	sales.product_id,
		DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS date_rank
FROM
	sales JOIN members
	ON
		sales.order_date = members.join_date
WHERE
	sales.order_date >= members.join_date
)
SELECT
	customer_id,
	product_name,
	order_date
FROM
	member_order_cte JOIN menu
	ON member_order_cte.product_id = menu.product_id
WHERE
	date_rank = 1;
    
    
-- 7. Which item was purchased just before the customer became a member?
WITH previous_order_cte AS(
SELECT
	sales.customer_id,
	members.join_date,
	sales.order_date,
	sales.product_id,
		DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS date_rank
FROM
	sales JOIN members
	ON
		sales.customer_id = members.customer_id
WHERE
	sales.order_date < members.join_date
)
SELECT
	customer_id,
	product_name,
	order_date
FROM
	previous_order_cte JOIN menu
	ON previous_order_cte.product_id = menu.product_id
WHERE
	date_rank = 1
ORDER BY
	customer_id;
    

--8. What is the total items and amount spent for each member before they became a member?
SELECT
	sales.customer_id,
	COUNT(DISTINCT sales.product_id) AS total_items,
	SUM(menu.price) AS total_price
FROM
	sales JOIN menu
		ON sales.product_id = menu.product_id
	JOIN members
		ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
GROUP BY
	sales.customer_id
ORDER BY
	sales.customer_id;
    
    
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH price_points_cte AS (
SELECT
	*, CASE
	WHEN product_name = 'sushi' THEN price * 20
	ELSE price * 10
	END AS points
FROM
	menu
)
SELECT
	sales.customer_id,
	SUM(price_points_cte.points)
FROM
	sales JOIN price_points_cte
	ON sales.product_id = price_points_cte.product_id
GROUP BY
	sales.customer_id
ORDER BY
	sales.customer_id;
 
 
 -- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
