#Nettoyage de données

#pour nettoyer les données 
Col_supprime_modifie <- function(g_b, colonnes_a_supprimer) {
  
  # Ajouter la colonne is_valid, initialement à TRUE
  g_b$is_valid <- TRUE
  
  # Avoir juste la date dans la colonne dwc_event_date
  g_b$dwc_event_date <- substr(g_b$dwc_event_date, 1, 10)
  
  # Mettre les bons types de colonnes
  g_b$observed_scientific_name <- as.character(g_b$observed_scientific_name)
  g_b$dwc_event_date <- as.Date(g_b$dwc_event_date)
  
  
  #Séparer les presences et abundance pour uniformiser le tout
  
  g_b$obs_variable <- tolower(g_b$obs_variable)  # En minuscule, au cas où
  g_b$obs_variable[g_b$obs_variable %in% c("occurrence", "pr@#sence")] <- "presence"
  g_b$obs_variable[!g_b$obs_variable %in% c("presence", "abundance")] <- NA  # Optionnel : mettre NA aux autres
  
  
  # Convertir les colonnes lat et lon en numériques
  g_b$lat <- as.numeric(g_b$lat)
  g_b$lon <- as.numeric(g_b$lon)
  
  # Fusionner 'titre' et 'title'
  if ("title" %in% names(g_b)) {
    g_b$titre <- ifelse(is.na(g_b$titre) | g_b$titre == "", g_b$title, g_b$titre)
    g_b$title <- NULL
  }
  
  return(g_b)
}