--Netflix Project
drop table if exists netflix;
create table netflix (
show_id	 varchar(6),
type   varchar(10),
title	varchar(110),
director varchar(208),
casts	varchar(1000),
country varchar(150),
date_added  varchar(50),
release_year int,
rating	varchar(10),
duration varchar(20),
listed_in	varchar(100),
description varchar(250)
);

select * from netflix;

--BUISNESS PROBLEMS
--1. Count the Number of Movies vs TV Shows
select
type,
count(*) as total_content
from netflix
group by type;

--2. Find the Most Common Rating for Movies and TV Shows

select type,
     rating
from 
(
select  type,
        rating,
		count(*),
		rank() over( partition by type order by count(*) desc ) as ranking
from netflix
group by 1,2
) as t1
where ranking = 1;

--3. List All Movies Released in a Specific Year (e.g., 2020)
select type,
       title
from netflix
where release_year = '2020';

--4. Find the Top 5 Countries with the Most Content on Netflix
select  
        unnest (string_to_array(country, ',')) as new_country,
        count(show_id) as total_content
from netflix
group by 1 
order by 2 desc
limit by 5;

--5. Identify the Longest Movie

 select
    type,
	duration
from netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

--6. Find Content Added in the Last 5 Years
select 
      *
from netflix
where 
to_date(date_added, 'month, DD, YYYY') >= current_date - interval '5 years';

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select * from netflix
where director ilike '%Rajiv Chilaka%';

--8. List All TV Shows with More Than 5 Seasons
select 
      *
from netflix
where type = 'TV Show'
and 
split_part(duration, ' ',1)::int > 5 ;

--9. Count the Number of Content Items in Each Genre

select 
unnest (string_to_array(listed_in , ',')) as genre,
count(show_id) as total_content
from netflix
group by 1
order by 2 desc ;

--10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!
select 
      count(*),
	  extract(YEAR from to_date(date_added,'Month,DD,YYY')) as year,
	  round( count(*) :: numeric/(select count(*)from netflix where country ='India'):: numeric * 100,2) as avg_content
from netflix where country ='India'
group by 2
order by 1 desc
limit  5;

--11. List All Movies that are Documentaries
select * 
from netflix
where listed_in like '%Documentaries%';

--12. Find All Content Without a Director
select *
from netflix 
where director is null;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select * 
from netflix
where casts like '%Salman Khan%'
and release_year > extract(year from current_date) -10;

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select 
unnest(string_to_array(casts,','))as actors,
count(*) as total_content
from netflix
 WHERE country ILIKE '%india%'
group by 1
order by 2 desc
limit 10;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
WITH new_table
as
(
select *,
     case
	   when description ilike '%Kill%'
	   or
	   description ilike '%Violence%'
	   then 'Age-restricted_content'
	   else 'Clean_content'
	 end category
from netflix
)
select 
category,
count(*) as total_content
from new_table
group by 1;
