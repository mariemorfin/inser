# WARNING - Generated by {fusen} from dev/flat_prep_sel_data.Rmd: do not edit by hand

#' prep_sel_data
#' 
#' @description
#' Transform and prepare the database in order to compute the indices of the create_selectivity_sheet() function.
#' 
#' Inputs are catch comparison data obtained from test and standard fishing gear.
#' 
#' Data are recorded under 4 tables:
#' TR table records all information relative to the fishing trial and the gear used;
#' HH table records all information relative to the fishing operation,
#' SL table records all information to the catch weight for each fraction (landings and discards, and eventually landing categories), species (mandatory) and eventually landing category or sex;
#' HL table records number of individuals for each length class.
#' 
#' Not all species are measured and/or weighted, but for a given species, the same level of information is required for each gear and fraction.
#' 
#' The create_selectivity_sheet() function ensures consistency between the 4 tables and allows for filtering on vessel/trial/fishing operation/species to create the summary sheet of the experiment.
#' 
#' The function computes raised numbers of individuals from sampled observed.
#' 
#' @details
#' If the field ‘elevated_number_at_length’ is not provided in HL or some values are missing, the function calculate them using ‘number_at_length’ and the ratio between the subsample_weight and the weight (table SL).
#' 
#' @param data list A list of four data.frames (TR,HH,SL,HL) based on the ICES RDB data exchange format corresponding to each level of the dataset. EU/ICES have defined common format and processing tools, for fisheries statistics.
#' For more details on the input data format, see the related vignette :
#' \code{vignette("selectivity-data", package = "inser")}
#' @param filters list A list of filters to apply on the dataset. The optional filters can apply directly on the fields ‘project’, ‘vessel_identifier’, ‘selective_device’, ‘trip_code’, ‘station_number’. For the fields ‘species_LAN’, ‘species_DIS’, and ‘species_length’, the filter apply on the landings (LAN), discards (DIS) and on the measured species, respectively.
#'
#' @importFrom dplyr filter left_join
#'
#' @return data.frame A data.frame object corresponding to the join of the four tables.
#' @export
#' @examples
#' ### Example for protocol 'twin'
#'
#' OTT_data_folder <-
#'   system.file("script_origin", "Data", "Example_OTT",
#'               package = "inser")
#'
#' TR <- readr::read_delim(
#'   file = file.path(OTT_data_folder, "TR.csv"),
#'   delim = ";",
#'   escape_double = FALSE,
#'   locale = readr::locale(encoding = "WINDOWS-1252"),
#'   trim_ws = TRUE
#' )
#'
#' HH <- read.table(
#'   file.path(OTT_data_folder, "HH.csv"),
#'   sep = ";",
#'   header = TRUE,
#'   encoding = "WINDOWS-1252"
#' )#,colClasses = colClasses)
#'
#' SL <- read.table(
#'   file.path(OTT_data_folder, "SL.csv"),
#'   sep = ";",
#'   header = TRUE,
#'   encoding = "WINDOWS-1252"
#' )
#'
#' HL <- read.table(
#'   file.path(OTT_data_folder, "HL.csv"),
#'   sep = ";",
#'   header = TRUE,
#'   encoding = "WINDOWS-1252"
#' )
#'
#' colClasses <- rep(NA, ncol(HH))
#' colClasses[which(names(HH) == "statistical_rectangle")] <-
#'   "character"
#'
#' HH <- read.table(
#'   file.path(OTT_data_folder, "HH.csv"),
#'   sep = ";",
#'   header = TRUE,
#'   colClasses = colClasses,
#'   encoding = "WINDOWS-1252"
#' )
#'
#' # HH<-HH |>
#' #   rename(pos_start_lat=pos_start_lat_dec) |>
#' #   rename(pos_start_lon=pos_start_lon_dec) |>
#' #     rename(pos_stop_lat=pos_stop_lat_dec) |>
#' #   rename(pos_stop_lon=pos_stop_lon_dec)
#' # 
#' # write.table(HH,file=  file.path(OTT_data_folder, "HH.csv"),row.names = F,sep=";")
#'
#'
#' TAB <- prep_sel_data(data = list(TR, HH, SL, HL))
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
  
  ##Remove duplicated fields after having tested tables consistencies
  #if test == FALSE: lines with not the same values between tables
  if(length(var_bis)>0){
    for(ii in 1:length(var_bis)){
      idX<-which(names(TR_HH)==paste(var_bis[ii],".x",sep=""))
      idY<-which(names(TR_HH)==paste(var_bis[ii],".y",sep=""))
      test<-all(as.character(TR_HH[,idX]) == as.character(TR_HH[,idY]),na.rm=T)
      
      if(test==FALSE){print(paste("Attention probl\u00e8me de valeur dans",var_bis[ii]))}
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
  
  ##Remove duplicated fields after having tested tables consistencies
  #if test == FALSE: lines with not the same values between tables
  if(length(var_bis)>0){
    for(ii in 1:length(var_bis)){
      idX<-which(names(TR_HH_SL)==paste(var_bis[ii],".x",sep=""))
      idY<-which(names(TR_HH_SL)==paste(var_bis[ii],".y",sep=""))
      test<-all(as.character(TR_HH_SL[,idX]) == as.character(TR_HH_SL[,idY]),na.rm=T)
      
      if(test==FALSE){print(paste("Attention probl\u00e8me de valeur dans",var_bis[ii]))}
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
  
  
  ##Remove duplicated fields after having tested tables consistencies
  #if test == FALSE: lines with not the same values between tables
  if(length(var_bis)>0){
    for(ii in 1:length(var_bis)){
      idX<-which(names(TR_HH_SL_HL)==paste(var_bis[ii],".x",sep=""))
      idY<-which(names(TR_HH_SL_HL)==paste(var_bis[ii],".y",sep=""))
      test<-all(as.character(TR_HH_SL_HL[,idX]) == as.character(TR_HH_SL_HL[,idY]),na.rm=T)
      
      if(test==FALSE){print(paste("Attention probl\u00e8me de valeur dans",var_bis[ii]))}
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
          "mesh_gauge_codend_mm","area","statistical_rectangle","pos_start_lat","pos_stop_lat","pos_start_lon","pos_stop_lon",
 "water_depth","start_sorting_date_time","end_sorting_date_time","diurnal_operation","gear_speed","gear_depth",
  "sea_state","wind_force","wind_cardinal_direction", "seabed_features","sub_gear_position", "catch_weight","discard_weight",
 "landing_category","commercial_size_category","subsampling_category","sex")
  
  var<-list[which(!(list %in% names(TR_HH_SL_HL)))]
  if(length(var)>0){
    TAB_NA<-as.data.frame(matrix(NA,ncol=length(var),nrow=nrow(TR_HH_SL_HL)))
    names(TAB_NA)<-var
    TR_HH_SL_HL<-data.frame(TR_HH_SL_HL,TAB_NA)
  }
  return(TR_HH_SL_HL)
}

