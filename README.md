
# Multi-Channel Marketing Attribution & CAC Analysis

## 📌 Project Overview

Marketing teams invest across multiple acquisition channels such as Paid Search, Paid Social, Display, Email, Organic Search, Referral, and Direct.

However, relying only on **Last-Touch Attribution** can over-credit channels that appear closest to conversion while undervaluing channels that contributed earlier in the customer journey.

This project analyzes multi-channel customer journeys to answer:

> **Which marketing channels contribute to customer conversions and revenue, how does attribution methodology change channel performance, and how should a ₹10 lakh marketing budget be allocated?**

The project combines:

- **Python / Jupyter Notebook** → Data exploration, validation, attribution modeling, benchmark validation
- **MySQL** → Data storage, SQL analysis, business queries, attribution analysis
- **Excel** → Marketing performance analysis, CAC/ROAS analysis, attribution comparison, ₹10 lakh budget allocation model
- **Power BI** → Interactive executive dashboard and customer-level drillthrough
- **GitHub** → Project documentation and portfolio presentation

---

# 🎯 Business Problem

A company is spending money across multiple marketing channels but primarily evaluates performance using simple attribution approaches.

Management wants to understand:

1. Which channels generate the most customers?
2. Which channels generate the most revenue?
3. How does attribution methodology change channel performance?
4. Which channels are efficient based on CAC and ROAS?
5. How does customer journey length relate to conversion?
6. Should marketing decisions rely on Last-Touch Attribution?
7. How should a **₹10 lakh marketing budget** be allocated?
8. Can different attribution models be validated against a controlled benchmark?

The objective is to move from simple channel reporting toward a more **data-driven marketing allocation strategy**.

---

# 🧠 Key Business Questions

The project answers the following questions:

### Customer Journey

- How many customers are present in the dataset?
- What percentage of users convert?
- How many marketing touchpoints does a customer typically experience?
- Does journey length influence conversion?

### Channel Performance

- Which channels generate the most revenue?
- Which channels receive the most marketing spend?
- Which paid channels have the best CAC?
- Which paid channels have the best ROAS?

### Attribution

- How does First-Touch attribution differ from Last-Touch?
- How does Linear attribution distribute credit?
- How does Time-Decay attribution distribute credit?
- How does Position-Based attribution distribute credit?
- Which attribution model performs best against the controlled benchmark?

### Budget Allocation

- How should ₹10 lakh be allocated across paid channels?
- What revenue and conversion outcome is expected?
- What is the expected revenue uplift compared with the current performance?

---

# 📊 Dataset

The project uses a **controlled synthetic marketing dataset** designed to simulate multi-channel customer journeys.

The dataset contains two primary analytical tables.

## 1. `touchpoints.csv`

Contains individual customer marketing interactions.

### Size

- **47,584 touchpoints**
- **20,000 unique customer journeys**

### Columns

| Column | Description |
|---|---|
| `user_id` | Unique customer identifier |
| `touch_order` | Position of the touchpoint within the customer journey |
| `journey_length` | Total number of touchpoints in the journey |
| `channel` | Marketing channel associated with the touchpoint |
| `timestamp` | Timestamp of the interaction |
| `cost` | Marketing cost associated with the touchpoint |
| `converted` | Conversion indicator |
| `revenue` | Revenue associated with the converted journey |

---

## 2. `users_summary.csv`

Contains customer-level summary information.

### Size

- **20,000 customers**

### Columns

| Column | Description |
|---|---|
| `user_id` | Unique customer identifier |
| `journey_length` | Number of touchpoints in the customer journey |
| `converted` | Conversion indicator |
| `revenue` | Customer revenue |

---

# 📈 Dataset Summary

| KPI | Value |
|---|---:|
| Total Customers | 20,000 |
| Converted Customers | 3,514 |
| Conversion Rate | 17.57% |
| Total Revenue | ₹11,354,450.64 |
| Total Marketing Spend | ₹325,386.41 |
| Average Journey Length | 3.02 touchpoints |
| Maximum Journey Length | 5 touchpoints |

