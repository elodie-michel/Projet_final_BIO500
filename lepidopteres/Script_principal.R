# Charger les fonctions
source("Script_prefusion.R")
source("Script_nettoyage.R")
source("Script_test_erreur.R")
source("Script_table.R")

# Traitement de données
dossier <- "./donnees"
g_b <- traiter_donnees(dossier)

#nettoyage 
g_b<-Col_supprimé_modifié(g_b)

# Affichage des résultats
print(head(g_b))

#Tests pour retirer les erreurs potentielles de la base de données principale
g_b <- test_erreurs(g_b)

#Étapes pour la création des tableaux 
table_g_b <- creer_tables(g_b)
table_obs <- table_g_b$table_obs
table_temps <- table_g_b$table_temps
table_droits <- table_g_b$table_droits


#install.packages('RSQLite')
library(RSQLite)
con <- dbConnect(SQLite(), dbname="lepidopteres.db")

creer_obs <-
  'CREATE TABLE observations (
id_obs INTEGER NOT NULL,
observed_scientific_name VARCHAR(100),
lat REAL,
lon REAL,
obs_value  INTERGER,
id_droits INTEGER NOT NULL,
PRIMARY KEY (id_obs)
);'
dbSendQuery(con, creer_obs)

creer_temps <-
  'CREATE TABLE temps (
id_obs INTEGER NOT NULL,
dwc_event_date DATE,
year_obs INTEGER,
day_obs INTEGER,
time_obs TIME,
PRIMARY KEY (id_obs),
FOREIGN KEY (id_obs) REFERENCES observations(id_obs)
);'
dbSendQuery(con, creer_temps)

creer_droits <-
  'CREATE TABLE droits (
id_droits INTEGER NOT NULL,
creator VARCHAR(100),
title VARCHAR(100),
publisher VARCHAR(100),
intellectual_rights VARCHAR(100),
license VARCHAR(100),
owner VARCHAR(100),
original_source VARCHAR(100),
PRIMARY KEY (id_droits),
FOREIGN KEY (id_droits) REFERENCES observations(id_droits)
);'
dbSendQuery(con, creer_droits)

# Injection des enregistrements dans la BD
dbWriteTable(con, append = TRUE, name = "observations", value = table_obs, row.names = FALSE)
dbWriteTable(con, append = TRUE, name = "temps", value = table_temps, row.names = FALSE)
dbWriteTable(con, append = TRUE, name = "droits", value = table_droits, row.names = FALSE)
