library('f1dataR')
library('tidyverse')


# Driver data
driver_lookup <- readRDS("data/drivers_2024.rds")

# Get lap data
race_laps <- f1dataR::load_laps(round = 2)


show_lap_stats <- function(data, fastest, drop_laps = NULL) {
  step1 <- data
  
  if(!is.null(drop_laps)) {
    step1 <- step1 %>%
      filter(!(lap %in% drop_laps))
  }
  
  if(fastest) {
    step2 <- 
      step1 %>%
      mutate(rank = row_number(time_sec))
  } else {
    step2 <- 
      step1 %>%
      mutate(rank = row_number(desc(time_sec)))
  }
  
  step3 <- step2 %>%
    mutate(total_laps = n_distinct(lap)) %>%
    filter(rank <= total_laps) %>%
    group_by(driver_id) %>%
    summarise(laps = n()) %>%
    ungroup() %>%
    arrange(desc(laps)) %>%
    inner_join(
      driver_lookup
    )
  
  step3 %>%
    mutate(driver_code = factor(driver_code, levels = step3$driver_code))
}


summary <- show_lap_stats(race_laps, TRUE, c(8))


ggplot(summary) +
  geom_col(
    aes(driver_code, laps)
  ) +
  geom_text(
    aes(driver_code, laps, label = laps, vjust = ifelse(laps > 3, 2, -1)), 
    fontface = "bold"
  ) +
  nflplotR::geom_from_path(
    aes(driver_code, 0.5, path = driver_img), 
    width = 0.08
  ) +
  theme(
    axis.title = element_blank(), 
    axis.text.y = element_blank(), 
    axis.ticks = element_blank()
  )