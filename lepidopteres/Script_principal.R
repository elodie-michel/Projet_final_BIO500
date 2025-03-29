# Charger les fonctions
source("Script_prefusion.R")
source("Script_nettoyage.R")
source("Script_test_erreur.R")
source("Script_table.R")

# Traitement de données
dossier <- "./donnees"
g_b <- traiter_donnees(dossier)

# Affichage des résultats
print(head(g_b))

#Tests pour retirer les erreurs potentielles de la base de données principale
g_b <- test_erreurs(g_b)

#Étapes pour la création des tableaux 

#Création nouvelle colonne "id_obs" dans la base de données
g_b <- ajouter_id_obs(g_b)

#Création d'un identifiant "id_droits" pour chaque combinaison de colonne "creator, publisher, title, etc."
g_b <- ajouter_id_droits(g_b)

#Création de la table des observations (id_obs,id_droits, observed_scientific_name, lat, lon, obs_value)
table_obs <- creer_table_1(g_b)

#Création de la table temporelle (id_obs, dwc_event_date, year_obs, day_obs, time_obs)
table_temps <- creer_table_2 (g_b)

#Création de la table des droits (id_droits, creator, title, publisher, intellectual_rights, license, owner, original_source)
table_droits <- creer_table_3(g_b)


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