---

# 📢 Marketing Channels

The dataset contains seven marketing channels:

- Paid Search
- Paid Social
- Display
- Organic Search
- Email
- Direct
- Referral

### Paid Channels

The paid marketing channels are:

- **Paid Search**
- **Paid Social**
- **Display**

These channels are the primary focus for CAC, ROAS, and budget allocation decisions.

---

# 💰 Marketing Spend

| Paid Channel | Marketing Spend |
|---|---:|
| Paid Search | ₹231,677.45 |
| Paid Social | ₹72,535.83 |
| Display | ₹21,173.13 |
| **Total** | **₹325,386.41** |

The remaining channels have zero direct marketing spend in the dataset.

Therefore, CAC and ROAS are primarily evaluated for the paid channels.

---

# 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Python | Data analysis and attribution modeling |
| Jupyter Notebook | Analytical workflow |
| Pandas | Data manipulation |
| NumPy | Numerical analysis |
| Matplotlib | Visualization |
| Seaborn | Exploratory visualization |
| MySQL | Data storage and SQL analysis |
| MySQL Workbench | SQL development |
| Excel | Business modeling and budget allocation |
| Power BI | Interactive dashboard |
| DAX | Power BI measures and calculations |
| Git / GitHub | Version control and portfolio |

---

# 🔄 Project Workflow

```text
Raw Marketing Data
        │
        ▼
Python / Jupyter
        │
        ├── Data Validation
        ├── EDA
        ├── Customer Journey Analysis
        ├── Attribution Modeling
        └── Benchmark Validation
        │
        ▼
MySQL
        │
        ├── Data Storage
        ├── Data Quality Checks
        ├── Channel Analysis
        ├── CAC / ROAS
        └── Attribution Queries
        │
        ▼
Excel
        │
        ├── Channel Performance
        ├── Attribution Comparison
        ├── CAC / ROAS
        ├── ₹10 Lakh Budget Model
        └── Sensitivity Analysis
        │
        ▼
Power BI
        │
        ├── Executive Overview
        ├── Attribution Analysis
        ├── CAC & ROAS Analysis
        ├── Budget Allocation
        └── Customer Drillthrough
        │
        ▼
Business Recommendations
````

---

# 🐍 Python / Jupyter Analysis

Python was used as the primary analytical environment for understanding and validating the marketing dataset.

## Data Validation

The following checks were performed:

* Dataset dimensions
* Column validation
* Missing values
* Duplicate records
* Unique customers
* Channel validation
* Conversion validation
* Revenue validation
* Cost validation
* Customer-level consistency

### Data Quality Result

The datasets contained:

* No missing values
* No duplicate rows
* Consistent customer IDs
* Expected marketing channels
* Valid conversion indicators

---

# 👥 Customer Journey Analysis

Customer journeys were analyzed based on the number of marketing touchpoints.

Journey lengths range from:

* 1 touchpoint
* 2 touchpoints
* 3 touchpoints
* 4 touchpoints
* 5 touchpoints

Observed conversion rates increase with journey length.

| Journey Length | Conversion Rate |
| -------------: | --------------: |
|              1 |           7.99% |
|              2 |          15.14% |
|              3 |          21.72% |
|              4 |          28.07% |
|              5 |          36.81% |

### Business Interpretation

Customers with more interactions in the simulated journey show higher conversion rates.

This indicates that evaluating only the final interaction may not provide a complete picture of the customer journey.

However, this relationship should **not be interpreted as causal evidence**, because the dataset is synthetic and observational.

---

# 🎯 Attribution Modeling

Five attribution models were implemented.

## 1. First-Touch Attribution

100% of the conversion/revenue credit is assigned to the customer's first marketing interaction.

### Strength

Useful for understanding:

> Which channel initially introduced the customer?

### Limitation

It can undervalue channels that influence customers later in the journey.

---

# 2. Last-Touch Attribution

100% of the conversion/revenue credit is assigned to the customer's final marketing interaction.

### Strength

Simple and easy to interpret.

### Limitation

It can heavily favor channels close to conversion while ignoring earlier interactions.

---

# 3. Linear Attribution

Credit is distributed equally across all touchpoints in the customer journey.

For example:

```text
3 Touchpoints

