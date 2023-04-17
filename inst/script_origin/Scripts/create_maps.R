##Called in create_selectivity_sheet()

create_maps<-function(data,zones = NULL,protocol){

##Create two maps: Map and Zoom
  
  ###Map
if(length(zones)!=0){
    #identify the polygons corresponding to the study area
    ind_zones<-match(zones,paste(ICES_areas2$SubArea, ICES_areas2$Division,sep="."))
    SPs<-SpatialPolygons(ICES_areas2@polygons[ind_zones])
    
    MyDF<-data.frame(Area=zones)
    row.names(MyDF) =row.names(ICES_areas2@data)[ind_zones]
    
    ZoneMer<-SpatialPolygonsDataFrame(SPs,data=MyDF)
    ZoneMer_f<-tidy(ZoneMer)
    

  ICESp<-ggplot() +coord_quickmap()+theme_light()+
    theme(axis.text=element_text(size=18),axis.title = element_text(size=20))+
    annotation_map(map_data("world"),alpha=0.5,fill="grey",col="white")+ #Add the map as a base layer before the points
    geom_polygon(data = ZoneMer_f, aes( x = long, y = lat, group = group), alpha=0.5,fill="#69b3a2", color="white")
  
  df_ICES<-data.frame(x=c(-2,-4,0,-4,-7),y=c(45,47,50.2,49.5,49),name=zones)
  #Comment positionner les labels?
  
  lon_min<-floor(ZoneMer@bbox[1,1])
  lon_max<-ceiling(ZoneMer@bbox[1,2])
  lat_min<-floor(ZoneMer@bbox[2,1])
  lat_max<-ceiling(ZoneMer@bbox[2,2])
  by_lat<-round((lat_max-lat_min)/5)
  by_lon<-round((lon_max-lon_min)/5)
  
  rangeX<-with(TAB,abs(min(pos_start_lon_dec,pos_stop_lon_dec)-max(pos_start_lon_dec,pos_stop_lon_dec)))
  rangeY<-with(TAB,abs(min(pos_start_lat_dec,pos_stop_lat_dec)-max(pos_start_lat_dec,pos_stop_lat_dec)))
  xlim=with(TAB,c(min(pos_start_lon_dec,pos_stop_lon_dec)-0.15*rangeX,max(pos_start_lon_dec,pos_stop_lon_dec)+0.15*rangeX))
  ylim=with(TAB,c(min(pos_start_lat_dec,pos_stop_lat_dec)-0.15*rangeY,max(pos_start_lat_dec,pos_stop_lat_dec)+0.15*rangeY) )
  
  
  Map<-ICESp+
    geom_text(data=df_ICES,aes(x=x,y=y,label=name),col="white",fontface=3)+
    geom_rect(mapping=aes(xmin =xlim[1], xmax = xlim[2], ymin =ylim[1], ymax =ylim[2]), fill = NA, colour = "#1b98e0", linewidth = 1)+
       coord_sf( expand = TRUE,crs = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
    
  }else{
    areas<-unique(TAB$area) 
    if(length(which( is.na(areas)==FALSE)) >0) {
      #Area level 3 (level 4 for Baltic, Mediterranean, and Black Seas) in the Data Collection Regulation (EC, 2008a, 2008b).
      #=> Voir comment récupérer les zones correspondantes. 
      
      #Il y a aussi le champs "subpolygon: National level as defined by each country as child nodes (substratification) 
      #of the ICES rectangles. It is recommended that this is coordinated internationally, e.g. through the Regional Coordination Meetings (EC RCMs).
      
    }
  }
  
 
  ##Ajouter un test pour vérifier qu'au moins une OP est localisée
  PosX<-seq(floor(xlim[1]),ceiling(xlim[2]),5/60)
  Deg<-ceiling(PosX)
  Min<-round((Deg-PosX)*60)
  LabX<-str_c(Deg,"°",Min,"'W")
  idX<-which(PosX >= xlim[1]  & PosX <= xlim[2])
  
  PosY<-seq(floor(ylim[1]),ceiling(ylim[2]),5/60)
  Deg<-floor(PosY)
  Min<-round((PosY-Deg)*60)
  LabY<-str_c(Deg,"°",Min,"'N")
  idY<-which(PosY >= ylim[1]  & PosY <= ylim[2])
  
  if(protocol=="twin"){
  Pos_Start<- TAB %>% group_by(project,vessel_identifier,trip_code,station_number)%>%
    summarize(Lat=unique(pos_start_lat_dec),Lon=unique(pos_start_lon_dec))
  Pos_Start$order<-"start"
  Pos_Stop<- TAB %>% group_by(project,vessel_identifier,trip_code,station_number)%>%
    summarize(Lat=unique(pos_stop_lat_dec),Lon=unique(pos_stop_lon_dec))
  Pos_Stop$order<-"end"
  Pos_Station<-rbind(Pos_Start,Pos_Stop)
  Pos_Station$id_station<-with(Pos_Station,paste(project,vessel_identifier,trip_code,station_number))
  
  Zoom<-ggplot() +coord_quickmap()+theme_classic()+
    theme(panel.border = element_rect(color = "#1b98e0", fill = NA,linewidth = 3))+
    annotation_map(map_data("world"),alpha=0.5,fill="grey",col="white")+ #Add the map as a base layer before the points
    geom_polygon(data = ZoneMer_f, aes( x = long, y = lat, group = group), alpha=0.2,fill="#69b3a2", color="white")+
    geom_text(data=df_ICES,aes(x=x,y=y,label=name),col="white",fontface=3)+
    coord_sf(xlim = xlim, ylim = ylim, expand = FALSE,crs = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")) +
    geom_line(data=Pos_Station,aes(group =id_station,x=Lon,y=Lat),color="grey",
              arrow = arrow(type = "closed",length=unit(0.075, "inches")))#+
    #scale_x_continuous("longitude",breaks = PosX[idX], labels=LabX[idX]) + 
    #scale_y_continuous("latitude", breaks = PosY[idY], labels = LabY[idY])
  }
  
  if(protocol=="paired"){
      Pos_Start<- TAB %>% group_by(project,vessel_identifier,trip_code,tag_operation,station_number,gear_label)%>%
        summarize(Lat=unique(pos_start_lat_dec),Lon=unique(pos_start_lon_dec))
      Pos_Start$order<-"start"
      Pos_Stop<- TAB %>% group_by(project,vessel_identifier,trip_code,tag_operation,station_number,gear_label)%>%
        summarize(Lat=unique(pos_stop_lat_dec),Lon=unique(pos_stop_lon_dec))
      Pos_Stop$order<-"end"
      Pos_Station<-rbind(Pos_Start,Pos_Stop)
      Pos_Station$id_station<-with(Pos_Station,paste(project,vessel_identifier,trip_code,tag_operation,station_number))
      
      Zoom<-ggplot() +coord_quickmap()+theme_classic()+
        theme(legend.position="bottom",panel.border = element_rect(color = "#1b98e0", fill = NA,linewidth = 3))+
        guides(col = FALSE)  +
        xlab("")+ylab("")+
        labs(linetype="Engin")+
        annotation_map(map_data("world"),alpha=0.5,fill="grey",col="white")+ #Add the map as a base layer before the points
        geom_polygon(data = ZoneMer_f, aes( x = long, y = lat, group = group), alpha=0.2,fill="#69b3a2", color="white")+
        geom_text(data=df_ICES,aes(x=x,y=y,label=name),col="white",fontface=3)+
        coord_sf(xlim = xlim, ylim = ylim, expand = TRUE,crs = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")) +
        geom_line(data=Pos_Station,aes(group =id_station,x=Lon,y=Lat,color=as.factor(tag_operation),linetype=gear_label),
                  arrow = arrow(type = "closed",length=unit(0.075, "inches")))
    }
    
  
  if(protocol=="unpaired"){
    Pos_Start<- TAB %>% group_by(project,vessel_identifier,trip_code,station_number,gear_label)%>%
      summarize(Lat=unique(pos_start_lat_dec),Lon=unique(pos_start_lon_dec))
    Pos_Start$order<-"start"
    Pos_Stop<- TAB %>% group_by(project,vessel_identifier,trip_code,station_number,gear_label)%>%
      summarize(Lat=unique(pos_stop_lat_dec),Lon=unique(pos_stop_lon_dec))
    Pos_Stop$order<-"end"
    Pos_Station<-rbind(Pos_Start,Pos_Stop)
    Pos_Station$id_station<-with(Pos_Station,paste(project,vessel_identifier,trip_code,station_number))
    
    Zoom<-ggplot() +coord_quickmap()+theme_classic()+
      theme(legend.position="bottom",axis.text=element_text(size=18),legend.title=element_text(size=20),
          legend.text = element_text(size=18),  
      panel.border = element_rect(color = "#1b98e0", fill = NA,linewidth = 3))+
      guides(col = FALSE)  +
      xlab("")+ylab("")+
      labs(linetype="Engin")+
      annotation_map(map_data("world"),alpha=0.5,fill="grey",col="white")+ #Add the map as a base layer before the points
      geom_polygon(data = ZoneMer_f, aes( x = long, y = lat, group = group), alpha=0.2,fill="#69b3a2", color="white")+
      geom_text(data=df_ICES,aes(x=x,y=y,label=name),col="white",fontface=3)+
      coord_sf(xlim = xlim, ylim = ylim, expand = TRUE,crs = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")) +
      geom_line(data=Pos_Station,aes(group =id_station,x=Lon,y=Lat,color=as.factor(trip_code),linetype=gear_label),
                arrow = arrow(type = "closed",length=unit(0.075, "inches")))
  }
  
  Maps<-ggarrange(Map,Zoom)
 
  
  return(Maps)
}
  