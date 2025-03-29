#Fonction avec les différents tests pour détecter et corriger les erreurs
test_erreurs <- function(base_donnees) {
  #ajouter les packages nécessaires
  install.packages("dyplr")
  install.packages("lubridate")
  library(dplyr)
  library(lubridate)
  
  base_donnees %>%
    #Test 1, enlever les NA dans les colonnes "year_obs", "lat" et "lon"
    filter(complete.cases(year_obs, lat, lon)) %>%
    
    #Test 2, enlever les lignes identiques (doublons)
    distinct() %>%
    
    #Test 3, conserver les observation qui sont dans les limites géographiques du monde entier (supprime erreur de coordonnées)
    filter(lat >= -90 & lat <= 90 & lon >= -180 & lon <= 180) %>%
    
    #Test 4, supprimer les lignes avec des années erronées
    filter(year_obs >= 1859 & year_obs <= 2023) %>%
    
    # Test 5 et nettoyage, éliminer les valeurs de temps non-standard ou égal à zéro et changement en format HMS
    mutate(
      time_obs = ifelse(time_obs %in% c("0", "00:00:00"), NA, time_obs),
      time_obs = hms(time_obs)
    )
}




