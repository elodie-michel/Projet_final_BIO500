test_erreurs <- function(base_donnees, shapefile_obj) {
  library(dplyr)
  library(lubridate)
  library(sf)
  
  # Étape 0 : Ajouter un identifiant unique pour repérer les lignes
  base_donnees <- base_donnees %>%
    mutate(id_point = row_number())
  
  # Étape 1 : Corriger les coordonnées sans virgules (ex: 6504560 --> 65.04560)
  base_donnees <- base_donnees %>%
    mutate(
      lon = ifelse(abs(lon) > 180, lon / 1e5, lon),
      lat = ifelse(abs(lat) > 90, lat / 1e5, lat)
    )
  
  # Étape 2 : Conversion en objet sf
  base_sf <- st_as_sf(base_donnees, coords = c("lon", "lat"), crs = 4326, remove = FALSE)
  
  # Étape 3 : Corriger les géométries si nécessaire
  if (!all(st_is_valid(shapefile_obj))) {
    shapefile_obj <- st_make_valid(shapefile_obj)
  }
  
  # Étape 4 : S'assurer que les CRS sont identiques
  shapefile_obj <- st_transform(shapefile_obj, st_crs(base_sf))
  
  # Étape 5 : Filtrer les points à l’intérieur du polygone (limites du Québec)
  base_dans_zone <- st_filter(base_sf, shapefile_obj)
  
  # Étape 6 : Ajouter is_valid = TRUE par défaut
  base_sf <- base_sf %>%
    mutate(is_valid = TRUE)
  
  # Étape 7 : Marquer FALSE les points hors de la zone d’étude
  base_sf <- base_sf %>%
    mutate(is_valid = ifelse(!(id_point %in% base_dans_zone$id_point), FALSE, is_valid))
  
  # Test 1: Détecter les NA dans les colonnes nécessaires
  base_sf <- base_sf %>%
    mutate(is_valid = ifelse(!complete.cases(year_obs, lat, lon), FALSE, is_valid))
  
  # Test 2: Marquer les doublons (on garde la première occurrence comme TRUE)
  base_sf <- base_sf %>%
    mutate(duplicated_row = duplicated(across(everything()))) %>%
    mutate(is_valid = ifelse(duplicated_row, FALSE, is_valid)) %>%
    select(-duplicated_row)
  
  # Test 5: Vérifier les années valides
  base_sf <- base_sf %>%
    mutate(is_valid = ifelse(is.na(year_obs) | year_obs < 1859 | year_obs > 2023, FALSE, is_valid))
  
  # Test 6: Nettoyer les heures non valides
  base_sf <- base_sf %>%
    mutate(
      time_obs = ifelse(time_obs %in% c("0", "00:00:00"), NA, time_obs),
      time_obs = hms(time_obs)
    )
  
  # Étape finale : Retour à un data.frame sans géométrie ni id_point
  base_sf %>%
    select(-id_point) %>%
    st_drop_geometry()
}