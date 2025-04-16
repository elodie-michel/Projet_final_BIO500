library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)

con <- dbConnect(SQLite(), "lepidopteres.db")

requete1 <- "
SELECT year_obs, COUNT(DISTINCT observed_scientific_name) AS richesse
FROM temps
JOIN observations USING(id_obs)
GROUP BY year_obs
ORDER BY year_obs;
"

df1 <- dbGetQuery(con, requete1)

ggplot(df1, aes(x = year_obs, y = richesse)) +
  geom_line(color = "steelblue") +
  labs(title = "Richesse spécifique au fil du temps",
       x = "Année",
       y = "Nombre d'espèces différentes") +
  theme_minimal()

