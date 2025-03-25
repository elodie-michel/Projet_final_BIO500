# Fonction pour lire les fichiers CSV sauf "taxonomie.csv"
lire_csv <- function(dossier) {
  # Liste des fichiers CSV dans le dossier, sauf "taxonomie.csv"
  fichiers_csv <- list.files(dossier, pattern = "\\.csv$", full.names = TRUE)
  
  # Exclure le fichier "taxonomie.csv"
  fichiers_csv <- fichiers_csv[!grepl("taxonomie\\.csv$", fichiers_csv)]
  
  # Liste pour stocker les tables
  liste_donnees <- list()
  
  # Boucle pour lire chaque fichier
  for (fichier in fichiers_csv) {
    nom <- paste0("d_", gsub("\\.csv$", "", basename(fichier))) # Ajouter "d_" devant le nom
    liste_donnees[[nom]] <- read.csv(fichier)
    
    # Affichage temporaire (optionnel)
    print(paste("Affichage du tableau:", nom))
    print(head(liste_donnees[[nom]]))  # Affiche les premières lignes
  }
  
  return(liste_donnees)
}

ajouter_temps_fictif <- function(liste_donnees) {
  liste_donnees <- lapply(liste_donnees, function(df) {
    df$time_obs <- ifelse(df$time_obs == "" | is.na(df$time_obs), "00:00:00", df$time_obs)
    return(df)
  })
  return(liste_donnees)
}

verifier_values_non_numeriques <- function(liste_donnees) {
  non_numeric_values <- lapply(liste_donnees, function(df) {
    non_numeric_indices <- which(is.na(as.numeric(df$year_obs)))
    df$year_obs[non_numeric_indices]
  })
  return(non_numeric_values)
}

corriger_annee <- function(liste_donnees, index, annee) {
  liste_donnees[[index]]$year_obs <- annee
  return(liste_donnees)
}


convertir_annee_et_jour <- function(liste_donnees) {
  liste_donnees <- lapply(liste_donnees, function(df) {
    df$year_obs <- as.numeric(df$year_obs)
    df$day_obs <- as.numeric(df$day_obs)
    return(df)
  })
  return(liste_donnees)
}

fusionner_donnees <- function(liste_donnees) {
  library(dplyr)
  g_b <- bind_rows(liste_donnees, .id = "source")
  return(g_b)
}

