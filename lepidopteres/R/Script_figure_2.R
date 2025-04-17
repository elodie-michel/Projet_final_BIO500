#figure #2 : distribution spatiale 

library(DBI)
library(RSQLite)
library(dplyr)


con <- dbConnect(SQLite(), "lepidopteres.db")

# Requête SQL mise à jour avec les bons noms de tables
requete2 <- "
SELECT 
  ROUND(lat, 1) AS lat_bin,
  ROUND(lon, 1) AS lon_bin,
  COUNT(DISTINCT observed_scientific_name) AS richesse
FROM observations
GROUP BY lat_bin, lon_bin;
"

# Exécuter la requête et stocker les résultats dans un data.frame
richesse_spatiale <- dbGetQuery(con, requete2)

# Visualiser la richesse spécifique par grille spatiale
ggplot(richesse_quebec, aes(x = lon_bin, y = lat_bin)) +
  geom_tile(aes(fill = richesse)) +
  coord_fixed(xlim = c(-80, -57), ylim = c(44, 63), expand = FALSE) +
  scale_fill_viridis_c(option = "plasma") +
  labs(title = "Richesse spécifique au Québec (par grille spatiale)",
       x = "Longitude",
       y = "Latitude",
       fill = "Richesse") +
  theme_minimal()