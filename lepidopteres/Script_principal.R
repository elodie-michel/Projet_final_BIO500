# Charger les fonctions
source("Script_prefusion.R")
source("Script_nettoyage.R")
source("Script_test_erreur.R")
source("Script_table.R")
source("Script_SQL.R")

# Traitement de données
dossier <- "./donnees"
g_b_brut <- traiter_donnees(dossier)

#nettoyage 
# Utilise la valeur par défaut
g_b_nettoye<-nettoyer_les_donnees(g_b_brut)

#Tests pour retirer les erreurs potentielles de la base de données principale
g_b_final <- test_erreurs(g_b_nettoye)

#Étapes pour la création des tableaux 
table_g_b <- creer_tables(g_b_final)
table_obs <- table_g_b$table_obs
table_temps <- table_g_b$table_temps
table_droits <- table_g_b$table_droits

# Création de la base de données SQLite et insertion des données
creer_base_de_donnees_SQL("lepidopteres.db", table_obs, table_temps, table_droits)
