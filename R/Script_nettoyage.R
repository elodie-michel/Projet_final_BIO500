# Fonction pour nettoyer les données d'observations de lépidoptères où bd est le nom donnée à la base de données
nettoyer_les_donnees <- function(bd, colonnes_a_supprimer) {
  
  # Initialiser une colonne booléenne 'is_valid' pour indiquer si une ligne est valide (TRUE par défaut)
  bd$is_valid <- TRUE 
  bd$is_valid <- as.logical(bd$is_valid)  # S'assurer que la colonne est bien de type logique
  
  # Extraire uniquement la date (AAAA-MM-JJ) de la colonne 'dwc_event_date'
  bd$dwc_event_date <- substr(bd$dwc_event_date, 1, 10)
  
  # Conversion des types de colonnes pour assurer une bonne manipulation :
  bd$observed_scientific_name <- as.character(bd$observed_scientific_name)  # noms scientifiques en texte
  bd$dwc_event_date <- as.Date(bd$dwc_event_date)  # dates au format Date
  
  # Validation des noms scientifiques : marquer comme non valides les noms qui ne sont pas reconnus
  taxo <- read.csv("donnees/taxonomie.csv")  # lecture du fichier de référence taxonomique
  noms_valides <- unique(taxo$observed_scientific_name[taxo$rank == "species"])  # extraction des noms d'espèces valides
  bd$is_valid[!(bd$observed_scientific_name %in% noms_valides)] <- FALSE  # marquer les noms non valides comme FALSE
  
  # Uniformisation des types de mesures ('presence' ou 'abundance') dans la colonne 'obs_variable'
  bd$obs_variable <- tolower(bd$obs_variable)  # mettre tout en minuscule pour éviter les doublons liés à la casse
  bd$obs_variable[bd$obs_variable %in% c("occurrence", "pr@#sence")] <- "presence"  # harmoniser les libellés erronés
  bd$obs_variable[!bd$obs_variable %in% c("presence", "abundance")] <- NA  # remplacer les valeurs non reconnues par NA
  
  # Conversion des coordonnées géographiques en format numérique
  bd$lat <- as.numeric(bd$lat)
  bd$lon <- as.numeric(bd$lon)
  
  # Fusion des colonnes 'titre' et 'title' (on garde 'titre' comme colonne principale)
  if ("title" %in% names(bd)) {
    bd$titre <- ifelse(is.na(bd$titre) | bd$titre == "", bd$title, bd$titre)  # remplir les vides de 'titre' avec 'title'
    bd$title <- NULL  # supprimer la colonne 'title'
  }
  
  # Retourner la base de données nettoyé
  return(bd)
}