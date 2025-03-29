#Test 1, enlever les NA dans les colonnes "year_obs", "lat" et "lon"

#Fonction pour enlever les NA
enlever.na <- function(base_donnees) {
  base_donnees_sans_na <- base_donnees[complete.cases(base_donnees[, c("year_obs", "lat", "lon")]), ]
  return(base_donnees_sans_na)  # Retourne le dataframe sans NA
}


#Test 2, enlever les lignes identiques (doublons)

# Fonction pour détecter et supprimer les lignes identiques
supprimer_lignes_identiques <- function(base_donnees) {
  # Détecte les lignes dupliquées
  base_donnees_sans_doublons <- base_donnees[!duplicated(base_donnees), ]
  
  # Retourne le dataframe sans les doublons
  return(base_donnees_sans_doublons)
}


#Test 3, conserver les observation qui sont dans les limites géographiques du monde entier (supprime erreur de coordonnées)

# Fonction pour filtrer les lignes selon les limites géographiques du monde entier
filtrer_limites_geographiques <- function(base_donnees) {
  # Définir les limites de latitude et longitude pour le monde entier
  lat_min <- -90.0
  lat_max <- 90.0
  lon_min <- -180.0
  lon_max <- 180.0
  
  # Filtrer les lignes qui respectent les limites géographiques
  base_donnees_filtrees <- base_donnees[
    base_donnees$lat >= lat_min & base_donnees$lat <= lat_max & 
      base_donnees$lon >= lon_min & base_donnees$lon <= lon_max, 
  ]
  
  # Retourner la base de données filtrée
  return(base_donnees_filtrees)
}


#Test 4, supprimer les lignes avec des années erronées

# Fonction pour filtrer les lignes selon les années de la prise de données
filtrer_limites_temporelles <- function(base_donnees) {
  # Définir les limites temporelles
  annee_min <- 1859
  annee_max <- 2023
  
  # Filtrer les lignes qui respectent les limites temporelles
  base_donnees_filtrees <- base_donnees[
    base_donnees$year_obs >= annee_min & base_donnees$year_obs <= annee_max,
  ]
  
  # Retourner la base de données filtrées
  return(base_donnees_filtrees)
}


#Test 5 et nettoyage, éliminer les valeurs de temps non-standard ou égal à zéro et changement en format HMS

# Définition de la fonction pour corriger la colonne 'time_obs'
corriger_time_obs <- function(base_donnees) {
  library(dplyr)
  library(lubridate)
  base_donnees %>%
    
    # Modifier la colonne 'time_obs'
    mutate(
      
      # Remplacer les valeurs "0" et "00:00:00" par NA (valeurs manquantes)
      time_obs = ifelse(time_obs %in% c("0", "00:00:00"), NA, time_obs),
      
      # Convertir la colonne 'time_obs' au format heure (HH:MM:SS)
      time_obs = hms(time_obs)
    )
}
nettoyer_donnees <- function(base_donnees) {
  library(dplyr)
  library(lubridate)
  
  base_donnees %>%
    # Enlever les NA dans "year_obs", "lat" et "lon"
    filter(complete.cases(year_obs, lat, lon)) %>%
    
    # Supprimer les lignes identiques (doublons)
    distinct() %>%
    
    # Conserver les observations qui sont dans les limites géographiques du monde entier
    filter(lat >= -90 & lat <= 90 & lon >= -180 & lon <= 180) %>%
    
    # Supprimer les lignes avec des années erronées
    filter(year_obs >= 1859 & year_obs <= 2023) %>%
    
    # Corriger la colonne 'time_obs'
    mutate(
      time_obs = ifelse(time_obs %in% c("0", "00:00:00"), NA, time_obs),
      time_obs = hms(time_obs)
    )
}




