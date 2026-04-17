#  Regional Labor Market Analysis in Poland (2008–2024)

##  Project Overview
This project analyzes job creation and closure trends across Polish regions between 2008 and 2024.  
The goal is to identify regional differences, long-term trends, and top-performing vs underperforming areas.

The analysis combines SQL data preparation with interactive dashboards built in Tableau.

---

##  Key Questions
- How has job creation evolved over time?
- Which regions perform best and worst?
- Are there noticeable geographic patterns?
- How do trends change year by year?

---

## ️ Tools Used
- SQL (data cleaning & transformation)
- Tableau (data visualization & dashboards)

---

##  Dashboards

### 1. Overall Trends
![Dashboard 1](tableau_viz/dashboard_screens/overall_viz_1.png)

Shows overall job creation trends over time, including key drops (e.g., 2008–2009, 2020).

---

### 2. Regional Differences
![Dashboard 2](tableau_viz/dashboard_screens/regions_differ_viz_2.png)

Map + ranking showing how regions differ in job creation per 1,000 people for a selected year.

---

### 3. Top & Bottom Regions
![Dashboard 3](tableau_viz/dashboard_screens/outperform_viz_3.png)

Highlights the top 5 and bottom 5 regions for a selected year.

---

##  Key Insights
- Significant drops in job creation are visible during the 2008–2009 financial crisis and in 2020.
- Regional disparities are consistent, with some regions outperforming others across multiple years.
- The ranking highlights stable top performers and consistently weaker regions.

---

##  Project Structure

	project/
	├── sql/
	│   ├── population_jobs_GUS
	│
	├── tableau_viz/
	│   └── dashboard_screens/
	│       ├── overall_viz_1
	│       ├── regions_differ_viz_2
	│       ├── outperform_viz_3
	│
	├── README.md
	
---

##  Links
- Tableau Public: https://public.tableau.com/views/PolandLaborMarketPopulationDashboard20082024/HowHasthePolishLaborMarketEvolvedAcrossRegions20082024?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link
- GitHub Repository: (this repo)

---

##  Notes
- Net job creation is calculated as the difference between jobs created and closed, per 1,000 people.
- Urbanization data is available from 2010 onwards.