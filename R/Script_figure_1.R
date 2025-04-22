extraire_richesse_temporelle <- function(fichier_db) {
  library(DBI)
  library(RSQLite)
  
  # Connexion à la base de données
  con <- dbConnect(SQLite(), fichier_db)
  
  # Récupérer les données
  df <- tryCatch({
    requete <- "
      SELECT year_obs, COUNT(DISTINCT observed_scientific_name) AS richesse
      FROM temps
      JOIN observations USING(id_obs)
      GROUP BY year_obs
      ORDER BY year_obs;
    "
    dbGetQuery(con, requete)
  },
  finally = {
    dbDisconnect(con)
  })
  
  return(df)
}
