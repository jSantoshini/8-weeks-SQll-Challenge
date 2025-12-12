Use [7 database]
select top 10 * from dbo.[product_details 1] 
select top 10 * from dbo.[sales 1]

-->High Level Sales Analysis
---1.What was the total quantity sold for all products?
select sum(qty) from dbo.[sales 1]
--2.What is the total generated revenue for all products before discounts?
select sum(cast(qty as int)*cast(price as int)) as revenue from dbo.[sales 1]
--3.What was the total discount amount for all products?
select SUM(cast(qty as int)*cast(discount as int)) as discount_amount  from dbo.[sales 1]

-----Transaction Analysis------------------
---1.How many unique transactions were there?
SELECT count(distinct txn_id) from dbo.[sales 1]



---2.What is the average unique products purchased in each transaction?
select count(distinct prod_id)/count(prod_id) as avg_unique_roducts,txn_id from dbo.[sales 1]
group by txn_id 

SELECT 
    AVG(unique_product_count) AS avg_unique_products
FROM (
    SELECT 
        txn_id,
        COUNT(DISTINCT prod_id) AS unique_product_count
    FROM dbo.[sales 1]
    GROUP BY txn_id
) t;

---3.What are the 25th, 50th and 75th percentile values for the revenue per transaction?

with revenue_cte as 
(select sum(cast(qty as float)*cast(price as float)) as revenue,txn_id from dbo.[sales 1] 
group by txn_id)
select 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) 
        OVER() AS percentile_25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue)
        OVER() AS median_50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue)
        OVER() AS percentile_75
from revenue_cte
---4.What is the average discount value per transaction?

select avg(discount) as avg_discount,txn_id from dbo.[sales 1] group by txn_id
---5.What is the percentage split of all transactions for members vs non-members?
select member, count(txn_id)*1.0/(select count(txn_id) from dbo.[sales 1]) as cnt_txn_id from dbo.[sales 1]
group by member
---6.What is the average revenue for member transactions and non-member transactions?
select member,avg(a.revenue) as avg_revenue
from
(select member,sum(cast(qty as float)*cast(price as float)) as revenue,txn_id
from dbo.[sales 1]
group by member,txn_id) a
group by member

---------------Product Analysis------
select * from dbo.[product_details 1] p
join dbo.[sales 1] s
--1.What are the top 3 products by total revenue before discount?
select top 3 
	s.prod_id,
	sum(cast(s.qty as float)*cast(s.price as float)) as revenue
from dbo.[product_details 1] p
join dbo.[sales 1] s 
	on p.product_id = s.prod_id
group by s.prod_id
order by revenue desc

--2.What is the total quantity, revenue and discount for each segment?
with cte_qrd as 
(select s.qty,
		s.discount,
		p.segment_id,
	   (cast(s.qty as float)*cast(s.price as float)) as total_revenue 
from dbo.[sales 1] s
join dbo.[product_details 1] p
	on s.prod_id = p.product_id) 
select sum(qty) as total_quantity,
	   sum(total_revenue) as total_revenue,
	   sum(discount) as total_discount,
	   segment_id
from cte_qrd
group by segment_id

---3.What is the top selling product for each segment?
with cte_sellprod as 
(select s.prod_id,
		p.segment_id,
	   sum((cast(s.qty as float)*cast(s.price as float))) as total_revenue 
from dbo.[sales 1] s
join dbo.[product_details 1] p
	on s.prod_id = p.product_id
group by s.prod_id,p.segment_id),
rankng as
(select prod_id,
	   segment_id,
	   total_revenue,
	   rank() over(partition by segment_id order by total_revenue) as rn
from cte_sellprod)
select * from rankng where rn =1

--4.What is the total quantity, revenue and discount for each category?
select * from dbo.[product_details 1]
select * from dbo.[sales 1]
with cte_qrd as 
(select s.qty,
		s.discount,
		p.category_id,
	   (cast(s.qty as float)*cast(s.price as float)) as total_revenue 
from dbo.[sales 1] s
join dbo.[product_details 1] p
	on s.prod_id = p.product_id) 