Channel A → 33.3%
Channel B → 33.3%
Channel C → 33.3%
```

### Strength

Provides a balanced multi-touch view.

### Limitation

It assumes every interaction contributes equally.

---

# 4. Time-Decay Attribution

More credit is assigned to touchpoints closer to conversion.

The final Python analysis used the **actual timestamps** rather than only the touchpoint order.

A 7-day half-life was used for the decay calculation.

### Strength

Useful when recent interactions are expected to have greater influence.

### Limitation

The choice of half-life is a modeling assumption.

---

# 5. Position-Based Attribution

The Position-Based model assigns:

```text
First Touchpoint  → 40%
Middle Touchpoints → 20%
Last Touchpoint   → 40%
```

For journeys with multiple middle touchpoints, the 20% middle allocation is distributed among them.

### Strength

Recognizes both customer acquisition and conversion-driving interactions.

### Limitation

The 40/20/40 weighting is an assumption rather than causal proof.

---

# 🔬 Controlled Benchmark Validation

The dataset was generated using known channel-role patterns.

This allows the attribution models to be compared against a **controlled synthetic benchmark**.

The benchmark was used to calculate Mean Absolute Error (MAE).

### MAE Results

| Attribution Model |    MAE |
| ----------------- | -----: |
| Position-Based    |  32.80 |
| Time-Decay        |  34.63 |
| Linear            |  36.10 |
| Last-Touch        | 226.46 |
| First-Touch       | 278.69 |

### Result

**Position-Based Attribution achieved the lowest MAE on this controlled synthetic benchmark.**

This suggests that Position-Based Attribution most closely reproduced the benchmark contribution structure within this dataset.

### Important Limitation

The benchmark represents the known generative structure of the synthetic dataset.

It is **not real-world causal ground truth**.

Therefore:

> The result should be interpreted as a model validation exercise, not as proof that Position-Based Attribution is universally superior in real-world marketing.

---

# 🗄️ MySQL Analysis

MySQL was used to reproduce and extend the analytical workflow using SQL.

## Main SQL Activities

### Database Setup

Created:

```text
marketing_attribution
```

### Main Tables

```text
touchpoints
users_summary
```

### SQL Analysis

The MySQL stage included:

* Database creation
* Table creation
* CSV loading
* Data-quality checks
* Customer-level analysis
* Channel-level analysis
* Marketing spend analysis
* Revenue analysis
* Conversion analysis
* CAC analysis
* ROAS analysis
* Journey analysis
* First-Touch analysis
* Last-Touch analysis
* Business-focused SQL queries
* Analytical views

---

# 📂 SQL Project Structure

```text
sql/
├── 01_create_database.sql
├── 02_create_tables.sql
├── 03_data_quality_checks.sql
├── 04_business_kpis.sql
├── 05_channel_analysis.sql
├── 06_attribution_analysis.sql
└── 07_final_business_queries.sql
```

---

# 📊 CAC & ROAS Analysis

Two important marketing efficiency metrics were used.

## Customer Acquisition Cost

```text
CAC = Marketing Spend / Attributed Conversions
```

CAC measures how much marketing spend is required to acquire a converted customer under the selected attribution methodology.

---

## Return on Ad Spend

```text
ROAS = Attributed Revenue / Marketing Spend
```

ROAS measures the revenue generated for each ₹1 spent on marketing.

For example:

```text
ROAS = 5

