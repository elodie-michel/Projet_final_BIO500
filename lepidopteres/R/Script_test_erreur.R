test_erreurs <- function(base_donnees) {
  library(dplyr)
  library(lubridate)
  
  base_donnees %>%
    # Test 1: Détecter les NA dans les colonnes nécessaires
    mutate(is_valid = ifelse(!complete.cases(year_obs, lat, lon), FALSE, is_valid)) %>%
    
    # Test 2: Marquer les doublons (on garde la première occurrence)
    mutate(duplicated_row = duplicated(across(everything()))) %>%
    mutate(is_valid = ifelse(duplicated_row, FALSE, is_valid)) %>%
    select(-duplicated_row) %>%
    
    # Test 3: Corriger les coordonnées exagérées
    mutate(
      lon = ifelse(abs(lon) > 180, lon / 1e5, lon),
      lat = ifelse(abs(lat) > 90, lat / 1e5, lat)
    ) %>%
    
    # Test 4: Vérifier si les coordonnées sont dans les limites du Québec
    mutate(is_valid = ifelse(lat < 45 | lat > 62 | lon < -79 | lon > -57, FALSE, is_valid)) %>%
    
    # Test 5: Vérifier les années valides
    mutate(is_valid = ifelse(is.na(year_obs) | year_obs < 1859 | year_obs > 2023, FALSE, is_valid)) %>%
    
    # Test 6: Nettoyer les heures non valides
    mutate(
      time_obs = ifelse(time_obs %in% c("0", "00:00:00"), NA, time_obs),
      time_obs = hms(time_obs)
    )
  
}

