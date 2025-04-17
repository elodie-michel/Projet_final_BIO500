figure_richesse_spatiale <- function(db_path, shapefile_sf) {
  library(sf)
  library(ggplot2)
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
  
  # Conversion en objet sf
  richesse_sf <- st_as_sf(richesse_spatiale, coords = c("lon_bin", "lat_bin"), crs = 4326)
  
  # Corriger les géométries si nécessaires
  if (!all(st_is_valid(shapefile_sf))) {
    shapefile_sf <- st_make_valid(shapefile_sf)
  }
  
  # S'assurer que les CRS sont identiques
  shapefile_sf <- st_transform(shapefile_sf, st_crs(richesse_sf))
  
  # Filtrer les points à l’intérieur des polygones
  richesse_quebec <- st_filter(richesse_sf, shapefile_sf)
  
  # Créer la carte
  p <- ggplot() +
    geom_sf(data = shapefile_sf, fill = "lightgray", color = "black") +
    geom_sf(data = richesse_quebec, aes(color = richesse), size = 0.2) +
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
  
  return(p)
}

# Charger la carte du Québec
quebec <- st_read("donnees/donnees_cartographiques/bordure_quebec.shp")

# Corriger les géométries invalides
quebec <- st_make_valid(quebec)

#Création de la Figure 2
figure_richesse_spatiale("lepidopteres.db", quebec)