₹1 marketing spend
        ↓
₹5 attributed revenue
```

---

# 📈 Paid Channel Performance

The project evaluates the three paid channels:

* Paid Search
* Paid Social
* Display

Using the channel-level performance analysis:

| Channel     |       Spend | Last-Touch Conversions | Last-Touch CAC | Last-Touch ROAS |
| ----------- | ----------: | ---------------------: | -------------: | --------------: |
| Paid Search | ₹231,677.45 |                    820 |        ₹282.53 |          11.24x |
| Paid Social |  ₹72,535.83 |                    133 |        ₹545.38 |           6.22x |
| Display     |  ₹21,173.13 |                     96 |        ₹220.55 |          15.25x |

### Interpretation

Display has the highest Last-Touch ROAS among the paid channels in this analysis.

However, channel performance changes significantly depending on the attribution model.

Therefore:

> Paid-channel investment decisions should not rely exclusively on Last-Touch attribution.

---

# 📗 Excel Analysis

Excel was used as the business modeling layer.

The workbook was designed to translate analytical findings into a practical marketing budget decision.

## Main Excel Components

### 1. Channel Performance

Includes:

* Marketing spend
* Conversions
* Revenue
* CAC
* ROAS

---

### 2. Attribution Models

The workbook compares:

* First-Touch
* Last-Touch
* Linear
* Time-Decay
* Position-Based

This demonstrates how attribution methodology changes the perceived contribution of each channel.

---

### 3. Budget Model

A hypothetical:

> **₹10,00,000 marketing budget**

was used to build a budget allocation scenario.

The model evaluates how the budget could be distributed across paid marketing channels based on observed efficiency.

---

### 4. Sensitivity Analysis

The workbook includes different scenarios to understand how the budget model behaves under different assumptions.

Scenarios include:

* Conservative
* Base
* Aggressive

---

### 5. Executive Summary

The workbook summarizes:

* Marketing performance
* Attribution findings
* Paid-channel efficiency
* Budget recommendation
* Expected business outcomes

---

# 💰 ₹10 Lakh Budget Allocation

The Power BI budget allocation model presents the recommended allocation of:

```text
₹10,00,000
```

across paid marketing channels.

The current model recommends approximately:

| Channel     | Recommended Budget | Budget Share |
| ----------- | -----------------: | -----------: |
| Display     |       ₹4,46,087.97 |       44.61% |
| Paid Search |       ₹3,62,280.33 |       36.23% |
| Paid Social |       ₹1,91,631.70 |       19.16% |
| **Total**   |  **₹10,00,000.00** |     **100%** |

---

# 📈 Expected Budget Scenario

Under the modeled allocation:

* Total Budget: **₹10,00,000**
* Recommended Budget: **₹10,00,000**
* Expected Revenue: **₹12,065,387.39**
* Expected Conversions: **27,593.46**
* Expected Revenue Uplift: **6.26%**

These are **scenario-model outputs**, not guaranteed future results.

---

# 📊 Power BI Dashboard

The final Power BI report contains **five pages**.

---

# Page 1 — Executive Overview

### Purpose

Provides a high-level view of overall marketing performance.

### KPIs

* Total Users
* Converted Users
* Conversion Rate
* Total Revenue
* Revenue per Converted User
* Total Marketing Spend

### Visuals

* Revenue Contribution by Marketing Channel
* Marketing Spend by Channel
* Revenue Trend Over Time
* Conversions by Marketing Channel
* Customer Detail Table
* Business Insight section

### Interactivity

* Channel slicer
* Date slicer
* Customer-level table
* Reset Filters button
* Next-page navigation

---

# Page 2 — Attribution Analysis

### Purpose

Shows how attribution methodology changes channel revenue contribution.

### KPIs

* First-Touch Revenue
* Last-Touch Revenue
* Selected Attribution Revenue
* Average Touchpoints per Converted User
* Revenue Attribution Shift %

### Visuals

* First-Touch vs Last-Touch Revenue by Channel
* Linear Attribution Revenue by Channel
* Revenue Share by Marketing Channel
* Attribution Percentage Heatmap

### Attribution Models Covered

* First-Touch
* Last-Touch
* Linear

The page demonstrates that the selected attribution methodology can materially change the perceived importance of marketing channels.

---

# Page 3 — CAC & ROAS Analysis

### Purpose

Evaluates marketing efficiency across channels.

### KPIs

* Total Marketing Spend
* Total Revenue
* CAC
* ROAS
* Total Converted Users

### Visuals

* Customer Acquisition Cost by Marketing Channel
* Marketing Spend vs ROAS
* Attributed Revenue vs Marketing Spend
* Channel Efficiency / Performance Table
* Business Insight section

### Key Metrics

The performance table compares:

* Marketing Spend
* Converted Users
* CAC
* ROAS
* CAC vs Overall CAC %
* ROAS vs Overall ROAS %
* Revenue

This allows management to evaluate channels from both acquisition-cost and revenue-efficiency perspectives.

---

# Page 4 — Budget Allocation

### Purpose

Converts channel performance into a practical budget recommendation.

### Scenario

```text
Available Marketing Budget = ₹10,00,000
```

### KPIs

* Total Budget
* Recommended Budget
* Expected Revenue
* Expected Conversions
* Expected Revenue Uplift %

### Visuals

* Current vs Recommended Budget by Channel
* Recommended Budget Share by Channel
* Current vs Expected Revenue by Channel
* Budget Allocation Table
* Budget Allocation Insight

### Business Purpose

The page helps management answer:

> "If we have ₹10 lakh available for marketing, where should we allocate it?"

---

# Page 5 — Customer Drillthrough

### Purpose

Provides customer-level journey analysis.

A customer can be selected from the main report and analyzed individually.

### KPIs

* User ID
* Journey Length
* Conversion
* Customer Revenue

### Customer Details

Shows:

* Touch order
* Channel
* Timestamp
* Cost
* Conversion
* Revenue

### Visuals

* Customer Journey by Touchpoint
* Customer Touchpoint Cost by Channel

### Business Use

This page helps analysts investigate an individual customer's journey rather than only looking at aggregated channel-level results.

---

# 📌 Key Business Findings

## 1. Customer Journey Length Matters

Conversion rates increase as the number of customer touchpoints increases.

The simulated data shows:

```text
1 touchpoint  → 7.99%
2 touchpoints → 15.14%
3 touchpoints → 21.72%
4 touchpoints → 28.07%
5 touchpoints → 36.81%
```

This suggests that customer journeys with more interactions are associated with higher conversion rates.

---

## 2. Attribution Methodology Changes Channel Evaluation

Different attribution models assign substantially different conversion and revenue credit to the same channel.

For example, channels such as Paid Social and Display can appear very different under First-Touch versus Last-Touch attribution.

Therefore:

> Attribution methodology can materially influence marketing performance interpretation.

---

## 3. Last-Touch Can Overemphasize Closing Channels

Last-Touch attribution gives 100% of credit to the final interaction.

This can cause channels that frequently appear near conversion to receive disproportionate credit.

It may undervalue channels that introduced or influenced the customer earlier in the journey.

---

## 4. Paid Channel Efficiency Is Not Uniform

Paid Search, Paid Social, and Display have different levels of:

* Spend
* Conversions
* CAC
* ROAS

Therefore, a single budget allocation strategy for all paid channels would not be appropriate.

---

## 5. Position-Based Performed Best on the Controlled Benchmark

Position-Based Attribution achieved the lowest MAE:

```text
Position-Based → 32.80
Time-Decay     → 34.63
Linear         → 36.10
Last-Touch     → 226.46
First-Touch    → 278.69
```

This means Position-Based was closest to the known contribution structure used to generate this synthetic dataset.

Again, this should not be interpreted as universal real-world causal evidence.

---

# 💡 Business Recommendations

### Recommendation 1 — Do Not Rely Exclusively on Last-Touch

Marketing decisions should consider multiple attribution perspectives.

A multi-touch framework provides a more complete view of the customer journey.

---

### Recommendation 2 — Evaluate Paid Channels Using CAC and ROAS Together

A channel with strong ROAS but poor acquisition cost may require a different strategy from a channel with both strong ROAS and efficient CAC.

Therefore, management should evaluate:

```text
Spend
+
Conversions
+
CAC
+
ROAS
+
Attribution Contribution
```

together.

---

### Recommendation 3 — Use Position-Based Attribution as a Strong Candidate for This Dataset

Within this controlled benchmark, Position-Based Attribution produced the lowest MAE.

Therefore, it can be used as a practical attribution perspective for the budget scenario in this project.

It should still be validated against real-world data before being adopted as a permanent business attribution model.

---

### Recommendation 4 — Use the ₹10 Lakh Budget as a Scenario, Not a Guarantee

The budget model indicates a potential allocation across:

* Display
* Paid Search
* Paid Social

The resulting expected revenue and conversion figures are modeled estimates.

Actual future performance would require continuous monitoring and experimentation.

---

### Recommendation 5 — Validate Marketing Decisions Through Experiments

Attribution analysis can identify patterns, but attribution alone does not establish causality.

Future marketing decisions should be supported by:

* A/B testing
* Incrementality testing
* Holdout experiments
* Geo experiments
* Continuous performance monitoring

---

# ⚠️ Limitations

This project has several important limitations.

## 1. Synthetic Dataset

The dataset is synthetic rather than real company marketing data.

Therefore, results should not be interpreted as actual market performance.

---

## 2. Attribution Is Not Causality

Attribution models distribute credit among touchpoints.

They do not prove that a particular channel caused the conversion.

---

## 3. Benchmark Is Controlled

The benchmark used for MAE validation is based on the known generative structure of the synthetic dataset.

It is not real-world causal ground truth.

---

## 4. Position-Based Weights Are Assumptions

The 40/20/40 allocation is a modeling assumption.

Different businesses may require different attribution structures.

---

## 5. Time-Decay Half-Life Is an Assumption

The final Python Time-Decay implementation uses a 7-day half-life.

A real marketing organization would need to determine the appropriate decay period using historical behavior and validation.

---

## 6. Budget Allocation Is a Scenario Model

The ₹10 lakh budget allocation represents a modeled recommendation.

It does not guarantee the expected revenue or conversion outcomes.

---

## 7. Zero Spend Channels

Direct, Email, Organic Search, and Referral have no direct marketing spend in the provided dataset.

Therefore, traditional CAC and ROAS calculations are not meaningful for those channels in the same way as paid channels.

---

# 📁 Project Structure

```text
Marketing-Attribution-CAC-Analysis/
│
├── data/
│   ├── raw/
│   │   ├── touchpoints.csv
│   │   ├── users_summary.csv
│   │   ├── generate_attribution_data.py
│   │   └── analyze_attribution.py
│   │
│   └── processed/
│
├── src/
│   └── __init__.py
│
├── models/
│
├── outputs/
│
├── notebooks/
│   └── 01_Data_Understanding.ipynb
│
├── dashboard/
│   └── Marketing Attribution Power BI Report
│
├── docs/
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_data_quality_checks.sql
│   ├── 04_business_kpis.sql
│   ├── 05_channel_analysis.sql
│   ├── 06_attribution_analysis.sql
│   └── 07_final_business_queries.sql
│
├── Marketing_Attribution_Analysis.xlsx
├── README.md
├── requirements.txt
└── .gitignore
```

> Note: The exact contents of `outputs/`, `models/`, and `dashboard/` may vary depending on the final local project files and Power BI storage strategy.

---

# 🚀 How to Run the Python Analysis

## 1. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
```

