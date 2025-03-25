nettoyer_et_convertir_colonnes <- function(g_b) {
  # Avoir juste la date dans la colonne dwc_event_date
  g_b$dwc_event_date <- substr(g_b$dwc_event_date, 1, 10)
  
  # Mettre les bons types de colonnes
  g_b$observed_scientific_name <- as.character(g_b$observed_scientific_name)
  g_b$dwc_event_date <- as.Date(g_b$dwc_event_date)
  
  # Modifier la colonne obs_variable
  g_b$obs_variable <- g_b$obs_variable %in% c("presence", "occurrence", "abundance", "pr@#sence")
  
  # Convertir la colonne obs_value en entier
  g_b$obs_value <- as.integer(g_b$obs_value)
  
  # Convertir les colonnes lat et lon en numériques
  g_b$lat <- as.numeric(g_b$lat)
  g_b$lon <- as.numeric(g_b$lon)
  
  return(g_b)
}


supprimer_colonnes_non_necessaires <- function(g_b, colonnes_a_supprimer) {
  # Supprimer les colonnes spécifiées dans le dataframe g_b
  g_b <- g_b[, !(names(g_b) %in% colonnes_a_supprimer)]
  return(g_b)
}
