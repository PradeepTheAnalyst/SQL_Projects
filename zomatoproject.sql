-- drop table if exists goldusers_signup; or if not exists table name
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,"2024-09-22"),
(3,"2024-04-21");

-- drop table if exists users; or if not exists table name
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

-- drop table if exists sales; or if not exists table name
CREATE TABLE sale_sal(userid integer,created_date date,product_id integer); 

INSERT INTO sale_sal(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


-- drop table if exists product; or if not exists table name
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sale_sal;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1.what is the total amount each customer spend on zomato?
select
	s.userid as ID,
	sum(p.price) as total_amnt
from 
sale_sal s left join product p on s.product_id = p.product_id
group by s.userid
order by s.userid;

-- 2.how many days has each customer visited zomato?
select
	userid,
    count(distinct created_date) as cust_vis
from sale_sal
group by userid
order by userid;

-- 3.what was the first product purchased by each customer?
select * from
(select
	userid,
    product_id,
    created_date,
    rank() over (partition by userid order by created_date) rnk
from sale_sal) as ant
where rnk=1;

-- 4.what is the most purchased item on the menu and how many items was it purchased by all customers?
select
	userid,
    count(product_id)
from sale_sal
where product_id = 
(select
	product_id
from sale_sal
group by product_id
order by count(product_id) desc limit 1)
group by userid
order by userid;

-- 5.which item was the most popular for each customer?
select * from
(select 
	*,rank() over (partition by userid order by cnt desc) rnk
from
(select
	userid,
    product_id,
    count(product_id) as cnt
from sale_sal
group by userid,product_id)a)b
where rnk =1;