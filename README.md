# ClearAxis Health (RCM) Revenue Cycle Management Analytics
<p align="center">
  <img src="clearaxis_logo.png" alt="ClearAxis Health — Revenue Cycle Intelligence" width="450">
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

| Business Question | North Star Metric | Key Finding |
|---|---|---|
| **Main: Is ClearAxis collecting efficiently?** | **Net Collection Rate** | **87.45%** vs. 95% benchmark |
| **Q: Which payers are the biggest problem?** | **Denied Revenue at Risk** | **$298M** across 120,735 claims |
| **Q: What revenue are we giving up?** | **Total Write-Off Amount** | **$4.26M** permanently written off |

### Dataset Overview

The dataset is a 36-month RCM dataset covering **January 2022 through December 2024**. It contains **six relational tables structured as a star schema**, supporting analysis across claims, payments, denials, providers, payers, and patients.

#### Entity Relationship Diagram

<p align="center">
  <img src="clearaxis_erd.png" alt="ClearAxis Health Entity Relationship Diagram" width="1000">
</p>

### Table Descriptions

**`fact_claims` - (500,000 rows)** Core transactional table containing one row per insurance claim submitted. Contains claim status, charge amount, denial codes, clean claim flag, and Days in AR. This is the central fact table from which denial rates, collection efficiency, and billing quality are derived.

**`fact_payments` - (300,000 rows)** One row per payment event linked to a claim. Contains payment amounts, write-off amounts, write-off reasons, contractual adjustments, and posting dates. Serves as the source of truth for revenue actually collected and revenue permanently lost.

**`fact_denials` - (124,685) rows** One row per denial event. Contains denial codes, categories, appeal outcomes, and revenue recovered through appeals. Used for appeal overturn analysis and denial root-cause investigation.

**`dim_providers` - (2,000 rows)** Provider master containing specialty, group size, EHR system, state, onboarding and churn dates, and contract rate. Enables segmentation of claim quality by provider characteristics.

**`dim_payers` - (150 rows)** Payer master containing payer type, contract type, average reimbursement rate, and clearinghouse. Enables segmentation of denial and collection behavior by insurer.

**`dim_patients` - (50,000 rows)** Patient demographic table containing insurance type, state, and secondary coverage flag. Enables patient-level revenue analysis.
