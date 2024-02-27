select * from customer;
select * from billing;
select * from service_packages;
select * from service_usage;
select * from feedback;
select * from subscriptions;

-- demonstrating joins with feedback and service_usage. 
-- both these tables will have some common customer_id, 
-- but there will also be customer_ids in the feedback table that are not present in the service_usage table and vice-versa

-- your left table is the one after from
-- right table is the one after join

-- only returns results common in both tables
select su.customer_id, su.data_used, f.feedback_text
from service_usage as su
inner join feedback as f
on su.customer_id = f.customer_id;

-- returns all entries from the left table and only intersection from the right
select su.customer_id, su.data_used, f.feedback_text
from service_usage as su
left join feedback as f
on su.customer_id = f.customer_id;

-- returns all entries from the right table and only intersection from the left 
select su.customer_id, su.data_used, f.feedback_text
from service_usage as su
right join feedback as f
on su.customer_id = f.customer_id;


-- INNER JOIN
-- Exercise 1: 
-- Write a query to find all customers along with their billing information.
select c.customer_id, c.first_name, c.last_name, b.amount_due, b.payment_date
from customer c
inner join billing b
on c.customer_id = b.customer_id;

-- Exercise 2:
-- List all customers with their corresponding total due amounts from the billing table.

select c.customer_id, sum(b.amount_due) as total
from customer c
join billing b
on c.customer_id = b.customer_id
group by c.customer_id;


-- Exercise 3:
-- Display service packages along with the number of subscriptions each has.

select sp.package_name, COUNT(s.subscription_id) as no_of_subs from service_packages sp
inner join subscriptions s
on sp.package_id = s.package_id
group by sp.package_id, sp.package_name;



-- LEFT JOIN
-- Exercise 1:
-- Write a query to list all customers and any feedback they have given, including customers who have not given feedback.

select c.customer_id, c.last_name, f.feedback_text
from customer c
left join feedback f
on c.customer_id = f.customer_id;


-- Exercise 2:
-- Retrieve all customer and the package names of any subscriptions they might have.

-- customer id and name from customer, 
-- then join subscriptions to get package id for each customer 
-- then join service_packages to get name against each package id

select c.customer_id, c.last_name, s.package_id, sp.package_name
from customer c
left join subscriptions s on c.customer_id = s.customer_id
left join service_packages sp on s.package_id = sp.package_id;


--  Exercise 3:
-- Find out which customer have never given feedback by left joining customer to feedback.
select c.customer_id, c.last_name, f.feedback_text
from customer c
left join feedback f on c.customer_id = f.customer_id
where f.feedback_text is null;



-- RIGHT JOIN
-- Exercise 1: 
-- Write a query to list all feedback entries and the corresponding customer information, including feedback without a linked customer.
select c.customer_id, c.last_name, f.feedback_text
from customer c
right join feedback f
on c.customer_id = f.customer_id;


-- Exercise 2:
-- Show all feedback entries and the full names of the customer who gave them.

select f.feedback_id, concat(c.first_name, ' ', c.last_name) as customer_name, f.feedback_text
from feedback f
right join customer c on f.customer_id = c.customer_id;



-- Exercise 3:
-- List all customers, including those without a linked service usage.
select c.customer_id, c.last_name, s.data_used 
from service_usage s
right join customer c on s.customer_id = c.customer_id ;


-- Multiple JOINs
-- Exercise 1:
-- Write a query to list all customer, their subscription packages, and usage data.

select c.customer_id, c.first_name, c.last_name, sp.package_name, su.data_used, su.minutes_used
from customer c
join subscriptions s on c.customer_id = s.customer_id
join service_packages sp on s.package_id = sp.package_id 
join service_usage su on c.customer_id = su.customer_id;

-- Subqueries
-- Exercise 1: 
-- Single-row Subquery. Write a query to find the service package with the highest monthly rate.
select * from service_packages;



select package_name, max(monthly_rate) from service_packages; -- gives error due to aggregate function

select max(monthly_rate) from service_packages; -- subquery shown separately

select package_name, monthly_rate
from service_packages
where monthly_rate = (select max(monthly_rate) from service_packages);



