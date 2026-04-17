##### Legend / Commenting Structure #####

#### – Interesting findings / unexpected observations
### – Project name or main title
##  – Major step or milestone (e.g., Data Cleaning, Data Analysis)
#   – Minor step or specific task (e.g., Filtering data, Calculating averages)
--   – Inline comments, explanations, or temporarily disabled code


### Poland Labor Market & Population Analysis (2008–2024)


## Data Cleaning and Preparation

# Table 1 mp2008_2024

-- Rename columns for consistency and readability
ALTER TABLE mp2008_2024
CHANGE COLUMN `Nazwa` region VARCHAR(50),
CHANGE COLUMN `Miejsca pracy` jobs VARCHAR(50),
CHANGE COLUMN `Rok` year INT,
CHANGE COLUMN `Wartosc` value VARCHAR(20),
CHANGE COLUMN `Jednostka miary` unit_of_measurement VARCHAR(50);

-- Replace comma with dot for numeric conversion
UPDATE mp2008_2024
SET value = REPLACE(value, ',', '.');

-- Add numeric column for calculations
ALTER TABLE mp2008_2024
ADD COLUMN value_num DECIMAL (10,1);

-- Convert value to numeric format
UPDATE mp2008_2024
SET value_num = CAST(value AS DECIMAL(10,1));

-- Remove original text column
ALTER TABLE mp2008_2024
DROP COLUMN value;

-- Reorder column for better structure
ALTER TABLE mp2008_2024
MODIFY COLUMN value_num DECIMAL(10,1) 
AFTER year;

-- Standardize unit of measurement to base unit (jobs instead of thousands)
UPDATE mp2008_2024
SET unit_of_measurement = CASE 
	WHEN unit_of_measurement = 'thousands_of_jobs' THEN 'jobs'
END;

-- Convert values from thousands to absolute numbers
UPDATE mp2008_2024
SET value_num = CASE 
	WHEN unit_of_measurement = 'thousands_of_jobs' THEN value_num * 1000
END;

-- Aggregate job data into created and closed jobs per region and year
SELECT
    region,
    year,
    SUM(CASE 
        WHEN jobs = 'nowo utworzone miejsca pracy' 
        THEN value_num ELSE 0
    END) AS created_jobs,
    SUM(CASE 
        WHEN jobs = 'zlikwidowane miejsca pracy' 
        THEN value_num ELSE 0
    END) AS closed_jobs
FROM mp2008_2024
GROUP BY region, year
ORDER BY region, year;


# Table 2 lud_woj2008_2024

-- Rename columns for consistency and readability
ALTER TABLE lud_woj2008_2024
CHANGE COLUMN `Nazwa` region VARCHAR(50),
CHANGE COLUMN `WskaĹşniki` indicator VARCHAR(100),
CHANGE COLUMN `Rok` year INT,
CHANGE COLUMN `Wartosc` value VARCHAR(20),
CHANGE COLUMN `Jednostka miary` unit_of_measurement VARCHAR(50);

-- Standardization of unit_of_measurement
UPDATE lud_woj2008_2024
SET unit_of_measurement = CASE
	WHEN unit_of_measurement like 'osoba' THEN 'person'
    WHEN unit_of_measurement like 'tys. osĂłb' THEN 'thousand_persons'
    WHEN unit_of_measurement like '%' THEN 'percent'
END;

-- Add numeric column for further calculations
ALTER TABLE lud_woj2008_2024
ADD COLUMN value_num DECIMAL(15,5);

-- Convert value column to numeric format based on unit of measurement
UPDATE lud_woj2008_2024
SET value_num = CASE 
	WHEN unit_of_measurement = 'person' AND value <> '' THEN CAST(REPLACE(Value, ',', '.') AS DECIMAL(15,5))
    WHEN unit_of_measurement = 'thousand_persons' AND value <> '' THEN CAST(REPLACE(Value, ',','.') AS DECIMAL(15,5)) * 1000
    WHEN unit_of_measurement = 'percent' AND value <> '' THEN CAST(REPLACE(Value, ',', '.') AS DECIMAL(15,5)) / 100
    ELSE NULL
