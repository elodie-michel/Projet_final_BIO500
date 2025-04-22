# Fonction qui crée les 3 tables (objets) dans R à partir d'une base de données nettoyée
creer_tables <- function(base_de_donnees) {
  
  # --- Étape 1 : Ajouter un identifiant unique pour chaque observation ---
  ajouter_id_obs <- function(base_de_donnees) {
    library(dplyr)
    base_de_donnees %>%
      mutate(id_obs = row_number())  # Crée un identifiant croissant unique par ligne
  }
  base_de_donnees <- ajouter_id_obs(base_de_donnees)
  
  # --- Étape 2 : Générer un identifiant pour chaque groupe de droits ---
  ajouter_id_droits <- function(base_de_donnees) {
    library(data.table)
    setDT(base_de_donnees)  # Conversion du data frame en data.table pour le groupement efficace
    base_de_donnees[, id_droits := .GRP, by = .(creator, titre, publisher, intellectual_rights, license, owner, original_source)]
    return(base_de_donnees)  # Chaque combinaison unique de métadonnées reçoit un identifiant
  }
  base_de_donnees <- ajouter_id_droits(base_de_donnees)
  
  # --- Étape 3 : Filtrer uniquement les lignes valides ---
  # On ne conserve que les enregistrements jugés valides pour les analyses (is_valid = TRUE)
  base_de_donnees <- base_de_donnees %>% filter(is_valid == TRUE)
  
  # --- Étape 4 : Créer la table des observations ---
  creer_table_1 <- function(base_donnees) {
    base_donnees %>%
      select(id_obs, id_droits, observed_scientific_name, lat, lon, obs_value)
  }
  table_obs <- creer_table_1(base_de_donnees)
  
  # --- Étape 5 : Créer la table temporelle (date, année, jour) ---
  creer_table_2 <- function(base_donnees) {
    base_donnees %>%
      select(id_obs, dwc_event_date, year_obs, day_obs)
  }
  table_temps <- creer_table_2(base_de_donnees)
  
  # --- Étape 6 : Créer la table des droits ---
  creer_table_3 <- function(base_donnees) {
    base_donnees %>%
      select(id_droits, creator, titre, publisher, intellectual_rights, license, owner, original_source) %>%
      distinct()  # Retirer les doublons, une ligne par groupe de droits
  }
  table_droits <- creer_table_3(base_de_donnees)
  
  # --- Étape 7 : Retourner les trois tables sous forme de liste ---
  return(list(table_obs = table_obs, table_temps = table_temps, table_droits = table_droits))
}