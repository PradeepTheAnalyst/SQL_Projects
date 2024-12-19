/*INSTAGRAM CLONE EXPLORATORY DATA ANALYSIS USING SQL*/

/*SQL SKILLS: joins, date manipulation, regular expressions, views, stored procedures, aggregate functions, string manipulation*/
 
-- --------------------------------------------------------------------------------------------------------------

-- 1.The first 10 users on the platform

select 
	*
from 
	users
order by 
	created_at asc
limit 10;
-- --------------------------------------------------------------------------------------------------------------

-- 2.Total number of registrations

select
	count(*) as 'Total Registration'
from
	users;
-- --------------------------------------------------------------------------------------------------------------

-- 3.The day of the week most users register on

create view totalregistration as
select 
	dayname(created_at) as 'dayof week',
    count(id) as 'Total Reg'
from 
	users 
group by 1 
order by 2 desc ;

select * from totalregistration;

-- or
select 
	dayname(created_at) as 'dayof week',
    count(id) as 'Total Reg'
from 
	users 
group by 1 
order by 2 desc ;
-- --------------------------------------------------------------------------------------------------------------

-- 4.The users who have never posted a photo

select 
	u.username 
from 
	users u 
left join 
	photos p 
on	p.user_id = u.id 
where 
	p.id is null;
-- --------------------------------------------------------------------------------------------------------------

-- 5.The most likes on a single photo

select 
    u.username,
    p.image_url,
	count(l.user_id) as most_likes
from 
	likes l 
left join 
	photos p 
on l.photo_id = p.id 
join 
	users u 
on u.id=p.user_id
group by l.photo_id 
order by most_likes desc
limit 1;
-- or
select 
    round
((select 
		count(*)
  from
		photos) / 
(select 
		count(*)
  from
		users),2) as 'Average Posts by Users';
-- --------------------------------------------------------------------------------------------------------------

-- 6.The number of photos posted by most active users

select 
	u.username as active_users,
    count(p.image_url) as posted_photos
from 
	photos p 
left join users u 
on p.user_id=u.id 
group by 1 
order by 2 desc
limit 5;
-- --------------------------------------------------------------------------------------------------------------

-- 7.The total number of posts

select 
	sum(users_post.total_posts) as 'Total no.of posts' 
from
(
select 
	u.username,
    count(*) as total_posts
from 
	photos p 
join users u 
on u.id=p.user_id 
group by 
	p.user_id
) as users_post;
-- --------------------------------------------------------------------------------------------------------------

-- 8.The total number of users with posts

select 
    u.id,
    count(distinct (u.id)) as total_number_of_users_with_posts
from 
	photos p 
join users u 
on u.id=p.user_id 
group by 
	p.user_id;
-- --------------------------------------------------------------------------------------------------------------

-- 9.The usernames with numbers as ending

select 
	username 
from 
	users 
where 
	username regexp '[$0-9]' ;
-- --------------------------------------------------------------------------------------------------------------

-- 10.The usernames with charachter as ending

select 
	username 
from 
	users 
where 
	username not regexp '[$0-9]' ;
-- --------------------------------------------------------------------------------------------------------------

-- 11.The number of usernames that start with A

select 
	username 
from 
	users 
where username regexp '^[A]';
-- --------------------------------------------------------------------------------------------------------------

-- 12.The most popular tag names by usage

select 
	t.tag_name,
    count(t.tag_name) as used
from 
	photo_tags p 
join tags t 
on p.tag_id = t.id 
group by t.id 
order by used desc;
-- --------------------------------------------------------------------------------------------------------------

-- 13.The most popular tag names by likes

select 
	t.tag_name,
	count(l.photo_id) as total_likes
from 
	photo_tags p 
join likes l on p.photo_id=l.photo_id 
join tags t on p.tag_id=t.id
group by t.tag_name 
order by total_likes desc 
limit 10;
-- --------------------------------------------------------------------------------------------------------------

-- 14.The users who have liked every single photo on the site

select 
	u.username,
    u.id,
    count(l.user_id) as single_photo
from users u  
join likes l 
on u.id = l.user_id
group by u.id
having 
	single_photo=(select count(*) from photos);
-- --------------------------------------------------------------------------------------------------------------

-- 15.Total number of users without comments

select count(*) as total_users from 
(
select 
	u.username, 
    c.comment_text as text 
from users u 
left join comments c on u.id = c.user_id 
group by u.id,c.comment_text 
having comment_text is null
) table1;
-- --------------------------------------------------------------------------------------------------------------

-- 16.The percentage of users who have either never commented on a photo or likes every photo

select 
	table1.tot1,
    (table1.tot1/(select count(*) from users)) * 100 as '%',
    table2.tot2,
    (table2.tot2/(select count(*) from users)) * 100 as '%'
from
(
select 
	count(*) as tot1 
from (
select 
	u.username,c.comment_text from comments c 
    right join users u on u.id=c.user_id
	group by u.username,c.comment_text 
    having comment_text is null) 
    as ab) as table1
join 
(select 
        count(*) AS tot2
from (
select 
	u.id,u.username,count(u.id) as b 
	from users u 
    join likes l on u.id = l.user_id
	group by u.id,u.username 
    having b = (select count(*) from photos)) abc) 
    as table2;
-- --------------------------------------------------------------------------------------------------------------

-- 17.Clean URLs of photos posted on the platform

select 
	substring(
    image_url,
    locate('/',image_url)+2,
    length(image_url)-locate('/',image_url)
    ) as clean_url
from 
	photos;
-- --------------------------------------------------------------------------------------------------------------

-- 18.The average time on the platform

select 
	round(avg(datediff(current_timestamp,created_at)/360),2) as average_time 
from 
	users;
-- --------------------------------------------------------------------------------------------------------------

/*CREATING STORED PROCEDURES */

-- 1.Popular hashtags list

delimiter $$
create procedure populartags ()
begin
SELECT 
	t.tag_name,
	COUNT(p.photo_id) AS pop_list 
FROM photo_tags p 
JOIN tags t ON p.tag_id = t.id 
GROUP BY t.id, t.tag_name 
ORDER BY pop_list DESC;
end $$
delimiter ;

call populartags();

-- --------------------------------------------------------------------------------------------------------------

-- 2.Users who have engaged atleast one time on the platform

delimiter $$
create procedure engagedplatform ()
begin
select 
	distinct username
from users u 
left join photos p on u.id=p.user_id join likes l on l.user_id=p.user_id
where p.id is not null;
end $$
delimiter ;

call engagedplatform();

-- --------------------------------------------------------------------------------------------------------------

-- 3.Total number of comments by the users on the platform
delimiter $$
create procedure usercomments()
begin
select 
	count(*) as total_comments
from
(
select 
	u.username,
    c.user_id
from users u 
join comments c 
on u.id = c.user_id 
where 
	c.comment_text is not null 
group by 
	u.username,c.user_id) as table1;
end $$
delimiter ;

call usercomments();
-- --------------------------------------------------------------------------------------------------------------

-- 4.The username, image posted, tags used and comments made by a specific user

delimiter $$
create procedure userinfo(in userid int(11))
begin
select 
	u.id,
    u.username,
    p.image_url,
    t.tag_name,
    c.comment_text
from users u 
left join photos p on u.id=p.user_id 
join photo_tags s on s.photo_id=p.id 
join tags t on t.id=s.tag_id
join comments c on c.user_id=u.id
where u.id = userid;
end $$
delimiter ;

call userinfo(20);