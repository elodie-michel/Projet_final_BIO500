#Nettoyage de données

#pour nettoyer les données 
nettoyer_les_donnees <- function(g_b, colonnes_a_supprimer) {
  
  # Ajouter la colonne is_valid, si une erreur est détecté dans une ligne, la valeur de is_valid deviendra FALSE pour pouvoir l'exclure des analyses.
  g_b$is_valid <- TRUE #les donnees sont tous valides (inclues dans les analyses) jusqu'à preuve du contraire
  g_b$is_valid <- as.logical(g_b$is_valid) #format logique pour la colonne (TRUE ou FALSE)
  
  # Avoir juste la date dans la colonne dwc_event_date
  g_b$dwc_event_date <- substr(g_b$dwc_event_date, 1, 10)
  
  # Mettre les bons types de colonnes
  g_b$observed_scientific_name <- as.character(g_b$observed_scientific_name)
  g_b$dwc_event_date <- as.Date(g_b$dwc_event_date)
  
  #Fitrer les donnees pour utiliser juste celles avec un nom scientifique d'espèce bien écrit
  taxo <- read.csv("donnees/taxonomie.csv")
  noms_valides <- unique(taxo$observed_scientific_name[taxo$rank == "species"])
  g_b$is_valid[!(g_b$observed_scientific_name %in% noms_valides)] <- FALSE
  
  #Séparer les presences et abundance pour uniformiser le tout
  
  g_b$obs_variable <- tolower(g_b$obs_variable)  # En minuscule, au cas où
  g_b$obs_variable[g_b$obs_variable %in% c("occurrence", "pr@#sence")] <- "presence"
  g_b$obs_variable[!g_b$obs_variable %in% c("presence", "abundance")] <- NA  # Mettre NA aux autres
  
  # Convertir les colonnes lat et lon en numériques
  g_b$lat <- as.numeric(g_b$lat)
  g_b$lon <- as.numeric(g_b$lon)
  
  # Fusionner les colonnes 'titre' et 'title' (on garde juste la colonne titre)
  if ("title" %in% names(g_b)) {
    g_b$titre <- ifelse(is.na(g_b$titre) | g_b$titre == "", g_b$title, g_b$titre)
    g_b$title <- NULL
  }
  
  return(g_b)
}