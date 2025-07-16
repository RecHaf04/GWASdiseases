library(DBI)
library(RSQLite)
library(dplyr)

source_db_path <- "/sc/arion/projects/AsgariLab/RechumaHafter/gwas_data_v2.sqlite"
project_dir <- "/sc/arion/projects/AsgariLab/RechumaHafter/gwas_viewer"
output_dir <- file.path(project_dir, "shiny_frontend", "cross_pheno_data")

# Create the output folder if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# --- Main Logic ---
con <- dbConnect(RSQLite::SQLite(), source_db_path)
all_tables <- dbListTables(con)


for (table_name in all_tables) {

    message("\n--- Chunking data for: ", table_name, " ---")
   trait_data <- dbGetQuery(con, sprintf("SELECT Chromosome, Position, MarkerName, P_value FROM `%s`", table_name))
   trait_data_filtered <- trait_data %>%
     dplyr::mutate(P_value = as.numeric(as.character(P_value))) %>%
     dplyr::filter(!is.na(P_value), -log10(P_value) >= 1)
   
   for (chr in unique(trait_data_filtered$Chromosome)) {
     chr_subset <- subset(trait_data_filtered, Chromosome == chr)
     if (nrow(chr_subset) > 0) {
       saveRDS(chr_subset, file.path(output_dir, paste0(table_name, "_chr", chr, ".rds")))
     }
   } 
}

dbDisconnect(con)
message("\n--- CROSS-PHENOTYPE DATABASE CREATION COMPLETE ---")
