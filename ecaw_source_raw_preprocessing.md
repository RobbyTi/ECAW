---
title: "Data preprocessing: source data to raw data"
author: "Marton Kovacs"
output: html_document
date: "2023-03-17"
editor_options: 
  chunk_output_type: console
---



# Load source data


```r
source <- readr::read_csv(here("data/source/ecaw_221102_source_data.csv"))
```

```
## Rows: 154 Columns: 32
## ── Column specification ──────────────────────────────────────────────────────────────────
## Delimiter: ","
## chr (32): StartDate, EndDate, Status, Progress, Duration (in seconds), Finished, Recor...
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

# Clean variable names


```r
source <- janitor::clean_names(source)
```

# Removing Qualtrics labels


```r
label <-
  source %>% 
  slice(1:2)

source <-
  source %>% 
  slice(-(1:2))
```

# Creating a simple codebook


```r
codebook <-
  label %>% 
  slice(1) %>% 
  pivot_longer(cols = everything(), names_to = "original_var_name", values_to = "description") %>% 
  mutate(
    new_var_name = case_when(
      original_var_name == "q3_1_1"       ~ "typically_trustworthy",
      original_var_name == "q3_1_2"       ~ "typically_reproducible",
      original_var_name == "q4_1_1"       ~ "method_preregistered",
      original_var_name == "q4_1_2"       ~ "method_blind",
      original_var_name == "q4_1_3"       ~ "method_script",
      original_var_name == "q4_1_4"       ~ "method_confirmatory",
      original_var_name == "q4_1_5"       ~ "method_exploratory",
      original_var_name == "q8_1_1"       ~ "ecaw_trustworthy",
      original_var_name == "q8_1_2"       ~ "ecaw_reproducible",
      original_var_name == "q9_1_1"       ~ "alspac_less_willing",
      original_var_name == "q9_1_2"       ~ "alspac_opt_in",
      original_var_name == "q9_1_3"       ~ "alspac_study",
      original_var_name == "q9_1_4"       ~ "alspac_prefer_ecaw",
      original_var_name == "q9_2"         ~ "unsure_explain",
      original_var_name == "q10_1"        ~ "drawback_ecaw",
      original_var_name == "q10_2"        ~ "suggestions",
      original_var_name == "q10_3"        ~ "contact",
      original_var_name == "q11_1_1"      ~ "concerned",
      original_var_name == "q11_2"        ~ "n_studies",
      original_var_name == "q11_3"        ~ "programming_language",
      original_var_name == "q11_3_5_text" ~ "programming_language_other",
      original_var_name == "q11_4"        ~ "comments",
      TRUE ~ original_var_name
      )
    )

# Save the codebook
readr::write_csv(codebook, here("data/source/ecaw_221102_source_codebook.csv"))
```

# Variable renaming

We are assigning the new variable names to the source data table using the codebook.


```r
colnames(source) <- dplyr::recode(
  colnames(source), 
  !!!setNames(as.character(codebook$new_var_name), codebook$original_var_name)
)
```

# Save raw dataset


```r
readr::write_csv(source, here("data/raw/ecaw_raw_data.csv"))
```

