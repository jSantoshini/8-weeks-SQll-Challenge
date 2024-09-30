CREATE Database dannys_diner;
GO
Use dannys_diner;
Go
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

--1.What is the total amount each customer spent at the restaurant?
--select sum(price),customer_id from MENU JOIN sales on menu.product_id = sales.product_id;

SELECT SUM(MENU.price) AS total_sales, sales.customer_id
FROM MENU
JOIN sales ON MENU.product_id = sales.product_id
GROUP BY sales.customer_id;

SELECT sales.customer_id, SUM(menu.price) AS total_amount_spent
FROM menu as menu
INNER JOIN sales
	ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

--2.How many days has each customer visited the restaurant?
select count(distinct order_date) as numofcustomers, customer_id from sales group by customer_id;

SELECT sales.customer_id, COUNT(DISTINCT sales.order_date) AS visited_days
FROM sales
GROUP BY sales.customer_id
ORDER BY customer_id;



--3.What was the first item from the menu purchased by each customer?
select customer_id,min(product_id) as first_purchase_item,min(order_date) as first_purchased_date 
from sales group by customer_id;

SELECT sales.customer_id, sales.order_date, menu.product_name
FROM menu as menu
INNER JOIN sales as sales
ON sales.product_id = menu.product_id
WHERE sales.order_date = (
  select min(sales_1.order_date)
  from sales as sales_1
  WHERE sales.customer_id =sales_1.customer_id);

--4.What is the most purchased item on the menu and how many times was it purchased by all customers?
select max(repeatpurchased) from (select count(product_id) as repeatpurchased,product_id as itemnumber from sales group by product_id) as subquery;

SELECT menu.product_name, COUNT(sales.product_id) as times_purchased
FROM menu as menu
INNER JOIN sales as sales
ON menu.product_id = sales.product_id
GROUP BY menu.product_name LIMIT 1;

SELECT m.product_name, COUNT(s.product_id) as times_purchased
FROM menu as m
INNER JOIN sales as s ON m.product_id = s.product_id
GROUP BY m.product_name;

--5. Which item was the most popular for each customer?




-- 6. Which item was purchased first by the customer after they became a member?
select * from sales join members on sales.customer_id = members.customer_id where order_date >= join_date ;
 
-- 7. Which item was purchased just before the customer became a member?
select * from sales join members on sales.customer_id = members.customer_id where order_date < join_date ;

--8. What is the total items and amount spent for each member before they became a member?
 select * from (select * from sales join members on sales.customer_id = members.customer_id where order_date < join_date) as subquery join  menu on 
 menu.product_id = ;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,not 
--just sushi - how many points do customer A and B have at the end of January




