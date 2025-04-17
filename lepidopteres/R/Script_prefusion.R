traiter_donnees <- function(dossier) {
  library(dplyr)
  
  # Lire les fichiers CSV sauf "taxonomie.csv"
  fichiers_csv <- list.files(dossier, pattern = "\\.csv$", full.names = TRUE)
  fichiers_csv <- fichiers_csv[!grepl("taxonomie\\.csv$", fichiers_csv)]
  
  # Lire les fichiers et ajouter "d_" devant les noms
  liste_donnees <- lapply(fichiers_csv, function(fichier) {
    df <- read.csv(fichier)
    
    # Ajouter le temps fictif si manquant
    df$time_obs <- ifelse(df$time_obs == "" | is.na(df$time_obs), "00:00:00", df$time_obs)
    
    # Vérifier et corriger les valeurs non numériques de 'year_obs'
    non_numeric_indices <- which(is.na(as.numeric(df$year_obs)))
    if (length(non_numeric_indices) > 0) {
      df$year_obs[non_numeric_indices] <- NA  # Remplace les valeurs non valides par NA
    }
    
    # Conversion des colonnes en valeurs numériques
    df$year_obs <- as.numeric(df$year_obs)
    df$day_obs <- as.numeric(df$day_obs)
    
    return(df)
  })
  
  # Fusionner les données
  g_b <- bind_rows(liste_donnees, .id = "source")
  
  # Supprimer des colonnes non nécessaires
  colonnes_a_supprimer <- c("obs_unit")  # Liste des colonnes à supprimer
  g_b <- g_b %>% select(-all_of(colonnes_a_supprimer))  # Supprimer les colonnes spécifiées
  
  
  return(g_b)
}