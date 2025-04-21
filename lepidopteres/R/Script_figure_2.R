#Création de la Figure 2
figure_richesse_spatiale <- function(db_path, shapefile_sf) {
  library(sf)
  library(ggplot2)
  library(dplyr)
  library(RSQLite)
  
  # Créer dossier figures s'il n'existe pas
  if (!dir.exists("lepidopteres/figures")) {
    dir.create("lepidopteres/figures")
  }
  
  # Définir le chemin du fichier de sortie
  output_path <- "lepidopteres/figures/richesse_spatiale.png"
  
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
  
  # Conversion en objet sf
  richesse_sf <- st_as_sf(richesse_spatiale, coords = c("lon_bin", "lat_bin"), crs = 4326)
  
  # Corriger les géométries du shapefile si nécessaire
  if (!all(st_is_valid(shapefile_sf))) {
    shapefile_sf <- st_make_valid(shapefile_sf)
  }
  
  # Harmoniser les CRS
  shapefile_sf <- st_transform(shapefile_sf, st_crs(richesse_sf))
  
  # Créer la carte
  figure2 <-ggplot() +
    geom_sf(data = shapefile_sf, fill = "lightgray", color = "black") +
    geom_sf(data = richesse_sf, aes(color = richesse), size = 0.2) +
    scale_color_viridis_c(limits = c(0, 200), oob = scales::squish) +
    theme_minimal() +
    labs(
      title = "Carte de la richesse spécifique des lépidoptères au Québec",
      color = "Richesse spécifique"
    ) +
    theme(
      legend.title = element_text(face = "bold"),
      plot.title = element_text(face = "bold", hjust = 0.5),
      legend.position = "right"
      
   
    )
  # Sauvegarder la figure
  ggsave(output_path, plot = figure2, width = 10, height = 8, dpi = 300)
  
  # Retourner le chemin du fichier image
  return(output_path)
}