--  Exercise 2:
-- Find the customer with the smallest total amount of data used in service_usage.

select customer_id, data_used
from service_usage
where data_used = (select min(data_used) from service_usage);


-- Exercise 3:
-- Identify the service package with the lowest monthly rate.
select * from service_packages;

select package_id, package_name, monthly_rate
from service_packages
where monthly_rate = (select min(monthly_rate) from service_packages);


-- Exercise 4: 
-- In service_usage, label data usage as ‘High’ if above the average usage, ‘Low’ if below.
select customer_id, data_used,
case when data_used > (select avg(data_used) from service_usage) then 'high'
else 'low'
end as usage_status
from service_usage;

-- Multiple-row Subquery
-- Exercise 1 :
-- Find customers whose subscription lengths are longer than the average subscription length of every individual customer.

select * from subscriptions order by customer_id;

-- since the subquery below is returning more than one rows due to grouping, the following script will throw an error
select package_id, package_name, monthly_rate
from service_packages
where monthly_rate = (select min(monthly_rate) from service_packages group by service_type);

-- to handle multiple-row subqueries, we need to use where with IN as follows:

-- here i am just demonstrating the datediff function to find out each customer's subscription length
select customer_id, datediff(end_date, start_date)
from subscriptions
order by customer_id;

-- here we are taking average datediff for EACH customer to find out each customer's avg subscription length for all of their records
select customer_id, avg(datediff(end_date, start_date))
from subscriptions
group by customer_id
order by customer_id;

-- here we are finding out which customer_ids in the subscription table have a greater subscription lengths than ALL of each customer's average subscription length						
select customer_id
from subscriptions
where datediff(end_date, start_date) > ALL(select avg(datediff(s.end_date, s.start_date)) 
											from subscriptions s 
                                            group by s.customer_id);

-- now we can use the whole of above as a subquery to get information against this customer_id from the customer table
select *
from customer
where customer_id in (

select customer_id
from subscriptions
where datediff(end_date, start_date) > all( select avg(datediff(s.end_date, s.start_date)) 
																from subscriptions s 
																group by s.customer_id) 
);

-- Multiple-column Subquery

-- Exercise 1:
-- Select all feedback entries that match the worst rating given for any service type.


                                    
select* from feedback
 where rating = (select min(rating) from feedback);


-- Exercise2: find out the most recent feedback from each customer

-- subquery run separately
select customer_id, max(feedback_date)
from feedback
group by customer_id;

-- the whole query with the one above as a subquery
select customer_id, feedback_date, feedback_text
from feedback
where (customer_id, feedback_date) IN (select customer_id, max(feedback_date)
										from feedback
										group by customer_id);

-- Correlated Subquery
-- Exercise 1:
-- List all packages and information for packages with monthly rates are less than the maximum minutes used for each service type.


select * from service_packages as sp
where monthly_rate < (select max(minutes_used) from service_usage su group by service_type having sp.service_type = su.service_type);



-- 

-- Exercise 2: write a query to show each customer's name and their total amount_due from billing

select customer.Customer_id , customer.first_name , sum(amount_due)
 from customer
 inner join billing -- use innerjoin when there is atleast one billing match in both tables
 on customer.Customer_id = billing.Customer_id
 group by customer.Customer_id , customer.first_name;
 
 
 select customer.customer_id, customer.first_name,
(select sum(amount_due)
from billing 
where customer.customer_id = billing.customer_id) as total_amount_due
from customer ;


-- Exercise 3: write a query to show each customer's name and their total data_used from service_usage
select customer_id, first_name,
(select sum(data_used)
from service_usage su
where su.customer_id = c.customer_id) as total_data_used
from customer c;
 
 -- Write a query to show each customer's name and the number of subscriptions they have.


select customer.Customer_id , customer.First_name , count(subscription_id) as count
from customer
left join subscriptions      -- left join to list all customer , right join to list all subscriptions
on customer.Customer_id = subscriptions.customer_id
group by customer.Customer_id , customer.First_name;

select customer.Customer_id , customer.First_name, 
(select count(subscription_id)
from subscriptions
where customer.Customer_id = subscriptions.customer_id ) as count 
