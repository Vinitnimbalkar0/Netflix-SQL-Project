DROP TABLE IF EXISTS netflix
CREATE TABLE netflix(
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),	
	director VARCHAR(220),	
	castS VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in	VARCHAR(150),
	description	VARCHAR(250)

)

SELECT * FROM netflix

-- Q1. Count the number of Movies vs TV Shows

SELECT 
	DISTINCT type,
	COUNT(*) as Total_COUNT 
FROM netflix
GROUP BY 1

-- Q2. Find the most common rating for movies and TV shows
SELECT 
type,
rating
FROM(
	SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
	FROM netflix
	GROUP BY 1,2
) as t1
WHERE rnk = 1

-- Q3. List all movies released in a specific year (e.g., 2020)
SELECT 
	*
FROM netflix
WHERE type = 'Movie' and release_year = 2020

-- Q4. Find the top 5 countries with the most content on Netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as Total_Content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;

-- Q5. Identify the longest movie
SELECT
	*
FROM netflix
WHERE type='Movie'
and
duration = (SELECT MAX(duration) FROM netflix )

-- Q6. Find content added in the last 5 years
SELECT
	*
FROM netflix
WHERE TO_DATE(date_added,'Month DD,YYYY')  > CURRENT_DATE  - INTERVAL '5 years'

-- Q7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT
	*FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


-- Q8. List all TV shows with more than 5 seasons
SELECT
	*
FROM netflix
WHERE type = 'TV Show' and duration > '5 Seasons';

SELECT
	*
FROM netflix
WHERE type = 'TV Show' and SPLIT_PART(duration, ' ',1)::numeric > 5

-- Q9. Count the number of content items in each genre
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS Genre,
	COUNT(Show_id) AS No_of_Content
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in,','))

-- Q10.Find each year and the average numbers of content release in India on netflix. 
SELECT
	EXTRACT(YEAR FROM (TO_DATE(date_added,'Month DD,YYYY'))) as year,
	COUNT(*),
	ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric *100,2) AS AvgContentPerYear
FROM netflix
WHERE country = 'India'
GROUP BY 1

-- Q11. List all movies that are documentaries
SELECT
	*
FROM netflix
WHERE type = 'Movie' 
and 
listed_in ILIKE '%Documentaries%'

-- Q12. Find all content without a director
SELECT
	*
FROM netflix
WHERE director IS NULL


-- Q13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT
	*
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
	-- Show_id,
	-- casts,
	UNNEST(STRING_TO_ARRAY(casts,',')),
	COUNT(*) AS TOTAL_CONTENTS
FROM netflix
WHERE country ILIKE  '%India%'
GROUP BY 1
ORDER BY COUNT(*) DESC
LIMIT 10


-- Q 15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
	SELECT
		*,
		CASE
			WHEN description ILIKE '%kill%' 
			OR
			description ILIKE '%violence%' THEN 'Bad_content'
			ELSE 'Good_content'
		END category
	FROM netflix
)
SELECT
	category,
	COUNT(*) AS Total_Content
FROM new_table
GROUP BY 1