END;
    
-- Drop Value column
ALTER TABLE lud_woj2008_2024
DROP COLUMN value;

-- Standardization of indicator names
UPDATE lud_woj2008_2024
SET indicator = CASE 
	WHEN indicator like 'ludnoĹ›Ä‡ na 1 km2' THEN 'population_density_per_km2'
    WHEN indicator like 'gÄ™stoĹ›Ä‡ zaludnienia powierzchni zabudowanej i zurbanizowanej (osoby/km2)' THEN 'urban_population_density_per_km2'
    WHEN indicator like 'zmiana liczby ludnoĹ›ci na 1000 mieszkaĹ„cĂłw' THEN 'population_change_per_1000'
    WHEN indicator like 'ludnoĹ›Ä‡ w tysiÄ…cach' THEN 'population_thousands'
    WHEN indicator like 'ludnoĹ›Ä‡ w tysiÄ…cach mÄ™ĹĽczyĹşni' THEN 'male_population_thousands'
    WHEN indicator like 'ludnoĹ›Ä‡ w tysiÄ…cach kobiety' THEN 'female_population_thousands'
    WHEN indicator like 'wskaĹşnik urbanizacji' THEN 'urbanization_rate'
    ELSE NULL
END;

-- Reorder column for better table structure
ALTER TABLE lud_woj2008_2024
MODIFY COLUMN value_num DECIMAL(15,5) 
AFTER year;

-- Pivot population indicators from long format to wide format 
-- Convert population from absolute values to thousands for readability and consistency with indicator naming
SELECT 
	region,
	year,
	SUM(CASE 
		WHEN indicator = 'population_density_per_km2' THEN ROUND(value_num, 1) ELSE 0
        END) AS population_density_per_km2,
	SUM(CASE
		WHEN indicator = 'urban_population_density_per_km2' THEN ROUND(value_num, 1) ELSE 0
		END) AS urban_population_density_per_km2,
	SUM(CASE
		WHEN indicator = 'population_change_per_1000' THEN ROUND(value_num, 1) ELSE 0
		END) AS population_change_per_1000,
	SUM(CASE
		WHEN indicator = 'population_thousands' THEN ROUND(value_num/1000, 2) ELSE 0
		END) AS population_thousands,
	SUM(CASE
		WHEN indicator = 'male_population_thousands' THEN ROUND(value_num/1000, 2) ELSE 0
		END) AS male_population_thousands,
	SUM(CASE
		WHEN indicator = 'female_population_thousands' THEN ROUND(value_num/1000, 2) ELSE 0
		END) AS female_population_thousands,
	SUM(CASE
		WHEN indicator = 'urbanization_rate' THEN ROUND(value_num, 4) ELSE 0
		END) AS urbanization_rate_pct	
FROM lud_woj2008_2024
GROUP BY region, year;


## Data Analysis

-- Debug query (optional) to preview joined dataset before creating view
SELECT 
	a.region, 
    a.year, 
	SUM(CASE 
		WHEN a.indicator = 'population_density_per_km2' THEN ROUND(a.value_num, 1) ELSE 0
        END) AS population_density_per_km2,
	SUM(CASE
		WHEN a.indicator = 'urban_population_density_per_km2' THEN ROUND(a.value_num, 1) ELSE 0
		END) AS urban_population_density_per_km2,
	SUM(CASE
		WHEN a.indicator = 'population_change_per_1000' THEN ROUND(a.value_num, 1) ELSE 0
		END) AS population_change_per_1000,
	SUM(CASE
		WHEN a.indicator = 'population_thousands' THEN ROUND(a.value_num/1000, 2) ELSE 0
		END) AS population_thousands,
	SUM(CASE
		WHEN a.indicator = 'male_population_thousands' THEN ROUND(a.value_num/1000, 2) ELSE 0
		END) AS male_population_thousands,
	SUM(CASE
		WHEN a.indicator = 'female_population_thousands' THEN ROUND(a.value_num/1000, 2) ELSE 0
		END) AS female_population_thousands,
	SUM(CASE
		WHEN a.indicator = 'urbanization_rate' THEN ROUND(a.value_num, 4) ELSE 0
		END) AS urbanization_rate_pct,
	SUM(CASE 
        WHEN b.jobs = 'nowo utworzone miejsca pracy' THEN b.value_num ELSE 0
		END) AS created_jobs,
    SUM(CASE 
        WHEN b.jobs = 'zlikwidowane miejsca pracy' THEN b.value_num ELSE 0
		END) AS closed_jobs
