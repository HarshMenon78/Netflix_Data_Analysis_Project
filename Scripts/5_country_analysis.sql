-- 5_country_analysis :-

/* Problem 10 : Which are the top 15 content producing countries on Netflix by total title count? :-
   - For this we will create our 1st CTE named countries_content which will display the individual country wise content count, since there are multiple rows in original netflix cleaned data, that correspond to multiple countries mentioned in a big string where each countries is seperated with commas, we will use STRING_TO_ARRAY() to convert those multi-country-associated content rows's country colum  into an array of individual countries(from its original state of large String), then this individual countries inside of these multi-country-associated rows of contents will be displayed in seperate rows using UNNEST(), corresponding to their contet in a way that each content covers each of the country its associated to in individual rows(where the contents may end up repeating in multiple rows to display their corresponding associated countries ), While the TRIM() makes sure that each of theseindividual countries mentioned corresponding to their content are trimmed out for their leading and trailing unwanted spaces. Then we will count the number of content associated with each country using COUNT(*) and display the country name and its corresponding content count in the result-set.
   - Then we will create a second CTE named countries_rnk, where we will retrieve all the info mentioned in the 1st CTE and then will also assign a rank to each of these countries based on their content count using DENSE_RANK() window function, where the country with the highest content count will get the rank of 1, the next highest content count will get the rank of 2, and so on. If there are multiple countries with the same content count, they will receive the same rank, and the next rank in order will be assigned to the next rows in order accordingly.
   - In the main query we will retrieve all the contents of the countries_rnk CTE, and then we will filter the results to only show the top 15 countries with the highest content count by using the WHERE clause to specify that we only want to see rows where the country_rnk is less than or equal to 15. Then we will order the results by country_rnk in ascending order to see the countries with the highest content count(and the top most ranks) at the top of the result-set.
*/
WITH countries_content AS ( -- this CTE will find the individual rows of all the countries mentioned in the original countries column, seperating the list of countries mentioned in the original country column into individual rows using STRING_TO_ARRAY() which will create an array of individual country names corresponding to each content, and using UNNEST() to expand the array into individual rows[which will show each country in a separate row corresponding to each content, if a content has multiple countries associated with it, it will be repeated in multiple rows showing each country its corresponded with individually], and then count the number of content associated with each country will be shown, and display the country name and its corresponding content count in the result-set.
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS countries, -- Our country column originally contains multiple countries in a few rows, so we use STRING_TO_ARRAY() to seperate rows containing the single long string of multiple countries into an Array of smaller strings of individual countries, then these individual countries corresponding to their content will be divided into individual rows(such that each content shows all their genres corresponding to them in individual seperate rows[can mean the countries will repeat in multiple rows if they have multiple countries they are associated to]), and then we use TRIM() to remove any leading or trailing spaces from the newly created individual country name showing column.
    COUNT(*) AS content_count
FROM
    netflix
WHERE -- Ensures only those countries are retrieved in result-set which are mentioned in the original country column, and excludes any rows where the country is not mentioned in the original country column, as we are only interested in analyzing the known/mentioned content producing countries and not the unknown ones.
    country != '**Unknown**'
GROUP BY -- Grouping on the basis of each of the individual country to find out the count of contents associated to these individual countries from the new rows of netflix data(displaying contents having multiple countries in individual rows corresponding to each of their associated countries in individual rows).
    TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))
), countries_rnk AS (
SELECT
    countries,
    content_count,
    DENSE_RANK() OVER(ORDER BY content_count DESC) AS country_rnk -- will rank the countries in the order of their content count(since the ranking is being assigned when the data is ordered in descending order of their content_count, as mentioned in the ORDER BY content_count), country with the highest content count getting the rank of 1, and the next highest content count getting the rank of 2, and so on. If there are multiple countries with the same content count, they will receive the same rank, and the next rank in order will be assigned to the next rows in order accordingly.
FROM
    countries_content
)
SELECT
    countries,
    content_count,
    country_rnk
FROM
    countries_rnk
WHERE -- to retrieve the top 15 countries with the highest content count, we can use the WHERE clause to filter the results based on the country_rnk column, and specify that we only want to see rows where the country_rnk is less than or equal to 15.
    country_rnk <= 15 
