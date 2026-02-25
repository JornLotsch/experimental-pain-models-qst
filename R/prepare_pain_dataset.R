
############### Libraries ##############################
library(readxl)

############### Constants ##############################
# File paths
INPUT_FILE_PATH <- "/home/joern/Dokumente/QSTSchmerzmodelle/09Originale/Daten_Exp_pain_QST.xlsx"
OUTPUT_DIR <- "/home/joern/Aktuell/QST_DIB/DataSetPublished"

# Variable definitions
PAIN_TESTS_NAMES <- c(
  "PressureThr", "PressureTol", "TSACold", "ElectricThr", "ElectricTol",
  "Co2Thr", "CO2VAS", "LaserThr", "LaserVAS",
  "CDT", "WDT", "TSL", "CPT", "HPT", "PPT", "MPT", "MPS", "WUR", "MDT", "VDT",	"PHS",	"DMA"
)

DEMOGRAPHIC_FACTORS <- c("Alter", "Geschlecht_N_m1", "QST_Areal_N_1h2f", "Seite_Caps_N_1l2r")
DEMOGRAPHIC_FACTORS_ENGLISH <- c("Age", "Sex_m1", "QST_areal_1hand2foot", "Test_side_1r2l")

# Transformation specifications
PAIN_TESTS_TO_INVERT <- c("TSACold", "CO2VAS", "LaserVAS", "CDT", "CPT", "MPS", "WUR", "VDT", "DMA")
NEWTON_TO_KPA_TESTS <- c("PressureThr", "PressureTol")
NEWTON_TO_KPA_FACTOR <- 10

############### Transformation Functions ##############################

#' Round numeric data to specified digits, handling NAs
#' @param data Dataset to round
#' @param digits Number of decimal places (default: 3)
#' @return Rounded dataset
round_numeric_data <- function(data, digits = 3) {
  data[] <- lapply(data, function(x) {
    if (is.numeric(x)) {
      round(x, digits)
    } else {
      x
    }
  })
  return(data)
}

############### Data Processing Functions ##############################

#' Load and prepare QST pain model data
#' @return List containing original and transformed datasets
load_qst_data <- function() {
  # Load original data from Study 4 (QST)
  qst_pain_models <- data.frame(
    read_excel(INPUT_FILE_PATH, sheet = "DatenAnalysiert")
  )

  # Set participant numbers as row names
  rownames(qst_pain_models) <- qst_pain_models$Probanden_Nr

  return(qst_pain_models)
}

#' Apply transformations to align variables to "High number = low sensitivity"
#' @param data Original QST data
#' @return Transformed data
apply_transformations <- function(data) {
  transformed_data <- data

  # Invert specified pain tests (multiply by -1)
  transformed_data[, names(transformed_data) %in% PAIN_TESTS_TO_INVERT] <-
    lapply(
      transformed_data[, names(transformed_data) %in% PAIN_TESTS_TO_INVERT],
      function(x) { -x }
    )

  # Convert Newton/cm² to kilopascal (multiply by 10)
  transformed_data[, names(transformed_data) %in% NEWTON_TO_KPA_TESTS] <-
    lapply(
      transformed_data[, names(transformed_data) %in% NEWTON_TO_KPA_TESTS],
      function(x) { NEWTON_TO_KPA_FACTOR * x }
    )

  # Apply logarithmic transformation
  transformed_data[, names(transformed_data) %in% PAIN_TESTS_NAMES] <-
    lapply(
      transformed_data[, names(transformed_data) %in% PAIN_TESTS_NAMES],
      function(x, mi = min(x, na.rm = TRUE)) {
        log10(x - mi + 1)
      }
    )


  return(transformed_data)
}

#' Create publication-ready datasets
#' @param original_data Original QST data
#' @param transformed_data Transformed QST data
#' @return List of three datasets ready for publication
create_publication_datasets <- function(original_data, transformed_data) {

  # 1. Metadata with English variable names
  metadata <- original_data[, DEMOGRAPHIC_FACTORS, drop = FALSE]
  names(metadata) <- DEMOGRAPHIC_FACTORS_ENGLISH
  # Add participant ID as first column
  metadata <- cbind(ID = rownames(metadata), metadata)
  # Round numeric columns
  metadata <- round_numeric_data(metadata)

  # 2. Original QST data (pain tests only)
  original_pain_data <- original_data[, PAIN_TESTS_NAMES, drop = FALSE]
  # Round numeric data
  original_pain_data <- round_numeric_data(original_pain_data)
  # Add participant ID as first column
  original_pain_data <- cbind(ID = rownames(original_pain_data), original_pain_data)

  # 3. Transformed QST data (pain tests only)
  transformed_pain_data <- transformed_data[, PAIN_TESTS_NAMES, drop = FALSE]
  # Round numeric data
  transformed_pain_data <- round_numeric_data(transformed_pain_data)
  # Add participant ID as first column
  transformed_pain_data <- cbind(ID = rownames(transformed_pain_data), transformed_pain_data)

  return(list(
    metadata = metadata,
    original = original_pain_data,
    transformed = transformed_pain_data
  ))
}