## 2. Open the Project

```bash
cd Marketing-Attribution-CAC-Analysis
```

## 3. Create a Virtual Environment

```bash
python -m venv venv
```

## 4. Activate the Virtual Environment

### Windows PowerShell

```powershell
.\venv\Scripts\Activate.ps1
```

If PowerShell execution policy prevents activation, the environment can also be activated using:

```powershell
.\venv\Scripts\activate
```

depending on the local PowerShell configuration.

---

## 5. Install Required Packages

```bash
pip install -r requirements.txt
```

---

## 6. Start Jupyter Notebook

```bash
jupyter notebook
```

Open:

```text
notebooks/01_Data_Understanding.ipynb
```

Select the appropriate Python environment/kernel and run the notebook.

---

# 🗄️ How to Reproduce the MySQL Analysis

## 1. Open MySQL Workbench

Create/connect to your MySQL server.

## 2. Create the Database

Run:

```text
sql/01_create_database.sql
```

## 3. Create the Tables

Run:

```text
sql/02_create_tables.sql
```

## 4. Load the CSV Data

Load:

```text
data/raw/touchpoints.csv
data/raw/users_summary.csv
```

into the appropriate tables.

## 5. Run Data Quality Checks

```text
sql/03_data_quality_checks.sql
```

## 6. Run Business KPI Analysis