ORDER BY -- to order the final result-set in the order of their rank, we can use the ORDER BY clause and specify that we want to order the results by the country_rnk column in ascending order (which is the default order for ORDER BY). This will ensure that the countries with the highest content count (rank 1) will appear at the top of the result-set, followed by the next highest content count (rank 2), and so on, up to rank 15.
    country_rnk;

/* Problem 11 : Which countries produce above average content volume on Netflix? :-
   - For this we will first create a CTE called country_content where-in we will find out the individual country-wise content counts for each of these countries, since there are multiple rows in original netflix cleaned data, that correspond to multiple countries mentioned in a big string where each countries is seperated with commas, we will use STRING_TO_ARRAY() to convert those multi-country-associated content rows's country colum  into an array of individual countries(from its original state of large String), then this individual countries inside of these multi-country-associated rows of contents will be displayed in seperate rows using UNNEST(), corresponding to their contet in a way that each content covers each of the country its associated to in individual rows(where the contents may end up repeating in multiple rows to display their corresponding associated countries ), While the TRIM() makes sure that each of theseindividual countries mentioned corresponding to their content are trimmed out for their leading and trailing unwanted spaces.
   - We will make sure to include/filter-in only those countries that have been mentioned and are known to the dataset ignoring ambigous unkown countries whose contents have been mentioned.
   - We will then create a second CTE called country_avg, which will retrieve all the info mentioned in 1st CTE and corresponding to the rows of that , it will also display the AVG(content_count) for all the countries combined in a window function(so that the combined average be shown corresponding to each of the individual rows of individual countries and their corresponding content_count).
   - We will then create a 3rd CTE called country_status, which will retrieve all the info mentioned in the 2nd CTE of country_avg(i.e individual countries, their content_count, the overall avg content count of all the individual countries combined[corresponding to each row]), and then will determine the status of each of these individual rows of countries, their content_count and combined avg content count whether each country produces above average content volume or below average content volume by comparing the content_count of each country with the avg_content_count overall of all countries.
   - In the Main query we will retrieve all the contents of the country_status CTE(i.e individual countries, their content_count, the overall avg content count of all the individual countries combined, and the status of each country whether it produces above average content volume or below average content volume), and then we will filter the results to only show those countries that produce above average content volume by using the WHERE clause to specify that we only want to see rows where the status is 'Above Average'. Then we will order the results by content_count in descending order to see the countries with higher content production at the top of the result-set.
*/
WITH country_content AS( -- this CTE will find the individual rows of all the countries mentioned in the original countries column, seperating the list/array of countries(for those contents associated with multiple countries, shown in a long string seperated by commas) mentioned in the original country column into individual rows using STRING_TO_ARRAY() which will create an array of individual country names corresponding to each content, and using UNNEST() to expand the array into individual rows[which will show each country in a separate row corresponding to each content, if a content has multiple countries associated with it, it will be repeated in multiple rows showing each country its corresponded with individually], and then count the number of content associated with each country will be shown, and display the country name and its corresponding content count in the result-set.
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS countries, -- similar to the previous query, we are using STRING_TO_ARRAY() to split the original country column into an array of individual country names(for those rows of content associated with multiple countries, which are mentioned in a single big string where each countries is seperated by commas), and then using UNNEST() to expand the array into individual rows(for previously mentioned individual countries they will be shown in a single row itself, for those contents shown in multiple array of countries they will be shown in multiple rows correspondingly to their content which repeats to show their individual countries they associated to in individual rows), so that each country associated with a content is shown in a separate row, and then using TRIM() to remove any leading or trailing spaces from the newly created individual country name showing column.
        COUNT(*) AS content_count -- to count the number of content associated with each country, we can use the COUNT(*) function which will count the number of rows for each country in the result-set(where the contents/rows repeat in case of multiple countries are associated with that country, to display all the individual countries they are associated with individually in each row), giving us the total content count for each country.
    FROM
        netflix
    WHERE
        country != '**Unknown**' -- to ensure that we only consider the known/mentioned content producing countries in our analysis, we can use the WHERE clause to filter out any rows where the country is not mentioned in the original country column, as we are only interested in analyzing the known/mentioned content producing countries and not the unknown ones. 
    GROUP BY -- Grouping on the basis of each of the individual country to find out the count of contents associated to these individual countries from the new rows of netflix data(displaying contents having multiple countries in individual rows corresponding to each of their associated countries in individual rows).
        TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))
), country_avg AS ( -- this CTE will retrieve all the contents mentioned in the first CTE of country_content and then will also find the AVG of content_count for all the individual countries combined, corresponding to the individual countries and their content count.
SELECT
    countries,
    content_count,
    AVG(content_count) OVER() AS avg_content_count -- will find the avg of content count of all the rows included in the result-set of country_count CTE(i.e will find the AVG content_count of individual countries mentioned), and show it corresponding to each row value since we used the window function format.
FROM
    country_content
), country_status AS( -- this CTE will retrieve all the contents of the countries_avg CTE(i.e individual countries, their content_count, the overall avg content count of all the individual countries combined), and then will determine the status of each of these individual rows(content's country, its count & avg content_count of all the countries combined) whether each country produces above average content volume or below average content volume by comparing the content_count of each country with the avg_content_count overall of all countries.
SELECT
    countries,
    content_count,
    avg_content_count,
    CASE -- to determine whether each country produces above average content volume or below average content volume, we useed the CASE statement to compare the content_count of each country with the avg_content_count(overall of all countries[mentioned in countries_avg CTE i.e all the individual countries]). If the content_count is greater than the avg_content_count, we can label it as 'Above Average', otherwise we can label it as 'Below Average'. This will allow us to categorize each country based on its content production relative to the average.
        WHEN content_count > avg_content_count THEN 'Above Average'
        ELSE 'Below Average'
    END AS status
FROM
    country_avg
)
SELECT -- In the main query we will retrieve all the contents of the country_status CTE(i.e individual countries, their content_count, the overall avg content count of all the individual countries combined, and the status of each country whether it produces above average content volume or below average content volume), and then we will filter the results to only show those countries that produce above average content volume by using the WHERE clause to specify that we only want to see rows where the status is 'Above Average'. Then we will order the results by content_count in ascending order to see the countries with higher content production at the bottom of the result-set.
    countries,
    content_count,
    avg_content_count,
    status
FROM
    country_status
WHERE -- to retrieve only those countries that produce above average content volume, we can use the WHERE clause to filter the results based on the status column, and specify that we only want to see rows where the
    status = 'Above Average'
ORDER BY
    content_count DESC; -- to order the final result-set in descending order of content_count, we used the ORDER BY clause on content_count DESC. This way we will be able to see the countries with higher content production at the top of the result-set.

/* Problem 12 : What is the Movies vs TV Shows breakdown for each of the top 10 content producing countries? :-
   - For this we will first create a CTE called content_count_type_pivot which will display the contents in individual rows to each of their associated individual countries, then will GROUP BY those individual countries to find out the total content_count, the movie_count & the TV_show_count of that country.
   - In the second CTE we will plainly only find the average content count for all the individual countries combined mentioned in the 1st CTE(without mentioning any other entity from that CTE since that will require us to GROUP BY the data on the basis of that extra column/entity mentioned since aggregation can only display the aggregated result for the entire dataset or for all the rows of a group within an extra mentioned column in SELECT).
   - In the 3rd CTE which we named as countries_status, we will retrieve all the info called in 1st CTE of cctp, and corresponding to that we will also find the status of each country based on how they compare to the average content count in avg_content CTE(which will also be mentioned in FROM statement since we only need the value of avg_content_count from that CTE, it dosent have any corresponding values for each row in this CTE, hence Inner cross join will do the job and no need for extra JOIN statement is required).
   - In the Main query we will retrieve all the contents of the countries_status CTE, along with retrieving the values of what the movie_count and tv_show_count make up to the total of content_count(here we will ensure to convert the data type of movie_count & tv_sow_count respectively to 'numeric' since if we dont do it, SQL ignores the decimal number after the point in Int on int division eg if movie_count = 3 & content_count = 10, it will take it as 3/10 whose actual answer is 0.3 but the value after point will be ignored hence will result in 0 , even if we are multiplying it with 100 to find the % , it will be like 0 * 100 rather than 0.3 * 100, so hence will always return 0, so we have to convert the data type of movie_count & tv_show_count respectively in their own percentages finding), and filter the results to only show the countries having status as 'Above_average_count' where the individual rows are arranged in descending order of their content_count, and limited to 10 using LIMIT 10 since we needed the top 10 countries's content distribution. 
*/
WITH content_count_type_pivot AS( -- this CTE will find the individual countries-wise count(for the known countries, i.e whose individual name is known/mentioned in dataset) of all rows of content associated with these individual countries, and also will find the SUM of content count for each country based on the type of content whether it is a Movie or a TV Show in seperate columns in result-set(mentioned in SELECT as entities).
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS countries, -- similar to the previous queries, we are using STRING_TO_ARRAY() to split the original country column into an array of individual country names(for those rows of content associated with multiple countries, which are mentioned in a single big string where each countries is seperated by commas), and then using UNNEST() to expand the array into individual rows(for previously mentioned rows containing contents with corresponding array of strings of individual countries[which was converted into array format from a big string format seperated by commas], hence all the individual countries[mentioned in the array] associated with the multi country associated content will be displayed corresponding to them in individual rows), where multiple country-associated contents will repeat in multiple rows to individually show each country associated with that content in a seperate row, and then using TRIM() to remove any leading or trailing spaces from the newly created individual country name showing column.
    COUNT(*) AS content_count, -- this will count the indiviual rows of content(from the new rows, where cntents associated with multiple countries repeat to show each of these countries they are associated with in individual rows) associated with each country, giving us the total content count for each country.
    COUNT(CASE WHEN type = 'Movie' THEN 1 END) AS movie_count, -- this will ensure to pivot the data in a way that if the content row from the new rows of netflix data if belongs to movies content-type(from the 'type' column), then that row will be assigned value 1, and for all other rows since no ELSE statement is mentioned they will be assigned NULL, and the COUNT() function will count only those rows which are assigned 1 (i.e those rows which belong to Movie content type) and will not count those rows which are assigned NULL (i.e those rows which dont belong to tv show content type), giving us the total count of Movie content type for each country. We could even use SUM() instead of COUNT() in this function since the count of all these 1s assigned which matches the desired content type will be the same as the sum of all those 1s(even if in the ELSE condition was mentioned where the non-matching content-types were assigned 0, then count() will end up counting even the non-matching rows along with the matching giving the same result as total content count for the country, hence in that case SUM() will be more useful since it will only sum up the 1s, and the sum of 0 is gonna be 0 anyways so it will end up giving the exact count of all the rows of contents of that country belonging to the movie type content).
    COUNT(CASE WHEN type = 'TV Show' THEN 1 END) AS tv_show_count -- this will also ensure to pivot the data in such a way that if the new row of content(containing each of the content and their individual countries they are associated to in individual rows) from netflix data belongs to the content type of TV-show for the corresponding country its listed for(from the GROUP BY), if yes then it will assign 1 to those rows and for those which dont match they will be by default assigned NULL, and since we are using COUNT() function it will count only those rows which are assigned 1 (i.e those rows which belong to TV Show content type) and will not count those rows which are assigned NULL (i.e those rows which dont belong to movie content type), giving us the total count of TV Show content type for each country. We could even use SUM() instead of COUNT() in this function since the count of all these 1s assigned which matches the desired content type will be the same as the sum of all those 1s.
FROM
    netflix
WHERE
    country != '**Unknown**' -- to ensure that we only consider the known/mentioned content
GROUP BY -- to group the results by each individual country, we used the GROUP BY clause and specified that we want to group the results by the countries column(individual countries) which we created using TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) in the SELECT statement. This will ensure that we get a separate row for each country along with its corresponding content count, movie count, and TV show count.
    TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))
), avg_content AS( -- this CTE will only find out the aggregated result of average content count for all the individual countries and their content count combined. This result can be made use of in the next CTE to create status for each country on the basis of how their content count compares to the avgerage content count for all individual countries combined.
SELECT
    AVG(content_count) AS avg_content_count -- we used the aggregation function of AVG() to find the overall AVG content count of all the rows(of individual countries and their content count) included in the result-set of the previous CTE of content_count_type_pivot. Here we didnt use the GROUP BY since we didnt mention any other entity from the cctp CTE(1st cte mentioned in this query) in the SELECT statement of this current CTE(avg_content), hence it will show the overall average content count of all the countries combined (rather than showing the group-wise avg aggregation of content count for any group or segment from one of the pre-existing columns like country,type etc from netflix data[since cctp CTE retrieve all the country-wise content_count etc from netflix data itself]).
FROM
    content_count_type_pivot
), countries_status AS( -- This CTE will assign the status to each of the country-based row values from the content_count_type_pivot CTE for all its content_count based on how they compare with the avg_content_count from the avg_content CTE.
SELECT
    countries,
    content_count,
    movie_count,
    tv_show_count,
    CASE -- Assigning statuses to each of the country and their content_count based row for how they compare to the avg_content_count value of the overall countries and their content_count.(If content_count > avg_content_count Then that row should be of the status 'Above_Avg_count', if country's content_count > avg_content_count then it should be of the status of 'Below_avg_count')
        WHEN content_count > avg_content_count THEN 'Above_avg_count'
        ELSE 'Below_avg_count'
    END AS status
FROM
    content_count_type_pivot,
    avg_content
)
SELECT -- In the main query we will retrieve all the values from the above mentioned CTE of country_status(which by default already retrieves all the info from 1st CTE[country-wise total content_count, total movie_count & total TV_show_count] and finds an additional status that each of these countries hold based on their content count compared to the avg content count overall), and will ensure to filter out only those countries which are of the status of 'Above_avg_count' and will display the the countries in descending order of their content_count.
    countries,
    content_count,
    movie_count,
    tv_show_count,
    status,
    ROUND((movie_count::numeric / content_count) * 100, 2) AS movie_percentage, -- to find the percentage of movie content count out of the total content count for each country, we can divide the movie_count by the content_count and then multiply by 100 to get the percentage value. Here the ROUND() function is used to round the percentage value to 2 decimal places for better readability, and we also cast movie_count to numeric data type to ensure that we get a decimal value for the percentage calculation instead of an integer division result.
    ROUND((tv_show_count::numeric / content_count) * 100, 2) AS tv_show_percentage -- to find the percentage of TV show content count out of the total content count for each country, we can divide the tv_show_count by the content_count and then multiply by 100 to get the percentage value. Here the ROUND() function is used to round the percentage value to 2 decimal places for better readability, and we also cast tv_show_count to numeric data type to ensure that we get a decimal value for the percentage calculation instead of an integer division result.
FROM
    countries_status
WHERE -- will ensure to give out only those countries in the result-set of this query which belong to the above_avg_count status of their content_count
    status = 'Above_avg_count'
ORDER BY -- makes sure that the result displayed in the result-set of this query will be displayed in descending order of the content_count column
    content_count DESC
LIMIT -- Since we need the top 10 countries based on their content_count, and see their corresponding content distribution.
    10;


---------------------------------------------------

/* Basic query to find all the individual countries(which in PowerBI can be used to find their count) :- */
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS countries -- similar to the previous queries, we are using STRING_TO_ARRAY() to split the original country column into an array of individual country names(for those rows of content associated with multiple countries, which are mentioned in a single big string where each countries is seperated by commas), and then using UNNEST() to expand the array into individual rows(for previously mentioned rows containing contents with corresponding array of strings of individual countries[which was converted into array format from a big string format seperated by commas], hence all the individual countries[mentioned in the array] associated with the multi country associated content will be displayed corresponding to them in individual rows), where multiple country-associated contents will repeat in multiple rows to individually show each country associated with that content in a seperate row, and then using TRIM() to remove any leading or trailing spaces from the newly created individual country name showing column.
FROM
    netflix
WHERE
    country != '**Unknown**'; -- to ensure that we only consider the known/mentioned content producing countries in our analysis, we can use the WHERE clause to filter out any rows where the country is not mentioned in the original country column, as we are only interested in analyzing the known/mentioned content producing countries and not the unknown ones.