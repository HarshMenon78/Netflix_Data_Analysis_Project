# 🎬 Netflix Content Analysis — End-to-End Data Analysis Project

![Excel](https://img.shields.io/badge/Microsoft%20Excel-Data%20Cleaning-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-SQL%20Analysis-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=power-bi&logoColor=white)
![VS Code](https://img.shields.io/badge/VS%20Code-Query%20Execution%20%26%20GitHub%20Integration-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![DBeaver](https://img.shields.io/badge/DBeaver-Data%20Viewer-382923?style=for-the-badge&logo=dbeaver&logoColor=white)
![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-SQL%20Comments%20Documentation-000000?style=for-the-badge&logo=github&logoColor=white)
![Claude AI](https://img.shields.io/badge/Claude%20AI-Code%20Review%20%26%20Documentation-CC785C?style=for-the-badge&logo=claude&logoColor=white)

An end-to-end data analysis project analyzing Netflix's content catalog using **Microsoft Excel**, **PostgreSQL**, and **Power BI**. The project follows a real-world analyst workflow — raw data ingestion, cleaning, SQL-based analysis, and interactive dashboard reporting — addressing 15 business problems across content distribution, growth trends, genre patterns, director insights, geographic reach, and audience classification.

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
| **Microsoft Excel 2019** | Data ingestion, cleaning, Removing duplicates, blank handling, exploratory pivot tables |
| **PostgreSQL via pgAdmin 4** | Database creation, table schema setup, data reviewing after manipulating |
| **VS Code** | Importing cleaned data into database created in PostgreSQL, Writing and executing SQL analysis scripts, GitHub integration for local and remote repository management, README authoring and change tracking |
| **DBeaver** | Viewing table rows and data contents without the need for querying, used to save time during data validation and exploration |
| **Power BI Desktop** | Result-set import via Power Query, DAX measures, interactive 4-page dashboard |
| **GitHub Copilot** | Automation of pre-written SQL query's inline comments beside each query lines (mentioned in "--") which repeat across all scripts in `Scripts/`(explaining the role of all the individual lines of SQL code/query) |
| **Claude AI** | AI-assisted code review, project-documentation assistance, and project planning assistance to resolve bottlenecks on the independent plan — **All the major planning & queries have been scripted independently(i.e without using these above mentioned AI tools) for practicing and sharpening the tool based knowledge & skills** |

---

## 🔄 Project Workflow

### Stage 1 — Data Cleaning (Microsoft Excel)

The raw CSV was imported into Excel using **Data → Get & Transform → From Text/CSV** with UTF-8 encoding to preserve special characters. All cleaning was performed on a working copy, keeping the original raw sheet untouched.

**Key cleaning steps performed:**

- **Removed duplicates** using `show_id` as the unique identifier via Data → Remove Duplicates
- **Handled blank values** — columns with few missing rows (`release_year`, `duration`) were filled manually by cross-referencing the internet; high-volume blank columns (`director`, `cast`, `country`, `listed_in`) were bulk-filled using Filter → Blanks → Ctrl+Enter
- **Fixed date formatting** — used `=--TRIM(cell)` to strip leading/trailing spaces from `date_added` while preserving the underlying date serial number, then reformatted to a consistent date display format
- **Corrected misplaced values** — duration values found in the `rating` column were moved to `duration`; affected rating cells set to `Unknown`
- **Standardized ratings** — `NR` and `UR` replaced with `Not Rated` via Find & Replace with Match Entire Cell Contents enabled
- **Handled corrupted row** — row 8423 had all fields shifted due to an unescaped comma in the source CSV; fields were manually corrected; unrecoverable `show_id` assigned placeholder `s9999`
- **DATE and INT columns** — left as empty cells so PostgreSQL imports them as proper `NULL` values without type errors
- **Exploratory pivot tables** — built in a dedicated sheet covering content type split, top countries, genre frequency, and rating breakdown

**Output:** `netflix_clean_data.csv` exported as UTF-8 CSV for SQL import

---

### Stage 2 — SQL Analysis (PostgreSQL / VS Code / pgAdmin 4)

The cleaned CSV was imported into a PostgreSQL database (`netflix_db`). A dedicated setup script handles table schema creation and data import. Six analysis scripts each address a specific analytical theme, producing result-sets exported as CSVs for Power BI.

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

⚠️ Update the file path in the FROM command to your local path(of the cleaned data which needs to be imported to the empty database we just created in our PostgreSQL server) before running.

---

### Stage 3 — Dashboard (Power BI)

All 16 result-set CSVs were imported into Power BI via Power Query. Data types were verified and column names standardized before loading. DAX measures were written in a dedicated `_Measures` table. The dashboard covers a home navigation page and 4 analytical pages.

---

## 🔍 Business Problems Solved

### 📌 01 — Content Distribution &nbsp;&nbsp;`1_content_distribution.sql`

| # | Problem Statement | Approach |
|---|---|---|
| 1 | What is the overall split between Movies and TV Shows, and what percentage does each hold? | Grouped by `type`, counted rows, calculated percentage using window-level `SUM() OVER()` |
| 2 | What is the rating-wise breakdown of all content and what percentage does each rating hold? | Grouped by `rating`, counted rows per rating, derived percentage via window sum |

### 📌 02 — Growth Trends &nbsp;&nbsp;`2_growth_trends.sql`

| # | Problem Statement | Approach |
|---|---|---|
| 3 | How has Netflix's content count grown year over year, and what is the YoY growth %? | Extracted year from `date_added`, used two chained CTEs with `LAG()` to compare each year against the previous |
| 4 | What did Netflix's cumulative library size look like at any point in time? | Used `SUM() OVER()` with `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` on top of yearly counts CTE |
| — | *(Bonus)* How does yearly content addition differ between Movies and TV Shows? | Conditional aggregation — `SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END)` to pivot content types into columns |

### 📌 03 — Genre Analysis &nbsp;&nbsp;`3_genre_analysis.sql`

| # | Problem Statement | Approach |
|---|---|---|
| 5 | What are the most common individual genres when the multi-genre column is properly split? | Used `UNNEST(STRING_TO_ARRAY(listed_in, ','))` to explode comma-separated genres into individual rows, then grouped and counted |
| 6 | Which genre dominated Netflix's catalog for each year? | Three-CTE chain — explode genres, count by year and genre, then `DENSE_RANK() OVER(PARTITION BY year)` to find rank 1 per year |

### 📌 04 — Director Analysis &nbsp;&nbsp;`4_director_analysis.sql`

| # | Problem Statement | Approach |
|---|---|---|
| 7 | Who are the top 10 most frequent directors on Netflix? | Grouped by `director`, filtered out Unknown, ordered by count descending with `LIMIT 10` |
| 8 | Who are the top 5 directors separately for Movies and TV Shows? | Two CTEs — first counts by director and type, second applies `DENSE_RANK() OVER(PARTITION BY type)`, filtered to `rnk <= 5` |
| 9 | Which directors have worked across both Movies and TV Shows? | Grouped by `director`, used `HAVING COUNT(DISTINCT type) = 2` to keep only cross-format directors, `STRING_AGG` to display both types |

### 📌 05 — Country Analysis &nbsp;&nbsp;`5_country_analysis.sql`

| # | Problem Statement | Approach |
|---|---|---|
| 10 | Which are the top 15 content producing countries? | Used `UNNEST(STRING_TO_ARRAY(country, ','))` to handle multi-country rows, grouped and counted individual countries |
| 11 | Which countries produce above average content volume? | Computed per-country counts, used `AVG() OVER()` as a window function to compare each country against the overall average |
| 12 | What is the Movies vs TV Shows breakdown per top producing country? | Three-CTE chain — expand countries with UNNEST carrying `type`, conditional aggregation for movie/tv counts, window AVG for above-average status filter |

### 📌 06 — Ratings & Audience &nbsp;&nbsp;`6_rating_distribution.sql`

| # | Problem Statement | Approach |
|---|---|---|
| 13 | What is the overall rating distribution and percentage per rating? | Grouped by `rating`, counted rows, derived percentage via `SUM(COUNT(*)) OVER()` |
| 14 | How is content distributed across audience categories and what % does each hold? | Used `CASE WHEN` to classify 14 ratings into 5 audience bands inside a CTE, then grouped and counted in the outer query |
| 15 | For each audience category, what is the Movies vs TV Shows breakdown? | Extended Problem 14's CTE with conditional aggregation — `SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END)` alongside the audience classification |

---

## 📈 Power BI Dashboard

### 🏠 Home Page — Navigation Hub
![Home Page](Dashboard/Dashboard_Images/Netflix%20Dashboard%20Home%20Page.png)

---

### 📊 Page 1 — Content Distribution
*Covers Problems 1, 2, 13, 14, 15 &nbsp;|&nbsp; From: [`1_content_distribution.sql`](Scripts/1_content_distribution.sql) & [`6_rating_distribution.sql`](Scripts/6_rating_distribution.sql)*

![Content Distribution](Dashboard/Dashboard_Images/Page%201%20(Content%20Distribution).png)

---

### 📈 Page 2 — Growth Trends
*Covers Problems 3, 4 and Bonus query &nbsp;|&nbsp; From: [`2_growth_trends.sql`](Scripts/2_growth_trends.sql)*

![Growth Trends](Dashboard/Dashboard_Images/Page%202%20(Growth%20Trends).png)

---

### 🎬 Page 3 — Content & Creators
*Covers Problems 5, 6, 7, 8, 9 &nbsp;|&nbsp; From: [`3_genre_analysis.sql`](Scripts/3_genre_analysis.sql) & [`4_director_analysis.sql`](Scripts/4_director_analysis.sql)*

![Content and Creators](Dashboard/Dashboard_Images/Page%203%20(Content%20%26%20Creators).png)

---

### 🌍 Page 4 — Geographic Reach
*Covers Problems 10, 11, 12 &nbsp;|&nbsp; From: [`5_country_analysis.sql`](Scripts/5_country_analysis.sql)*

![Geographic Reach](Dashboard/Dashboard_Images/Page%204%20(Geographic%20Reach).png)

---

## 💡 Key Business Insights

- **Netflix is predominantly a Movie platform** — 69.62% of its catalog consists of Movies, yet TV Show additions have grown at a faster rate since 2016, signaling a gradual strategic shift toward serialized content
- **Content growth was explosive between 2015 and 2019** — Netflix's library scaled from under 500 titles to over 5,000 in just four years; growth has visibly slowed post-2019
- **Adult content dominates the catalog** — 45.52% of all content falls under the Adult audience category, positioning Netflix as a mature-content platform rather than a family-first service
- **International Movies and Dramas are the most prevalent genres** — reflecting Netflix's strategy of acquiring broad, globally accessible content for diverse international subscriber bases
- **The United States leads content production by a significant margin** — but India, the United Kingdom, and Japan are substantial contributors, highlighting Netflix's active localization strategy
- **Director talent pools are largely siloed by content type** — very few directors have directed both Movies and TV Shows on the platform, suggesting Netflix's Movie and TV production pipelines operate largely independently

---

## ▶️ How to Reproduce

**Step 1 — Excel Cleaning**
1. Open `data/Raw data/netflix_titles_raw_data.csv` in Excel via Data → Get & Transform → From Text/CSV (UTF-8 encoding)
2. Apply the cleaning steps documented in Stage 1 above
3. Export the cleaned sheet as `netflix_clean_data.csv` into `data/Cleaned data/csv/`

**Step 2 — PostgreSQL Setup & Analysis**
1. Install PostgreSQL and open pgAdmin 4
2. Create a new database named `netflix_db`
3. Open `Scripts/0_db_&_table_creation_and_setup.sql` in VS Code — update the file path in the COPY command to your local path — then execute
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
— Aspiring Data Analyst — Excel · SQL · Power BI

[![GitHub](https://img.shields.io/badge/GitHub-HarshMenon78-181717?style=flat&logo=github)](https://github.com/HarshMenon78)
