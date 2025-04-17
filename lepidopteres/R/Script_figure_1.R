figure_richesse_temporelle <- function(fichier_db) {
  library(DBI)
  library(RSQLite)
  
  # Créer dossier figures s'il n'existe pas
  if (!dir.exists("figures")) {
    dir.create("figures")
  }
  
  # Définir le chemin du fichier de sortie
  output_path <- "figures/richesse_temporelle.png"
  
  # Connexion à la base de données
  con <- dbConnect(SQLite(), fichier_db)
  
  tryCatch({
    # Requête SQL
    requete <- "
    SELECT year_obs, COUNT(DISTINCT observed_scientific_name) AS richesse
    FROM temps
    JOIN observations USING(id_obs)
    GROUP BY year_obs
    ORDER BY year_obs;
    "
    
    df <- dbGetQuery(con, requete)
    
    # Filtrer les données post-2000
    df_recent <- df[df$year_obs >= 2000, ]
    
    # Ouvrir un périphérique graphique PNG
    png(filename = output_path, width = 1000, height = 800, res = 120)
    
    # Paramètres graphiques
    par(mfrow = c(2, 1))
    par(mar = c(5, 6, 2, 1))  # marges : bas, gauche, haut, droite
    
    # Plot (a)
    plot(df$year_obs, df$richesse, type = "l", col = "steelblue", lwd = 1,
         xlab = "Année", ylab = "Richesse spécifique",
         main = "Richesse spécifique (toutes les années)",
         cex.lab = 1.4, cex.axis = 1.2, cex.main = 1.6)
    mtext("(a)", side = 3, line = 0.5, adj = 0, cex = 1.2)
    grid()
    
    # Plot (b)
    plot(df_recent$year_obs, df_recent$richesse, type = "l", col = "darkorange", lwd = 1,
         xlab = "Année", ylab = "Richesse spécifique",
         main = "Richesse spécifique depuis 2000",
         cex.lab = 1.4, cex.axis = 1.2, cex.main = 1.6)
    mtext("(b)", side = 3, line = 0.5, adj = 0, cex = 1.2)
    grid()
    
    # Fermer le fichier image
    dev.off()
  },
  finally = {
    dbDisconnect(con)
  })
  
  # Retourner le chemin du fichier image
  return(output_path)
}


