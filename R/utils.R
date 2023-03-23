#' Function to NOT include a vector in another vector
`%ni%` <- Negate(`%in%`)

#' Calculate the number of levels of a factor
n_levels <- function(var) length(levels(var))

#' Get the center level of a factor
center_level <- function(var) (n_levels(var) - 1) / 2 + 1

#' Calculate the percentage of responses of each factor level
level_percentage <- function(data, var, levels, exclude = NULL, exclude_missing = TRUE) {
  res <-
    data %>%
    filter(
      # Exclude specified answer option(s)
      {{ var }} %ni% exclude
    )

  # Exclude missing responses
  if (exclude_missing) {
    message(paste(nrow(filter(data, is.na({{ var }}))), "missing values were excluded."))
    res <-
      res %>%
      filter(!is.na({{ var }}))
  }

  res %>%
    # Replace missing values with explicit text
    mutate(
      # Replace missing values with explicit text
      {{ var }} := replace_na({{ var }}, "Missing"),
      # Transform to factor with level order specified in levels arg
      {{ var }} := factor({{ var }}, levels = levels)
    ) %>%
    # Count the number of response on each factor level
    count({{ var }}) %>%
    # Add n = 0 if no one choose a specific factor level
    tidyr::complete({{ var }}, fill = list(n = 0)) %>%
    mutate(
      # Assign level id to each factor level in increasing order
      levels_int = as.integer({{ var }}),
      # Calculate the number of all responses
      n_sum = sum(n),
      # Calculate the percentage for all factor level and round
      percentage = round(n / n_sum * 100)
    ) %>%
    # Reorder variables for cleaner output
    select(levels_int, {{ var }}, n, n_sum, percentage)
}

#' Calculate percentage for each support category
support_percentage <- function(data, var, levels, exclude = NULL, exclude_missing = TRUE) {
  # Calculate the percentage of responses of each factor level
  level_percentage(data, {{var}}, levels, exclude = exclude, exclude_missing = exclude_missing) %>% 
    # Drop these variables
    select(-n_sum, -percentage) %>% 
    mutate(
      # Get center level id
      center_level = center_level({{var}}),
      # Assign support to each level
      support = case_when(levels_int < center_level ~ "negative",
                          levels_int ==  center_level ~ "neutral",
                          levels_int > center_level ~ "positive",
                          TRUE ~ NA_character_)
    ) %>%
    group_by(support) %>%
    # Calculate the sum of responses by support levels
    summarise(n = sum(n)) %>% 
    ungroup() %>% 
    mutate(
      # Calculate the number of all responses
      n_sum = sum(n),
      # Calculate percentage of support levels
      percentage = round(n / n_sum * 100)
      )
}
