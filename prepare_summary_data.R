library(DBI)
library(RSQLite)
library(dplyr)

source_db_path <- "/sc/arion/projects/AsgariLab/RechumaHafter/gwas_data_v2.sqlite"
output_dir <- "shiny_frontend/summary_data"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
con <- dbConnect(RSQLite::SQLite(), source_db_path)
all_tables <- dbListTables(con)
for (table_name in all_tables) {
  message("Processing summary for: ", table_name)
  
  query <- sprintf("SELECT * FROM `%s` WHERE `P_value` < 1e-5", table_name)
  full_table <- dbGetQuery(con, paste0("SELECT * FROM `", table_name, "`"))
  full_table$P_value <- as.numeric(as.character(full_table$P_value))
  significant_hits <- full_table %>% 
    filter(P_value < 1e-5) %>%
    arrange(P_value)
  if (nrow(significant_hits) > 0) {
    saveRDS(significant_hits, file.path(output_dir, paste0(table_name, "_summary.rds")))
  }
}
dbDisconnect(con)
message("\n--- Summary data preparation complete. ---")
