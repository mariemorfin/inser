###Fonction prep_sel_data()

##Prépare la base de donnée pour le calcul des indicateurs: 
#S'assure de la cohérence entre les 4 tables
#Sélection des marées /OP sur lesquelles réaliser la fiche
#Calcul les poids/effectifs élevés à partir des fractions échantillonnées si les infos
#manquent

library(tidyverse)

##Arguments: 
#data (mandatory): list of the four data.frame object 
#filters (optional): list of filters for 'project' (vector of character), vessel_identifier ('vessel'=vector),
#trip_code ('trip'= vector of numerics), station_number (station=vector), species
#to report in weights from landings and discards (species_LAN and species_DIS resp.), and species
#to report in size (species_length)

prep_sel_data<-function(data,filters=list(project="all",vessel="all",trip="all",station="all",species_LAN="all",species_DIS="all",species_length="all")){

  #Check if data is a list with four data.frames: 
  if(is.list(data)==FALSE)print("data is not a list")#STOP?
  if(length(data)!=4)print("data does not include 4 data.frames")
  TR<-data[[1]] 
  if(is.data.frame(TR)==FALSE)print("data does not include 4 data.frames")
  
  HH<-data[[2]] 
  if(is.data.frame(HH)==FALSE)print("data does not include 4 data.frames")
  
  SL<-data[[3]] 
  if(is.data.frame(SL)==FALSE)print("data does not include 4 data.frames")
  
  HL<-data[[4]]
  if(is.data.frame(HL)==FALSE)print("data does not include 4 data.frames")
  
  ##Filter the 4 tables
  if(filters$project!="all"){
    TR<-filter(TR,project %in% filters$project)
  }
  if(filters$vessel!="all"){
    TR<-filter(TR,vessel_identifier %in% filters$vessel)
  }
  if(filters$trip!="all"){
    TR<-filter(TR,trip_code %in% filters$trip)
  }
  if(filters$station!="all"){
    HH<-filter(HH,station_number %in% filters$station)
  }
  
  if("fishing_validity" %in% names(HH)){
    HH<-filter(HH,fishing_validity != "I")
  }
  
  if(filters$species_LAN!="all"){
    SL[SL$catch_category=="LAN",]<-filter(SL,catch_category=="LAN" & species %in% filters$species_LAN)
  }
  if(filters$species_DIS!="all"){
    SL[SL$catch_category=="DIS",]<-filter(SL,catch_category=="DIS" & species %in% filters$species_DIS)
  }
  if(filters$species_length!="all"){
    HL<-filter(HL,species %in% filters$species_length)
  }
  
  ###Combine the 4 data.frames
  
  #A) TR_HH: trip x Gear x FO 
  key_var<-c("project","vessel_identifier","trip_code","gear_label")
  var_bis<-names(TR)[is.na(match(names(TR),names(HH)))==FALSE]#shared fields
  var_bis<-var_bis[!(var_bis %in% key_var)]
  TR_HH<-left_join(TR,HH,by=key_var)
  
  ##On retire les champs doublons après avoir testé la cohérence des tables
  #Si test = FALSE, il y a des lignes qui n'ont pas le même valeur entre les tables
  if(length(var_bis)>0){
    for(ii in 1:length(var_bis)){
      idX<-which(names(TR_HH)==paste(var_bis[ii],".x",sep=""))
      idY<-which(names(TR_HH)==paste(var_bis[ii],".y",sep=""))
      test<-all(as.character(TR_HH[,idX]) == as.character(TR_HH[,idY]),na.rm=T)
      
      if(test==FALSE){print(paste("Attention problème de valeur dans",var_bis[ii]))}
      if(test==TRUE){
        names(TR_HH)[idX]<-var_bis[ii]
        TR_HH<-TR_HH[,-idY]
      }  
    }
  }
  
  
  #B) TR_HH_SL: trip x Gear x FO x species x fraction x sub-cat x sex 
  key_var<-c("project","vessel_identifier","trip_code","gear_label","station_number")
  var_bis<-names(TR_HH)[is.na(match(names(TR_HH),names(SL)))==FALSE]#shared fields
  var_bis<-var_bis[!(var_bis %in% key_var)]
  TR_HH_SL<-left_join(TR_HH,SL,by=key_var)
  
  ##On retire les champs doublons après avoir testé la cohérence des tables
  #Si test = FALSE, il y a des lignes qui n'ont pas le même valeur entre les tables
  if(length(var_bis)>0){
    for(ii in 1:length(var_bis)){
      idX<-which(names(TR_HH_SL)==paste(var_bis[ii],".x",sep=""))
      idY<-which(names(TR_HH_SL)==paste(var_bis[ii],".y",sep=""))
      test<-all(as.character(TR_HH_SL[,idX]) == as.character(TR_HH_SL[,idY]),na.rm=T)
      
      if(test==FALSE){print(paste("Attention problème de valeur dans",var_bis[ii]))}
      if(test==TRUE){
        names(TR_HH_SL)[idX]<-var_bis[ii]
        TR_HH_SL<-TR_HH_SL[,-idY]
      }  
    }
  }
  
  #Elevate the total weight if not already done? Mandatory for now
  # if(!("weight" %in% names(SL))){
  # 
  #   TR_HH_SL$weight[TR_HH_SL$catch_category=="DIS" & TR_HH_SL$subsampling_category=="H-Vrac"]<-with(filter(TR_HH_SL,catch_category=="DIS" & subsampling_category=="H-Vrac"),sample_weight)#DIS H-VRAC
  #   TR_HH_SL$weight[TR_HH_SL$catch_category=="DIS" & TR_HH_SL$subsampling_category!="H-Vrac"]<-with(filter(TR_HH_SL,catch_category=="DIS" & subsampling_category!="H-Vrac"),sample_weight/coef_discard)#DIS Vrac
  #   TR_HH_SL$weight[TR_HH_SL$catch_category=="LAN"]<-with(filter(TR_HH_SL,catch_category=="LAN"),subsample_weight/coef_subsampling)#LAN
  # }#else{
  #   # idNA<-which(is.na(TR_HH_SL$weight))
    # if(length(idNA)>0){
    #   TR_HH_SL$weight[idNA][]<-with(TR_HH_SL[idNA,],subsample_weight/frac_weight)
    #   TR_HH_SL$weight[idNA]<-with(TR_HH_SL[idNA,],subsample_weight/frac_weight)
    # }
  #}
  
  
  ### C) TR_HH_SL_HL: trip x Gear x FO x species x fraction x sub_cat x lan_cat x com_cat x sex 
  key_var<-c("project","vessel_identifier","trip_code","gear_label","station_number","species","catch_category")
  #Optional key fields: 
  opt_key_id<-match(c("landing_category","commercial_size_category","subsampling_category","sex"),names(HL))
  opt_key_id<-opt_key_id[which(is.na(opt_key_id)==FALSE)]
  
  if(length(opt_key_id)>0){opt_key_var<-names(HL)[opt_key_id]
  key_var<-c(key_var,opt_key_var)
  }
  
  var_bis<-names(TR_HH_SL)[is.na(match(names(TR_HH_SL),names(HL)))==FALSE]#shared fields
  var_bis<-var_bis[!(var_bis %in% key_var)]
  TR_HH_SL_HL<-left_join(TR_HH_SL,HL,by=key_var)
  
  
  ##On retire les champs doublons après avoir testé la cohérence des tables
  #Si test = FALSE, il y a des lignes qui n'ont pas le même valeur entre les tables
  if(length(var_bis)>0){
    for(ii in 1:length(var_bis)){
      idX<-which(names(TR_HH_SL_HL)==paste(var_bis[ii],".x",sep=""))
      idY<-which(names(TR_HH_SL_HL)==paste(var_bis[ii],".y",sep=""))
      test<-all(as.character(TR_HH_SL_HL[,idX]) == as.character(TR_HH_SL_HL[,idY]),na.rm=T)
      
      if(test==FALSE){print(paste("Attention problème de valeur dans",var_bis[ii]))}
      if(test==TRUE){
        names(TR_HH_SL_HL)[idX]<-var_bis[ii]
        TR_HH_SL_HL<-TR_HH_SL_HL[,-idY]
      }  
    }
  }
  
  #Elevate the number at lengths if not provided (no field or NA:
  #Mandatory: elevated_number_at_length in HL or subsample_weight + weight in SL
  
  if(!("elevated_number_at_length" %in% names(HL))){
    TR_HH_SL_HL$coef_subsampling<-TR_HH_SL_HL$subsample_weight/TR_HH_SL_HL$weight
    TR_HH_SL_HL$elevated_number_at_length<-TR_HH_SL_HL$number_at_length/TR_HH_SL_HL$coef_subsampling
  }else{
    idNA<-which(is.na(TR_HH_SL_HL$elevated_number_at_length))
    if(length(idNA)>0){
      TR_HH_SL_HL$coef_subsampling<-TR_HH_SL_HL$subsample_weight/TR_HH_SL_HL$weight
      TR_HH_SL_HL$elevated_number_at_length[idNA]<-(TR_HH_SL_HL$number_at_length/TR_HH_SL_HL$coef_subsampling)[idNA]
    }
  }
  
  ##Add all the optional fields if not already reported
  list<-c("vessel_name","selective_device","departure_date_time","return_date_time","headline_cumulative_length",
          "mesh_gauge_codend_mm","area","statistical_rectangle","pos_start_lat_dec","pos_stop_lat_dec","pos_start_lon_dec","pos_stop_lon_dec",
 "water_depth","start_sorting_date_time","end_sorting_date_time","diurnal_operation","gear_speed","gear_depth",
  "sea_state","wind_force","wind_cardinal_direction", "seabed_features","sub_gear_position", "catch_weight",
  "discard_weight")
  var<-list[which(!(list %in% names(TR_HH_SL_HL)))]
  if(length(var)>0){
    TAB_NA<-as.data.frame(matrix(NA,ncol=length(var),nrow=nrow(TR_HH_SL_HL)))
    names(TAB_NA)<-var
    TR_HH_SL_HL<-data.frame(TR_HH_SL_HL,TAB_NA)
  }
  return(TR_HH_SL_HL)
}

