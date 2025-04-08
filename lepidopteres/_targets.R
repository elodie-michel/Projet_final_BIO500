library(targets)
library(tarchetypes)

source("Script_prefusion.R")
source("Script_nettoyage.R")
source("Script_test_erreur.R")
source("Script_table.R")
source("Script_SQL.R")

tar_option_set(
  packages = c("dplyr", "RSQLite", "lubridate", "data.table")
)

list(
  tar_target(
    name = dossier,
    command = "./donnees",
    format = "file"
  ),
  tar_target(
    name = g_b_brut,
    command = traiter_donnees(dossier)
  ),
  tar_target(
    name = g_b_nettoye,
    command = Col_supprime_modifie(g_b_brut)
  ),
  tar_target(
    name = g_b_final,
    command = test_erreurs(g_b_nettoye)
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
      creer_base_de_donnees_SQL(
        nom_bd = "lepidopteres.db",  
        table_obs = table_obs,
        table_temps = table_temps,
        table_droits = table_droits
      )
      "lepidopteres.db"
    },
    format = "file"
  )
  
)