```text
sql/04_business_kpis.sql
```

## 7. Run Channel Analysis

```text
sql/05_channel_analysis.sql
```

## 8. Run Attribution Analysis

```text
sql/06_attribution_analysis.sql
```

## 9. Run Final Business Queries

```text
sql/07_final_business_queries.sql
```

---

# 📗 How to Use the Excel Model

Open:

```text
Marketing_Attribution_Analysis.xlsx
```

The workbook contains the business modeling layer of the project.

The major analysis areas include:

```text
Channel Performance
Attribution Models
Budget Model
Sensitivity Analysis
Executive Summary
```

The budget model can be used to evaluate a hypothetical:

```text
₹10,00,000 marketing budget
```

and compare the current marketing structure with the recommended scenario.

---

# 📊 Power BI Report

Open the completed Power BI report from the project's dashboard/report location.

The report contains:

```text
1. Executive Overview
2. Attribution Analysis
3. CAC & ROAS Analysis
4. Budget Allocation
5. Customer Drillthrough
```

The dashboard includes interactive:

* Channel filtering
* Date filtering
* Attribution model selection
* Customer drillthrough
* Reset filter buttons
* Page navigation

---

# 🔍 Analytical Methodology

The project follows this analytical framework:

```text
1. Understand the business problem
              ↓
2. Validate the raw data
              ↓
3. Analyze customer journeys
              ↓
4. Measure channel performance
              ↓
5. Apply multiple attribution models
              ↓
6. Validate models against a controlled benchmark
              ↓
7. Calculate CAC and ROAS
              ↓
8. Build ₹10 lakh budget scenario
              ↓
9. Visualize results in Power BI
              ↓
10. Generate business recommendations
```

