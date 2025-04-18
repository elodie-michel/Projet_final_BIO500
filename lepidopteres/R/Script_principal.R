# Charger les fonctions
source("R/Script_prefusion.R")
source("R/Script_nettoyage.R")
source("R/Script_test_erreur.R")
source("R/Script_table.R")
source("R/Script_SQL.R")
source("R/Script_figure_1.R")
source("R/Script_figure_2.R")
source("R/Script_figure_3.R")

# Charger la carte du Québec pour le filtrage des coordonnées
library(sf)
quebec <- st_read("donnees/donnees_cartographiques/bordure_quebec.shp")

# Traitement de données
dossier <- "./donnees"
g_b_brut <- traiter_donnees(dossier)

#nettoyage 
# Utilise la valeur par défaut
g_b_nettoye<-nettoyer_les_donnees(g_b_brut)

#Tests pour retirer les erreurs potentielles de la base de données principale
g_b_final <- test_erreurs(g_b_nettoye, quebec)

#Étapes pour la création des tableaux 
table_g_b <- creer_tables(g_b_final)
table_obs <- table_g_b$table_obs
table_temps <- table_g_b$table_temps
table_droits <- table_g_b$table_droits

# Création de la base de données SQLite et insertion des données
creer_base_de_donnees_SQL("lepidopteres.db", table_obs, table_temps, table_droits)

#Créer la figure 1 de richesse spécifiques par année
figure_richesse_temporelle("R/lepidopteres.db")

#Créer la figure 2 de richesse spécifique spatiale 
figure_richesse_spatiale("R/lepidopteres.db", quebec)

#créer la figure 3 de phénologie 
figure_phenologie("R/lepidopteres.db", 10)
