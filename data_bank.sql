set sql_mode=only_full_group_by;
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
select * from customer;
select * from transaction;
create schema data_bank;

alter table customer
modify column start_date date;

alter table customer
modify column end_date date;

alter table transaction
modify column txn_date date;

-- A. Customer Nodes Exploration

-- 1. How many unique nodes are there on the Data Bank system?

select count(distinct(node_id)) as "Unique Nodes"
from customer;

-- 2. What is the number of nodes per region?

select r.region_id as "Region ID", r.region_name as "Region Name", count(distinct c.node_id) as "No of Nodes"
from region r join customer c on r.region_id = c.region_id
group by r.region_id, r.region_name;

-- 3. How many customers are allocated to each region?
select r.region_id as "Region ID", r.region_name as "Region Name", count(distinct(c.customer_id)) as "No of Customer"
from region r join customer c on r.region_id = c.region_id
group by r.region_id, r.region_name
order by 3 desc;

-- 4. How many days on average are customers reallocated to a different node?
select round(avg(datediff(end_date, start_date)),0) as "Average No. Reallocation of Days" from customer
where end_date != "9999-12-31";

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

with RD as (select customer_id ,region_id, datediff(end_date, start_date) as Days_in_Node from customer
where end_date != "9999-12-31"),
ordered as (
select region_id, Days_in_Node,
row_number() over (partition by region_id order by region_id, Days_in_Node) as rn from ard),
max_row as (
select region_id, max(rn) as max_rn from ordered
group by region_id)

select 	distinct o.region_id,
	MAX(CASE WHEN rn = ROUND(mr.max_rn / 2, 0) THEN o.Days_in_Node END) OVER (PARTITION BY region_id)  AS Median,
    MAX(CASE WHEN rn = ROUND(mr.max_rn * 0.8, 0) THEN o.Days_in_Node END) OVER (PARTITION BY region_id) AS "80th Percentile",
    MAX(CASE WHEN rn = ROUND(mr.max_rn * 0.95, 0) THEN o.Days_in_Node END) OVER (PARTITION BY region_id) AS "95th Percentile"
    from ordered o join max_row mr on o.region_id = mr.region_id
where rn in (round(mr.max_rn/2, 0),
			round(mr.max_rn*0.8, 0),
            round(mr.max_rn*0.95, 0)
);
---------------------------------------------------------------- B. Customer Transactions------------------------------------------------------------------------------------

-- 1. What is the unique count and total amount for each transaction type?

select txn_type, count(txn_type), sum(txn_amount)
from transaction group by txn_type
order by 3 desc;

-- 2. What is the average total historical deposit counts and amounts for all customers?
with deposit_summary as (
select txn_type, count(txn_type) as txn_count, sum(txn_amount) as total_amount
from transaction
where txn_type = 'deposit'
group by customer_id
)
select txn_type, round(avg(txn_count), 2) as "Average No. of Deposits", round(avg(total_amount),2) as "Average Deposit Amount"
from deposit_summary;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

with txn_summary as (
	select customer_id,
			month(txn_date) as Month_No,
            monthname(txn_date) as Month_name,
            count(case when txn_type = 'deposit' then 1 end) as No_of_Deposits,
            count(case when txn_type = 'purchase' then 1 end) as No_of_Purchases,
            count(case when txn_type = 'withdrawal' then 1 end) as No_of_Withdrawals
from transaction
group by customer_id, month(txn_date) , monthname(txn_date)  
)

select Month_No, month_name, count(distinct (customer_id)) as No_of_Customer
from txn_summary
where No_of_Deposits > 1
and (No_of_Purchases > 0 or No_of_Withdrawals > 0)
group by Month_No, Month_name;

-- 4. What is the closing balance for each customer at the end of the month?
 with Txn_activities as (
	select
		customer_id,
		Month(txn_date) as Month_No,
        monthname(txn_date) Month_Name,
        sum(case when txn_type = 'deposit' then txn_amount else -1*txn_amount end) as Total_Amount
	from transaction
    group by customer_id, month(txn_date)
    )
    
    select customer_id, Month_No, Month_Name, sum(total_amount) over(partition by customer_id order by Month_No) as "Closing Balance"
    from txn_activities
    group by customer_id, Month_No, Month_Name;
    
