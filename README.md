# OPPO Brazil Market Analysis

Preliminary analysis of Brazil's smartphone and related smart terminal import market for OPPO, based on customs data and public market sources.

## Project Objective

This project supports an initial assessment of:
- Brazil's smartphone and related smart terminal import structure
- Active brands, companies, and supply chains
- Major source countries and exporters
- Potential Brazilian importers, distributors, and channel partners
- Product and price segment opportunities for OPPO

## Data Scope

- Time range: `2024–2026 YTD`
- Destination market: `Brazil`
- Main HS codes used:
  - `851713` — smartphones
  - `847130` — tablets / portable computing devices
  - `851830` — earphones / headset accessories
  - `851779` — telecom/device-related components

## Project Structure

- `do/` — Stata cleaning and analysis scripts
- `docs/` — report drafts and notes
- `output/summary/` — cleaned summary tables used in the report
- `metadata/` — data dictionary and field notes

## Workflow

1. `round1_clean.do`
   - Imports raw export files
   - Standardizes column names
   - Creates basic tags and quality flags

2. `round2_clean.do`
   - Applies product/category filters
   - Separates devices, accessories, and components
   - Builds brand and supply-chain grouping logic

3. `round3_report_ready.do`
   - Removes grey-pool records from main reporting views
   - Generates report-ready summary outputs
   - Produces brand, country, price-band, and supply-chain summaries

## Notes on Interpretation

- Customs import price is **not** the same as retail market price.
- Some records are grouped under `NONE` or unidentified entities; these were separated from the main reporting scope where possible.
- Some brand presence may be understated in customs data because imports may pass through distributors, ODMs, or affiliated supply-chain entities rather than brand-named legal entities.

## Main Preliminary Findings

- China is the dominant source country for smartphones and related terminals imported into Brazil.
- Vietnam is the second most important source location, especially in Samsung-related and selected accessory/device supply chains.
- Apple leads identified smartphone import value.
- Xiaomi is the most active identified Chinese consumer smartphone brand in the dataset.
- Samsung and Motorola remain key competitive references, though customs entity mapping may understate their full market presence.
- OPPO-related activity appears through `HeyTap Pte. Ltd.`, suggesting at least limited market-entry or channel-testing activity.
- In components, four major supply-chain clusters are visible:
  - Samsung Chain
  - Apple/Foxconn Chain
  - Motorola/ODM Chain
  - Huawei/ZTE Chain

## Channel Observations

Based on the identified `851713` importer/exporter tracking data, Brazil's smartphone channel structure appears to include:
- Brand-led local legal entity imports
- Distributor / trade-company-led consumer electronics imports
- Duty-free and retail-oriented imports
- Small-scale special-use imports (medical, industrial, offshore, project-based)

Potentially relevant consumer-electronics-oriented Brazilian entities include:
- `GRUPO MULTI S.A.`
- `DL COMERCIO E INDUSTRIA DE PRODUTOS ELETRONICOS LTDA`
- `INOVIVO COMERCIO E IMPORTACAO DE EQUIPAMENTOS ELETRONIC`
- `VALUE TRADE COMERCIAL IMPORTADORA E EXPORTADORA LTDA`
- `INFORCELL ...`

## Reproducibility

This repository is intended to preserve:
- Cleaning logic
- Analysis logic
- Report-ready summarized outputs

Raw customs exports are not included by default.

## Disclaimer

This repository contains research workflow materials and summary outputs only.  
Please verify licensing, confidentiality, and data-sharing permissions before publishing raw customs data.
