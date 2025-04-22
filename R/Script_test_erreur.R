# Fonction pour tester et marquer les erreurs dans une base de données spatiale
test_erreurs <- function(base_donnees, shapefile_obj) {
  library(dplyr)      # Manipulation de données
  library(lubridate)  # Gestion des objets temporels
  library(sf)         # Analyse spatiale (objets géométriques)
  
  # Étape 0 : Ajouter un identifiant unique à chaque ligne 
  # Cela permet de suivre chaque point lors des opérations spatiales
  base_donnees <- base_donnees %>%
    mutate(id_point = row_number())
  
  # Étape 1 : Corriger les coordonnées aberrantes sans décimales
  # Si les valeurs de longitude/latitude dépassent les valeurs plausibles, on suppose qu'il manque une virgule
  base_donnees <- base_donnees %>%
    mutate(
      lon = ifelse(abs(lon) > 180, lon / 1e5, lon),
      lat = ifelse(abs(lat) > 90, lat / 1e5, lat)
    )
  
  # Étape 2 : Convertir en objet spatial (sf) pour les opérations géographiques 
  base_sf <- st_as_sf(base_donnees, coords = c("lon", "lat"), crs = 4326, remove = FALSE)
  
  # Étape 3 : Corriger les géométries invalides du shapefile (au besoin)
  if (!all(st_is_valid(shapefile_obj))) {
    shapefile_obj <- st_make_valid(shapefile_obj)
  }
  
  # Étape 4 : Harmoniser les systèmes de coordonnées (CRS)
  shapefile_obj <- st_transform(shapefile_obj, st_crs(base_sf))
  
  # Étape 5 : Garder uniquement les points à l'intérieur du shapefile (exemple ici pour le Québec)
  base_dans_zone <- st_filter(base_sf, shapefile_obj)
  
  # Étape 6 : Initialiser la colonne 'is_valid' à TRUE 
  base_sf <- base_sf %>% mutate(is_valid = TRUE)
  
  # Étape 7 : Marquer comme FALSE les points hors du polygone (hors Québec par ex.)
  base_sf <- base_sf %>%
    mutate(is_valid = ifelse(!(id_point %in% base_dans_zone$id_point), FALSE, is_valid))
  
  # Test 1 : Marquer comme invalides les lignes avec des valeurs manquantes critiques
  base_sf <- base_sf %>%
    mutate(is_valid = ifelse(!complete.cases(year_obs, lat, lon), FALSE, is_valid))
  
  # Test 2 : Identifier les doublons exacts et les marquer comme invalides
  # On garde seulement la première occurrence comme valide
  base_sf <- base_sf %>%
    mutate(duplicated_row = duplicated(across(everything()))) %>%
    mutate(is_valid = ifelse(duplicated_row, FALSE, is_valid)) %>%
    select(-duplicated_row)
  
  # Test 3 : Valider l'année d'observation (entre 1859 et 2023 seulement)
  base_sf <- base_sf %>%
    mutate(is_valid = ifelse(is.na(year_obs) | year_obs < 1859 | year_obs > 2023, FALSE, is_valid))
  
  # Test 4 : Nettoyer les heures nulles ou invalides
  # Par convention, on transforme "00:00:00" ou "0" en NA
  base_sf <- base_sf %>%
    mutate(
      time_obs = ifelse(time_obs %in% c("0", "00:00:00"), NA, time_obs),
      time_obs = hms(time_obs)  # Conversion en format horaire
    )
  
  # Étape finale : Retour à un data.frame classique sans géométrie ni identifiant technique
  base_sf %>%
    select(-id_point) %>%     # On enlève l’identifiant temporaire
    st_drop_geometry()        # On retire la composante spatiale
}