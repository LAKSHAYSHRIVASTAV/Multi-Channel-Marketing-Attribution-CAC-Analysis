
# Multi-Channel Marketing Attribution & CAC Analysis

## Project Overview

Marketing teams invest across multiple acquisition channels such as Paid Search, Paid Social, Display, Email, Organic Search, Referral, and Direct.

Relying on a single attribution model can give an incomplete view of channel performance. A channel that appears weak under Last-Touch Attribution may have contributed significantly earlier in the customer journey.

This project analyzes multi-channel customer journeys to answer:

> Which marketing channels contribute to conversions and revenue, how does attribution methodology change channel performance, and how should a ₹10 lakh marketing budget be allocated?

The project combines Python, MySQL, Excel, and Power BI to move from raw customer-journey data to business recommendations.

## Business Objectives

1. Identify channels contributing to conversions and revenue.
2. Evaluate channel efficiency using CAC and ROAS.
3. Compare First-Touch, Last-Touch, Linear, Time-Decay, and Position-Based attribution.
4. Build a ₹10 lakh marketing budget allocation scenario.
5. Provide customer-level journey and conversion insights.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Python / Jupyter | EDA, data validation, attribution calculations, analytical checks |
| MySQL | Data storage, joins, SQL analysis, customer journey queries |
| Excel | Attribution comparison, CAC/ROAS analysis, budget allocation, sensitivity analysis |
| Power BI | Interactive executive dashboard, KPIs, drillthrough, business insights |
| GitHub | Version control and portfolio presentation |

## Project Structure

```text
Multi-Channel-Marketing-Attribution-CAC-Analysis/
│
├── Excel/
│   └── Marketing_Attribution_Analysis.xlsx
├── dashboard/
├── data/
├── notebooks/
├── sql/
├── src/
├── .gitignore
├── README.md
└── requirements.txt
```

## Analytical Workflow

```text
Raw Customer Journey Data
        ↓
Data Validation
        ↓
MySQL
        ↓
Customer Journey Analysis
        ↓
Python
        ↓
Attribution Modeling
        ↓
Excel Business Modeling
        ↓
CAC / ROAS / Budget Analysis
        ↓
Power BI Dashboard
        ↓
Business Recommendations
```

# 1. Data & Customer Journey Analysis

The dataset contains customer-level marketing touchpoints.

Each customer can interact with multiple channels before conversion.

Example:

```text
Display
   ↓
Paid Social
   ↓
Paid Social
   ↓
Paid Search
   ↓
Conversion
```

Important fields include:

- `user_id`
- `touch_order`
- `channel`
- `timestamp`
- `cost`
- `converted`
- `revenue`

This structure makes it possible to analyze both the sequence of interactions and their economic value.

# 2. Attribution Analysis

The project compares five attribution approaches.

### First-Touch Attribution

Assigns 100% of the conversion or revenue credit to the first marketing touchpoint.

**Business use:** Understand which channels initiate customer journeys.

### Last-Touch Attribution

Assigns 100% of the credit to the final touchpoint before conversion.

**Business use:** Understand which channels are closest to conversion.

### Linear Attribution

Distributes credit equally across all touchpoints in a customer journey.

**Business use:** Useful when every interaction is assumed to contribute equally.

### Time-Decay Attribution

Gives greater weight to touchpoints closer to conversion.

**Business use:** Useful when recent interactions are expected to have greater influence.

### Position-Based Attribution

Gives higher weight to the first and last interactions while distributing the remaining credit across middle interactions.

**Business use:** Useful when both acquisition and conversion-driving interactions matter.

# 3. CAC & ROAS Analysis

### Customer Acquisition Cost

```text
CAC = Marketing Spend / Converted Customers
```

Lower CAC generally indicates more efficient customer acquisition.

### Return on Ad Spend

```text
ROAS = Attributed Revenue / Marketing Spend
```

Higher ROAS generally indicates stronger revenue return relative to marketing spend.

The analysis compares:

- Marketing Spend
- Converted Users
- CAC
- ROAS
- Revenue
- CAC vs Overall CAC
- ROAS vs Overall ROAS

# 4. Excel Business Model

The Excel workbook contains:

### Channel Performance

- Marketing Spend
- Conversions
- Revenue
- CAC
- ROAS

### Attribution Models

- First-Touch
- Last-Touch
- Linear
- Time-Decay
- Position-Based

### Budget Model

A hypothetical ₹10 lakh marketing budget is allocated using channel-performance assumptions.

The model estimates:

- Recommended Budget
- Budget Share
- Budget Change
- Expected Revenue
- Expected Conversions
- Allocation Recommendation

### Sensitivity Analysis

The model includes:

- Conservative scenario
- Base scenario
- Aggressive scenario

This helps evaluate how recommendations may change under different assumptions.

# 5. Power BI Dashboard

The Power BI report contains five pages.

## Page 1 — Executive Overview

Purpose: Provide management with a high-level view of marketing performance.

Key KPIs:

- Total Users
- Converted Users
- Conversion Rate
- Total Revenue
- Revenue per Converted User
- Total Marketing Spend

Visuals include:

- Revenue Contribution by Marketing Channel
- Marketing Spend by Channel
- Revenue Trend Over Time
- Conversions by Marketing Channel
- Customer Detail Table
- Dynamic Business Insight

## Page 2 — Attribution Analysis

Purpose: Understand how revenue contribution changes under different attribution approaches.

Key components:

