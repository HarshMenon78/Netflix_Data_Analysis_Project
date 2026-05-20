# 🎬 Netflix Content Analytics — End-to-End Data Analysis Project

![Excel](https://img.shields.io/badge/Microsoft%20Excel-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DBeaver](https://img.shields.io/badge/DBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-000000?style=for-the-badge&logo=githubcopilot&logoColor=white)
![Claude](https://img.shields.io/badge/Claude.ai-CC785C?style=for-the-badge&logo=anthropic&logoColor=white)

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
| Columns | 12 — show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description |

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
| **PostgreSQL via pgAdmin 4** | Database creation, table setup, and monitoring loaded data and database assets |
| **VS-Code** | Primary query editor for writing SQL to solve business problems and exporting result sets to `result_set_csv_files/` for later Power BI visualization |
| **DBeaver** | Used alongside pgAdmin for browsing table rows and verifying imported data without writing queries each time |
| **Power BI Desktop** | Result-set import via Power Query, DAX measures, interactive 4-page dashboard |
| **GitHub Copilot** | Assisted with auto-completion of inline SQL comments mentioned beside each lines of sql query(explaining the significance of that line of SQL query) i.e to assist in query documentation inside `Scripts/`'s sql files |
| **Claude.ai** | Used as an AI assistant for project planning, workflow structuring, and documentation — all SQL queries, cleaning decisions, and dashboard design were executed independently |

---

## 🔄 Project Workflow

### Stage 1 — Data Cleaning (Microsoft Excel)

The raw CSV was imported into Excel using **Data → Get & Transform → From Text/CSV** with UTF-8 encoding to preserve special characters. All cleaning was performed on a working copy, keeping the original raw sheet untouched.

**Key cleaning steps performed:**

- **Removed duplicates** using `show_id` as the unique identifier via Data → Remove Duplicates
- **Handled blank values** — columns with few missing rows (`release_year`, `duration`) were filled manually by cross-referencing the internet; high-volume blank columns (`director`, `cast`, `country`, `listed_in`) were bulk-filled with `**Unknown**` using Filter → Blanks → Ctrl+Enter
- **Fixed date formatting** — used `=--TRIM(cell)` to strip leading/trailing spaces from `date_added` while preserving the underlying date serial number, then reformatted to a consistent date display format
- **Corrected misplaced values** — duration values (`74 min`, `84 min`) in the `rating` column were moved to `duration`; affected `rating` cells set to `**Unknown**`
- **Standardized ratings** — `NR` and `UR` replaced with `Not Rated` via Find & Replace with Match Entire Cell Contents enabled
- **Handled corrupted row** — row 8423 had all fields shifted due to an unescaped comma in the source export; manually corrected; `show_id` assigned placeholder `s9999`
- **DATE and INT columns** — left as empty cells so PostgreSQL imports them as proper `NULL` values without type errors
- **Exploratory pivot tables** — built in a dedicated sheet covering content type split, top countries, genre frequency, and rating breakdown

**Output:** `netflix_clean_data.csv` saved under `data/Cleaned data/csv/`

---

### Stage 2 — SQL Analysis (PostgreSQL / pgAdmin 4)

The cleaned CSV was imported into a PostgreSQL database (`netflix_db`) using the `COPY` command. A dedicated setup script handles database and table creation. Six analysis scripts address specific analytical themes, each producing a result-set exported as CSV into `result_set_csv_files/`.

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

---

### Stage 3 — Dashboard (Power BI)

All 16 result-set CSVs were imported into Power BI via Power Query. Data types were verified and column names standardized before loading. DAX measures were written in a dedicated `_Measures` table. The dashboard is structured across a home navigation page and 4 analytical pages, built with a Netflix-inspired dark theme.

---

## 🔍 Business Problems Solved

### 📌 01 — Content Distribution &nbsp;[`1_content_distribution.sql`](Scripts/1_content_distribution.sql)

| # | Problem Statement | Approach |
|---|---|---|
| 1 | What is the overall split between Movies and TV Shows on Netflix, and what percentage does each hold? | Grouped by `type`, used `COUNT` and `ROUND` with `SUM() OVER()` window function to compute row percentages alongside counts in a single query |
| 2 | What is the content-type-wise (rating-wise) breakdown and what percentage does each category make up? | Grouped by `rating`, applied the same window percentage pattern; sorted descending by content count |

---

### 📌 02 — Growth Trends &nbsp;[`2_growth_trends.sql`](Scripts/2_growth_trends.sql)

| # | Problem Statement | Approach |
|---|---|---|
| 3 | How has Netflix's content count grown year over year, and what is the YoY growth percentage? | Used two chained CTEs — first to extract yearly counts via `EXTRACT(YEAR FROM date_added)`, second to apply `LAG()` window function for previous year comparison and derive growth percentage |
| 4 | What did Netflix's cumulative library size look like at any point in time? | Used a CTE for yearly counts, then applied `SUM() OVER()` with `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` frame clause for running total |
| — | *(Bonus)* How does yearly content addition differ between Movies and TV Shows? | Used conditional aggregation — `SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END)` — to pivot content types into separate columns per year in a single query |

---

### 📌 03 — Genre Analysis &nbsp;[`3_genre_analysis.sql`](Scripts/3_genre_analysis.sql)

| # | Problem Statement | Approach |
|---|---|---|
| 5 | What are the most common individual genres when the multi-genre column is properly split? | Used `UNNEST(STRING_TO_ARRAY(listed_in, ','))` with `TRIM()` to explode comma-separated genre strings into individual rows before aggregating — handling multi-value columns SQL natively |
| 6 | Which genre dominated Netflix's catalog for each year? | Used three CTEs — UNNEST expansion, yearly genre counts, then `DENSE_RANK() OVER(PARTITION BY year ORDER BY count DESC)` — filtering to rank 1 per year in the final SELECT |

---

### 📌 04 — Director Analysis &nbsp;[`4_director_analysis.sql`](Scripts/4_director_analysis.sql)

| # | Problem Statement | Approach |
|---|---|---|
| 7 | Who are the top 10 most frequent directors on Netflix? | Filtered out `Unknown` and `NULL` directors, grouped by `director`, sorted descending by count, limited to top 10 |
| 8 | Who are the top 5 directors separately for Movies and TV Shows? | Used two CTEs — first for director-type counts, second applying `DENSE_RANK() OVER(PARTITION BY type ORDER BY total DESC)` — filtered to rank ≤ 5 per content type |
| 9 | Which directors have worked across both Movies and TV Shows? | Used `HAVING COUNT(DISTINCT type) = 2` to filter only directors appearing in both content types; `STRING_AGG(DISTINCT type, ' & ')` to display both types in one readable column |

---

### 📌 05 — Country Analysis &nbsp;[`5_country_analysis.sql`](Scripts/5_country_analysis.sql)

| # | Problem Statement | Approach |
|---|---|---|
| 10 | Which are the top 15 content producing countries? | Applied `UNNEST(STRING_TO_ARRAY(country, ','))` with `TRIM()` to handle multi-country rows correctly before aggregating — same pattern used for genres |
| 11 | Which countries produce above average content volume? | Used a CTE for country counts, then applied `AVG(content_count) OVER()` as a window function to compute the overall average inline, classified each country using `CASE WHEN` |
| 12 | What is the Movies vs TV Shows breakdown per top country? | Used an `expanded_countries` CTE carrying the `type` column through the UNNEST expansion, enabling conditional aggregation for movie and TV show counts in the same row per country |

---

### 📌 06 — Ratings & Audience &nbsp;[`6_rating_distribution.sql`](Scripts/6_rating_distribution.sql)

| # | Problem Statement | Approach |
|---|---|---|
| 13 | What is the overall rating distribution and percentage per rating? | Grouped by `rating`, used `COUNT` with `ROUND` and `SUM() OVER()` window percentage — same pattern as Problem 1 |
| 14 | How is content distributed across audience categories and what percentage does each hold? | Used a CTE to classify each row into Kids / Kids (7+) / Teens / Adults / Unclassified via `CASE WHEN` on `rating`; outer query aggregated counts and window percentages by audience category |
| 15 | For each audience category, what is the Movies vs TV Shows breakdown? | Extended the audience classification CTE with conditional aggregation — `SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END)` — to produce movie and TV show counts per audience band in one query |

---

## 📈 Power BI Dashboard

### 🏠 Home Page — Navigation Hub
![Home Page](Dashboard/Dashboard_Images/Netflix%20Dashboard%20Home%20Page.png)

---

### 📊 Page 1 — Content Distribution
*Problems 1, 2, 13, 14, 15 — from [`1_content_distribution.sql`](Scripts/1_content_distribution.sql) & [`6_rating_distribution.sql`](Scripts/6_rating_distribution.sql)*

![Content Distribution](Dashboard/Dashboard_Images/Page%201%20(Content%20Distribution).png)

---

### 📈 Page 2 — Growth Trends
*Problems 3, 4 + Bonus — from [`2_growth_trends.sql`](Scripts/2_growth_trends.sql)*

![Growth Trends](Dashboard/Dashboard_Images/Page%202%20(Growth%20Trends).png)

---

### 🎬 Page 3 — Content & Creators
*Problems 5, 6, 7, 8, 9 — from [`3_genre_analysis.sql`](Scripts/3_genre_analysis.sql) & [`4_director_analysis.sql`](Scripts/4_director_analysis.sql)*

![Content and Creators](Dashboard/Dashboard_Images/Page%203%20(Content%20%26%20Creators).png)

---

### 🌍 Page 4 — Geographic Reach
*Problems 10, 11, 12 — from [`5_country_analysis.sql`](Scripts/5_country_analysis.sql)*

![Geographic Reach](Dashboard/Dashboard_Images/Page%204%20(Geographic%20Reach).png)

---

## 💡 Key Business Insights

- **Netflix is predominantly a Movie platform** — 69.62% of its catalog consists of Movies, yet TV Show additions have grown at a faster rate since 2016, signaling a gradual strategic shift toward serialized content
- **Content growth was explosive between 2015 and 2019** — the library scaled from under 500 titles to over 5,000 in four years, reflecting an aggressive global acquisition phase; growth has visibly slowed post-2019
- **Adult content dominates the catalog** — 45.52% of all content falls under the Adult audience category (TV-MA, R, NC-17), positioning Netflix as a mature-content platform rather than a family-first service
- **International Movies and Dramas are the most prevalent genres** — reflecting a strategy of acquiring broad, globally accessible content to serve diverse international subscriber bases
- **The United States leads content production by a significant margin** — but India, the United Kingdom, and Japan are substantial contributors, highlighting Netflix's active localization strategy in key markets
- **Director talent pools are largely siloed by content type** — very few directors on the platform have directed both Movies and TV Shows, suggesting Netflix's Movie and TV production pipelines operate largely independently

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
4. Click Refresh — all visuals will populate

---

## 👤 Author

**Harsh Menon**
Aspiring Data Analyst — Excel · SQL · Power BI

[![GitHub](https://img.shields.io/badge/GitHub-HarshMenon78-181717?style=flat&logo=github)](https://github.com/HarshMenon78)