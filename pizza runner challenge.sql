/*
CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  */
  
  
  
  
  
  
  
  
-- How many pizzas were ordered?
  Select count(*) from customer_orders;
  
  -- How many unique customer orders were made?
  Select count(distinct order_id) from customer_orders;
  
  -- How many successful orders were delivered by each runner?
  
  Select runner_id , count(*) as delivered
  From runner_orders 
  where cancellation is NULL 
  group by runner_id;
  
  
--  How many of each type of pizza was delivered?

Select pizza_id , count(pizza_id)
from runner_orders ro 
join customer_orders co on ro.order_id = co.order_id
Where cancellation is NULL
group by pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id , pizza_name , count(pizza_name)
from customer_orders co join pizza_names pn on co.pizza_id=pn.pizza_id
group by  customer_id , pizza_name;

Select customer_id , sum(Case when pizza_id=1 then 1   else 0 END) as Meatlovers , sum(Case when pizza_id=2 then 1   else 0 END) as Veg
From customer_orders
Group by customer_id;

-- What was the maximum number of pizzas delivered in a single order?

Select co.order_id , count(pizza_id) pizzas
from runner_orders ro join customer_orders co on ro.order_id = co.order_id
WHERE cancellation is NULL
group by order_id
order by pizzas DESC
Limit 1;


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

Select customer_id , sum(case when (exclusions is not null) OR (extras is not null) then 1 else 0 END ) pizza_with_changes,
Sum(case when (exclusions is null) and (extras is null) then 1 else 0 end ) pizza_with_no_changes
From customer_orders join runner_orders on customer_orders.order_id= runner_orders.order_id
Where cancellation is null
Group by customer_id; 

-- How many pizzas were delivered that had both exclusions and extras?

Select      Sum(CASE WHEN (exclusions is not null ) and (extras is not null) then 1 else 0 END ) pizzas
From customer_orders join runner_orders on customer_orders.order_id= runner_orders.order_id
where cancellation is null ;

-- What was the total volume of pizzas ordered for each hour of the day?

Select hour(Order_time) as Hours , Count(pizza_id)
From customer_orders
group by Hours;

-- What was the volume of orders for each day of the week?

Select dayname(order_time) as Days , Count(distinct order_id)
From customer_orders
group by Days;



/*                                              B-Runner and Customer Experience
1-How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/

select count(runner_id) as runners, datediff(registration_date,'2021-01-01') div 7 as week_number  
from runners
group by week_number;

/*
2-What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?*/

select * from runner_orders;
select * from customer_orders;
Select  runner_id , AVG(timestampdiff(minute,order_time,pickup_time))
From runner_orders ro join customer_orders co on ro.order_id = co.order_id
Where cancellation is null
group by runner_id
;




/*
3-Is there any relationship between the number of pizzas and how long the order takes to prepare?*/

Select  ro.order_id ,count(pizza_id), AVG(timestampdiff(minute,order_time,pickup_time))
From runner_orders ro join customer_orders co on ro.order_id = co.order_id
Where cancellation is null
group by order_id
;



/*
4-What was the average distance travelled for each customer?*/

Select customer_id , count(co.order_id) orders_per_customer, round(avg(distance),0) avg_distance
From customer_orders co join runner_orders ro on co.order_id= ro.order_id
where cancellation is null
group by customer_id;


/*
5-What was the difference between the longest and shortest delivery times for all orders?*/

Select  Max(duration)-min(duration) as difference
From runner_orders
where cancellation is null;


/*
6-What was the average speed for each runner for each delivery and do you notice any trend for these values?*/

Select runner_id ,order_id ,(distance / duration * 60) as speed
From runner_orders
where cancellation is null
;

/*
7-What is the successful delivery percentage for each runner? */
With cte1 as(
Select runner_id,count(order_id) total , Sum( case When cancellation is null then 1 else 0 END) as delivred
from runner_orders
group by runner_id
)

Select runner_id , delivred / total * 100 as porcentage
From cte1;

