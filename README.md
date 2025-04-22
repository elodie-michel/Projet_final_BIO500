# BIO500 Lépidoptères : Création de la base de données des différentes espèces de lépidoptères observées au Québec

**Description du projet**

Dans le cadre du projet BIO500, du cours Méthodes en écologie computationnelle, nous avons été appelé à faire le nettoyage, l'analyse ainsi que la présentation des résultats des données récoltées sur la biodiversité de lépidoptères retrouvées au Québec entre les années 1859 et 2023.

Pour ce faire, nous avons commencé par rassembler l'ensemble des fichiers de données, pour ainsi favoriser la vérification et le nettoyage de ces dernières et finalement créer une base de données communes accessible à plusieurs autres personnes permettant la reproductibitlité de notre travail.

Par la suite, une fois la base de données préparée et prête à utilisation, nous avons établi des figures expliquant l'évolution de la richesse spécifique de lépidoptères sur les dernières années et l'ensembles des années de récolte sur le terrain autant saptialement que temporellement pour finalement présenter une figure expliquant les dates d'arriver et de départ, sur une seule année, des 10 espèces les plus abondantes.

Le tout permettant de répondre à la question initiale qui est :  Comment les variations spatiales et temporelles influencent-elles la structure des communautés de lépidoptères ?

**Structure du répertoire**

Notre travail est séparé de la façon suivante:

```
├── donnees                                             
│     ├── fichiers.csv                                      # L'ensemble des données
│     ├── donnees_cartographiques                           # Données pour la carte du Québec
│ 
├── R                                                   
│     ├── Scripts R                                         # Contient les fonctions d'exécution du code 
│ 
├── rapport_final_BIO500                                   
│     ├── rapport_final_BIO500.Rmd                          # Fichier RMarkdown 
│     ├── rapport_final_BIO500.pdf                          # Pdf du rapport final créé par le RMarkdown
│
├── _targets.R                                              # Fichier targets qui défini le pipeline
│
├── .gitignore                                              # Fichier qui spécifie les fichiers à ignorer 
│
├── README.md                                               # Contient la description et instruction du projet
```


Dans le dossier donnees, on retrouve plusieurs fichiers CSV. Il s'agit des fichiers de données pour chacune des années de récolte sur le terrain. On retrouve également un sous-dossier donnees_cartographiques qui sert à construire la carte du Québec pour la deuxième figure.

Dans le dossier R, on retrouve tous les scripts contenant une fonction chacun, pour l'exécution du code. Au total, il y a 8 scripts.

    a) Script_figure_1.R
    b) Script_figure_2.R
    c) Script_figure_3.R
    d) Script_prefusion.R
    e) Script_nettoyage.R
    f) Script_test_erreur.R
    g) Script_table.R
    h) Script_SQL.R
    
Dans le dossier rapport_final_BIO500, on retrouve le fichier contenant le RMarkdown ainsi que le pdf le rapport en pdf.

Dans le dossier targets, on retrouve le dossier rattachant les métadonnées et le dossier contenant les objets retrouvés dans le Target.  

**Description des fichiers**

Le fichier le plus important est le fichier _targets.R. En effet, ce fichier contient l'entiereté du pipeline et est essentiel pour pouvoir exécuté tout le projet.

Les autres fichiers importants sont les suivants: 

a) Script_figure_1.R: Ça créer une base de données à partir de langage SQL pour former la figure 1.

b) Script_figure_2.R: Ça créer une base de données à partir de langage SQL pour former la figure 2.

c) Script_figure_3.R: Ça créer une base de données à partir de langage SQL pour former la figure 3.

d) Script_prefusion.R: Sert à mettre ensemble les fichiers csv qui se trouve dans le dossier donnees.

e) Script_nettoyage.R: Contient une fonction pour nettoyer les données d'observations de lépidoptères où bd est le nom donnée à la base de données. 

f) Script_test_erreur.R: Contient une fonction pour tester et marquer les erreurs dans une base de données.

g) Script_table.R: Contient une fonction qui crée les 3 tables (table_obs, table_temps et table_droits) dans R à partir d'une base de données nettoyée.

h) Script_SQL.R: Contient la fonction pour créer une base de données SQLite contenant trois tables : observations, temps et droits.

**Description des variables**

Voici le contenu de chaque table qui ont été créées avec SQLite:


Table observations: 

- id_obs: Créer une liste de 1 à nombre d'observations maximale pour avoir une identification unique pour chaque observation

- observed_scientific_name:  Nom scientifique de l'espèce observée

- lat: Latitude de l'observation

- lon: Longitude de l'observation

- obs_value: Valeur observée

- id_droits: Créer une liste où chaque observation est une combinaison unique des auteur des données, titre du jeu de données dont les données sont extraites, des éditeur des données, des droits intellectuels, des licence des données et des propriétaire des données


Table temps:

- id_obs: Créer une liste de 1 à nombre d'observations maximale pour avoir une identification unique pour chaque observation

- dwc_event_date: Date de l'observation

- year_obs: Année de l'observation

- day_obs: Jour de l'observation

Table droits: 

- id_droits: Créer une liste où chaque observation est une combinaison unique des auteur des   données, titre du jeu de données dont les données sont extraites, des éditeur des données, des droits intellectuels, des licence des données et des propriétaire des données.
creator` Auteur des données

- titre: Titre du jeu de données dont les données sont extraites

- publisher: Éditeur des données

- intellectual_rights: Droits intellectuels

- license: Licence des données

- owner:Propriétaire des données

- original_source: Source originale des données


**Instruction pour l'exécution du code dans le logiciel R**

Préalablement, assurez-vous d'avoir bien choisi votre Set Working Directory afin qu'il soit dans le Projet_final_BIO500.


Par la suite pour l'exécution du code, veuillez-vous assurer d'avoir installé les packages suivant : 

Library(dplyr)
Library(RSQLite)
Library(data.table)
Library(lubridate) 
Library(sf)
Library(DBI)
Library(ggplot2)
Library(lubridate)
Library(targets)
Library(tarchetypes)
Library(rmarkdown)


Ensuite, ouvrir le fichier _targets.R, qui définit le pipeline et puis faire la commande tar_make dans la console du logiciel R. 


Enfin, l'ensemble des étapes du code sera exécuté et vous obtiendrez les figures (phenologie.png, richesse_saptial.png et richesse_temporelle.png) ainsi que le rapport_final_BIO500.pdf rattaché au travail.

**Auteurs et contributeurs**

Éloïse Paquette, Danaé Vaillancourt, Élodie Michel et Camille Breton
