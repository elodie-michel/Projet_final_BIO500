# Charger les fonctions
source("Script_prefusion.R")
source("Script_nettoyage.R")
source("Script_test_erreur.R")
source("Script_table.R")

# Lire les fichiers CSV 
dossier <- "./donnees"
liste_donnees <- lire_csv(dossier)

# Appliquer les différentes transformations
liste_donnees <- ajouter_temps_fictif(liste_donnees)
non_numeric_values <- verifier_values_non_numeriques(liste_donnees)

# Corriger les années spécifiques
liste_donnees <- corriger_annee(liste_donnees, index = which(names(liste_donnees) == "d_1985"), 1985)

liste_donnees <- corriger_annee(liste_donnees, index = which(names(liste_donnees) == "d_1987"), 1987)

# Convertir les colonnes year_obs et day_obs
liste_donnees <- convertir_annee_et_jour(liste_donnees)

# Fusionner les bases de données
g_b <- fusionner_donnees(liste_donnees)

# Nettoyer et convertir les colonnes spécifiques
g_b <- nettoyer_et_convertir_colonnes(g_b)

#Suprimer des colonnes non-nécessaire
# Liste des colonnes à supprimer
colonnes_a_supprimer <- c("obs_unit")

# Appliquer la fonction pour supprimer ces colonnes
g_b <- supprimer_colonnes_non_necessaires(g_b, colonnes_a_supprimer)

# Affichage des résultats
print(head(g_b))


#Tests pour retirer les erreurs potentielles de la base de données principale

#Test 1, pour enlever les NA dans les colonnes numériques
g_b <- enlever.na(g_b)

#Test 2, pour retirer les lignes identiques 
g_b <- supprimer_lignes_identiques(g_b)

#Test 3, pour filtrer les lignes selon les limites géographiques du monde entier
g_b <- filtrer_limites_geographiques (g_b)

#Test 4, pour supprimer les lignes avec des années erronées
g_b <- filtrer_limites_temporelles (g_b)

#Test 5, pour éliminer les valeurs de temps non-standard ou égal à zéro et changement en format HMS
g_b <- corriger_time_obs(g_b)


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
