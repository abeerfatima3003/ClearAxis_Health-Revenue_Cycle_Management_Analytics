# ClearAxis Health (RCM) Revenue Cycle Management Analytics
<p align="center">
  <img src="images/clearaxis_logo.png" alt="ClearAxis Health — Revenue Cycle Intelligence" width="450">
</p>

---
## Table of Contents

| |
|---|
| **[Background & Overview](#background--overview)** |
| &nbsp;&nbsp;Company Context |
| &nbsp;&nbsp;Project Goals |
| &nbsp;&nbsp;Insights & Recommendations |
| &nbsp;&nbsp;Stakeholder Alignment |
| **[Initial Business Questions & Data Structure](#initial-business-questions--data-structure)** |
| &nbsp;&nbsp;North Star Metrics |
| &nbsp;&nbsp;Dataset Overview |
| &nbsp;&nbsp;Entity Relationship Diagram |
| &nbsp;&nbsp;Table Descriptions |
| **[Executive Summary](#executive-summary)** |
| **[Insights Deep Dive](#insights-deep-dive)** |
| &nbsp;&nbsp;**[Executive Performance](#executive-performance)** |
| &nbsp;&nbsp;&nbsp;&nbsp;Net Collection Rate |
| &nbsp;&nbsp;&nbsp;&nbsp;Revenue Disposition Overview |
| &nbsp;&nbsp;**[Payer & Denial Performance](#payer--denial-performance)** |
| &nbsp;&nbsp;&nbsp;&nbsp;Denied Revenue by Payer Type |
| &nbsp;&nbsp;&nbsp;&nbsp;Denial Accountability Analysis |
| &nbsp;&nbsp;&nbsp;&nbsp;Appeal Effectiveness & Revenue Recovery |
| &nbsp;&nbsp;**[Write-Off Analysis & Revenue Impact](#write-off-analysis--revenue-impact)** |
| &nbsp;&nbsp;&nbsp;&nbsp;Write-Off Trends by Payer Type |
| &nbsp;&nbsp;&nbsp;&nbsp;Write-Off Drivers by Reason |
| &nbsp;&nbsp;&nbsp;&nbsp;Write-Off Distribution by Amount |
| **[Recommendations](#recommendations)** |
| **[Technical Details](#technical-details)** |
| **[Clarifying Questions, Assumptions & Caveats](#clarifying-questions-assumptions--caveats)** |
| **[Appendix](#appendix)** |

---
<h2 align="center">Background & Overview</h2>

### Company Context

ClearAxis Health is a Revenue Cycle Management (RCM) SaaS platform serving healthcare providers across 15 states. ClearAxis operates as the billing and claims management backbone for physicians, hospitals, clinics, and surgery centers, enabling providers to submit, track, and collect on insurance claims across 150 payer organizations, including Commercial, Medicare, Medicaid, Medicare Advantage, Tricare, Self-Pay, and Workers Compensation.

### Project Goals

As the data analyst embedded with the ClearAxis Finance and Revenue Cycle Operations teams, this analysis was commissioned to answer a single overarching business question:

> **Is ClearAxis Health collecting revenue as efficiently as it should be — and where are the primary sources of revenue loss, delay, and collection risk?**

To answer this, the analysis pursues four specific objectives:

1. **Evaluate collection performance** against the 95% target benchmark for Net Collection Rate.
2. **Identify the primary drivers** of the collection gap, denial patterns, and write-off behavior.
3. **Assess accountability** between provider-side, payer-side, and shared denial causes.
4. **Prioritize actionable recommendations** that Revenue Cycle, Finance, and Operations leadership can act on immediately.
#### Key Performance Indicators
The KPIs investigated are:
- **Net Collection Rate**
- **Denied Revenue at Risk**
- **Appeal Overturn Rate**
- **Write-Off Amount**

### Insights & Recommendations

Insights and recommendations are provided across four key areas of the revenue cycle:

- **Collection Efficiency** - Evaluate overall collection performance against the 95% target benchmark and assess the disposition of collectible, collected, denied, written-off, and pending revenue.
- **Denial Management** - Identify payer segments contributing the greatest amount of denied revenue and assess the relative accountability of provider-side, payer-side, and shared denial drivers.
- **Appeal Performance** - Evaluate appeal overturn rates and the amount of revenue recovered through successful appeals to determine the effectiveness of the appeals process.
- **Write-Off Analysis** - Identify the primary drivers of write-offs, payer concentration, write-off amount distribution, and timely filing trends to determine where revenue is being permanently lost.

### Stakeholder Alignment

| Insight Area | Primary Stakeholder(s) | Decision Enabled |
|---|---|---|
| **Net Collection Rate** | CFO · Finance Director | Assess whether revenue is being collected efficiently enough to support financial performance. |
| **Denied Revenue by Payer** | Revenue Cycle Director · Payer Contracting | Identify payer segments that contribute the greatest amount of denied revenue and should be prioritized for intervention. |
| **Denial Accountability** | Revenue Cycle Operations · Coding & Billing | Determine how much denied revenue is attributable to provider-side, payer-side, and shared factors. |
| **Appeal Effectiveness & Revenue Recovery** | Appeals Team · Revenue Cycle Director | Evaluate whether the appeals process is effectively converting denied claims into recovered revenue. |
| **Write-Off Analysis** | Finance · AR Manager · Revenue Cycle Operations | Identify where revenue is being permanently lost and which write-off drivers should be prioritized for corrective action. |

---
<h2 align="center">Initial Business Questions & Data Structure</h2>

### North Star Metrics

**Is ClearAxis collecting efficiently?**  
**Net Collection Rate:** 87.45% vs. 95% benchmark

**Which payers are the biggest problem?**  
**Denied Revenue at Risk:** $298M across 120,735 claims

**What revenue are we giving up?**  
**Total Write-Off Amount:** $4.26M permanently written off

### Dataset Overview

The dataset covers **36 months (January 2022–December 2024)** and contains **6 relational tables structured as a star schema**, supporting analysis across claims, payments, denials, providers, payers, and patients.

### Entity Relationship Diagram

<p align="center">
  <img src="clearaxis_ERD.png" alt="ClearAxis Health Entity Relationship Diagram" width="600">
</p>

### Table Descriptions

**`fact_claims` - 500,000 rows** Core claim-level transaction table containing charges, status, denial codes, clean claim flags, and Days in AR.

**`fact_payments` - 300,000 rows** Payment-level transaction table containing collections, write-offs, contractual adjustments, and payment dates.

**`fact_denials` - 124,685 rows** Denial-level table containing denial codes, categories, appeal outcomes, and recovered revenue.

**`dim_providers` - 2,000 rows** Provider master containing specialty, EHR system, state, group size, and contract information.

**`dim_payers` - 150 rows** Payer master containing payer type, contract type, reimbursement rate, and clearinghouse information.

**`dim_patients` - 50,000 rows** Patient dimension containing insurance type, state, and secondary coverage information.

---
<h2 align="center">Executive Summary</h2>

- **Collection performance:** Net Collection Rate was **87.45%**, 7.55 percentage points below the 95% benchmark, representing approximately **$58.4M in unrealized collectible revenue**.

- **Denial exposure:** **$298M across 120,735 denied or appealed claims** remains at risk. Denial rates are consistent across all seven payer types, indicating a **systemic operational issue rather than a single problem payer**.

- **Revenue recovery:** Denial accountability is split between **provider-driven (42%)**, **payer-driven (42%)**, and **shared (16%)** causes. Appeals currently recover approximately **$20.6M**, with overturn rates of 34–37%.

- **Permanent revenue loss:** **$4.26M was written off**, with no meaningful variation by payer, year, or provider group size. **Medium-sized write-offs ($100–$1,000) account for the largest dollar impact at $2.37M.**

---
<h2 align="center">Insights Deep Dive</h2>

## Executive Performance

### Net Collection Rate

<p align="center">
  <img src="net_collection_rate.png" alt="Net Collection Rate" width="900">
</p>

- ClearAxis collected **$407.4M of $465.8M** in net collectible revenue, producing a **Net Collection Rate of 87.45%**.

- The rate is **7.55% below the 95% benchmark**, representing approximately **$58.4M in unrealized collectible revenue**.

- At the 95% benchmark, the same revenue base would generate approximately **$35.2M more in annual collections**.

- This performance gap prompted a deeper investigation into **denial exposure and permanent write-offs**.

### Revenue Disposition Overview

**Visualization:** `revenue_summary` — diverging bar chart

- **$407M** of net collectible revenue was collected, representing the **87.45% Net Collection Rate**.

- **$298M** in denied or appealed claims remains at risk, measured at charge amount.

- **$142M** remains in pending or void status and has not yet been classified as permanently lost.

- **$4.26M** was permanently written off. These figures use different revenue bases and **should not be summed as additive components**.

## Payer & Denial Performance

### Denied Revenue by Payer Type

**Visualization:** `denied_revenue_by_payer_type` — horizontal bar chart with denial rate labels

- Medicaid has the highest denied revenue at **$53M**, followed by Tricare ($48M) and Medicare ($43M).

- Denial rates are nearly identical across all seven payer types, ranging from **24% to 25%**.

- Average denied claim values are also consistent at approximately **$2,422–$2,512**.

- The variation in denied revenue is therefore driven primarily by **claim volume, not payer denial behavior**, indicating a systemic operational issue.

### Denial Accountability Analysis

**Visualization:** `provider_vs_payer_split` — vertical bar chart with percentage labels

- **Provider-driven:** $93.6M (**42%**)  
- **Payer-driven:** $93.3M (**42%**)  
- **Shared:** $31.5M (**16%**)

- The near-even split shows that the denial problem cannot be addressed through a single intervention.

- Internal billing and coding improvements must be paired with **payer-side contract, eligibility, and coordination-of-benefits interventions**.

### Appeal Effectiveness & Revenue Recovery

**Visualization:** `overturned_revenue` — horizontal bar chart with recovered revenue labels

- Appeal overturn rates range from **34.26% to 36.99%** across payer types, indicating consistent appeal effectiveness.

- Successful appeals have recovered approximately **$20.6M** across the three-year period.

- Medicaid generated the highest recovery at **$3.84M**, consistent with its higher claim volume.

- The largest opportunity is increasing the **appeal filing rate among eligible denied claims**, rather than targeting a specific payer.

## Write-Off Analysis & Revenue Impact

### Write-Off Trends by Payer Type

**Visualizations:** `writeoffs_payer_type_by_year` — faceted bar chart · `top_writeoffs_by_month` — line chart

- Total write-offs were **$4.26M**, with payer-level totals relatively evenly distributed.

- Write-offs changed by only **-0.28% from 2022 to 2024**, indicating no meaningful improvement or deterioration over the analysis period.

- Write-off rates range from **0.56% to 0.62% across provider group sizes**, showing little evidence that practice size is a major driver.

- Monthly patterns are inconsistent across payers and years, providing **no evidence of a persistent seasonal driver**.

### Write-Off Drivers by Reason

**Visualizations:** `writeoffs_reason` — horizontal bar chart · `timely_filing_heatmap` — month × year heatmap

- The five write-off categories contribute relatively similar amounts, with **Timely Filing highest at $893K (21%)**.

- **Timely Filing is the clearest, directly preventable category**, representing claims submitted after payer deadlines.

- Timely Filing write-offs declined from **$302K in 2022 to $272K in 2024**, a 9.9% reduction.

- No month shows consistently elevated timely filing losses across all three years, indicating a **chronic process issue rather than a seasonal problem**.

### Write-Off Distribution by Amount

**Visualization:** `writeoffs_distribution` — lollipop chart

- Small write-offs (<$100) account for **27,329 transactions but only $516K**, averaging approximately $19 each.

- Medium write-offs ($100–$1,000) generate the greatest dollar impact at **$2.37M across 7,771 transactions**.

- Large write-offs (>$1,000) are less frequent but represent **$1.51M across 838 transactions**, averaging $1,801 each.

- **Medium balances represent the strongest collection opportunity**, while small balances may be better suited to automated write-off policies.

---

<h2 align="center">Recommendations</h2>

| Priority | Action | Team | Success Metric |
|---|---|---|---|
| **P0** | **Implement 30-day submission monitoring** to flag claims approaching payer timely filing deadlines. | Billing Operations | Timely filing write-off amount |
| **P0** | **Launch a systematic appeal program** for eligible denied claims, prioritizing provider-driven denial codes. | Revenue Cycle · Appeals | Appeal filing rate · Overturn rate |
| **P0** | Run a **dual-track denial reduction initiative** addressing internal billing errors and payer-side disputes. | Coding · Billing · Payer Contracting | Net Collection Rate · Denial rate by accountability |
| **P1** | Establish a **dedicated workflow for $100–$1,000 balances** before write-off decisions are made. | AR Management | Medium write-off amount · Recovery rate |
| **P1** | **Automate handling of balances below $100** to reduce low-value collection effort. | AR Management · Finance | Staff hours per dollar recovered |
| **P2** | **Investigate the $858K classified as “Unknown”** and strengthen write-off reason documentation. | Revenue Cycle · Compliance | Unknown write-off % of total |

---
<h2 align="center">Technical Details</h2>
> **Explore the project:** [View SQL Analysis & Tableau Visualizations](#)

### Tools & Technologies

- **Database:** Microsoft SQL Server 2022 Express — data loading, cleaning, transformation, and analysis
- **Visualization:** Tableau Public — analytical dashboards and visualizations
- **Version Control:** GitHub — SQL scripts, documentation, and project files

### Project Files

| Resource | Link |
|---|---|
| SQL Cleaning Scripts | *Add GitHub link* |
| SQL Analysis Queries | *Add GitHub link* |
| Tableau Public Dashboard | *Add Tableau Public link* |
| Dataset Guide | *Add file link* |

---
<h2 align="center">Clarifying Questions, Assumptions & Caveats</h2>

### Data Quality & Methodology

- **Date inconsistencies:** Service, submission, and payment dates contained multiple formats and incorrect year entries. Clean DATE fields were created and invalid records flagged during transformation.

- **Duplicate claim IDs:** Approximately 2% of claim IDs contained formatting variants such as lowercase or hyphenated values. IDs were standardized, and duplicate records were excluded from analysis.

- **Appeal date anomalies:** 49,072 denial records contained inconsistent date sequences. The analysis retains valid denial-to-appeal sequences to avoid the systematic exclusion of successful appeals.

- **Missing and inconsistent fields:** Missing place-of-service names, inconsistent gender values, and NULL denial codes were standardized using deterministic transformation rules.

### Assumptions & Stakeholder Questions

- **Net collectible revenue:** Defined as charge amount less contractual adjustments from `fact_payments`, representing revenue considered realistically collectible.

- **Denied revenue at risk:** Includes both Denied and Appealed claims measured at `charge_amount`, since `allowed_amount` may be unavailable for claims that were never adjudicated.

- **Write-off classification:** The $858K “Unknown” category requires stakeholder clarification to determine whether the issue reflects missing documentation, inconsistent workflows, or a data capture gap.

- **Operational validation:** Stakeholders should confirm whether the decline in timely filing write-offs reflects a specific operational initiative and whether post-churn claims represent legitimate late submissions or a data pipeline issue.



