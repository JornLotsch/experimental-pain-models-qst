# Quantitative Sensory Testing and Experimental Pain Models Dataset - Data Preparation Pipeline

## Publication Reference

**A small yet comprehensive subset of human experimental pain models emerging from correlation analysis with a clinical quantitative sensory testing protocol in healthy subjects**

Lötsch J, Dimova V, Ultsch A, Lieb I, Zimmermann M, Geisslinger G, Oertel BG. 
*Eur J Pain.* 2016 May;20(5):777-89. doi: 10.1002/ejp.803

**Dataset:** Lotsch, Jorn; Dimova, Violeta (2026), “Quantitative sensory testing and classical pain model dataset in 127 healthy volunteers”, Mendeley Data, V2, doi: 10.17632/9v8ndhctvz.2

## Overview

This repository contains R code to prepare pain threshold measurements from 127 healthy volunteers under control (untreated) conditions for publication on Mendeley Data. The script transforms raw data into three publication-ready CSV files: demographic metadata, original measurements, and log-transformed measurements.

## Data Preparation

This script prepares pain threshold measurements from 127 healthy volunteers for publication on Mendeley Data, producing three CSV files:

- `qst_pain_metadata.csv` - Demographic information
- `qst_pain_data_orig.csv` - Original pain measurements  
- `qst_pain_data_transformed.csv` - Log-transformed measurements

## Transformations

The script applies the following transformations to prepare data for publication:

1. **Sign Inversion** - Multiplies selected variables by -1 to align direction (higher values = lower pain sensitivity)
   - Variables: TSACold, CO2VAS, LaserVAS, CDT, CPT, MPS, WUR, VDT, DMA

2. **Unit Conversion** - Converts pressure measurements to kilopascals (Newton/cm² × 10)
   - Variables: PressureThr, PressureTol

3. **Logarithmic Transformation** - Applies base-10 log to normalize distributions
   - Formula: `log₁₀(x - min(x) + 1)` for all pain measures
   - Implements Weber-Fechner law and reduces right-skewness

4. **Data Alignment** - Creates three coordinated output files with verified ID alignment

## Requirements

**R:** Version 4.0+  
**Packages:** `readxl`

```r
install.packages("readxl")
```

## Usage

1. **Update paths in script:**
   - `INPUT_FILE_PATH`: Path to source Excel file
   - `OUTPUT_DIR`: Where to save CSV files

2. **Run:**
   ```bash
   Rscript R/prepare_pain_dataset.R
   ```
   Or from R/RStudio: `source("R/prepare_pain_dataset.R")`

## Data Quality

Complete data for all 127 participants. No missing values.

## Reproducibility

All transformations are deterministic (no random processes):
- Running the script multiple times with identical input data produces identical output files
- Seed-based reproducibility is not necessary as no stochastic operations are employed
- All transformations are fully documented in the console output and script comments

## Data Availability

The complete dataset is available on **Mendeley Data** (V2, doi: 10.17632/9v8ndhctvz.2)

The data preparation and dataset are described in detail in the accompanying paper published in *Data in Brief* (Elsevier).

## Citation

Please cite the accompanying paper in *Data in Brief*:

Lötsch J, Dimova V, Ultsch A, Lieb I, Zimmermann M, Geisslinger G, Oertel BG.
A small yet comprehensive subset of human experimental pain models emerging from correlation analysis with a clinical quantitative sensory testing protocol in healthy subjects.
*Eur J Pain.* 2016 May;20(5):777-89. doi: 10.1002/ejp.803

## License

CC-BY 4.0

---
**Mendeley Data:** https://data.mendeley.com/datasets/9v8ndhctvz/2  
**Original Article:** Eur J Pain. 2016;20(5):777-89. doi: 10.1002/ejp.803
