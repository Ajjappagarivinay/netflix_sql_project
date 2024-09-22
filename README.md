# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
    select type,
    count(*) as total
    from netflix
    group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
    select type,rating
    from
    	(select type,rating,count(*) as max_rating,
    		rank() over(partition by type order by count(*) desc)as total_ratings
    	from netflix
    	group by 1,2
    	order by 1,3 desc) as t1
    where total_ratings=1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
    select * from netflix
    where type='Movie' AND release_year=2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
--UNNEST :In PostgreSQL, the UNNEST() function is used to expand an array into a set of rows, effectively transforming each element of the array into its own row. It is particularly useful when you have array data and want to work with individual elements as rows in a query.

--STRING_TO_ARRAY: In PostgreSQL, the STRING_TO_ARRAY() function is used to split a string into an array, based on a specified delimiter. This function is particularly useful when dealing with delimited strings, allowing you to transform them into arrays for easier processing.
--SYNTAX:STRING_TO_ARRAY(text, delimiter)

    select unnest(string_to_array(country , ',')) as new,
    count(show_id) as total_content from netflix
    group by 1
    order by total_content
    desc limit 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
    select * from netflix
    where type='Movie'
    and duration = (select max(duration) from netflix);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
    SELECT *
    FROM netflix
    WHERE 
        TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
    select * from netflix
    where director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
    SELECT *,
           split_part(duration, ' ', 1)::numeric AS session
    FROM netflix
    WHERE type = 'TV Show'
      AND split_part(duration, ' ', 1)::numeric > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
    select unnest(string_to_array(listed_in,',')) as genre,
    count(show_id) as total_content
    from netflix
    group by genre
    order by total_content desc;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql

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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
    select * from netflix
    where listed_in ILIKE '%Documentaries%';

```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
    select * from netflix
    where director is null;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
    select * from netflix
    where casts ILIKE '%Salman Khan%'
    AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
    select 
    unnest(string_to_array(casts, ',')) as actors,
    count(*) as actor_count from netflix
    where type='Movie' and country ILIKE '%India'
    group by 1
    order by actor_count desc
    limit 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Ajjappagari Vinay

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:


- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/ajjappagari-vinay-862752280/)
- **GITHUB**: [Connect with me professionally](https://github.com/Ajjappagarivinay)


Thank you for your support, and I look forward to connecting with you!
