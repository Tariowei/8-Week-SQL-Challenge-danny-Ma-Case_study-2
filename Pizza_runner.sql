-- A. Pizza Metrics
-- 1.	How many pizzas were ordered?

SELECT COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders;

-- 2.	How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS num_of_orders
FROM customer_orders;

-- 3.	How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE pickup_time <> 'null'
GROUP BY runner_id;

-- 4.	How many of each type of pizza was delivered?

SELECT pizza_name, COUNT(runner_orders.order_id) AS successful_orders
FROM customer_orders
INNER JOIN runner_orders
ON customer_orders.order_id = runner_orders.order_id
INNER JOIN pizza_names
ON customer_orders.pizza_id = pizza_names.pizza_id
WHERE pickup_time <> 'null'
GROUP BY pizza_name ;

-- 5.	How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_name, COUNT(runner_orders.order_id) AS num_of_orders
FROM customer_orders
INNER JOIN runner_orders
ON customer_orders.order_id = runner_orders.order_id
INNER JOIN pizza_names
ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name;

-- 6.	What was the maximum number of pizzas delivered in a single order?

WITH max_num AS(
SELECT COUNT(runner_orders.order_id) AS max_delivery, 
RANK () OVER( ORDER BY COUNT(runner_orders.order_id) DESC) AS delivered_pizza
FROM runner_orders
INNER JOIN customer_orders
ON runner_orders.order_id = customer_orders.order_id
WHERE pickup_time <> 'null'
GROUP BY runner_orders.order_id)
SELECT max_delivery
FROM max_num
WHERE delivered_pizza = 1;

-- 7.	For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT customer_id, COUNT(customer_id) AS Num_of_changes
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE exclusions IS NOT NULL OR extras IS NOT NULL
AND cancellation IS NULL
GROUP BY customer_id;  

SELECT customer_id, COUNT(customer_id) AS No_change 
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE exclusions IS NULL AND extras IS  NULL
AND cancellation IS NULL 
GROUP BY customer_id; 

-- 8.	How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(customer_id) AS delivered_with_changes
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE exclusions IS NOT NULL AND extras IS NOT NULL
AND cancellation IS NULL;

-- 9.	What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS Hour_of_the_day,
COUNT(order_id) AS num_of_orders
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time) ASC;

-- 10.	What was the volume of orders for each day of the week?
SELECT DAY(order_time) AS Day_of_the_week,
COUNT(order_id) AS num_of_orders
FROM customer_orders
GROUP BY DAY(order_time)
ORDER BY DAY(order_time) ASC;

							-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT WEEK(registration_date,"2021-01-01") AS Weeks,
COUNT(runner_id) AS Num_of_reg 
FROM runners
GROUP BY Weeks;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT runner_id, ROUND(AVG(duration),2) AS Average_time
FROM runner_orders
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT c.order_id,COUNT(c.order_id) AS Num_of_pizza,
MAX(TIMEDIFF(pickup_time,order_time)) AS Time_taken
FROM customer_orders c
JOIN runner_orders r 
ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY Num_of_pizza DESC;

-- 4. What was the average distance travelled for each customer?

SELECT customer_id, ROUND(AVG(distance),2) AS Average_distance
FROM runner_orders r 
JOIN customer_orders c 
ON r.order_id  = c.order_id
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT (MAX(duration) - MIN(duration)) AS delivery_time_range
FROM runner_orders;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id, order_id, AVG(ROUND((distance*1000)/(duration*60),2)) AS Avg_speed
FROM runner_orders
WHERE distance IS NOT NULL
GROUP BY order_id, runner_id;

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id,count(order_id) as Successful_delivery
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