---

# 📌 Important Metric Definitions

## Conversion Rate

```text
Conversion Rate =
Converted Users / Total Users
```

---

## CAC

```text
CAC =
Marketing Spend / Attributed Conversions
```

---

## ROAS

```text
ROAS =
Attributed Revenue / Marketing Spend
```

---

## Revenue per Converted User

```text
Revenue per Converted User =
Total Revenue / Converted Users
```

---

## MAE

Mean Absolute Error measures the average absolute difference between the attribution model's estimated contribution and the controlled benchmark contribution.

```text
MAE =
Average(|Predicted Contribution - Benchmark Contribution|)
```

Lower MAE indicates closer agreement with the benchmark.

---

# 🎓 Skills Demonstrated

This project demonstrates practical Data Analyst skills in:

### Data Analysis

* Exploratory Data Analysis
* Data validation
* Data cleaning
* KPI analysis
* Customer journey analysis
* Business interpretation

### SQL

* Database creation
* Table design
* Data validation
* Aggregations
* GROUP BY
* JOINs
* CTEs
* Window functions
* Business queries
* Attribution calculations
* Analytical views

### Python

* Pandas
* NumPy
* Data transformation
* Exploratory analysis
* Attribution modeling
* Time-based calculations
* Model comparison
* MAE validation
* Visualization

