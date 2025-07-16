library(plumber)
library(readr)
function(chromosome, position) {
  
  # Get the list of all prepared data files
  data_files <- list.files("api_data", pattern = "\\.rds$", full.names = TRUE)
  results <- list()
  
  for (file_path in data_files) {
    trait_data <- readRDS(file_path)
    snp_row <- subset(trait_data, Chromosome == chromosome & Position == as.numeric(position))
 
       if (nrow(snp_row) > 0) {
      # Extract trait name from filename
      trait_name <- sub("\\.rds$", "", basename(file_path))
      snp_row$Trait <- trait_name
      results[[length(results) + 1]] <- snp_row
    }
  }
  
  if (length(results) > 0) {
    do.call(rbind, results)
  } else {
    # Return an empty data frame if no SNP is found
    data.frame()
  }
}

function(phenoId = "") {
  file_path <- file.path("api_data", paste0(phenoId, "_summary.rds"))
  
  if (!file.exists(file_path)) {
    stop("Summary data not found for this phenotype.")
  }
  
  readRDS(file_path)
}
