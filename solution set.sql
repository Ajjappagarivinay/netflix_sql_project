-- Netflix Project table creation

drop table if exists netflix;
create table netflix(
show_id	varchar(10),
type varchar(20),
title varchar(150),
director varchar(250),
casts varchar(1000),
country varchar(200),
date_added varchar(60),
release_year int,
rating varchar(20),
duration varchar(50),
listed_in varchar(100),
description varchar(500)

)
-- to show data of the netflix table
select * from netflix;

select count(*)
from netflix

-- 15 Business problems

--1. Count the number of Movies vs TV Shows

select type,
count(*) as total
from netflix
group by type;

--2. Find the most common rating for movies and TV shows

select type,rating
from
	(select type,rating,count(*) as max_rating,
		rank() over(partition by type order by count(*) desc)as total_ratings
	from netflix
	group by 1,2
	order by 1,3 desc) as t1
where total_ratings=1;

3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where type='Movie' AND release_year=2020;

--4. Find the top 5 countries with the most content on Netflix

--UNNEST :In PostgreSQL, the UNNEST() function is used to expand an array into a set of rows, effectively transforming each element of the array into its own row. It is particularly useful when you have array data and want to work with individual elements as rows in a query.

--STRING_TO_ARRAY: In PostgreSQL, the STRING_TO_ARRAY() function is used to split a string into an array, based on a specified delimiter. This function is particularly useful when dealing with delimited strings, allowing you to transform them into arrays for easier processing.
--SYNTAX:STRING_TO_ARRAY(text, delimiter)

select unnest(string_to_array(country , ',')) as new,
count(show_id) as total_content from netflix
group by 1
order by total_content
desc limit 5;

--5. Identify the longest movie

select * from netflix
where type='Movie'
and duration = (select max(duration) from netflix);

--6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE 
    TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director ILIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons

SELECT *,
       split_part(duration, ' ', 1)::numeric AS session
FROM netflix
WHERE type = 'TV Show'
  AND split_part(duration, ' ', 1)::numeric > 5;

--9. Count the number of content items in each genre

select unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total_content
from netflix
group by genre
order by total_content desc;

--10.Find each year and the average numbers of content release in India on netflix.

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
	(COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India')) * 100
	,2) AS avg_content
FROM 
    netflix
WHERE 
    country = 'India'
GROUP BY 1 
ORDER BY year;

--11. List all movies that are Documentaries

select * from netflix
where listed_in ILIKE '%Documentaries%';

--12. Find all content without a director

select * from netflix
where director is null;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix
where casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
unnest(string_to_array(casts, ',')) as actors,
count(*) as actor_count from netflix
where type='Movie' and country ILIKE '%India'
group by 1
order by actor_count desc
limit 10;

15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

WITH cte AS (
    SELECT *,
           CASE 
               WHEN description ILIKE '%kill%' OR 
                    description ILIKE '%violence%' THEN 'Bad Content'
               ELSE 'Good Content'
           END AS category
    FROM netflix
)
SELECT category,
       COUNT(*) AS total_content
FROM cte
GROUP BY category;

--where description ILIKE '%kill%'
--or description ILIKE '%violence%'








