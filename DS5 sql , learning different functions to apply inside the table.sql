-- 1) Changing Data Types for Date Columns:
alter table feedback
modify column feedback_date date;

alter table service_usage
modify column usage_date date;
 
-- Back up customer data:
 create table customer_backup
 as select* from customer;

-- SQL safe updates off

set sql_safe_updates = 0;

-- Change Subscription_Date
 alter table subscriptions
 modify column start_date date;

 alter table subscriptions
 modify column end_date date;
-- Change Date_of_Birth

-- Change last_interaction_date



-- 2) Setting Primary Keys and Autoincremental Values:
  -- for customer table
alter table customer
modify Customer_id int auto_increment primary key;


-- for billing table
alter table billing
modify bill_id int auto_increment primary key;


-- 3) INSERT Statements:

-- Insert new customer:

insert into customer (FIRST_NAME, LAST_NAME, EMAIL, ADDRESS, PHONE_NUMBER, DATE_OF_BIRTH, SUBSCRIPTION_DATE, LAST_INTERACTION_DATE)
values ('huma' , 'maan' , 'huma.maan493@gmail.com' , 'USA' , 3473223999 , '1993-07-15', '2024-08-16' , '2023-07-08');

-- Adding a new billing entry:
select * from billing;
 insert into billing (customer_id, amount_due, due_date, payment_date, billing_cycle, discounts_applied, late_fee)
 values (1001, 4539.09, '2024-02-15', '2024-01-31', '23-Dec', 150.70, 50.65);
 
-- Inserting a customer with minimal details:

insert into customer(first_name)
values ( 'ayesha');

-- Adding billing with only the billing cycle specified

insert into billing(billing_cycle)
values(' 24-jan');

-- 4) UPDATE Statements:

-- Update last_interaction_date of customers with a subscription_date before 2023-01-01:
 
  update customer
  set last_interaction_date = '2022-01-01'
  where subscription_date < '2023-01-01';
  
-- Update email for customer named "Anonymous":

update customer
set email= 'ayesha@gmail.com'
where first_name = 'ayesha';

-- Increase late fee for overdue payments:

update billing
set late_fee = late_fee + 10
where payment_date > due_date ;

select* from billing;
-- Changing phone number for customer ID 10:

update customer
set phone_number = 3473332990
where customer_id = 10 ;

-- 5) DELETE Statements:

-- Delete customers without subscription or last interaction date:
delete from customer
where subscription_date is null or last_interaction_date is null;

-- Erase customers named "Anonymous":
 delete from customer
 where First_name = 'ayesha';
 select* from customer;
 
-- Deleting entries in the billing table with due date before 2022-01-01:

delete from billing 
where due_date < '2021-01-01' ;

-- 6) Data Cleaning:
-- Identify customers with phone numbers not starting with "555":
select* from customer
where Phone_number not like "555%";

-- Replace "Road" with "Rd." in address field:

update customer
set address = replace(address , 'road' , 'rd');

-- Convert billing cycle to uppercase:

update billing
set billing_cycle= upper(billing_cycle);

-- Identify records with negative discounts applied
 select * from billing
 where discounts_applied <0;

-- Remove leading/trailing whitespaces from the name field
 update customer
 set first_name = trim(first_name);
 
 update customer
 set last_name = trim(last_name);
select* from customer;


-- 7) Data Transformation:

-- Adding a month to all subscription dates:
select subscription_date, subscription_date + interval 1 month 
from customer;

update customer
set subscription_date = subscription_date + interval 1 month ;


-- Extracting the year from sub,scription dates:
select subscription_date, year(subscription_date)
from customer;


-- Concatenating name and email fields:

select concat(first_name , ' ' , email)
from customer;

