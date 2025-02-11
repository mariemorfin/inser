# # read csv and extract language as named list
# translator <- read.csv(
#   file = system.file("template", "translation_2_utf8.csv", package = "inser"),
#   encoding =  "UTF-8",
#   sep = ";"
# )
#
# head(translator)
#
# new_tab<-data.frame(id="1_maps_figure",
#            description="The caption of the maps figure",
#            EN="Map of the study area (left) and locations of the fishing operations (right)",
#            FR="Carte de la zone d'étude (à gauche) et positions des opérations de pêche (à droite)")
#
# translator<-rbind.data.frame(translator,new_tab)
#
#
# path<- system.file("template", package = "inser")
#
# write.table(translator, file =paste(path,"translation_3_utf8.csv",sep="/"),fileEncoding =  "UTF-8",sep = ";")
