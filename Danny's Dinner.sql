/* Schema SQL Query SQL ResultsEdit on DB Fiddle
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
*/








-- The amount each customer spent in the restaurant 
Select customer_id , Sum(price) as Total_Spent 
From sales s join menu m on s.product_id = m.product_id
group by customer_id ;

-- How many Days each customer visited the restaurant 
Select customer_id , Count( distinct order_date) as Visits
From sales 
group by customer_id;

-- The first item from the menu purchased by each customers
With CTE1 as (
Select customer_id , order_date ,product_id, row_number() over (partition by customer_id order by order_date ) as row_num
from sales )

Select Customer_id,CTE1.product_id, product_name
From CTE1 Join menu on CTE1.product_id = menu.product_id
Where row_num = 1 ;

-- the most purchased item on the menu and how many times was it purchased by all customers

 Select s.product_id,product_name,count(s.product_id) 
 From sales s join menu m  on s.product_id=m.product_id
 group by product_id,product_name
 order by count(s.product_id) DESC
 LIMIT 1;

-- What item was the most popular for each customer
 With CTE2 as(

Select customer_id,s.product_id,product_name,count(s.product_id)  as num
From sales s join menu m on s.product_id=m.product_id
group by customer_id,s.product_id,product_name
 ), CTE3 as(
Select * , row_number() over(partition by customer_id order by num DESC ) as ranky from CTE2
)
select * from CTE3
where ranky = 1;


-- Which item was purchased first by the customer after they became a member?
with cte4 as(
Select distinct  s.customer_id , order_date, product_name ,join_date,
Rank() over (partition by customer_id order by order_date) as rnk
from sales s join menu m on s.product_id = m.product_id
join members me on s.customer_id = me.customer_id
where order_date > join_date)
select customer_id , product_name
from cte4
where rnk =1;

-- Which item was purchased first by the customer after they became a member?
WITH CTE6 as (
Select distinct  s.customer_id , order_date, product_name ,join_date,
row_number() over (partition by customer_id order by order_date ) as rnk
from sales s join menu m on s.product_id = m.product_id
join members me on s.customer_id = me.customer_id
Where join_date > order_date)

Select customer_id, product_name
from CTE6
where rnk=1;

-- What is the total items and amount spent for each member before they became a member?

select distinct s.Customer_id,sum(price) as total_amount , count(s.product_id)as Total_items
From sales s join menu m on s.product_id=m.product_id
join members me on me.customer_id = s.customer_id
Where join_date > order_date
group by s.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

Select customer_id , SUM( case when s.product_id=2 then price*10
							When s.product_id=3 then price*10
                            else price*20 END) as points
						From sales s join menu m on s.product_id = m.product_id
                        group by customer_id;
                            
  --  In the first week after a customer joins  the program (including their join date) they earn 2x points on all items,*
  --  not just sushi - how many points do customer A and B have at the end of January?        
  
  Select s.customer_id , SUM(CASE WHEN order_date Between join_date and date_add(join_date, interval 6 day)
  then price*20 
  When product_name="sushi" then price*20 
  else price*10 END) as points
  From sales s join members me on s.customer_id = me.customer_id
  join menu m on m.product_id = s.product_id
  Where order_date <= '2021-01-31'
  Group by s.customer_id;
  
  
  