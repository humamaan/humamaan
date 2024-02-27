-- SELECT

-- Exercise: Retrieve all columns and rows from the `customer` table
select * from customer;

-- Exercise: List only the names and subscription dates of the customer.
select first_name, last_name, subscription_date from customer;

Set sql_safe_updates=0;

update customer
set date_of_birth = str_to_date(date_of_birth, '%m/%d/%Y');

alter table customer
modify column date_of_birth date;

update customer
set subscription_date = str_to_date(subscription_date, '%m/%d/%Y');

alter table customer
modify column subscription_date date;

update customer
set last_interaction_date = str_to_date(last_interaction_date, '%m/%d/%Y');

alter table customer
modify column last_interaction_date date;
-- Exercise: Fetch all unique email addresses from the `customer` table and then count the number of unique email ids 

select count(distinct email) from customer;

-- because it should be unique for all.

-- Exercise: Display all columns from the `billing` table.
select * from billing;


update billing
set due_date = str_to_date(due_date, '%m/%d/%Y');

alter table billing
modify column due_date date;

UPDATE billing
SET payment_date = CASE WHEN payment_date <> '' then STR_TO_DATE(payment_date, '%m/%d/%Y') else NULL END;

alter table billing
modify column payment_date date;

-- Exercise: Show only the bill ID and the amount due from the `billing` table.
 
 select bill_id, amount_due from billing;
 
-- WHERE

--  Exercise: Identify customer who live at "209 Pond Hill"
 
 select * from customer where address = '209 Pond Hill';
 
--  Exercise: Find bills in the `billing` table with an amount_due greater than 1000.
select * from billing where amount_due > 1000;

--  Exercise: Find all the late fee less than 500
select * from billing where late_fee < 500;

--  Show bills that were generated for `customer_id' 5
select * from billing where customer_id = 5; 
 
-- WHERE with (IN, OR, AND, NOT EQUAL TO, NOT IN)

-- Exercise: Identify customer who live at either '5 Northridge Road', '814 Kinsman Lane’


select * from customer where Address in ("5 Northridge Road" , "814 Kinsman Lane");


-- Exercise: using or and AND

-- Exercise: Display customer whose phone number is NOT '123-456-7890'.
select * from customer
where Phone_number <> 1234567890;

-- Exercise: List all bills except those with billing cycles in "January 2023" and "February 2023"
select * from billing 
where billing_cycle not in ('23-jan' , '23-feb');

-- ORDER BY

-- Exercise: Order customer by their names in ascending order
select * from customer order by first_name;

-- Exercise: Display bills from the `billing` table ordered by `amount_due` in descending order.
select * from billing order by amount_due desc;

-- LIMIT

-- Exercise: Show only the first 10 customer.
select * from customer
 limit 10;
-- Exercise: List the top 5 highest bills from the `billing` table.
select * from billing
 order by amount_due 
 desc limit 5;
 
-- Exercise: Retrieve the latest 3 bills based on the due date.
select * from billing 
order by due_date desc
 limit 3;