- First-Touch Revenue
- Last-Touch Revenue
- Selected Attribution Revenue
- Average Touchpoints per Converted User
- Revenue Attribution Shift %
- First-Touch vs Last-Touch Revenue by Channel
- Linear Attribution Revenue by Channel
- Revenue Share by Marketing Channel
- Attribution % Heatmap

An Attribution Model selector makes the page interactive.

## Page 3 — CAC & ROAS Analysis

Purpose: Evaluate marketing efficiency across channels.

Key KPIs:

- Total Marketing Spend
- Total Revenue
- CAC
- ROAS
- Total Converted Users

Visuals include:

- Customer Acquisition Cost by Marketing Channel
- Marketing Spend vs ROAS by Channel
- Attributed Revenue vs Marketing Spend
- Channel Efficiency / Performance Table

## Page 4 — Budget Allocation

Purpose: Answer the management question:

> Where should ₹10 lakh be invested to maximize performance?

Key KPIs:

- Total Budget
- Recommended Budget
- Expected Revenue
- Expected Conversions
- Expected Revenue Uplift %

Visuals include:

- Current vs Recommended Budget by Channel
- Recommended Budget Share by Channel
- Current vs Expected Revenue by Channel
- Budget Allocation Table
- Dynamic Budget Allocation Insight

## Page 5 — Customer Drillthrough

Purpose: Move from channel-level analysis to an individual customer journey.

The page includes:

- User ID
- Journey Length
- Conversion Status
- Customer Revenue
- Customer Touchpoint Details
- Customer Journey by Touchpoint
- Customer Touchpoint Cost by Channel
- Dynamic Customer Drillthrough Insight

A customer can be selected from the Executive Overview and opened through drillthrough.

# Key Dashboard Results

The final dashboard shows approximately:

| KPI | Result |
|---|---:|
| Total Users | **20K** |
| Converted Users | **3.5K** |
| Conversion Rate | **17.6%** |
| Total Revenue | **₹11.35M** |
| Marketing Spend | **₹325.39K** |
| Overall CAC | **₹92.60** |
| Overall ROAS | **34.90x** |
| Avg. Touchpoints / Converted User | **2.98** |

# Business Insights

The project demonstrates why marketing decisions should not rely on one metric or one attribution model.

Examples:

- A channel can generate high revenue while also requiring high spend.
- A channel can have strong ROAS but lower absolute revenue contribution.
- First-Touch and Last-Touch attribution can assign very different levels of credit to the same channel.
- Customer journeys often contain multiple touchpoints.
- Budget decisions should consider revenue, conversions, CAC, ROAS, and attribution together.

A practical decision framework is:

```text
Revenue
   +
Conversions
   +
CAC
   +
ROAS
   +
Attribution
   +
Budget Impact
   ↓
Marketing Investment Decision
```

# Business Recommendations

1. Do not rely on Last-Touch Attribution alone.
2. Compare multiple attribution models before judging channel performance.
3. Evaluate CAC and ROAS together with revenue and conversion volume.
4. Prioritize channels that demonstrate strong economic performance.
5. Review low-efficiency channels before increasing their budgets.
6. Treat budget allocation as a scenario model, not a guaranteed forecast.
7. Continue monitoring customer journeys to understand how channels work together.

# Important Assumptions

The ₹10 lakh budget allocation is a scenario-based business model, not a guaranteed future forecast.

Expected revenue and expected conversions depend on historical performance and the assumptions used in the model.

Therefore:

> The recommended allocation should be treated as decision support and validated against future campaign performance.

# How to Reproduce the Analysis

## 1. Clone the repository

```bash
git clone <your-github-repository-url>
cd Multi-Channel-Marketing-Attribution-CAC-Analysis
```

## 2. Create a virtual environment

```bash
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

## 3. Install dependencies

```bash
pip install -r requirements.txt
```

## 4. Run Jupyter

```bash
jupyter notebook
```

Open the relevant notebook from `notebooks/`.

## 5. MySQL

Run the SQL scripts from the `sql/` folder in MySQL Workbench in the required order.

## 6. Power BI

Open the Power BI report from the `dashboard/` folder and refresh the data connections if required.

# Data & Security

Do not commit API keys, passwords, database credentials, or other secrets to GitHub.

The repository uses `.gitignore` to exclude sensitive and unnecessary files.

# Skills Demonstrated

- Business problem framing
- Marketing analytics
- Customer journey analysis
- Multi-touch attribution
- First-Touch Attribution
- Last-Touch Attribution
- Linear Attribution
- Time-Decay Attribution
- Position-Based Attribution
- CAC analysis
- ROAS analysis
- Budget allocation
- Sensitivity analysis
- SQL
- Python
- Excel
- Power BI
- DAX
- Data visualization
- KPI development
- Interactive dashboards
- Customer-level drillthrough
- Business recommendations

# Portfolio Value

This project demonstrates an end-to-end analytical workflow rather than only dashboard creation:

```text
Business Problem
      ↓
Data
      ↓
SQL Analysis
      ↓
Python Analysis
      ↓
Attribution Modeling
      ↓
Excel Business Modeling
      ↓
CAC / ROAS Analysis
      ↓
Budget Allocation
      ↓
Power BI Dashboard
      ↓
Business Recommendation
```

It is suitable for demonstrating skills relevant to **Data Analyst, Business Analyst, Marketing Analyst, and Analytics-focused roles**.

## Author

**Lakshay Shrivastav**

Built as a portfolio project demonstrating end-to-end business analytics, marketing attribution, financial modeling, and interactive dashboard development.
