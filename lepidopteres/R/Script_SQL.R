# Fonction pour créer une base de données SQLite contenant trois tables : observations, temps et droits
creer_base_de_donnees_SQL <- function(nom_bd, table_obs, table_temps, table_droits) {
  
  # Charger la bibliothèque nécessaire pour utiliser SQLite avec R
  library(RSQLite)
  
  # Définir le chemin de la base de données
  chemin_complet <- file.path(nom_bd)
  
  # Connexion à la base de données SQLite (création si elle n'existe pas)
  con <- dbConnect(SQLite(), dbname = chemin_complet)
  
  # S'assurer que la colonne de date dans la table "temps" est bien au format caractère
  # (nécessaire pour l'insertion dans SQLite qui peut avoir des contraintes de type)
  table_temps <- table_temps %>%
    mutate(
      dwc_event_date = as.character(dwc_event_date)
    )
  
  # Supprimer les tables si elles existent déjà, pour éviter les conflits ou doublons
  dbExecute(con, "DROP TABLE IF EXISTS observations;")
  dbExecute(con, "DROP TABLE IF EXISTS temps;")
  dbExecute(con, "DROP TABLE IF EXISTS droits;")
  
  # Requêtes SQL pour créer les trois tables avec leurs schémas respectifs
  requetes_sql <- list(
    
    # Table des observations : contient les données principales d'observation
    'CREATE TABLE observations (
      id_obs INTEGER NOT NULL,
      observed_scientific_name VARCHAR(100),
      lat REAL,
      lon REAL,
      obs_value INTEGER,
      id_droits INTEGER NOT NULL,
      PRIMARY KEY (id_obs)
    );',
    
    # Table du temps : contient les informations temporelles liées à chaque observation
    'CREATE TABLE temps (
      id_obs INTEGER NOT NULL,
      dwc_event_date DATE,
      year_obs INTEGER,
      day_obs INTEGER,
      PRIMARY KEY (id_obs),
      FOREIGN KEY (id_obs) REFERENCES observations(id_obs)
    );',
    
    # Table des droits : contient les informations sur la propriété intellectuelle et les métadonnées
    'CREATE TABLE droits (
      id_droits INTEGER NOT NULL,
      creator VARCHAR(100),
      titre VARCHAR(100),
      publisher VARCHAR(100),
      intellectual_rights VARCHAR(100),
      license VARCHAR(100),
      owner VARCHAR(100),
      original_source VARCHAR(100),
      PRIMARY KEY (id_droits),
      FOREIGN KEY (id_droits) REFERENCES observations(id_droits)
    );'
  )
  
  # Exécuter les requêtes SQL pour créer les tables dans la base de données
  lapply(requetes_sql, function(requete) {
    query_result <- dbSendQuery(con, requete)  # Exécuter la requête
    dbClearResult(query_result)  # Libérer les ressources après exécution
  })
  
  # Insérer les données dans les tables correspondantes
  dbWriteTable(con, append = TRUE, name = "observations", value = table_obs, row.names = FALSE)
  dbWriteTable(con, append = TRUE, name = "temps", value = table_temps, row.names = FALSE)
  dbWriteTable(con, append = TRUE, name = "droits", value = table_droits, row.names = FALSE)
  
  # Fermer la connexion à la base de données
  dbDisconnect(con)
  
  # Message de confirmation
  message("Base de données créée et données insérées avec succès.")
}