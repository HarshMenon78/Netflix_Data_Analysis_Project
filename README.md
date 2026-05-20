# 🎬 Netflix Content Analytics — End-to-End Data Analysis Project

![Excel](https://img.shields.io/badge/Excel-Data%20Cleaning-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-SQL%20Analysis-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

An end-to-end data analytics project analyzing Netflix's content catalog using **Microsoft Excel**, **PostgreSQL (pgAdmin 4)**, and **Power BI**. The project follows a real-world analyst workflow — raw data ingestion, cleaning, SQL-based analysis, and interactive dashboard reporting — addressing 15 business problems across content distribution, growth trends, genre patterns, director insights, geographic reach, and audience classification.

---

## 📁 Repository Structure

```
Netflix_Data_Analysis_Project/
│
├── Dashboard/
│   ├── netflix_dashboard.pbix
│   └── Dashboard_Images/
│       ├── Netflix Dashboard Home Page.png
│       ├── Page 1 (Content Distribution).png
│       ├── Page 2 (Growth Trends).png
│       ├── Page 3 (Content & Creators).png
│       └── Page 4 (Geographic Reach).png
│
├── data/
│   ├── Cleaned data/
│   │   ├── csv/
│   │   │   └── netflix_clean_data.csv
│   │   └── excel_file/
│   │       └── netflix_cleaning.xlsx
│   └── Raw data/
│       └── netflix_titles_raw_data.csv
│
├── result_set_csv_files/
│   ├── 1_content_distribution(1).csv
│   ├── 1_content_percentage(2).csv
│   ├── 2_cumilative_content(4).csv
│   ├── 2_growth_YOY(3).csv
│   ├── 2_yearly_content_type_distribution(Bonus).csv
│   ├── 3_top_genres_for_each_year(6).csv
│   ├── 3_top_genres(5).csv
│   ├── 4_top_directors_for_each_content_type(8).csv
│   ├── 4_top_directors_working_both_content_types(9).csv
│   ├── 4_top_directors(7).csv
│   ├── 5_top_countries_content_count(10).csv
│   ├── 5_top_countries_content_type_distribution(12).csv
│   ├── 5_top_countries_of_above_avg_content_count(11).csv
│   ├── 6_rating_by_audience_category_distribution(14).csv
│   ├── 6_ratings_by_audience_content_type_wise_distribution(15).csv
│   └── 6_ratings_wise_distribution(13).csv
│
├── Scripts/
│   ├── 0_db_&_table_creation_and_setup.sql
│   ├── 1_content_distribution.sql
│   ├── 2_growth_trends.sql
│   ├── 3_genre_analysis.sql
│   ├── 4_director_analysis.sql
│   ├── 5_country_analysis.sql
│   └── 6_rating_distribution.sql
│
└── README.md
```

---

## 📊 Dataset

| Property | Details |
|---|---|
| Source | [Kaggle — Netflix Movies and TV Shows by Shivam Bansal](https://www.kaggle.com/datasets/shivamb/netflix-shows) |
| Raw File | `netflix_titles_raw_data.csv` |
| Total Records | ~8,807 rows (post-cleaning) |
| Columns | 12 — `show_id`, `type`, `title`, `director`, `cast`, `country`, `date_added`, `release_year`, `rating`, `duration`, `listed_in`, `description` |

**Known data quality issues present in raw data:**
- ~30% missing values in the `director` column
- Multi-value columns — `cast`, `country`, and `listed_in` contain multiple comma-separated values stored in single cells
- Inconsistent date formats with leading/trailing spaces in `date_added`
- Misplaced values — duration values (`74 min`, `84 min`) incorrectly stored in the `rating` column
- One fully corrupted row (row 8423) with all fields shifted due to an unescaped comma in the source CSV
- Non-standard rating values — `NR` and `UR` present alongside standard ratings

---

## 🛠 Tools Used

| Tool | Role in this project |
|---|---|
| **Microsoft Excel 2019** | Data ingestion, cleaning, deduplication, blank handling, exploratory pivot tables |
| **PostgreSQL via pgAdmin 4** | Database creation, data import via COPY, SQL-based analysis across 15 business problems |
| **DBeaver** | Alternative database client for exploring & manipulating the `netflix_db` and its contents from the `netflix` table directly(Without Querying) |
| **Power BI Desktop** | Result-set import via Power Query, DAX measures, interactive 4-page dashboard |
| **VS-Code** | Data Loading (into the netflix database in postgres server), SQL Querying (Solving Business problems), Creating the GitHub Repository to synchronize the changes into it & Create `README.md` file |
| **Claude.ai** | AI assistant used for summarization and automation of the comments written beside each line of SQL query in the files of `Scripts/` (where the business problems regarding the netflix data were solved using SQL queries which give out their result-sets which can be analyzed and visualized) |

---

## 🔄 Project Workflow

### Stage 1 — Data Cleaning (Microsoft Excel)

The raw CSV was imported into Excel using **Data → Get & Transform → From Text/CSV** with UTF-8 encoding to preserve special characters in titles and names. All cleaning was performed on a working copy of the data, keeping the original raw sheet untouched.

**Key cleaning steps performed:**

- **Removed duplicates** using `show_id` as the unique identifier via Data → Remove Duplicates
- **Handled blank values** — columns with few missing rows (`release_year`, `duration`) were filled manually by cross-referencing the internet; high-volume blank columns (`director`, `cast`, `country`, `listed_in`) were filled with `**Unknown**` using Filter → Blanks → Ctrl+Enter bulk fill method
- **Fixed date formatting** — used `=--TRIM(cell)` formula to strip leading/trailing spaces from `date_added` while preserving the underlying date serial number, then reformatted cells to a consistent date display format using flash fill
- **Corrected misplaced values** — duration values (`74 min`, `84 min`) found in the `rating` column were manually moved to their correct `duration` column; the affected `rating` cells were set to `**Unknown**`
- **Standardized ratings** — `NR` and `UR` replaced with `Not Rated` via Find & Replace with Match Entire Cell Contents enabled
- **Handled corrupted row** — row no. `8423` had all fields shifted due to an unescaped comma in the source CSV export; fields were manually corrected using internet references; `show_id` was unrecoverable and assigned the placeholder `s9999`; documented in the cleaning log sheet
- **DATE and INT typed columns** — left as empty cells rather than filling with text, ensuring PostgreSQL imports them as proper `NULL` values without type errors
- **Exploratory pivot tables** — built in a dedicated sheet covering content type distribution, top countries, genre frequency, and rating breakdown to validate the cleaned data before SQL import

**Output:** `netflix_clean_data.csv` saved under `data/Cleaned data/csv/` and exported as UTF-8 CSV for SQL import

---

### Stage 2 — SQL Analysis (PostgreSQL / pgAdmin 4)

The cleaned CSV was imported into a PostgreSQL database (`netflix_db`) using the `COPY` command. A dedicated setup script handles database creation, table schema definition, and data import. Six analysis scripts address specific analytical themes, each producing a result-set exported as CSV.

**Database setup** (`0_db_&_table_creation_and_setup.sql`)**:**

```sql
CREATE TABLE netflix (
    show_id       VARCHAR(10) PRIMARY KEY,
    type          VARCHAR(10),
    title         VARCHAR(200),
    director      VARCHAR(300),
    cast          TEXT,
    country       VARCHAR(200),
    date_added    DATE,
    release_year  INT,
    rating        VARCHAR(20),
    duration      VARCHAR(20),
    listed_in     VARCHAR(200),
    description   TEXT
);

COPY netflix
FROM 'your/local/path/to/netflix_clean_data.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
```

**SQL concepts applied across all analysis scripts:**

`SELECT` `WHERE` `GROUP BY` `ORDER BY` `HAVING` `LIMIT` `COUNT` `SUM` `AVG` `ROUND` `CASE WHEN` `EXTRACT` `LAG()` `DENSE_RANK()` `PARTITION BY` `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` `CTEs (WITH clause)` `Subqueries` `UNNEST` `STRING_TO_ARRAY` `STRING_AGG` `TRIM` `COALESCE` `NULLIF`

Each script's result set was exported as a `.csv` file into `result_set_csv_files/` for Power BI consumption.

---

### Stage 3 — Dashboard (Power BI)

All 16 result-set CSVs (including the bonus query) were imported into Power BI via Power Query. Data types were verified and column names standardized in Power Query before loading. DAX measures were written in a dedicated `_Measures` table to keep all calculations organized separately from data tables. The dashboard is structured across a home navigation page and 4 analytical pages.

---

## 🔍 Business Problems Solved

### 📌 01 — Content Distribution &nbsp;`1_content_distribution.sql`
| # | Problem Statement |
|---|---|
| 1 | What is the overall split between Movies and TV Shows on Netflix, and what percentage does each hold of the total content volume? |
| 2 | What is the content-type-wise breakdown of all content and what percentage does each category make up of the entire catalog? |

### 📌 02 — Growth Trends &nbsp;`2_growth_trends.sql`
| # | Problem Statement |
|---|---|
| 3 | How has Netflix's content count grown year over year, and what is the YoY growth percentage? |
| 4 | What did Netflix's cumulative library size look like at any point in time? |
| — | *(Bonus)* How does the yearly content addition trend differ between Movies and TV Shows? |

### 📌 03 — Genre Analysis &nbsp;`3_genre_analysis.sql`
| # | Problem Statement |
|---|---|
| 5 | What are the most common individual genres on Netflix when the multi-genre `listed_in` column is properly split and counted? |
| 6 | Which genre dominated Netflix's catalog for each year? |

### 📌 04 — Director Analysis &nbsp;`4_director_analysis.sql`
| # | Problem Statement |
|---|---|
| 7 | Who are the top 10 most frequent directors on Netflix by total titles directed? |
| 8 | Who are the top 5 directors separately for Movies and TV Shows — do the same directors dominate both content types? |
| 9 | Which directors have worked across both Movies and TV Shows on Netflix? |

### 📌 05 — Country Analysis &nbsp;`5_country_analysis.sql`
| # | Problem Statement |
|---|---|
| 10 | Which are the top 15 content producing countries on Netflix by total title count? |
| 11 | Which countries produce above average content volume on Netflix? |
| 12 | What is the Movies vs TV Shows breakdown for each of the top content producing countries? |

### 📌 06 — Ratings & Audience &nbsp;`6_rating_distribution.sql`
| # | Problem Statement |
|---|---|
| 13 | What is the overall rating distribution across Netflix's catalog, and what percentage does each rating hold? |
| 14 | How is content distributed across audience categories (Kids / Kids 7+ / Teens / Adults / Unclassified) and what percentage does each hold? |
| 15 | For each audience category, what is the Movies vs TV Shows breakdown? |

---

## 📈 Power BI Dashboard

### 🏠 Home Page — Navigation Hub
![Home Page](Dashboard/Dashboard_Images/Netflix%20Dashboard%20Home%20Page.png)

### 📊 Page 1 — Content Distribution
*Covers Problems 1, 2, 13, 14, 15*

![Content Distribution](Dashboard/Dashboard_Images/Page%201%20(Content%20Distribution).png)

### 📈 Page 2 — Growth Trends
*Covers Problems 3, 4 and Bonus query*

![Growth Trends](Dashboard/Dashboard_Images/Page%202%20(Growth%20Trends).png)

### 🎬 Page 3 — Content & Creators
*Covers Problems 5, 6, 7, 8, 9*

![Content and Creators](Dashboard/Dashboard_Images/Page%203%20(Content%20%26%20Creators).png)

### 🌍 Page 4 — Geographic Reach
*Covers Problems 10, 11, 12*

![Geographic Reach](Dashboard/Dashboard_Images/Page%204%20(Geographic%20Reach).png)

---

## 💡 Key Business Insights

- **Netflix is predominantly a Movie platform** — 69.62% of its catalog consists of Movies, yet TV Show additions have grown at a consistently faster rate since 2016, signaling a gradual strategic shift toward serialized content
- **Content growth was explosive between 2015 and 2019** — Netflix's library scaled from under 500 titles to over 5,000 in just four years, reflecting an aggressive global content acquisition phase; growth has visibly slowed post-2019
- **Adult content dominates the catalog** — 45.52% of all content falls under the Adult audience category (TV-MA, R, NC-17), positioning Netflix as a mature-content platform rather than a family-first service
- **International Movies and Dramas are the most prevalent genres** — reflecting Netflix's strategy of acquiring broad, globally accessible content to serve diverse international subscriber bases
- **The United States leads content production by a significant margin** — but India, the United Kingdom, and Japan are substantial contributors, highlighting Netflix's active localization strategy in key international markets
- **Director talent pools are largely siloed by content type** — very few directors on the platform have directed both Movies and TV Shows, suggesting Netflix's Movie and TV production pipelines operate largely independently of each other

---

## ▶️ How to Reproduce

**Step 1 — Excel Cleaning**
1. Open `data/Raw data/netflix_titles_raw_data.csv` in Excel via Data → Get & Transform → From Text/CSV (set encoding to UTF-8)
2. Apply the cleaning steps documented in Stage 1 above
3. Export the cleaned sheet as `netflix_clean_data.csv` into `data/Cleaned data/csv/`

**Step 2 — PostgreSQL Setup & Analysis**
1. Install PostgreSQL and open pgAdmin 4
2. Create a new database named `netflix_db`
3. Open and run `Scripts/0_db_&_table_creation_and_setup.sql` — update the file path in the COPY command to your local path before running
4. Run each analysis script from `Scripts/` in numbered order (01 through 06)
5. After running each script, export the result set as CSV into `result_set_csv_files/`

**Step 3 — Power BI Dashboard**
1. Open Power BI Desktop
2. Open `Dashboard/netflix_dashboard.pbix`
3. If prompted to update data source paths, redirect to your local `result_set_csv_files/` folder
4. Click Refresh — all visuals will populate with your data

---

## 👤 Author

**Harsh Menon**
Aspiring Data Analyst — Excel · SQL · Power BI

[![GitHub](https://img.shields.io/badge/GitHub-HarshMenon78-181717?style=flat&logo=github)](https://github.com/HarshMenon78)