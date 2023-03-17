---
title: "Data preprocessing: raw data to processed data"
author: "Marton Kovacs"
output: html_document
date: "2023-03-17"
editor_options: 
  chunk_output_type: console
---



# Load raw data


```r
raw <- readr::read_csv(here("data/raw/ecaw_raw_data.csv"))
```

Before any exclusions we had 152 responses in the dataset.

# Exclusions
## Test data

The survey was sent out on 2022/10/10 to the participants. Thus, any responses in the dataset before that data are coming from the testing of the survey. These responses will be excluded from further analysis. We excluded 18 test responses. 


```r
raw <-
  raw %>% 
  dplyr::filter(lubridate::as_date(start_date) >= lubridate::as_date("2022-10-10"))
```

## Partial responses

We only include full responses in the final analysis as preregistered (see the full text of the preregistration [https://osf.io/g2fw5](https://osf.io/g2fw5)). There were 27 respondents who did not finish the survey.


```r
raw <- 
  raw %>% 
  dplyr::filter(finished)
```

At the end of the exclusion we had 107 responses remaining for the analysis.

It was optional to answer all of the questions in our survey, so it is possible to have missing responses even if the respondent finished the survey. We will keep these responses.


```r
raw <-
  raw %>% 
    # dropping those questions that were open ended or conditional on other responses or irrelevant
    # flag those responses that has any missing values
    mutate(
      has_missing = case_when(
        if_any(
          c(
            -start_date,
            -end_date,
            -status,
            -progress,
            -duration_in_seconds,
            -finished,
            -recorded_date,
            -distribution_channel,
            -user_language,
            -programming_language_other,
            -unsure_explain,
            -drawback_ecaw,
            -suggestions,
            -comments
            ),
          .fns = is.na) ~ TRUE,
        TRUE ~ FALSE
        )
      )
```

There were 21 respondents who had at least one missing value in the main questions of interests.

# Distribution of completition time

On median it took 7.2166667 to finish the survey to the participants in hour sample.


```r
# We will only need the duration in minutes for the main analysis so we calculate it here
raw <-
  raw %>% 
  mutate(duration_in_mins = duration_in_seconds / 60)

raw %>% 
  ggplot() +
  aes(x = duration_in_mins) +
  geom_histogram() +
  labs(
    x = "Response duration in minutes",
    y = "Count"
  )
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)

# Delete not used variables


```r
raw <-
  raw %>% 
  select(
    - start_date,
    - end_date,
    - status,
    - progress,
    - finished,
    - duration_in_seconds,
    - recorded_date,
    - distribution_channel,
    - user_language
  )
```

# Exploring the number of responses to open-ended questions

The survey contained 4 open-ended questions (*unsure_explain*, *drawback_ecaw*, *suggestions*, *comments*) that we analyzed qualitatively as preregistered (see page X line Y of the preregistration).

Here, we calculate the number of responses for each open ended question.


```r
raw %>% 
  select(unsure_explain, drawback_ecaw, suggestions, comments) %>% 
  # convert to long format
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "response",
  ) %>% 
  # flag missing responses
  mutate(is_na = is.na(response)) %>%
  # count missing responses per variables
  count(variable, is_na) %>% 
  # keep only complete responses
  filter(!is_na)
```

```
## # A tibble: 4 × 3
##   variable       is_na     n
##   <chr>          <lgl> <int>
## 1 comments       FALSE     5
## 2 drawback_ecaw  FALSE    41
## 3 suggestions    FALSE    19
## 4 unsure_explain FALSE    27
```

# Categorizing free-text responses

In some cases respondents had the option to provide free-text responses in case they choose the _Other_ option in a multiple-choice question. We will categorize these responses manually.


```r
# prepearing free-text responses for manual rating
# this part of the code is commented out not to overwrite the manual grouping
# raw %>%
#   select(response_id, programming_language_other) %>%
#   dplyr::filter(!is.na(programming_language_other)) %>%
#   mutate(group_mk = NA_character_) %>%
#   rename(programming_language_to_group = programming_language_other) %>%
#   write_xlsx(., here("data/raw/ecaw_free_text_grouping_data.xlsx"))

# processing grouped responses
raw <-
  # joining free-text responses to the data table
  left_join(
    raw,
    # reading manually grouped free-text responses
    readxl::read_xlsx(here("data/raw/ecaw_free_text_grouping_data.xlsx")),
    by = "response_id"
  ) %>% 
  # replacing "Other (please describe)" text in response with grouped response
  mutate(
    programming_language  = stringr::str_replace(programming_language, "Other \\(please describe\\)", group_mk)
  ) %>% 
  # drop not needed variables
  select(
    - programming_language_other,
    - programming_language_to_group,
    - group_mk)
```

# Creating a simple codebook

For creating the codebook we will use the codebook created for the source data.


```r
codebook <-
  read_csv(here("data/source/ecaw_221102_source_codebook.csv")) %>% 
  select(-original_var_name) %>% 
  rename(var_name = new_var_name) %>% 
  filter(var_name %in% colnames(raw))

# Save the codebook
readr::write_csv(codebook, here("data/raw/ecaw_raw_codebook.csv"))
```

# Save processed dataset


```r
readr::write_csv(raw, here("data/processed/ecaw_processed_data.csv"))
```
