# Charger les fonctions
source("Script_prefusion.R")
source("Script_nettoyage.R")
source("Script_test_erreur.R")
source("Script_table.R")
source("Script_SQL.R")

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

# Création de la base de données SQLite et insertion des données
creer_base_de_donnees_SQL("lepidopteres.db", table_obs, table_temps, table_droits)
