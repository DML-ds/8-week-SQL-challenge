--1.How many customers has Foodie-Fi ever had?
SELECT
	COUNT(DISTINCT customer_id) as unique_customer
FROM
	subscriptions;
  
  
--2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT
	DATE_PART('month', start_date) as Month_num,
	TO_CHAR(start_date, 'Month') as Month_name,
	COUNT(*) as Trial_startdate
FROM
	subscriptions as s JOIN plans as p
	ON s.plan_id = p.plan_id
WHERE
	p.plan_id = 0
GROUP BY
	DATE_PART('month', start_date),
	TO_CHAR(start_date,'Month')
ORDER BY
	Month_num;
  
  
  --3.What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
	p.plan_id,
	p.plan_name,
	SUM(
		CASE 
			WHEN start_date <= '2020-12-31' THEN 1
			ELSE 0
		END) AS subscription_2020,
	SUM(
		CASE
			WHEN start_date >= '2021-01-01' THEN 1
			ELSE 0
		END) AS subscription_2021
FROM
	plans as p JOIN subscriptions as s
	ON p.plan_id = s.plan_id
GROUP BY
	p.plan_name,
	p.plan_id
ORDER BY
	p.plan_id;
  
  
  --4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
  COUNT(*) AS count_churn,
  ROUND(100 * COUNT(*) ::NUMERIC/ (
    SELECT COUNT(DISTINCT customer_id) AS customer_count
    FROM subscriptions), 1) AS churn_percentage
FROM subscriptions AS s JOIN plans AS p
  ON s.plan_id = p.plan_id
WHERE
  s.plan_id = 4;


--5.How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH ranking_cte AS(
SELECT
	s.customer_id,
	p.plan_id,
	p.plan_name,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY p.plan_id) as rank_count
FROM
	subscriptions AS s JOIN plans AS p
	ON s.plan_id = p.plan_id
)

SELECT
	COUNT(*) AS churn_count,
	ROUND(100 * COUNT(*)/(
		SELECT COUNT(DISTINCT customer_id)
		FROM subscriptions), 0) as rounded_percentage
FROM
	ranking_cte
WHERE
	plan_id = 4
	AND rank_count = 2;
  
  
 --6. What is the number and percentage of customer plans after their initial free trial?
WITH plan_lead_cte as(
	SELECT
		customer_id,
		plan_id,
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) as plan_lead
	FROM
		subscriptions
)
SELECT
	plan_lead,
	COUNT(*) AS plan_lead_count,
	ROUND(100 * COUNT(*)::NUMERIC/(
		SELECT
			COUNT(DISTINCT customer_id)
		FROM
			subscriptions), 1) as percentage
FROM
	plan_lead_cte
WHERE
	plan_lead IS NOT NULL
	AND plan_id = 0
GROUP BY
	plan_lead
ORDER BY
	plan_lead;

