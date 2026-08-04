# 🇵🇱 Polish Labor Market & Demographics Pipeline (GUS Data 2008–2024)

**Author:** Damian Sobolewski  
**Tools:** MySQL Workbench, Advanced SQL (Views, Dynamic Aggregations, Benchmarking)  
**Domain:** Macroeconomics, Public Sector Analytics, Regional Development  

---

## 📌 Executive Summary
This project analyzes **16 years of Polish demographic and labor market fluctuations (2008–2024)** sourced directly from the Central Statistical Office of Poland (GUS). 

It builds an end-to-end relational data pipeline that cleans, standardizes, and joins raw demographic metrics (population density, urbanization rates) with transactional job creation and destruction data. The final output generates **macroeconomic KPIs** and benchmarks regional voivodeships against national averages (`POLSKA`).

---

## 🛠️ Data Pipeline & SQL Architecture

1. **ETL & Data Standardization:**
   - Cleansed Polish regional encoding issues, cast string inputs into strict `DECIMAL` types, and standardized mixed units of measurement (absolute counts vs. thousands vs. percentages).
2. **Matrix Pivoting (Conditional Aggregation):**
   - Transformed long-format demographic tables into structured wide-format analytical entities using optimized `SUM(CASE WHEN...)` pivoting logic.
3. **Analytical View Engineering (`SQL Views`):**
   - Engineered modular SQL Views (`v_population_jobs` and `v_population_jobs_final`) to abstract complex joins, aggregations, and business logic from end queries.
4. **Macroeconomic Benchmarking & Per-Capita Scaling:**
   - Joined regional trends against country-wide baselines (`POLSKA`) to dynamically calculate market shares and net job creation per 1,000 residents (`net_jobs_per_1k_population`).

---

## 📊 Interactive Tableau Dashboards & Storytelling

### 1. Macroeconomic Labor Market Evolution (2008–2024)
*Tracking national job creation, job destruction, and macro-shocks over 16 years:*

![Macro Overview](/Tableau_viz/overall_viz_1.png)

- **Macro Trend:** Net job creation peaked at **3.01M in 2017**, followed by significant contraction during the COVID-19 pandemic (down to **987K in 2020**).
- **KPI Summary:** Cumulative job creation reached **67.04M**, with **37.92M** jobs closed, yielding a net positive growth of **29.12M positions**.

---

### 2. Regional Job Density & Performance Ranking
*Analyzing spatial job creation and regional efficiency scaled per 1,000 residents:*

![Regional Distribution](/Tableau_viz/regions_differ_viz_2.png)

- **Economic Dominance:** **Mazowieckie** leads nationally with **55.20 net jobs per 1k residents**, heavily outperforming regional benchmarks.
- **Regional Disparity:** Clear divide between industrial/metropolitan centers and peripheral eastern voivodeships (e.g., Śląskie at **39.70** vs. Świętokrzyskie at **10.20**).

---

### 3. Outperformers vs. Underperformers Benchmark
*Isolating Top 5 and Bottom 5 voivodeships against the national average:*

![Outperformers Benchmark](/Tableau_viz/outperform_viz_3.png)

- **Top 5 Engine:** Mazowieckie, Wielkopolskie, Śląskie, Dolnośląskie, and Małopolskie consistently drive national employment expansion.
- **Lagging Regions:** Świętokrzyskie, Lubelskie, and Podkarpackie require targeted economic intervention, falling significantly below the national average benchmark.

---

## 💡 Key Analytical Takeaways

- **Regional Job Polarization:** Economic job creation is heavily concentrated in major metropolitan hubs, while peripheral voivodeships experience disproportionate rates of job destruction relative to population size.
- **Demographic Pressure:** A strong correlation exists between declining population density in rural zones and negative net job generation, accelerating urbanization trends.
- **Risk Mitigation via Per-Capita Scaling:** Measuring absolute job numbers distorts regional performance; evaluating **Net Jobs per 1,000 Residents** isolates actual economic efficiency across small vs. large regions.

---

## 💻 Featured SQL Code Snippet

### Analytical View Engine with National Benchmarking
*Demonstrating Self-Joins against national baselines ('POLSKA') and dynamic metric derivation:*

```sql
CREATE OR REPLACE VIEW v_population_jobs_final AS
SELECT 
    a.*,
    (a.created_jobs - a.closed_jobs) AS net_jobs,
    ROUND(((a.created_jobs - a.closed_jobs) / NULLIF((p.created_jobs - p.closed_jobs), 0)) * 100, 2) AS net_jobs_share_pct,
    ROUND(((a.closed_jobs / NULLIF(p.closed_jobs, 0)) * 100), 2) AS closed_jobs_share_pct,
    ROUND(((a.created_jobs / NULLIF(p.created_jobs, 0)) * 100), 2) AS created_jobs_share_pct,
    ROUND(((a.created_jobs - a.closed_jobs) / NULLIF(a.population_thousands, 0)), 1) AS net_jobs_per_1k_population
FROM v_population_jobs AS a
JOIN v_population_jobs AS p
    ON a.year = p.year
    AND p.region = 'POLSKA' -- Join with national baseline for benchmarking
WHERE a.region <> 'POLSKA'
GROUP BY a.region, a.year;

---

## 📬 Contact
- **Author:** Damian Sobolewski
- **LinkedIn:** [Damian Sobolewski Profile](https://www.linkedin.com/in/damian-sobolewski-43257a260/)
- **Tableau Public:** [Damian Sobolewski Profile](https://public.tableau.com/app/profile/damian3277/vizzes)
