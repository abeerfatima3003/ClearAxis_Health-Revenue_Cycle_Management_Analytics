# ClearAxis Health (RCM) Revenue Cycle Management Analytics
<p align="center">
  <img src="clearaxis_logo.png" alt="ClearAxis Health — Revenue Cycle Intelligence" width="900">
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

# Background & Overview

## Company Context

ClearAxis Health is a Revenue Cycle Management (RCM) SaaS platform serving healthcare providers across 15 states. ClearAxis operates as the billing and claims management backbone for physicians, hospitals, clinics, and surgery centers, enabling providers to submit, track, and collect on insurance claims across 150 payer organizations, including Commercial, Medicare, Medicaid, Medicare Advantage, Tricare, Self-Pay, and Workers Compensation.

## Project Goals

As the data analyst embedded with the ClearAxis Finance and Revenue Cycle Operations teams, this analysis was commissioned to answer a single overarching business question:

> **Is ClearAxis Health collecting revenue as efficiently as it should be — and where are the primary sources of revenue loss, delay, and collection risk?**

To answer this, the analysis pursues four specific objectives:

1. **Evaluate collection performance** against the 95% target benchmark for Net Collection Rate.
2. **Identify the primary drivers** of the collection gap, denial patterns, and write-off behavior.
3. **Assess accountability** between provider-side, payer-side, and shared denial causes.
4. **Prioritize actionable recommendations** that Revenue Cycle, Finance, and Operations leadership can act on immediately.
### Key Performance Indicators

The KPIs investigated are:

- **Net Collection Rate**
- **Denied Revenue at Risk**
- **Appeal Overturn Rate**
- **Write-Off Amount**

## Insights & Recommendations

Insights and recommendations are provided across four key areas of the revenue cycle:

- **Collection Efficiency** - Evaluate overall collection performance against the 95% target benchmark and assess the disposition of collectible, collected, denied, written-off, and pending revenue.
- **Denial Management** - Identify payer segments contributing the greatest amount of denied revenue and assess the relative accountability of provider-side, payer-side, and shared denial drivers.
- **Appeal Performance** - Evaluate appeal overturn rates and the amount of revenue recovered through successful appeals to determine the effectiveness of the appeals process.
- **Write-Off Analysis** - Identify the primary drivers of write-offs, payer concentration, write-off amount distribution, and timely filing trends to determine where revenue is being permanently lost.

## Stakeholder Alignment

| Insight Area | Primary Stakeholder(s) | Decision Enabled |
|---|---|---|
| **Net Collection Rate** | CFO · Finance Director | Assess whether revenue is being collected efficiently enough to support financial performance. |
| **Denied Revenue by Payer** | Revenue Cycle Director · Payer Contracting | Identify payer segments that contribute the greatest amount of denied revenue and should be prioritized for intervention. |
| **Denial Accountability** | Revenue Cycle Operations · Coding & Billing | Determine how much denied revenue is attributable to provider-side, payer-side, and shared factors. |
| **Appeal Effectiveness & Revenue Recovery** | Appeals Team · Revenue Cycle Director | Evaluate whether the appeals process is effectively converting denied claims into recovered revenue. |
| **Write-Off Analysis** | Finance · AR Manager · Revenue Cycle Operations | Identify where revenue is being permanently lost and which write-off drivers should be prioritized for corrective action. |
