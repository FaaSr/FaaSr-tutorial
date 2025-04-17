get_target_data <- function(folder, output_target, output_blinded) {
  # Download and process the target data for aquatics
  
  # Load required libraries
  library(neon4cast)
  library(tidyverse)
  library(tsibble)
  
  # Download target data
  target <- read_csv("https://data.ecoforecast.org/neon4cast-targets/aquatics/aquatics-targets.csv.gz")
  
  # Process data
  aquatic <- target %>% 
    pivot_wider(names_from = "variable", values_from = "observation") %>%
    as_tsibble(index = datetime, key = site_id)
  
  # Save the full dataset
  write_csv(aquatic %>% as_tibble(), "aquatic_full.csv")
  
  # Create blinded dataset (drop last 35 days)
  blinded_aquatic <- aquatic %>%
    filter(datetime < max(datetime) - 35) %>% 
    fill_gaps()
  
  # Save the blinded dataset
  write_csv(blinded_aquatic %>% as_tibble(), "blinded_aquatic.csv")
  
  # Upload both files to S3
  faasr_put_file(local_file = "aquatic_full.csv", remote_folder = folder, remote_file = output_target)
  faasr_put_file(local_file = "blinded_aquatic.csv", remote_folder = folder, remote_file = output_blinded)
  
  # Log message
  log_msg <- paste0('Function get_target_data finished; outputs written to folder ', folder, ' in default S3 bucket')
  faasr_log(log_msg)
}