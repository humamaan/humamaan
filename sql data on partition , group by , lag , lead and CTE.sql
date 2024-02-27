-- PARTITION vs GROUP BY
-- groupby produces singlerow summary for each group by consolidating it 
-- partition produces calculations by keeping the individual row details.

-- MULTIPLE PARTITIONS
-- supposee you have sales data and want to calculate the cummulative sales foe each product and region  , then you use partition for both productas and region


--  count(..) over(patition by....) from ;


-- PARTITION BY EXERCISES
-- Exercise 1: Find the number of feedback entries for each service type for each customer

select customer_id , service_impacted, count(feedback_id)
from feedback
group by customer_id , service_impacted;

select customer_id, service_impacted,
count(feedback_id) over(partition by customer_id , service_impacted) from feedback;



-- Exercise 2: Calculate the Average data_used for each service_type for each customer



-- RANK() and DENSE_RANK()

-- assume we have set of scores 10,20,20,30 so with rank the scores would be ranked as 1,2,2,4(value increases by 1 for each)
-- and with dense rank would be 1,2,2,3(values increases by 1 for diffeerent value

select *,
rank() over(order by data_used desc) as ranking
from service_usage;

-- ranking inside each partition


-- rank exercises
-- Exercise 1: Rank customers according to the number of services they have subscribed to

 select customer_id , count(subscription_id) as no_of_subs,
 rank() over(order by count(subscription_id) desc) as ranking from subscriptions
 group by customer_id;
 
 
 
-- Exercise 2:Rank customers based on the total sum of their rating they have ever given.


 select customer_id , sum(rating) as total_rating,
 rank() over(order by sum(rating)desc) from feedback
 group by customer_id;
 
 
 
-- LEAD(): lead shows the customer next month data


-- lead(...) over (patition by.....)  as ..
-- from...



-- Exercise 1:View next session’s data usage for each customer

select customer_id , data_used,
lead(data_used) over (partition by customer_id) as current_data
from service_usage;    -- lead shows the customer next month data

-- Exercise 2:Calculate the difference in data usage between the current and next session.

select customer_id , data_used,
lead(data_used) over (partition by customer_id) as current_data,
data_used - lead(data_used) over (partition by customer_id) as previous_data
from service_usage;    

-- LAG():
-- Exercise 1: Previous Session's Data Usage

select customer_id , data_used, usage_date,
lag(data_used) over (partition by customer_id) as previous_data
from service_usage;    

-- Exercise 2:Interval Between previous and current record

select customer_id , data_used, usage_date,
lag(data_used) over (partition by customer_id) as previous_data ,
data_used - lag(data_used) over (partition by customer_id) as difference
from service_usage;    

-- COMMON TABLE EXPRESSIONS (CTEs)

--  we define subquery by giving it a column.

-- using a subquery vs a CTE

-- with subquery					

-- with CTE



-- Exercise 2: find out the most recent feedback from each customer.

select customer_id , feedback_text , max(feedback_date)
from feedback
group by customer_id ;

 
 SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
 
 
 

-- with CTE

with latest_feedback as (


select customer_id , max(feedback_date) as max_date
from feedback
group by customer_id )


select lf.customer_id ,f.feedback_text , f.rating , lf.max_date
from feedback f
join latest_feedback lf on f.customer_id = lf.customer_id and f.feedback_date = lf.max_date;

 

-- Exercise 3: Find customer name and id for all customers with length of subscription more than 4000 days

