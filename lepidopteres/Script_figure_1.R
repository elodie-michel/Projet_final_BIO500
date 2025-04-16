library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)

# Connexion et données
con <- dbConnect(SQLite(), "lepidopteres.db")

requete1 <- "
SELECT year_obs, COUNT(DISTINCT observed_scientific_name) AS richesse
FROM temps
JOIN observations USING(id_obs)
GROUP BY year_obs
ORDER BY year_obs;
"

df1 <- dbGetQuery(con, requete1)

# Séparer les données
df2 <- df1[df1$year_obs >= 2000, ]

# 2 plots l’un au-dessus de l’autre
par(mfrow = c(2,1), mar = c(4.5,5,3,2))  # marges: bas, gauche, haut, droite

# Plot 1 – toutes années
plot(df1$year_obs, df1$richesse, type = "l", col = "steelblue", lwd = 1,
     xlab = "Année", ylab = "Richesse spécifique",
     main = "Richesse spécifique (toutes les années)",
     cex.lab = 1.4, cex.axis = 1.2, cex.main = 1.6)
grid()

# Plot 2 – depuis 2000
plot(df2$year_obs, df2$richesse, type = "l", col = "darkorange", lwd = 1,
     xlab = "Année", ylab = "Richesse spécifique",
     main = "Richesse spécifique depuis 2000",
     cex.lab = 1.4, cex.axis = 1.2, cex.main = 1.6)
grid()