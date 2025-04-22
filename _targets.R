library(targets)
library(tarchetypes)

tar_source("lepidopteres/R")  # équivalent à tous tes `source(...)` actuels

tar_option_set(
  packages = c("dplyr", "RSQLite", "lubridate", "data.table", "DBI", "sf", "ggplot2", "rmarkdown","knitr")
)

list(
  tar_target(
    name = quebec,
    command = st_read("lepidopteres/donnees/donnees_cartographiques/bordure_quebec.shp")
  ),
  tar_target(
    name = dossier,
    command = "lepidopteres/donnees",
    format = "file"
  ),
  tar_target(
    name = g_b_brut,
    command = traiter_donnees(dossier)
  ),
  tar_target(
    name = g_b_nettoye,
    command = nettoyer_les_donnees(g_b_brut)
  ),
  tar_target(
    name = g_b_final,
    command = test_erreurs(g_b_nettoye,quebec)
  ),
  tar_target(
    name = table_g_b,
    command = creer_tables(g_b_final)
  ),
  tar_target(
    name = table_obs,
    command = table_g_b$table_obs
  ),
  tar_target(
    name = table_temps,
    command = table_g_b$table_temps
  ),
  tar_target(
    name = table_droits,
    command = table_g_b$table_droits
  ),
  tar_target(
    name = base_sqlite,
    command = {
      creer_base_de_donnees_SQL("lepidopteres.db", table_obs, table_temps, table_droits)
      "lepidopteres.db"  # renvoie le fichier créé
    },
    format = "file"
  )
  ,
  tar_target(
    name = fig_richesse_temporelle,
    command = extraire_richesse_temporelle(base_sqlite)
  ),
  tar_target(
    name = fig_richesse_spatiale,
    command = extraire_richesse_spatiale(base_sqlite)
  ),
  tar_target(
    name = fig_phenologie,
    command = extraire_phenologie(base_sqlite, 10)
  ),
  tar_render(
    name = rapport,
    path = "lepidopteres/rapport/rapport_final_BIO500/rapport_final_BIO500.Rmd",  # Mon fichier RMarkdown
  )
)



