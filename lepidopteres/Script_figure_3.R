library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)
library(lubridate)

# Connexion à la base
con <- dbConnect(SQLite(), "lepidopteres.db")

# Requête pour obtenir les dates d’observation
requete <- "
SELECT o.observed_scientific_name AS taxa_name,
       t.dwc_event_date AS date_obs
FROM observations o
JOIN temps t ON o.id_obs = t.id_obs
WHERE t.dwc_event_date IS NOT NULL
"

data <- dbGetQuery(con, requete)

# Mise en forme
data <- data %>%
  mutate(date_obs = as.Date(date_obs),
         jour_annee = yday(date_obs),
         annee = year(date_obs))

# Calcul des moyennes pour chaque espèce
summary_data <- data %>%
  group_by(taxa_name, annee) %>%
  summarise(start_day = min(jour_annee), end_day = max(jour_annee), .groups = "drop") %>%
  group_by(taxa_name) %>%
  summarise(start_jour_moyen = round(mean(start_day)),
            end_jour_moyen = round(mean(end_day)),
            presence_days = end_jour_moyen - start_jour_moyen,
            .groups = "drop") %>%
  mutate(start_date = as.Date(start_jour_moyen, origin = "2023-01-01"),
         end_date = as.Date(end_jour_moyen, origin = "2023-01-01")) %>%
  arrange(desc(presence_days)) %>%
  slice_head(n = 10)

# Graphique
ggplot(summary_data, aes(y = reorder(taxa_name, presence_days), x = start_date, xend = end_date)) +
  geom_segment(aes(yend = taxa_name), color = "#8888aa", linewidth = 1.2) +  # ligne douce bleu-gris
  
  geom_point(aes(x = start_date), color = "#1f78b4", size = 4) +  # Début observation (bleu)
  geom_point(aes(x = end_date), color = "#e66101", size = 4) +    # Fin observation (orange)
  
  # Dates SOUS les points
  geom_text(aes(x = start_date, label = format(start_date, "%d %b")),
            vjust = 2, color = "#1f78b4", fontface = "bold", size = 3.5) +
  geom_text(aes(x = end_date, label = format(end_date, "%d %b")),
            vjust = 2, color = "#e66101", fontface = "bold", size = 3.5) +
  
  # Encadré gris et jours de présence
  annotate("rect", xmin = max(summary_data$end_date) + 10, xmax = max(summary_data$end_date) + 40, 
           ymin = 0.5, ymax = nrow(summary_data) + 0.5, fill = "gray50", alpha = 0.8) +
  annotate("text", x = max(summary_data$end_date) + 25, y = nrow(summary_data) + 1, 
           label = "Jours de présence", color = "white", fontface = "bold", size = 5) +
  geom_text(aes(x = max(summary_data$end_date) + 25, y = taxa_name, 
                label = presence_days), color = "white", fontface = "bold", size = 5) +
  
  # Légende visuelle
  #description "Jours de présence" en haut à droite
  annotate("text", x = max(summary_data$end_date) + 10, y = nrow(summary_data) + 1, 
           label = "Jours de présence", color = "gray20", fontface = "italic", size = 5) +
  
  annotate("point", x = min(summary_data$start_date) - 30, y = nrow(summary_data) + 1, 
           color = "#1f78b4", size = 4) +  # Arrivée moyenne (déplacé plus bas)
  annotate("text", x = min(summary_data$start_date) - 25, y = nrow(summary_data) + 1, 
           label = "Arrivée moyenne", hjust = 0, color = "#1f78b4", fontface = "bold", size = 4) +
  annotate("point", x = min(summary_data$start_date) - 30, y = nrow(summary_data) + 0.50 , 
           color = "#e66101", size = 4) +  # Départ moyen (déplacé plus bas)
  annotate("text", x = min(summary_data$start_date) - 25, y = nrow(summary_data) + 0.50 , 
           label = "Départ moyen", hjust = 0, color = "#e66101", fontface = "bold", size = 4) +
  
  expand_limits(y = nrow(summary_data) + 1.5) +
  
  scale_x_date(date_labels = "%B", date_breaks = "1 month") +
  labs(y = NULL, x = NULL, title = "Phénologie moyenne des 5 espèces les plus observées") +
  theme_minimal(base_size = 16) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(margin = margin(r = 10)),
        plot.title = element_text(size = 18, face = "bold"))
