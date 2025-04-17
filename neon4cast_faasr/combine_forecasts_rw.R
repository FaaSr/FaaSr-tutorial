combine_forecasts_rw <- function(folder, input_oxygen, input_temperature, output_file) {
  # Combine oxygen and temperature forecasts
  
  # Load required libraries
  library(tidyverse)
  library(glue)
  
  # Download the forecast files
  faasr_get_file(remote_folder = folder, remote_file = input_oxygen, local_file = "oxygen_fc_rw.csv")
  faasr_get_file(remote_folder = folder, remote_file = input_temperature, local_file = "temperature_fc_rw.csv")
  
  # Read the forecasts
  oxygen_fc <- read_csv("oxygen_fc_rw.csv")
  temperature_fc <- read_csv("temperature_fc_rw.csv")
  
  # Convert both to character to ensure compatibility
  oxygen_fc$parameter <- as.character(oxygen_fc$parameter)
  temperature_fc$parameter <- as.character(temperature_fc$parameter)
  
  # For a more robust solution, ensure all common columns have the same type
  common_cols <- intersect(names(oxygen_fc), names(temperature_fc))
  for (col in common_cols) {
    # Convert both to character if they're different types
    if (!identical(class(oxygen_fc[[col]]), class(temperature_fc[[col]]))) {
      oxygen_fc[[col]] <- as.character(oxygen_fc[[col]])
      temperature_fc[[col]] <- as.character(temperature_fc[[col]])
    }
  }
  
  # Combine the forecasts
  forecast <- bind_rows(oxygen_fc, temperature_fc)
  
  # Generate the output filename following EFI naming conventions
  forecast_file <- "rw_forecast_combined.csv"
  write_csv(forecast, forecast_file)
  
  # Create the properly named file for EFI submission
  efi_filename <- glue::glue("aquatics-{date}-benchmark_rw.csv.gz",
                             date = Sys.Date())
  write_csv(forecast, efi_filename)
  
  # Upload both files to S3
  faasr_put_file(local_file = forecast_file, remote_folder = folder, remote_file = output_file)
  faasr_put_file(local_file = efi_filename, remote_folder = folder, remote_file = efi_filename)
  
  # Log message
  log_msg <- paste0('Function combine_forecasts_rw finished; outputs written to folder ', folder, ' in default S3 bucket')
  faasr_log(log_msg)
}
