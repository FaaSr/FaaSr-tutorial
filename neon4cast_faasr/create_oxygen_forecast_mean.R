create_oxygen_forecast_mean <- function(folder, input_file, output_file) {
  # Create oxygen forecast using random walk model
  
  # Load required libraries
  library(neon4cast)
  library(tidyverse)
  library(fable)
  library(tsibble)
  
  # Download the blinded dataset
  faasr_get_file(remote_folder = folder, remote_file = input_file, local_file = "blinded_aquatic.csv")
  
  # Read the dataset and convert to tsibble
  blinded_aquatic <- read_csv("blinded_aquatic.csv") %>%
    as_tsibble(index = datetime, key = site_id)
  
  # Create oxygen forecast
  oxygen_fc_mean <- blinded_aquatic %>%
    model(benchmark_mean = MEAN(oxygen)) %>%
    forecast(h = "35 days") %>%
    efi_format()
  
  # Save the forecast
  write_csv(oxygen_fc, "oxygen_fc_mean.csv")
  
  # Upload the forecast to S3
  faasr_put_file(local_file = "oxygen_fc_mean.csv", remote_folder = folder, remote_file = output_file)
  
  # Log message
  log_msg <- paste0('Function create_oxygen_forecast_mean finished; output written to ', folder, '/', output_file, ' in default S3 bucket')
  faasr_log(log_msg)
}
