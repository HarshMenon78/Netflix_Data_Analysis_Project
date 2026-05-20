-- 2_growth_trends :-

/* Problem 3 : How has Netflix's content count grown year over year, and what is the YoY growth percentage? :-
   - For this we will find the year_added corresponding to each content on the basis of their date_added, using EXTRACT(YEAR FROM date_added).
   - After grouping the data by year_added in the first CTE, we will move along to the second CTE where we will find out the previous year's content count using LAG() window function(by mentioning content_count inside of lag() since the previous value of that column is what we need , when arranged in ascending order of their year_added , to fetch us the previous year's content_count).
   - In the main query we will find the difference of content count between the current year and previous year to find out how much has the content_count added changed in the current year compared to the previous year, and find the growth percentage of the current year's content_count compared to the previous year's. 
*/
WITH yearly_content_count AS( -- this CTE contains the year_added-wise content_count, displaying the count of all the contents added on the dates of that particular year_added, and the year_added is extracted from the date_added column of netflix table.
SELECT
    EXTRACT(YEAR FROM date_added) AS year_added, -- extracting the year from the date_added column to find the year-wise growth of content on netflix.
    COUNT(*) AS content_added_count -- will find the count of all the individual rows from netflix table, which have the corresponding year_added on the basis of which we have GROUPED the data.
FROM
    netflix
WHERE
    date_added IS NOT NULL -- filtering out the rows which have NULL values in the date_added column, since we cannot extract year from NULL values, and it would show error if we try to do so.
GROUP BY -- grouping the result by the year_added, so that we can get the aggregated result of count of content added in each year separately.
    year_added
), lag_content_count AS( -- this CTE contains the year_added-wise content_count along with the previous year's content_count, which is calculated using LAG() window function, and it will help us in calculating the growth of content count from previous year to current year in the main query.
SELECT
    year_added,
    content_added_count,
    LAG(content_added_count) OVER(ORDER BY year_added) AS previous_year_content_count -- using the LAG analytical window function to get the content_added_count of the previous year(since the window function is arranged in ascending order of the year_added & its corresponging contents will be shown accordingly) for each year_added, which will help us in calculating the growth of content count from previous year to current year.
FROM
    yearly_content_count
)
SELECT
    year_added,
    content_added_count,
    previous_year_content_count,
    content_added_count - previous_year_content_count AS content_added_count_growth_from_previous_year, -- calculating the growth of content count from previous year to current year by subtracting the content_count of previous year from the content_count of current year.
    ROUND(((content_added_count::decimal - previous_year_content_count) / previous_year_content_count) * 100, 2)  AS percentage_growth -- based on the principle of (((old_value - new_value)/old_value) * 100) , giving us the idea of how much has the change of content_count of current year compared to its previous year makes up to the previous year's content count.
FROM
    lag_content_count
ORDER BY -- to retrieve the result-set's rows in ascending order of year_added.
    year_added;

/* Problem 4 : What did Netflix's cumulative library size look like at any point in time? :-
   - For this we will create a CTE called yearly_content_info to calculate the yearly content count , by grouping the data by year_added(which was found out by using EXTRACT(YEAR FROM date_added)).
   - Then in the main query we will use window function on the SUM() to find the cumulative sum of all the content_count up untill that year/current year(ehich will be done using the ORDER BY sub-clause which will arrange the rows in ascending order of year_added, hence for the rows arranged in ascending order of year_added, the cumulative sum will be calculated accordingly up untill the year of the current row).
*/
WITH yearly_content_info AS ( -- This CTE will display the year_added-wise content_count i.e the count of contents(tv shows & movies) added in that year(i.e the date_added falls in that year).
SELECT
    EXTRACT(YEAR from date_added) AS year_added,
    COUNT(*) AS year_content_added_count
FROM
    netflix
WHERE
    date_added IS NOT NULL
GROUP BY
    year_added
)
SELECT
    year_added,
    year_content_added_count,
    SUM(year_content_added_count) OVER(ORDER BY year_added) AS running_content_count -- will find the sum of all the counts of years up untill the current row's year mentioned(i.e SUM of year_content_added_count of all years_added including previous years to the current year, up untill current year), since we used ORDER BY sub-clause and arranged it in ascending order of their year_added in the window function of OVER(), hence giving us the sum of content_count up untill the year_added corresponding to it in the result-set. [this formula basically sets the frame clause to include rows only up untill the current row i.e UNBOUNDED PRECEDING to the CURRENT ROW, hence ends up showing the running count of content corresponding to each year_added in the result-set by adding up al the content counts of the previuos year_added to that year added aswell]
FROM -- we are retrieving all the year_added wise year_content_added_count & finding the running_content_count till each year_added from the above created CTE of yearly_content_info.
    yearly_content_info
ORDER BY 
    year_added;


/* Bonus Problem : Year-Wise Content Distribution for movies and TV shows :-
   - We firstly need to extract the year from the date_added column to find the year-wise content distribution of netflix.
   - Then, we will group the data by the extracted year and count the number of movies and TV shows added in each year.
   - We will also select the column of 'type' in SELECT and also mention it in GROUP BY to find the content-type wise distribution of all contents added for that year added.
   - The COUNT(*) will give us the aggregated result of count of all the Rows/contents from the netflix table, for the entities we have grouped it on the basis of(cohort groups)... i.e year_added and their corresponding content-types(type column's values).
   - Finally we will Order the result-set in ascending order of year_added to get the year-wise content distribution for movies and TV shows in a chronological order.
*/
SELECT
    EXTRACT(YEAR FROM date_added) AS year_added, -- will extract the year from the date_added column to find the year-wise contnet distribution of netflix, after mentioning the same year_added entity in the GROUP BY clause.
    type, -- we will also select the type column to find the distribution of movies and TV shows in each year_added, after mentioning the same type entity in the GROUP BY clause.
    COUNT(*) AS content_count -- will find the count of all the individual rows from netflix table, which have the corresponding year_added on the basis of which we have GROUPED the data.
FROM
    netflix
WHERE
    date_added IS NOT NULL -- filtering out the rows which have NULL values in the date_added column, since we cannot extract year from NULL values, and it would show error if we try to do so.
GROUP BY -- grouping the data by the extracted year and type to form a cohort group of year_added and for each contnet-type's there is for the contents belonging to that year_added , and hence finding their cohort group's corresponding aggregated value of COUNT(*), which will basically give us the count of all the rows/content from the netflix table, corresponding to that year added and the type of the content that exists within that year_added, corresponding to their distinct cohort groups.
    year_added,
    type
ORDER BY -- to retrieve the result-set's rows in ascending order of year_added, to get the year-wise content distribution for movies and TV shows in a chronological order.
    year_added;