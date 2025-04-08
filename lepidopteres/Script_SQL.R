creer_base_de_donnees_SQL <- function(nom_bd, table_obs, table_temps, table_droits) {
  # Charger la bibliothèque
  library(RSQLite)
  
  # Connexion à la base de données SQLite
  con <- dbConnect(SQLite(), dbname = nom_bd)
  
  # Création des tables
  requetes_sql <- list(
    'CREATE TABLE observations (
      id_obs INTEGER NOT NULL,
      observed_scientific_name VARCHAR(100),
      lat REAL,
      lon REAL,
      obs_value INTEGER,
      id_droits INTEGER NOT NULL,
      PRIMARY KEY (id_obs)
    );',
    
    'CREATE TABLE temps (
      id_obs INTEGER NOT NULL,
      dwc_event_date DATE,
      year_obs INTEGER,
      day_obs INTEGER,
      time_obs TIME,
      PRIMARY KEY (id_obs),
      FOREIGN KEY (id_obs) REFERENCES observations(id_obs)
    );',
    
    'CREATE TABLE droits (
      id_droits INTEGER NOT NULL,
      creator VARCHAR(100),
      title VARCHAR(100),
      publisher VARCHAR(100),
      intellectual_rights VARCHAR(100),
      license VARCHAR(100),
      owner VARCHAR(100),
      original_source VARCHAR(100),
      PRIMARY KEY (id_droits),
      FOREIGN KEY (id_droits) REFERENCES observations(id_droits)
    );'
  )
  
  # Exécuter les requêtes SQL pour créer les tables
  lapply(requetes_sql, function(requete) dbSendQuery(con, requete))
  
  # Injection des enregistrements dans la BD
  dbWriteTable(con, append = TRUE, name = "observations", value = table_obs, row.names = FALSE)
  dbWriteTable(con, append = TRUE, name = "temps", value = table_temps, row.names = FALSE)
  dbWriteTable(con, append = TRUE, name = "droits", value = table_droits, row.names = FALSE)
  
  # Fermer la connexion
  dbDisconnect(con)
  
  message("Base de données créée et données insérées avec succès.")
}