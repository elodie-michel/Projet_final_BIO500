extraire_phenologie <- function(nom_bd, n_especes) {
  suppressMessages({
    library(DBI)
    library(RSQLite)
  })
  
  # Connexion à la base
  con <- dbConnect(SQLite(), nom_bd)
  on.exit(dbDisconnect(con), add = TRUE)
  
  requete3 <- "
    SELECT o.observed_scientific_name AS taxa_name,
           t.dwc_event_date AS date_obs
    FROM observations o
    JOIN temps t ON o.id_obs = t.id_obs
    WHERE t.dwc_event_date IS NOT NULL
  "
  
  data <- dbGetQuery(con, requete3)
 
  return(data)
}
