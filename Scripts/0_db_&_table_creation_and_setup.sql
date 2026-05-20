-- Creation of netflix_db database, where we will create the netflix table with all its columns and data types :
CREATE DATABASE netflix_db;

-- Create the netflix table, when connected to the netflix_db database :
CREATE TABLE netflix (
    show_id VARCHAR(10) PRIMARY KEY,
    type VARCHAR(10),
    title VARCHAR(200),
    director VARCHAR(300),
    "cast" TEXT,
    country VARCHAR(300),
    date_added DATE,
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(20),
    listed_in VARCHAR(300),
    description TEXT
);

-- Copy the data of the table from our netflix_clean_data.csv file into the netflix table recently created in our netflix_db database :

COPY netflix -- it basically says, copy into the netflix table, the table which we created in our netflix_db database... the data of the file whose path has been mentioned in the FROM statement, along with the specifications of the file(whose path we mentioned in FROM clause) mentioned in the WITH clause(contains the specs of the file).
FROM 'C:/Users/Harsh/OneDrive/Desktop/Data Analytics Projects/Netflix_Data_Analysis_Project/data/Cleaned data/csv/netflix_clean_data.csv' -- We have to make sure our path is relative to the system's storage, and is displayed with forward slashes('/'), instead of the typical bak slashes('\').
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8');

/* In the above mentioned table we made sure to remove the NULL/Unknown keywords from the DATE nad INT type columns of date_added and release_year,
 since they are not compatible with the data types of those columns, and we replaced them with empty values, which will be automatically be displayed as NULL in SQL result-sets when retrieved */

-- To check if the data has been successfully copied into the netflix table, we can run the following query to retrieve all the records of the netflix table :
SELECT * FROM netflix;

-- To check the number of rows in the netflix table, we can run the following query :
SELECT COUNT(*) FROM netflix; -- count of rows excluding the headers.

