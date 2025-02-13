# read csv and extract language as named list
translator <- read.csv(
  file = system.file("template", "translation_3_utf8.csv", package = "inser"),
  encoding =  "UTF-8",
  sep = ";"
)

head(translator)

# translator[which(translator$id=="3_escapement") ,]$FR="Taux d'échappement (%) de l'engin test par rapport au standard."
# translator[which(translator$id=="3_escapement") ,]$EN="Escapement rate (%) of the test gear compared to the standard gear."
#
# translator[which(translator$id=="2_2_LAN_table_caption") ,]$FR="Résultats des tests de différence de poids débarqués de l'engin test par rapport à l'engin standard, pour chaque espèce. La statistique testée est identifiée par '*'. Plus la p-value est faible, plus la différence est significative."
# translator[which(translator$id=="2_2_LAN_table_caption") ,]$EN="Results of the comparison tests on the landed weights of the tested compared to the standard gear, for each species. The tested statistic is identified by '*'. The lower the p-value, the more significant is the difference."
#
#
# new_tab<-data.frame(id="3_2_figure_caption",
#            description="Reporting sentence for discarding rate",
#            EN="Elevated relative selectivity for each length class. The point size is proportionnal to the sample size. If present, the green dashed line indicates the minimum commercial size.",
#            FR="Sélectivité relative estimée par élévation pour chaque classe de taille. La taille des points est proportionnelle à l'effectif sous-jaçent. Si elle apparaît, la ligne verticale verte indique la taille minimale de débarquement.")




new_tab<-data.frame(id="2_2_discard_rate",
                    description="Reporting sentence for the mean discarding rate by FO",
                    EN="The mean discarding rate by fishing operation is ",
                    FR="Le taux de rejet moyen par opération de pêche est de ")


new_tab<-data.frame(id="2_1_landing_weight_labs",
                    description="Figure axis label for the landings weight",
                    EN="Landings weight by catch (kg) ",
                    FR="Poids des débarquements par capture (kg)")

#
# new_tab<-data.frame(id="1_maps_figure",
#                     description="Reporting sentence for discarding rate",
#                     EN="Map of the study area (left) and locations of the fishing operations (right).",
#                     FR="Carte de la zone d’étude (à gauche) et positions des opérations de pêche (à droite).")

translator<-rbind.data.frame(translator,new_tab)


path<- system.file("template", package = "inser")

write.table(translator, file =paste(path,"translation_3_utf8.csv",sep="/"),fileEncoding =  "UTF-8",sep = ";")

