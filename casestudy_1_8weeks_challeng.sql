USE dannys_diner
SELECT * FROM  sales
SELECT * FROM menu
SELECT * FROM members

--1.What is the total amount each customer spent at the restaurant?
SELECT S.customer_id,SUM(M.price) AS TOTAL_AMOUNT
FROM SALES S
JOIN menu M ON M.product_id = S.product_id
GROUP BY S.customer_id

--2.How many days has each customer visited the restaurant?
SELECT S.customer_id, COUNT(S.order_date) AS CUSTOMERVISITED
FROM sales S
GROUP BY S.customer_id

--3.What was the first item from the menu purchased by each customer?
SELECT * FROM  sales
SELECT * FROM menu
SELECT * FROM members
SELECT X.customer_id,X.order_date,X.product_name,X.RN FROM
(SELECT S.customer_id, 
    M.product_name, 
    S.order_date,ROW_NUMBER() OVER(PARTITION BY  customer_id ORDER BY customer_id) AS RN
FROM sales S
JOIN MENU M
ON S.product_id = M.product_id) AS X
WHERE RN = 1

-- WITH CTE
WITH RANKEDSALES AS (SELECT S.customer_id, 
    M.product_name, 
    S.order_date,ROW_NUMBER() OVER(PARTITION BY  customer_id ORDER BY customer_id) AS RN
FROM sales S
JOIN MENU M
ON S.product_id = M.product_id)
SELECT customer_id, product_name, order_date
FROM RANKEDSALES WHERE RN = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT * FROM  sales
SELECT * FROM menu
SELECT * FROM members

SELECT TOP 1 M.product_name, COUNT(M.product_name) AS PURCHASECOUNT
FROM SALES S
JOIN MENU M ON S.product_id = M.product_id
GROUP BY M.product_name
ORDER BY COUNT(M.product_name) DESC

--5. Which item was the most popular for each customer?

SELECT customer_id, product_name, MOST_PURCHASED
FROM (
    SELECT S.customer_id,
           M.product_name,
           COUNT(M.product_name) AS MOST_PURCHASED,
           ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY COUNT(M.product_name) DESC) AS RN
    FROM SALES S
    JOIN MENU M ON S.product_id = M.product_id
    GROUP BY S.customer_id, M.product_name
) AS ranked
WHERE RN = 1;

--Which item was purchased first by the customer after they became a member?
select customer_id,order_date,product_name,join_date 
from 
(select s.customer_id,order_date,product_name,join_date,
		RANK() over(partition by s.customer_id order by s.order_date) as rn
FROM SALES S
    JOIN MENU M ON S.product_id = M.product_id
	join members me on me.customer_id = s.customer_id
where  order_date >= join_date) x
where x.rn = 1

--7.Which item was purchased just before the customer became a member?

select customer_id,order_date,product_name,join_date 
from 
(select s.customer_id,order_date,product_name,join_date,
		ROW_NUMBER() over(partition by s.customer_id order by s.order_date) as rn
FROM SALES S
    JOIN MENU M ON S.product_id = M.product_id
	join members me on me.customer_id = s.customer_id
where  order_date < join_date) x
where x.rn = 1

--8.What is the total items and amount spent for each member before they became a member?
select s.customer_id,
	   sum(m.price)as amount_spent,
	   count(S.product_id) as total_items
FROM SALES S
    JOIN MENU M ON S.product_id = M.product_id
	join members me on me.customer_id = s.customer_id
where  order_date < join_date
group by s.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id,sum(x.price_dollar) as total
from (select s.customer_id,
CASE when m.product_name = 'sushi' then 2*price*10
	 else 10*price
	 end as price_dollar
FROM SALES S
    JOIN MENU M ON S.product_id = M.product_id) as x
group by customer_id

--10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January?
select customer_id,sum(points.total_points) as total_earned
from 
(select s.customer_id,
case when s.order_date between me.join_date and DATEADD(day,7,join_date) then m.price*2*10
	 when m.product_name = 'sushi' then price*2*10
	 else 10*price
	 end as total_points
FROM SALES S
    JOIN MENU M ON S.product_id = M.product_id
	join members me on me.customer_id = s.customer_id
	where order_date >= join_date
	and s.customer_id in ('A','B')
	and me.join_date <= '2023-01-31') as points
group by customer_id



