-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
    with Txn_activities1 as (
	select
		customer_id,
		Month(txn_date) as Month_No,
        monthname(txn_date) Month_Name,
        sum(case when txn_type = 'deposit' then txn_amount else -1*txn_amount end) as Total_Amount
	from transaction
    group by customer_id, month(txn_date)
    ),
    closing_balance as (
    select customer_id, Month_No, Month_Name, sum(total_amount) over(partition by customer_id order by Month_No) as cb
    from txn_activities1),
    pct as (
    select customer_id, Month_No, Month_Name, cb, lag(cb) over(partition by customer_id order by Month_No),
    100 * (cb - LAG(cb) OVER (PARTITION BY customer_id ORDER BY month_no)) / NULLIF(LAG(cb) OVER (PARTITION BY customer_id ORDER BY month_no), 0) AS pct_increase
 FROM closing_balance)
 
 select round(100.00 * count(distinct customer_id) / (select count(distinct customer_id) from transaction),2) as Percentage_Increase
 from pct
 where pct_increase > 5;
 
 -- C. Data Allocation Challenge
 -- Option 1: Data is allocated based off the amount of money at the end of the previous month?

WITH adjusted_amount AS (
SELECT customer_id, txn_type, 
MONTH(txn_date) AS "month_number", 
MONTHNAME(txn_date) AS "month_name",
CASE 
WHEN  txn_type = 'deposit' THEN txn_amount
ELSE -txn_amount
END AS amount
FROM transaction
),
balance AS (
SELECT customer_id, month_number, month_name,
SUM(amount) OVER(PARTITION BY customer_id, month_number ORDER BY month_number ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
AS running_balance
FROM adjusted_amount
),
allocation AS (
SELECT customer_id, month_number,month_name,
LAG(running_balance) OVER(PARTITION BY customer_id, month_number ORDER BY month_number) AS monthly_allocation
FROM balance
)
SELECT month_number,month_name,
SUM(CASE WHEN monthly_allocation < 0 THEN 0 ELSE monthly_allocation END) AS total_allocation
FROM allocation
GROUP BY 1,2
ORDER BY 1,2; 
 
-- Option 2: Data is allocated on the average amount of money kept in the account in the previous 30 days

WITH updated_transactions AS (
SELECT customer_id, txn_type, 
MONTH(txn_date) AS Month_number,
MONTHNAME(txn_date) AS month_name,
CASE
WHEN txn_type = 'deposit' THEN txn_amount
ELSE -txn_amount
END AS amount
FROM transaction
),
balance AS (
SELECT customer_id, month_name, month_number,
SUM(amount) OVER(PARTITION BY customer_id, month_number ORDER BY customer_id, month_number 
ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM updated_transactions
),
avg_running AS(
SELECT customer_id, month_name,month_number,
AVG(running_balance) AS avg_balance
FROM balance
GROUP BY 1,2,3
ORDER BY 1
)
SELECT month_number,month_name, 
SUM(CASE WHEN avg_balance < 0 THEN 0 ELSE avg_balance END) AS allocation_balance
FROM avg_running
GROUP BY 1,2
ORDER by 1,2;


-- Option 3: Data is updated real-time
WITH updated_transactions AS (
SELECT customer_id, txn_type,
MONTH(txn_date) as month_number,
MONTHNAME(txn_date) AS month_name,
CASE
WHEN txn_type = 'deposit' THEN txn_amount
ELSE -txn_amount
END AS amount
FROM transaction
),
balance AS (
SELECT customer_id, month_number, month_name, 
SUM(amount) OVER(PARTITION BY customer_id, month_number ORDER BY customer_id, month_number ASC 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM updated_transactions
)
SELECT month_number, month_name,
SUM(CASE WHEN running_balance < 0 THEN 0 ELSE running_balance END) AS total_allocation
FROM balance
GROUP BY 1,2
ORDER BY 1;
 -- . running customer balance column that includes the impact each transaction
 
 select customer_id as "Customer ID",
 txn_date as "Date",
 txn_type as "Txn Type", txn_amount as "Amount", sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) over (partition by customer_id order by txn_date) as "Running Balance" from
 transaction;
 
 -- . customer balance at the end of each month
 with Txn_activities as (
	select
		customer_id,
		Month(txn_date) as Month_No,
        monthname(txn_date) Month_Name,
        sum(case when txn_type = 'deposit' then txn_amount else -1*txn_amount end) as Total_Amount
	from transaction
    group by customer_id, month(txn_date)
    )
    
    select customer_id, Month_No, Month_Name, sum(total_amount) "Closing Balance"
    from txn_activities
    group by customer_id, Month_No, Month_Name;
    
-- 0. minimum, average and maximum values of the running balance for each customer

WITH running_balance AS
(SELECT 
	customer_id,
	SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount else -txn_amount end)
	OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance
	FROM transaction
)

SELECT customer_id,
       round(AVG(running_balance),2) as "Average Running Balance",
       round(MIN(running_balance),2) as "Minimum Running Balance",
       round(MAX(running_balance),2) as "Maximum Running Balance"
FROM running_balance
GROUP BY customer_id;