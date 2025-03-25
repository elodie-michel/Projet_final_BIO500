#Création de la colonne "id_obs" dans la base de données principale
#Fonction pour ajouter un identifiant unique à chaque ligne
ajouter_id_obs <- function(base_de_donnees) {
  library(dplyr)
  base_de_donnees %>%
    mutate(id_obs = row_number()) # Crée un identifiant croissant pour chaque ligne
}


#Création de la colonne "id_droits" dnas la base de données principale
# Fonction pour ajouter un identifiant unique basé sur une combinaison de colonnes
ajouter_id_droits <- function(base_de_donnees) {
  library(data.table)
  # Convertir le dataframe en data.table
  setDT(base_de_donnees)
  # Créer un identifiant unique pour chaque combinaison de colonnes
  base_de_donnees[, id_droits := .GRP, by = .(creator, title, publisher, intellectual_rights, license, owner, original_source)]
  
  return(base_de_donnees)
}


# Fonction pour créer une table pour les observations avec des colonnes spécifiques
creer_table_1 <- function(base_donnees) {
  # Sélectionner les colonnes souhaitées
  table_selectionnee <- base_donnees %>%
    select(id_obs,id_droits, observed_scientific_name, lat, lon, obs_value)
  
  # Retourner la table sélectionnée
  return(table_selectionnee)
}


# Fonction pour créer une table temporelle avec des colonnes spécifiques
creer_table_2 <- function(base_donnees) {
  # Sélectionner les colonnes souhaitées
  table_selectionnee <- base_donnees %>%
    select(id_obs, dwc_event_date, year_obs, day_obs, time_obs)
  
  # Retourner la table sélectionnée
  return(table_selectionnee)
}


# Fonction pour créer une table avec les valeurs uniques de 'id_droits' et leur combinaison des autres colonnes
creer_table_3 <- function(base_donnees) {
  # Sélectionner les colonnes nécessaires
  table_unique_droits <- base_donnees %>%
    select(id_droits, creator, title, publisher, intellectual_rights, license, owner, original_source) %>%
    distinct(id_droits, creator, title, publisher, intellectual_rights, license, owner, original_source)
  
  # Retourner la table résultante avec les valeurs uniques
  return(table_unique_droits)
}

