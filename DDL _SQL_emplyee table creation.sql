/*
Create a table called  employees with the following columns and datatypes:

ID - INT autoincrement
last_name - VARCHAR of size 50 should not be null
first_name - VARCHAR of size 50 should not be null
age - INT
job_title - VARCHAR of size 100
date_of_birth - DATE
phone_number - INT
insurance_id - VARCHAR of size 15

SET ID AS PRIMARY KEY DURING TABLE CREATION

*/
create table employees (id int auto_increment primary key,last_name varchar(50) not null,first_name varchar(50) not null, age int, job_title varchar(100), date_of_birth date , phone_number int , insurance_id varchar(15));

select*from employees;					
/*
Add the following data to this table in a SINGLE query:

Smith | John | 32 | Manager | 1989-05-12 | 5551234567 | INS736 |
Johnson | Sarah | 28 | Analyst | 1993-09-20 | 5559876543 | INS832 |
Davis | David | 45 | HR | 1976-02-03 | 5550555995 | INS007 |
Brown | Emily | 37 | Lawyer | 1984-11-15 | 5551112022 | INS035 |
Wilson | Michael | 41 | Accountant | 1980-07-28 | 5554403003 | INS943 |
Anderson | Lisa | 22 | Intern | 1999-03-10 | 5556667777 | INS332 |
Thompson | Alex | 29 | Sales Representative| 5552120111 | 555-888-9999 | INS433 |

*/
insert into employees (first_name, last_name, age, job_title, date_of_birth, phone_number, insurance_id)
values('smith', 'john', 32, 'manager', '1989-05-12', 5551234567, 'INS736'), 
	('johnson', 'sarah', 28, 'analyst', '1993-09-20', 5559876543,'INS832'),
    ('davis', 'david', 45, 'HR', '1976-02-03', 5550555995, 'INS007'),
    ('Brown' ,'Emily' ,37 ,'Lawyer' ,'1984-11-15' , 5551112022 ,'INS035'),
	('Wilson' , 'Michael' ,41 , 'Accountant' , '1980-07-28' , 5554403003 , 'INS943'),
	('Anderson', 'Lisa' , 22 ,'Intern' , '1999-03-10' ,5556667777 , 'INS332'),
	('Thompson','Alex', 29 , 'Sales Representative', '2000-04-10' , 5558889999 ,'INS433');


giving #errors in phonenumber


-- Rename the ID column to employee_ID

alter table employees
rename column id to employee_id;



-- phone_number is INT right now. Change the datatype of phone_number to make them strings of FIXED LENGTH of 10 characters.
-- Do some research on which datatype you need to use for this.

alter table employees
modify phone_number varchar(10);

insert into employees (first_name, last_name, age, job_title, date_of_birth, phone_number, insurance_id)
values('smith', 'john', 32, 'manager', '1989-05-12', 5551234567, 'INS736'), 
	('johnson', 'sarah', 28, 'analyst', '1993-09-20', 5559876543,'INS832'),
    ('davis', 'david', 45, 'HR', '1976-02-03', 5550555995, 'INS007'),
    ('Brown' ,'Emily' ,37 ,'Lawyer' ,'1984-11-15' , 5551112022 ,'INS035'),
	('Wilson' , 'Michael' ,41 , 'Accountant' , '1980-07-28' , 5554403003 , 'INS943'),
	('Anderson', 'Lisa' , 22 ,'Intern' , '1999-03-10' ,5556667777 , 'INS332'),
	('Thompson','Alex', 29 , 'Sales Representative', '2000-04-10' , 5558889999 ,'INS433');
select*from employees;

/*-- Create a table called employee_insurance with the following columns and datatypes:

insurance_id VARCHAR of size 15
insurance_info VARCHAR of size 100

Make insurance_id the primary key of this table
							
*/
create table employee_insrance (insurance_id varchar(15) primary key, insurance_info varchar(100));



/*
Insert the following values into employee_insurance:

"INS736", "unavailable"
"INS832", "unavailable"
"INS007", "unavailable"
"INS035", "unavailable"
"INS943", "unavailable"
"INS332", "unavailable"
"INS433", "unavailable"

*/
insert into employee_insrance 
values ( "INS736", "unavailable"
"INS832", "unavailable"
"INS007", "unavailable"
"INS035", "unavailable"
"INS943", "unavailable"
"INS332", "unavailable"
"INS433", "unavailable" );

select* from employee_insrance; 

-- Set the insurance_id column in employees table as a foreign key referencing the insurance_id columnin the employee_insurance table. 

alter table employees
add constraint fk_id foreign key (insurance_id) references employee_insrance (insurance_id);



-- Add a column called email to the employees table. Remember to set an appropriate datatype
alter table employees
add column email varchar(100);



-- Add the value "unavailable" for all records in email in a SINGLE query

update employees
set email= 'unavailable'
where employee_id >0 ;

