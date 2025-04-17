# Fonction qui crée les 3 tables (objets) dans R
creer_tables <- function(base_de_donnees) {
  
  # Création de la colonne "id_obs" dans la base de données principale
  ajouter_id_obs <- function(base_de_donnees) {
    library(dplyr)
    base_de_donnees %>%
      mutate(id_obs = row_number()) # Crée un identifiant croissant pour chaque ligne
  }
  base_de_donnees <- ajouter_id_obs(base_de_donnees)
  
  # Création de la colonne "id_droits" dans la base de données principale
  ajouter_id_droits <- function(base_de_donnees) {
    library(data.table)
    setDT(base_de_donnees) # Convertir en data.table
    base_de_donnees[, id_droits := .GRP, by = .(creator, titre, publisher, intellectual_rights, license, owner, original_source)]
    return(base_de_donnees)
  }
  base_de_donnees <- ajouter_id_droits(base_de_donnees)
  
  #On garde seulement les lignes où on a pas d'erreurs et qu'on a toutes les informations nécessaires pour les analyses (is_valid = TRUE)
  base_de_donnees <- base_de_donnees %>% filter(is_valid == TRUE)
  
  # Fonction pour créer une table pour les observations
  creer_table_1 <- function(base_donnees) {
    base_donnees %>%
      select(id_obs, id_droits, observed_scientific_name, lat, lon, obs_value)
  }
  table_obs <- creer_table_1(base_de_donnees)
  
  # Fonction pour créer une table temporelle
  creer_table_2 <- function(base_donnees) {
    base_donnees %>%
      select(id_obs, dwc_event_date, year_obs, day_obs, time_obs)
  }
  table_temps <- creer_table_2(base_de_donnees)
  
  # Fonction pour créer une table des droits
  creer_table_3 <- function(base_donnees) {
    base_donnees %>%
      select(id_droits, creator, titre, publisher, intellectual_rights, license, owner, original_source) %>%
      distinct()
  }
  table_droits <- creer_table_3(base_de_donnees)
  
  # Retourner une liste contenant les trois tables
  return(list(table_obs = table_obs, table_temps = table_temps, table_droits = table_droits))
}
