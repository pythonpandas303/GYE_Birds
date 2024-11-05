library(bbsBayes2)
library(sf)       
library(dplyr)   
library(ggplot2)  

fetch_bbs_data()

setwd('Your_File_Path') 


map <- sf::read_sf('./GIS/GYE_Buffer_Bayes2.shp')
map$STRAT <- c(1,1)
map <- rename(map, strata_name = layer)

bird_names <- read.csv('./uniquebirdnames_4.csv')
process_species <- function(species) {
  tryCatch({
    
    
    
    s <- stratify(by = "GYE", species = species, strata_custom = map)
    
    
    p <- prepare_data(s,
                      min_year = 1990,
                      max_year = 2022)
    
    pm <- prepare_model(p, model = "gamye", model_variant = "hier", calculate_cv = TRUE)
    
    m <- run_model(pm, 
                   refresh = 10,
                   iter_warmup = 1000,
                   iter_sampling = 2000,
                   adapt_delta = 0.8,
                   max_treedepth = 15)
    
    
    i <- generate_indices(m)
    i2 <- as.data.frame(i$indices)
    i2$species <- species
    
    i2$significant_90 <- ifelse(i2$index_q_0.05 > 0 & i2$index_q_0.95 > 0, "Positive",
                                ifelse(i2$index_q_0.05 < 0 & i2$index_q_0.95 < 0, "Negative", "Not Significant"))
    
  
    significance_summary <- data.frame(
      year = i2$year,
      significant = i2$significant_90,
      lower_bound = i2$index_q_0.05,
      upper_bound = i2$index_q_0.95
    )
    
    significance_summary$lower_diff <- c(NA, diff(significance_summary$lower_bound))
    significance_summary$upper_diff <- c(NA, diff(significance_summary$upper_bound))
    
    
    significance_summary$year_significance <- ifelse(
      significance_summary$lower_bound > 0 & significance_summary$upper_bound > 0, "Positive",
      ifelse(significance_summary$lower_bound < 0 & significance_summary$upper_bound < 0, "Negative", "Not Significant")
    )
    
    filename <- sprintf("./Indicescsv91/%s.csv", species)
    write.csv(i2, filename)
    
    gye_buffer_wgs84 <- i2 %>% filter(strata_included == "GYE_Buffer ; GYE_WGS84")
    gye_buffer <- i2 %>% filter(strata_included == "GYE_Buffer")
    gye_wgs84 <- i2 %>% filter(strata_included == "GYE_WGS84")
    
    
    plot_data <- function(data, species_name) {
      title_text <- sprintf("%s (GYE 1990-2022)", species_name)
      
      p <- ggplot(data, aes(x = year)) +
        geom_line(aes(y = index, color = "Median Percent Change")) +  # Line for Median Percent Change
        geom_point(aes(y = obs_mean, color = "Mean Count")) +  # Points for Mean Count
        geom_ribbon(aes(ymin = index_q_0.05, ymax = index_q_0.95), alpha = 0.2) +
        geom_vline(xintercept = 2020, color = "red", linetype = "dashed") +
        scale_color_manual(values = c("Mean Count" = "blue", "Median Percent Change" = "black")) +  # Set colors for legend
        theme_minimal() +
        labs(title = title_text, x = "Year", y = "Median Percent Change \n & Mean Count", color = NULL) +  # Remove legend title
        theme(axis.text.x = element_text(angle = 45, hjust = 1),
              legend.position = "right",  # You can adjust this as needed
              plot.margin = unit(c(1, 1, 1, 1), "cm"),
              plot.title = element_text(size = 14, face = "bold", hjust = 0.5, vjust = 1.5),
              axis.title.y = element_text(angle = 90, vjust = 2.5), 
              plot.background = element_rect(fill = "white", color = "black"),
              clip = "off")  # Prevent clipping outside the plot area
      
      return(p)
    }
    
    p1 <- plot_data(gye_buffer_wgs84, species)
    print(p1)
    
    
    filename <- sprintf("./charts91/%s.png", species) 
    ggsave(filename, plot = p1, width = 10, height = 8, units = "in")
    
    t <- generate_trends(i)
    
    t2 <- as.data.frame(t$trends)
    t2$species <- species
    filename <- sprintf("./Trendcsv91/%s_Data.csv", species)
    write.csv(t2, filename)
    
  }, error = function(e) {
    message(sprintf("Error processing species %s: %s", species_name, e$message))
  })
}

for (species_name in bird_names$species) {
  process_species(species_name)
}

folder_path <- "Trendcsv91/"

csv_files <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

combined_data <- csv_files %>%
  lapply(read.csv) %>%
  bind_rows()

write.csv(combined_data, file = "Trend91_combined.csv", row.names = FALSE)

cat("All CSV files have been combined and saved as 'Trend91_combined.csv'.\n")

folder_path <- "Indicescsv91/"

csv_files <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

combined_data <- csv_files %>%
  lapply(read.csv) %>%
  bind_rows()

write.csv(combined_data, file = "Indices91_combined.csv", row.names = FALSE)

cat("All CSV files have been combined and saved as 'Indices91_combined.csv'.\n")
