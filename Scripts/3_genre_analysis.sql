-- 3_genre_analysis :-

/* Problem 5 : What are the top 10 most common individual genres on Netflix when the multi-genre column is properly split and counted? :-
    - For this we will use the STRING_TO_ARRAY() function to split the listed_in column which contains multiple genres in a single string, into an array of individual genres by using ',' as the separator, then on top of that we will use the UNNEST() function to split the array of genres into individual rows corresponding to their show_id, and then we will use TRIM() function to remove any leading or trailing unwanted spaces from the individual genres after splitting them into individual cell/row values. 
    - Then we will use COUNT(*) to count the no. of rows from the netflix table for each genre(showing individual genres from listed_in corresponding to each show_id, the show_id might repeat if it had multiple genres in the original listed_in column, to display each of its genres corresponding to it in individual rows), and then we will use GROUP BY to group the result on the basis of genre to get the aggregated result of count of content corresponding to each category in genre(individual).
    - We will arrange the order of result in the result-set in descending order of genre_content_count to get the most common genres at the top, and then we will use LIMIT 10 to show only the top 10 most common genres on Netflix.
*/
SELECT
    TRIM((UNNEST(STRING_TO_ARRAY(listed_in, ',')))) AS genre, -- here the STRING_TO_ARRAY() will sperate each individual genres in the listed_in column by using ',' as the separator, and then the UNNEST() will seperate the individual genres in the array into individual rows corresponding to that show_id(which will be repeated in multiple rows to display all the genres it holds individually in each row) which holds that array of genres(previously string), and TRIM() is used to remove any leading or trailing spaces from the genres after splitting them into individual cell/row values.
    COUNT(*) AS genre_content_count -- will count the individual rows from netflix table when its split in according to individual genres as mentioned above(each content is split on the basis of their genre where each content is repeated to show each of the genres it includes in listed_in in individual rows), and count the no. of rows where that particular genre has been mentioned, corresponding to the genre.
FROM
    netflix
GROUP BY -- group it on the basis of genre to get the corresponding aggregated result of ganre_content_count corresponding to each category in genre(individual).
    genre 
ORDER BY
    genre_content_count DESC
LIMIT 10;

/* Problem 6 : Which genre dominated netflix's catalog for each year? :-
   - For this we will create our first CTE called yearly_genre_count to find year-wise genre dominance using EXTRACT(YEAR FROM date_added) and string_to_array()/UNNEST()/TRIM() respectiveley to create distinct groups and then mention them in GROUP BY so that we can form cohort groups.
   - Then we will create a second CTE named genre_rnk where we will retrieve all the year_added-wise genre's content count, where we will assign ranks to each genre within each year based on ther count of content falling within that cohort group(of added_year and the genre respectively) using DENSE_RANK() which will assign repeating ranks for similar valued rows, and the next row in order will be provided the rank next in order without gap.
   - Then in the Main query we will call out all the info called out in the prevoius CTE of genre_rnk(which itself retrieves all the info from its previous CTE along with providing the ranking information), we will here filter out the top genre for each year based on their ranks(which are further based on their genre_content_count_for_year).
 */
WITH yearly_genre_count AS( -- this CTE will find the year_added-wise genre count, by splitting the listed_in column into individual genres and counting them according to their year_added.
SELECT
    EXTRACT(YEAR FROM date_added) AS year_added, -- will find the year to which the date_added belongs to, on the basis of this further in this query it will find the count of all the individual rows from netflix table/data(of shows) which fall under the cohort groups of particular year_added and the particular genres.
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre, -- this will find the individual genres inside of the listed_in column mentioned as 1 big string which will be converted to an array of individual genres since we used it inside of STRING_TO_ARRAY() with ',' as delimiter, then thes individual genres splitted into seperate strings to form an array will be further splitted into rows containing individual genres corresponding to their show_id which carried each of these genres in a single large string previously, then these individually row-wise splitted genres(corresponding to the show/show_id added) will now be trimmed out for extra spaces using TRIM().
    COUNT(*) AS genre_content_count_for_year -- will find the count of total no. of rows of the individual genre-wise splitted column of all show-wise individual genres, and finding the count of each of the genres for a given year.
FROM
    netflix
WHERE
    date_added IS NOT NULL -- filtering out the rows which have NULL values in the date_added column, since we cannot extract year from NULL values, and it would show error if we try to do so.
GROUP BY -- grouping the result by both year_added and genre to get the aggregated result of count of all the individual rows of content which belong to that cohort group of year_added & genre(i.e all the rows[new ones displaying same repeating shows in multiple rows, to display each of their genres originally counted in listed_in column individually] of content added sharing same year_added & genre).
    year_added, 
    genre
), genre_rnk AS ( -- This CTE will call-out all the contents mentioned in the forst CTE of yearly_genre_count(i.e year_added, their corresponding content's genres and their count of content belonging to that particular year_added and genre respectively) and alongside that will also calculate a ranking column, which ranks the rows belonging to the partitions of year_added, for their individual rows when arranged in DESCENDING order of their genre_content_count_for_year.
SELECT
    year_added, --------------------|
    genre, -------------------------| -- Extrcting all the entities declared in yearly_genre_count CTE, giving the information of year-wise count of shows for the specefic genres of their cohort groups(formed of year_added and genres).
    genre_content_count_for_year, --|
    DENSE_RANK() OVER(PARTITION BY year_added ORDER BY genre_content_count_for_year DESC) AS rnk -- will assign ranking(DENSE_rank() will assign repeating ranks for similar valued rows, and the next row in order will be provided the rank next in order without gap) to each of the rows inside of the year_added partition(since we mentioned year_added in PARTITION BY sub-clause), when the rows within these partitions are arranged in descending order of their genre_content_count_for_year.
FROM
    yearly_genre_count
)
SELECT
    year_added,
    genre,
    genre_content_count_for_year,
    rnk
FROM
    genre_rnk
WHERE -- making sure that only the top 1 genres based on thier content count for that year be shown.
    rnk <= 1
ORDER BY
    year_added,
    genre_content_count_for_year DESC,
    rnk;