select sum(qty) as total_quantity,
	   sum(total_revenue) as total_revenue,
	   sum(discount) as total_discount,
	   category_id
from cte_qrd
group by category_id


--5.What is the top selling product for each category?
with cte_top_category as
(select product_id,
		sum(qty) as total_quantity,
		category_id
from dbo.[product_details 1] p
join dbo.[sales 1] s
	on s.prod_id = p.product_id
group by product_id,category_id),
ranking as
(select product_id, 
		category_id,
		total_quantity,
		rank() over(partition by category_id order by total_quantity desc) as rn
from cte_top_category)
select * from ranking where rn = 1


--6.What is the percentage split of revenue by product for each segment?
with percentage_revenue as
(select p.segment_id,
		p.product_id,
	    sum(cast(s.qty as float)*cast(s.price as float)) as revenue
from dbo.[product_details 1] p
join dbo.[sales 1] s
	on s.prod_id = p.product_id
group by p.segment_id,p.product_id)
select product_id,
		segment_id,
		round(revenue*100/(select sum(revenue) from percentage_revenue),2) as percentage_revenue
from percentage_revenue


--7.What is the percentage split of revenue by segment for each category?

with percentage_revenue as
(select p.segment_id,
		p.category_id,
	    sum(cast(s.qty as float)*cast(s.price as float)) as revenue
from dbo.[product_details 1] p
join dbo.[sales 1] s
	on s.prod_id = p.product_id
group by p.segment_id,p.category_id)
select category_id,
		segment_id,
		round(revenue*100/(select sum(revenue) from percentage_revenue),2) as percentage_revenue
from percentage_revenue

--8.What is the percentage split of total revenue by category?
select  p.category_id,
	    sum(cast(s.qty as float)*cast(s.price as float))*100/(select sum(cast(qty as float)*cast(price as float)) as revenue from dbo.[sales 1]) as percentage_spilt
from dbo.[product_details 1] p
join dbo.[sales 1] s
	on s.prod_id = p.product_id
group by p.category_id 
--9.What is the total transaction “penetration” for each product? (hint: penetration = number of transactions 
--where at least 1 quantity of a product was purchased divided by total number of transactions)
select count(distinct txn_id),prod_id
from dbo.[product_details 1] p
join dbo.[sales 1] s
	on p.product_id = s.prod_id
group by prod_id


WITH total_tx AS (
    SELECT COUNT(DISTINCT txn_id) AS total_transactions
    FROM dbo.[sales 1]
),
product_tx AS (
    SELECT 
        s.prod_id,
        COUNT(DISTINCT s.txn_id) AS product_transactions
    FROM dbo.[sales 1] s
    GROUP BY s.prod_id
)
SELECT 
    p.prod_id,
    p.product_transactions,
    t.total_transactions,
    CAST(p.product_transactions AS FLOAT) / t.total_transactions AS penetration
FROM product_tx p
CROSS JOIN total_tx t;




--10.What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
WITH total_tx AS (
    SELECT COUNT(DISTINCT txn_id) AS total_transactions
    FROM dbo.[sales 1]
),
product_tx AS (
    SELECT 
        s.prod_id,
        COUNT(DISTINCT s.txn_id) AS product_transactions
    FROM dbo.[sales 1] s
    GROUP BY s.prod_id
)
SELECT 
    p.prod_id,
    pd.product_name,
    p.product_transactions,
    t.total_transactions,
    CAST(p.product_transactions AS FLOAT) / t.total_transactions AS penetration_decimal,
    CONCAT(
        ROUND( (CAST(p.product_transactions AS FLOAT) / t.total_transactions) * 100, 2 ),
        '%'
    ) AS penetration_percentage
FROM product_tx p
CROSS JOIN total_tx t
LEFT JOIN dbo.[product_details 1] pd
    ON p.prod_id = pd.product_id
ORDER BY penetration_decimal DESC;


