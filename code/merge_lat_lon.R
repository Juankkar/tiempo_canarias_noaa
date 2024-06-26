#!/usr/bin/env Rscript

library(tidyverse)

# Caja de coordenadas donde se encontraría canarias, sacado del idecanarias.
canarias_box <- data.frame(
  latitude = c(29.68374429, 29.73653255, 
               27.22072549, 27.29312474),
  longitude = c(-18.81624366, -13.02475776, 
                -18.67278517, -13.06979070)
)

read_fwf("data/ghcnd-inventory.txt",
         col_positions = fwf_cols(
            id = c(1,11),
            latitude = c(13,20),
            longitude = c(22,30),
            element = c(32, 35),
            first_year = c(37, 40),
            last_year = c(42, 45)
         )) %>%
    mutate(inside_canarias = case_when(
            latitude >= min(canarias_box$latitude) & 
                latitude <= max(canarias_box$latitude) &
            longitude >= min(canarias_box$longitude) & 
                longitude <= max(canarias_box$longitude) ~ TRUE,
            TRUE ~ FALSE
           )) %>% 
    filter(inside_canarias & element == "PRCP") %>%
    group_by(longitude, latitude) %>%
    mutate(region = cur_group_id()) %>%
    select(-element, -inside_canarias) %>%
    write_tsv("data/ghcnd_canary_regions_years.tsv")
    