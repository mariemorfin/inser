
library(knitr)
library(rmarkdown)
library(ggpubr)
library(tidyverse)
library(broom)

create_selectivity_sheet<-function(data,protocol,output_dir = NULL,output_file = NULL,min_length = NULL,language="EN",zones = NULL){
  #How to make by default the same parameters as in the render() function?

  ##Control function parameters?
  
  ##Mapping : A mettre dans le Rmd? (comme scripts Rmd séparés par language + protocol, 
  ##Comment faire si ni zones ni area sont renseignées ?
  
  Maps<-create_maps(data,zones,protocol)

  if(protocol=="twin"){
    if(language=="EN"){
      rmarkdown::render("Scripts/selectivity_sheet_twin_EN.Rmd",output_dir = output_dir,output_file = output_file)
    }
    if(language=="FR"){
      rmarkdown::render("Scripts/selectivity_sheet_twin_FR.Rmd",output_dir = output_dir,output_file = output_file)
    }
  }

  if(protocol=="paired"){
    if(language=="EN"){
      rmarkdown::render("Scripts/selectivity_sheet_paired_EN.Rmd",output_dir = output_dir,output_file = output_file)
    }
    if(language=="FR"){
      rmarkdown::render("Scripts/selectivity_sheet_paired_FR.Rmd",output_dir = output_dir,output_file = output_file)
    }
  }
  
  if(protocol=="unpaired"){
    if(language=="EN"){
      rmarkdown::render("Scripts/selectivity_sheet_unpaired_EN.Rmd",output_dir = output_dir,output_file = output_file)
    }
    if(language=="FR"){
      rmarkdown::render("Scripts/selectivity_sheet_unpaired_FR.Rmd",output_dir = output_dir,output_file = output_file)
    }
  }

  
}
