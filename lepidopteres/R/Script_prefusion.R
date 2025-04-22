# Fonction pour lire, nettoyer et fusionner plusieurs fichiers CSV dans un dossier (sauf le fichier taxonomique)
traiter_donnees <- function(dossier) {
  library(dplyr)  # Pour la manipulation de données
  
  # Étape 1 : Identifier les fichiers CSV à lire 
  fichiers_csv <- list.files(dossier, pattern = "\\.csv$", full.names = TRUE)  # Lister tous les fichiers CSV dans le dossier
  fichiers_csv <- fichiers_csv[!grepl("taxonomie\\.csv$", fichiers_csv)]  # Exclure le fichier "taxonomie.csv" (non destiné à l'analyse)
  
  # Étape 2 : Lire les fichiers CSV et les traiter individuellement 
  liste_donnees <- lapply(fichiers_csv, function(fichier) {
    df <- read.csv(fichier)  # Lire chaque fichier CSV
    
    # Ajouter une heure fictive ("00:00:00") si la colonne time_obs est vide ou NA
    df$time_obs <- ifelse(df$time_obs == "" | is.na(df$time_obs), "00:00:00", df$time_obs)
    
    # Identifier les entrées non numériques dans year_obs
    non_numeric_indices <- which(is.na(as.numeric(df$year_obs)))
    if (length(non_numeric_indices) > 0) {
      df$year_obs[non_numeric_indices] <- NA  # Remplacer les valeurs non valides par NA
    }
    
    # Convertir year_obs et day_obs en types numériques (si ce n'est pas déjà le cas)
    df$year_obs <- as.numeric(df$year_obs)
    df$day_obs <- as.numeric(df$day_obs)
    
    return(df)  # Retourner le fichier nettoyé
  })
  
  # Étape 3 : Fusionner tous les fichiers traités en une seule base de données 
  bd <- bind_rows(liste_donnees, .id = "source")  # Ajoute une colonne "source" pour identifier la provenance des lignes
  
  # Étape 4 : Supprimer les colonnes inutiles
  colonnes_a_supprimer <- c("obs_unit")  # Cette colonne contient uniquement des NA (ou est jugée inutile)
  bd <- bd %>% select(-all_of(colonnes_a_supprimer))  # Supprimer proprement ces colonnes
  
  # Étape 5 : Retourner la base de données fusionnée et nettoyée
  return(bd)
}