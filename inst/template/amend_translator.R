# read csv and extract language as named list
translator <- read.csv(
  file = system.file("template", "translation_3_utf8.csv", package = "inser"),
  encoding =  "UTF-8",
  sep = ";"
)

head(translator)

translator[translator$id=="2_1_subtitle_frac_weight",]$EN<-"Catch weights by fraction (landings/discards)"
translator[translator$id=="2_2_subtitle",]$FR<-"Comparaison des poids débarqués et rejetés par espèce"


translator |> filter(id=="2_1_sorting_var1")

new_tab<-data.frame(id="2_2_discard_rate_STD",
                    description="Reporting sentence for the mean discarding rate by FO for the STD gear",
                    EN="The mean discarding rate by fishing operation is %i % for the standard gear.",
                    FR="Le taux de rejet moyen par opération de pêche est de %i % pour l'engin standard.")


translator<-rbind.data.frame(translator,new_tab)

path<- system.file("template", package = "inser")

write.table(translator, file =paste(path,"translation_3_utf8.csv",sep="/"),fileEncoding =  "UTF-8",sep = ";")

translator
