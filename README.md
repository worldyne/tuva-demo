# Oncology Population Cost Analysis

## Project Abstract

This project profiled costs across care settings to identify savings and outcomes opportunities for oncology patients using the [Tuva Project](https://thetuvaproject.com/) healthcare data framework. Cancer is defined by the ICD 10 codes for Neoplasms.

---

## Population Summary

| Metric | Value |
|--------|-------|
| Total Patients | 475 |
| Total Paid | $8.78M |
| Total Claims | 68,842 |
| Avg Paid per Patient | $18,490 |
| Avg Paid per Claim | $127.58 |
| Avg Claims per Patient | 145 |

---

## Key Insights

### Cost by Care Setting

**Acute inpatient** reflects the highest cost at an average of $10,568/patient, around 4x higher than the next category.


**Pharmacy costs** are also notable with regards to claims — outpatient pharmacy alone averages **$987/claim** (highest per-claim cost after inpatient pharmacy at $1,708/claim).

### Spend Distribution by Cancer Type

**Benign Neoplasms** drive the highest total costs, accounting for over **$4.4M** (50%+ of total spend):



### High Cost Patients

The top 3 highest-cost patients (>$100K each) were all categorized as **Benign Neoplasms**, suggesting potential opportunities for:
- Care management optimization
- Outcomes evaluation
- Medical economics analysis

### Key Observations

1. **Benign ≠ Low Cost**: Despite being non-malignant, benign neoplasm patients incur the highest costs, likely due to chronic monitoring and procedures. There should be a re-evaluation on the cost structure and care provided.
2. **Pharmacy is a cost driver**: Cross-setting pharmacy costs ($1.2M total) represent a significant portion of spend
3. **Lab utilization is high**: 474 of 475 patients (99.8%) had lab claims, averaging $1,800/patient
4. **ED usage is relatively low-cost**: Emergency department averages only $400/patient

### AI Utilization

AI was used to rapidly prototype and accelerate the development of the oncology_analysis.ipynb file for data analysis and aggregation. I mainly steered the AI to resolve how it improperly filled gaps with Nulls instead of investigating the full dataset to find more effective ways to impute. I also used AI to get a sitrep of the repository so I could quickly find the key resources and undestand the base state of the data.










## Setup Steps Below

















[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![dbt logo and version](https://img.shields.io/static/v1?logo=dbt&label=dbt-version&message=1.5.x&color=orange)

# The Tuva Project Demo

## 🧰 What does this project do?

This demo provides a quick and easy way to run the Tuva Project 
Package in a dbt project with synthetic data for 1k patients loaded as dbt seeds.

To set up the Tuva Project with your own claims data or to better understand what the Tuva Project does, please review the ReadMe in [The Tuva Project](https://github.com/tuva-health/the_tuva_project) package for a detailed walkthrough and setup.

For information on the data models check out our [Docs](https://thetuvaproject.com/).

## ✅ How to get started

### Pre-requisites
You only need one thing installed:
1. [uv](https://docs.astral.sh/uv/getting-started/) - a fast Python package manager. Installation is simple and OS-agnostic:
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
   Or on Windows:
   ```powershell
   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

**Note:** This demo uses DuckDB as the database, so you don't need to configure a connection to an external data warehouse. Everything is configured and ready to go!

### Getting Started
Complete the following steps to run the demo:

1. [Clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) this repo to your local machine or environment.
2. In the project directory, install Python dependencies and set up the virtual environment:
   ```bash
   uv sync
   ```
3. Activate the virtual environment:
   ```bash
   source .venv/bin/activate  # On macOS/Linux
   # or on Windows:
   .venv\Scripts\activate
   ```
4. Run `dbt deps` to install the Tuva Project package:
   ```bash
   dbt deps
   ```
5. Run `dbt build` to run the entire project with the built-in sample data:
   ```bash
   dbt build
   ```

The `profiles.yml` file is already included in this repo and pre-configured for DuckDB, so no additional setup is needed!

### Using uv commands
You can also run dbt commands directly with `uv run` without activating the virtual environment:
```bash
uv run dbt deps
uv run dbt build
```

## 🤝 Community

Join our growing community of healthcare data practitioners on [Slack](https://join.slack.com/t/thetuvaproject/shared_invite/zt-16iz61187-G522Mc2WGA2mHF57e0il0Q)!
