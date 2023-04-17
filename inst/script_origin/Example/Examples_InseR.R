###Exemples d'utilisation du package InseR

##### Formatage des données + Fiches de sélectivité

setwd("inst/script_origin")

#library(sp)#Est chargé automatiquement avec load ci-dessous

#Package functions
source("Scripts/prep_sel_data.R")
source("Scripts/create_selectivity_sheet.R")
source("Scripts/create_maps.R")#Fonction interne au package

##ICES areas
load("Data/ICES_areas/ICES_areas2.Rdata",verbose=T)#SpatialPolygonsDataFrame => load sp package

###A. Example for protocol 'twin'
TR <- readr::read_delim(
  file = "Data/Example_OTT/TR.csv",
  delim = ";",
  escape_double = FALSE,
  locale = locale(encoding = "WINDOWS-1252"),
  trim_ws = TRUE
)
HH<-read.table("Data/Example_OTT/HH.csv",sep=";",header=T, encoding = "WINDOWS-1252")#,colClasses = colClasses)
SL<-read.table("Data/Example_OTT/SL.csv",sep=";",header=T, encoding = "WINDOWS-1252")
HL<-read.table("Data/Example_OTT/HL.csv",sep=";",header=T, encoding = "WINDOWS-1252")

colClasses<-rep(NA,ncol(HH))
colClasses[which(names(HH)=="statistical_rectangle")]<-"character"

HH<-read.table("Data/Example_OTT/HH.csv",sep=";",header=T,colClasses = colClasses, encoding = "WINDOWS-1252")

###Merge the 4 tables in a unique table, while testing for inconsistencies
#Filter on vessel, project, trip, station, species
#by default, all the data are included

TAB<-prep_sel_data(data=list(TR,HH,SL,HL))

###Create the selectivity sheet on the dataset TAB

#For species analyzed in length, we can provide the minimum targeted length for selectivity
#(e.g., MCRS) for graphics and statistics (species_length)
min_length<-data.frame(species=unique(TAB$species),min_length=c(27,24,20,NA,27,NA))
#Contour de la zone d'étude: merge des zones 8a, 8b, "7.d","7.e","7.h" => voir comment on parametrise
zones<-c("8.a","8.b","7.d","7.e","7.h")

create_selectivity_sheet(data=TAB,output_dir="Example/Outputs",output_file="fiche_InseR_twin",protocol="twin",language="FR",zones=zones,min_length=min_length)


### B. Example for OTB, protocol="paired"
#Read dataset
TR <- readr::read_delim(
  file = "Data/Example_OTT/TR.csv",
  delim = ";",
  escape_double = FALSE,
  locale = locale(encoding = "WINDOWS-1252"),
  trim_ws = TRUE
)
HH<-read.table("Data/Example_OTB_alternate/HH.csv",sep=";",header=T)#,colClasses = colClasses)
SL<-read.table("Data/Example_OTB_alternate/SL.csv",sep=";",header=T)
HL<-read.table("Data/Example_OTB_alternate/HL.csv",sep=";",header=T)

colClasses<-rep(NA,ncol(HH))
colClasses[which(names(HH)=="statistical_rectangle")]<-"character"

HH<-read.table("Data/Example_OTB_alternate/HH.csv",sep=";",header=T,colClasses = colClasses)

#Concatenate the four datasets in a unique one
TAB<-prep_sel_data(data=list(TR,HH,SL,HL))

#Create a selectivity sheet for the 'paired' protocol
create_selectivity_sheet(data=TAB,output_dir="Example/Outputs",output_file="fiche_InseR_paired",protocol="paired",language="FR",zones=zones,min_length=min_length)

### C. Example for OTB, protocol="unpaired"

create_selectivity_sheet(data=TAB,output_dir="Example/Outputs",output_file="fiche_InseR_unpaired",protocol="unpaired",language="FR",zones=zones,min_length=min_length)


