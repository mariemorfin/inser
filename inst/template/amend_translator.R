# read csv and extract language as named list
translator <- read.csv(
  file = system.file("template", "translation_3_utf8.csv", package = "inser"),
  encoding =  "UTF-8",
  sep = ";"
)

head(translator)

translator[translator$id=="2_2_discard_rate_STD",]$EN<-"The mean discarding rate by fishing operation is %i %% for the standard gear."
translator[translator$id=="2_2_discard_rate_STD",]$FR<-"Le taux de rejet moyen par opération de pêche est de %i %% pour l'engin standard."


translator[translator$id=="2_2_discard_rate_TEST",]$EN<-"The mean discarding rate by fishing operation is %i %% for the test gear."
translator[translator$id=="2_2_discard_rate_TEST",]$FR<-"Le taux de rejet moyen par opération de pêche est de %i %% pour l'engin test."


translator[translator$id=="2_1_sorting_var2",]$EN<-"A %s of %i %% of the sorting time is observed when considering the mean sorting time."
translator[translator$id=="2_1_sorting_var2",]$FR<-"Une %s de %i %% de la durée de tri est observée avec l'engin test en considérant la durée moyenne."




translator |> filter(id=="2_1_sorting_var1")

new_tab<-data.frame(id="2_2_discard_rate_TEST",
                    description="Reporting sentence for the mean discarding rate by FO for the TEST gear",
                    EN="The mean discarding rate by fishing operation is %i % for the test gear.",
                    FR="Le taux de rejet moyen par opération de pêche est de %i % pour l'engin test.")


translator<-rbind.data.frame(translator,new_tab)

path<- system.file("template", package = "inser")

write.table(translator, file =paste(path,"translation_3_utf8.csv",sep="/"),fileEncoding =  "UTF-8",sep = ";")

translator
