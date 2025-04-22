#Création de la Figure 2
extraire_richesse_spatiale <- function(db_path) {
  library(dplyr)
  library(RSQLite)
  
  # Connexion à la base de données
  con <- dbConnect(SQLite(), db_path)
  
  # Requête SQL pour extraire la richesse spécifique
  requete <- "
    SELECT 
      ROUND(lat, 1) AS lat_bin,
      ROUND(lon, 1) AS lon_bin,
      COUNT(DISTINCT observed_scientific_name) AS richesse
    FROM observations
    GROUP BY lat_bin, lon_bin;
  "
  
  richesse_spatiale <- dbGetQuery(con, requete)
  dbDisconnect(con)
 
  # Retourner le chemin du fichier image
  return(richesse_spatiale)
}

