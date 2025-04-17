In this part, we will download and process the target data for aquatics in order to create forecast for different variables from the target data.

### Install the development version of neon4cast
```
install.packages("tidyverse")
install.packages("fable")
install.packages("tsibble")
install.packages("remotes")
remotes::install_github("eco4cast/neon4cast")
```
###  Load required libraries

```
library(neon4cast)
library(tidyverse)
library(fable)
library(tsibble)
```

### Download and process the target data for aquatics

```
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
```


### Create forecasts

```
# A simple random walk forecast, see ?fable::RW
oxygen_fc <- blinded_aquatic %>%
  model(benchmark_rw = RW(oxygen)) %>%
  forecast(h = "35 days") %>%
  efi_format()

## also use random walk for temperature
temperature_fc <- blinded_aquatic  %>% 
  model(benchmark_rw = RW(temperature)) %>%
  forecast(h = "35 days") %>%
  efi_format_ensemble()


```

### Combine forecasts and export file to local

```
# stack into single table
forecast <- bind_rows(oxygen_fc, temperature_fc) 

## Write the forecast to a file following EFI naming conventions:
forecast_file <- glue::glue("{theme}-{date}-{team}.csv.gz",
                            theme = "aquatics", 
                            date=Sys.Date(),
                            team = "benchmark_rw")
write_csv(forecast, forecast_file)
```