### Excel

* KPI calculations
* Attribution analysis
* CAC and ROAS
* Business modeling
* Budget allocation
* Scenario analysis
* Sensitivity analysis
* Executive reporting

### Power BI

* Data modeling
* DAX measures
* KPI cards
* Interactive slicers
* Conditional formatting
* Heatmaps
* Drillthrough
* Bookmarks
* Navigation buttons
* Executive dashboards
* Dynamic business insights

### Business & Consulting Skills

* Problem structuring
* Marketing analytics
* Attribution methodology
* Performance measurement
* Budget optimization
* Scenario modeling
* Business recommendations
* Data-driven decision making

---

# 🧩 Business Impact

The project demonstrates how a Data Analyst can move beyond simply reporting historical numbers.

The analytical process connects:

```text
Customer Behavior
       +
Marketing Channels
       +
Attribution
       +
CAC / ROAS
       +
Budget Modeling
       ↓
Business Decision
```

Instead of asking only:

> "Which channel generated the most conversions?"

the project asks:

> "How should we evaluate channel contribution, marketing efficiency, and budget allocation when customers interact with multiple channels before converting?"

This creates a more complete framework for marketing decision-making.

---

# 🏆 Final Project Outcome

The final solution provides management with:

### Customer Perspective

* Customer journey analysis
* Conversion behavior
* Touchpoint analysis
* Customer-level drillthrough

### Marketing Perspective

* Channel performance
* Attribution comparison
* Revenue contribution
* Marketing spend analysis

### Financial Perspective

* CAC
* ROAS
* Revenue
* Budget allocation

### Decision-Making Perspective

* Attribution model comparison
* Controlled benchmark validation
* ₹10 lakh budget scenario
* Expected revenue and conversion outcomes
* Business recommendations

---
---

# ⚠️ Disclaimer

This project is an analytical portfolio project based on a controlled synthetic dataset.

The findings demonstrate an analytical methodology and should not be interpreted as actual company performance or causal marketing evidence.

The attribution benchmark represents the known generative structure of the synthetic dataset and is used only for model validation.

Budget allocation outputs are scenario-based estimates rather than guaranteed future results.

---

# 👤 Author

**Lakshay Shrivastav**

Data Analyst | Business Analytics | SQL | Python | Excel | Power BI

---

# ⭐ Project Highlights

```text
20,000 Customers
47,584 Marketing Touchpoints
7 Marketing Channels
5 Attribution Models
₹11.35M Revenue
₹325K Marketing Spend
₹10 Lakh Budget Allocation Scenario
5-Page Interactive Power BI Dashboard
Python + MySQL + Excel + Power BI
```

---

# 📌 Portfolio Focus

This project demonstrates an end-to-end approach to solving a realistic marketing analytics problem:

```text
Raw Data
   ↓
Data Validation
   ↓
Exploratory Analysis
   ↓
Customer Journey Analysis
   ↓
Attribution Modeling
   ↓
SQL Business Analysis
   ↓
CAC & ROAS
   ↓
Excel Budget Modeling
   ↓
Power BI Dashboard
   ↓
Business Recommendation
```

**The goal was not only to analyze data, but to convert analysis into a business decision.**

```



#   M u l t i - C h a n n e l - M a r k e t i n g - A t t r i b u t i o n - C A C - A n a l y s i s  
 