#' Write datasets to CSV files
#' @param datasets List of datasets to write
write_datasets <- function(datasets) {
  # Create output directory if it doesn't exist
  if (!dir.exists(OUTPUT_DIR)) {
    dir.create(OUTPUT_DIR, recursive = TRUE)
  }

  # Write datasets
  write.csv(
    x = datasets$metadata,
    file = file.path(OUTPUT_DIR, "qst_pain_metadata.csv"),
    row.names = FALSE
  )

  write.csv(
    x = datasets$original,
    file = file.path(OUTPUT_DIR, "qst_pain_data_orig.csv"),
    row.names = FALSE
  )

  write.csv(
    x = datasets$transformed,
    file = file.path(OUTPUT_DIR, "qst_pain_data_transformed.csv"),
    row.names = FALSE
  )

  cat("Data files written to:", OUTPUT_DIR, "\n")
  cat("Files created:\n")
  cat("- qst_pain_metadata.csv\n")
  cat("- qst_pain_data_orig.csv\n")
  cat("- qst_pain_data_transformed.csv\n")
}

############### Main Execution ##############################

# Load data
cat("Loading QST data...\n")
qst_original <- load_qst_data()

# Apply transformations
cat("Applying transformations...\n")
qst_transformed <- apply_transformations(qst_original)

# Create publication datasets
cat("Creating publication datasets...\n")
publication_datasets <- create_publication_datasets(qst_original, qst_transformed)

# Verify data alignment
cat("Verifying data alignment...\n")
cat("Metadata dimensions:", dim(publication_datasets$metadata), "\n")
cat("Original data dimensions:", dim(publication_datasets$original), "\n")
cat("Transformed data dimensions:", dim(publication_datasets$transformed), "\n")

# Check if participant IDs match across all datasets
id_match <- all(
  publication_datasets$metadata$ID == publication_datasets$original$ID,
  publication_datasets$original$ID == publication_datasets$transformed$ID
)
cat("Participant IDs aligned across datasets:", id_match, "\n")

# Write datasets
cat("Writing datasets to files...\n")
write_datasets(publication_datasets)

############### Transformation Documentation ##############################

cat("\n=== TRANSFORMATION SUMMARY FOR SCIENTIFIC REPORT ===\n")
cat("Data preprocessing involved the following transformations:\n\n")

cat("1. SIGN INVERSION (to align with 'high value = low sensitivity'):\n")
cat("   Variables inverted (multiplied by -1):\n")
for (var in PAIN_TESTS_TO_INVERT) {
  cat("   -", var, "\n")
}

cat("\n2. UNIT CONVERSION:\n")
cat("   Newton/cm² to kilopascal conversion (multiplied by 10):\n")
for (var in NEWTON_TO_KPA_TESTS) {
  cat("   -", var, "\n")
}

cat("\n3. LOGARITHMIC TRANSFORMATION:\n")
cat("   Applied to all pain test variables using base-10 logarithm:\n")
cat("   Formula: log₁₀(x - min(x) + 1)\n")
cat("   This transformation:\n")
cat("   - Shifts values to ensure all are positive before log transformation\n")
cat("   - Reduces skewness in the data distribution\n")
cat("   - Handles minimum values appropriately by adding 1\n")
cat("   Variables transformed:\n")
for (var in PAIN_TESTS_NAMES) {
  cat("   -", var, "\n")
}

cat("\n4. DATA STRUCTURE:\n")
cat("   All datasets include 'ID' as the first column for alignment\n")
cat("   Metadata contains demographic variables with English names\n")
cat("   Original and transformed datasets contain only pain test measurements\n")


############### Data set statistics ##############################

# Dimensions
lapply(publication_datasets, dim)
psych::describe(publication_datasets$metadata$Age)
table(publication_datasets$metadata$Sex_m1)

# Missings
lapply(publication_datasets, function(x) sum(is.na(x)) )
mapply(`/`, lapply(publication_datasets, function(x) sum(is.na(x)) ) , lapply(publication_datasets, function(x) prod(dim((x)))) ) * 100
lapply(publication_datasets, function(x) sum(complete.cases(x)) )
