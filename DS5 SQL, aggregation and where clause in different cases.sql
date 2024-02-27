select * from customer;
select * from billing;
select * from service_packages;
select * from service_usage;
select * from feedback;
select * from subscriptions;

-- Aggregating Data

-- 1. Exercise: Find the average monthly rate for each service type in service_packages. Use the ROUND function here to make result set neater

 select service_type , round((monthly_rate),2) as average
 from service_packages;
 
-- 2. Exercise: Identify the customer who has used the most data in a single service_usage record. (covers ORDER BY and LIMIT that we did in last class)
select * from service_usage
order by data_used
limit 2;
-- 3. Exercise: Calculate the total minutes used by all customers for mobile services.

select sum(minutes_used) as total_mobile
from service_usage
where service_type = 'mobile';



-- 4. Exercise: List the total number of feedback entries for each rating level.

select rating , count(rating) as feedback_count
from feedback
group by rating
order by rating;

-- 5. Exercise: Calculate the total data and minutes used per customer, per service type.

select customer_id , service_type , sum(data_used), sum(minutes_used)
from service_usage
group by customer_id , service_type;


-- 7. Exercise: Group feedback by service impacted and rating to count the number of feedback entries.

select service_impacted , rating , count(*) 
from feedback
group by service_impacted , rating;


-- HAVING clause

-- 8. Exercise: Show the total amount due by each customer, but only for those who have a total amount greater than $100.

alter table billing
add column total_amount_due int ;

update billing
set total_amount_due = amount_due + late_fee - discounts_applied;
 
 select* from billing;
 
 select customer_id , sum(total_amount_due)
 from billing
 group by Customer_id 
 having sum(total_amount_due) > 100 ;
 
-- 9. Determine which customers have provided feedback on more than one type of service, but have a total rating less than 10.
select* from feedback;
select customer_id , count(distinct(service_impacted)) , sum(rating) as total_rating
from feedback
group by customer_id
having count(*) >1 and total_rating < 10 ; 

-- Conditional Expressions and CASE Statements

-- 1. Exercise: Categorize customers based on their subscription date: ‘New’ for those subscribed after 2023-01-01, ‘Old’ for all others.
 
 select * , case when subscription_date > '2023-01-01' then 'new' else 'old' 
 end as category
 from customer;


-- 2. Exercise: Provide a summary of each customer’s billing status, showing ‘Paid’ if the payment_date is not null, and ‘Unpaid’ otherwise.

select * , case when payment_date is not null then 'paid' else 'unpaid'
end as billing_status
from billing;


-- 4. Exercise: In service_usage, label data usage as ‘High’ if above the average usage, ‘Low’ if below.
 select* from service_usage;
 1. Temporary Change (for Current Session):
-- Check the current sql_mode
SELECT @@sql_mode;

-- Disable ONLY_FULL_GROUP_BY for the current session
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
 
 
 
 select * , case when data_used > avg(data_used) then 'high' else 'low'
 end as data_category
 from service_usage
 group by (data_used);

-- 5. Exercise: For each feedback given, categorise the service_impacted into ‘Digital’ for ‘streaming’ or ‘broadband’ and ‘Voice’ for ‘mobile’.

select *,  case when service_impacted = 'mobile' then 'voice' else 'digital' 
end as service_category 
from feedback;


-- 6. Exercise: Update the discounts_applied field in billing to 10% of amount_due for bills with a payment_date past the due_date, otherwise set it to 5%.

update billing
set discounts_applied = case when payment_date > due_date
then round(0.1 * amount_due, 2)
else round(0.05 * amount_due, 2)
end ;

select * from billing;

-- 7. Exercise: Classify each customer as ‘High Value’ if they have a total amount due greater than $500, or ‘Standard Value’ if not.
select * , case when total_amount_due > 500 then 'high value' else 'standard value'
end
from billing;
-- 8. Exercise: Mark each feedback entry as ‘Urgent’ if the rating is 1 and the feedback text includes ‘outage’ or ‘down’.

select *, case when rating = 1 and (feedback_text like '%outage%' or feedback_text like '%down%') then 'Urgent' end as Feedback_status from feedback;

-- 9. Exercise: In billing, create a flag for each bill that is ‘Late’ if the payment_date is after the due_date, ‘On-Time’ if it’s the same, and ‘Early’ if before.

alter table billing
add column flag varchar(255);

update billing
set flag = case when payment_date > due_date then 'late' else 'on time'
end;

select* from billing;