FROM lud_woj2008_2024 AS a
JOIN mp2008_2024 AS b
	ON a.region = b.region AND a.year = b.year
GROUP BY a.region, a.year
ORDER BY a.region, a.year
;

# Creating aggregated dataset by joining population and jobs tables
CREATE OR REPLACE VIEW v_population_jobs AS 
SELECT 
	a.region, 
    a.year,
	SUM(CASE 
		WHEN a.indicator = 'population_density_per_km2' THEN ROUND(a.value_num, 1) ELSE 0
        END) AS population_density_per_km2,
	SUM(CASE
		WHEN a.indicator = 'urban_population_density_per_km2' THEN ROUND(a.value_num, 1) ELSE 0
		END) AS urban_population_density_per_km2,
	SUM(CASE
		WHEN a.indicator = 'population_change_per_1000' THEN ROUND(a.value_num, 1) ELSE 0
		END) AS population_change_per_1000,
	SUM(CASE
		WHEN a.indicator = 'population_thousands' THEN ROUND(a.value_num/1000, 2) ELSE 0
		END) AS population_thousands,
	SUM(CASE
		WHEN a.indicator = 'male_population_thousands' THEN ROUND(a.value_num/1000, 2) ELSE 0
		END) AS male_population_thousands,
	SUM(CASE
		WHEN a.indicator = 'female_population_thousands' THEN ROUND(a.value_num/1000, 2) ELSE 0
		END) AS female_population_thousands,
	SUM(CASE
		WHEN a.indicator = 'urbanization_rate' THEN ROUND(a.value_num, 4) ELSE 0
		END) AS urbanization_rate_pct,
	SUM(CASE 
        WHEN b.jobs = 'nowo utworzone miejsca pracy' THEN b.value_num ELSE 0
		END) AS created_jobs,
    SUM(CASE 
        WHEN b.jobs = 'zlikwidowane miejsca pracy' THEN b.value_num ELSE 0
		END) AS closed_jobs
FROM lud_woj2008_2024 AS a
JOIN mp2008_2024 AS b
	ON a.region = b.region AND a.year = b.year
GROUP BY a.region, a.year
;

-- Calculating net_jobs
SELECT *,
	(created_jobs - closed_jobs) AS net_jobs
FROM v_population_jobs;

# Create final analytical view with benchmarking against Poland
-- Aggregated dataset combining population indicators and job market data at region-year level
CREATE OR REPLACE VIEW v_population_jobs_final AS
SELECT a.*,
    (a.created_jobs - a.closed_jobs) AS net_jobs,
    ROUND(((a.created_jobs - a.closed_jobs) / NULLIF((p.created_jobs - p.closed_jobs), 0)) * 100, 2) AS net_jobs_share_pct,
    ROUND(((a.closed_jobs / NULLIF(p.closed_jobs, 0)) * 100), 2) AS closed_jobs_share_pct,
    ROUND(((a.created_jobs / NULLIF(p.created_jobs, 0)) * 100), 2) AS created_jobs_share_pct,
    ROUND(((a.created_jobs - a.closed_jobs) / NULLIF(a.population_thousands, 0)), 1) AS net_jobs_per_1k_population
FROM v_population_jobs AS a
JOIN v_population_jobs AS p
	ON a.year = p.year
    AND p.region = 'POLSKA' -- Join with Poland aggregate data for benchmark comparison
WHERE a.region <> 'POLSKA'
GROUP BY a.region, a.year
;

-- Final querry
SELECT *
FROM v_population_jobs_final
ORDER BY region, year;




