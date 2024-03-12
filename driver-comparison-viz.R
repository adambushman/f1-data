library('f1dataR')
library('tidyverse')


View(f1dataR::plot_fastest)

piastri <- load_driver_telemetry(
  season = 2024, 
  round = 2, 
  session = "R", 
  driver = "PIA", 
  laps = "all"
)




fastest_NOR <- load_driver_telemetry(
  round = 2, session = "R", driver = "NOR"
)

compare_fastest <- function(round, drivers) {
  fastest_laps <- list()
  for(name in drivers) {
    data = load_driver_telemetry(
      round = {{round}}, session = "R", driver = name
    )
    
    n = nrow(data)
    
    fastest_laps[[name]] = list(
      "data" = data, "n" = n
    )
  }
  
  get_variable <- function(driver, var) {
    return(unlist(fastest_laps[[driver]][["data"]][,{{var}}], use.names = FALSE))
  }
  
  col_names = paste0("speed_", drivers)
  
  comparison <- tibble(
    x = get_variable(drivers[1], "x"),
    y = get_variable(drivers[1], "y"),
    !!col_names[1] := get_variable(drivers[1], "speed"),
    !!col_names[2] := get_variable(drivers[2], "speed")
  )
  
  comparison$speed_diff = unlist(comparison[,3] - comparison[,4], use.names = FALSE)
  
  full_data <- comparison %>%
    mutate(faster_driver = case_when(
      speed_diff > 0 ~ drivers[1], 
      speed_diff < 0 ~ drivers[2], 
      TRUE ~ as.character(NA)
    ))
  
  viz <- 
    ggplot(
      full_data, aes(x, y)
    ) +
    geom_path(
      aes(color = speed_diff), 
      linewidth = 4, lineend = "round", 
      show.legend = FALSE
    ) +
    geom_path(linewidth = 0.25, lineend = "round") +
    scale_color_gradient2(
      low = "#FF8000", mid = "white", high = "black", 
      midpoint = 0
    ) +
    theme(
      plot.background = element_rect(fill = "white", color = NA), 
      panel.grid = element_blank(), 
      axis.title = element_blank(), 
      axis.text = element_blank(), 
      axis.ticks = element_blank()
    )
  
  return(correct_track_ratio(viz))
}


main_viz <- compare_fastest(1, c("PIA", "NOR"))





func <- colorRampPalette(c("#FF8000", "#FFFFFF", "#000000"))


test <- tibble(
  x1 = seq(1, 5, 1) * 10, 
  y1 = 0,
  y2 = 10, 
  col = func(5)
) %>%
  mutate(
    x2 = ifelse(is.na(lag(x1)), 0, lag(x1))
  )


ggplot(test) +
  geom_rect(
    aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2, fill = col)
  ) +
  annotate(
    "text", x = 25, y = 11, hjust = 0.5, label = "Faster"
  ) +
  annotate(
    "segment", x = 20, y = 11, xend = 10, yend = 11,
    arrow = arrow(type = "closed", length = unit(0.02, "npc"))
  ) +
  annotate(
    "segment", x = 30, y = 11, xend = 40, yend = 11,
    arrow = arrow(type = "closed", length = unit(0.02, "npc"))
  ) +
  scale_fill_identity() +
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(limits = c(0, 12), expand = c(0,0)) +
  theme_void()
