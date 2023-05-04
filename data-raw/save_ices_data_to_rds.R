library(sf)

# Save ICES Data in sf format (rds)
# original data can be downloaded from:
# https://gis.ices.dk/shapefiles/ICES_areas.zip

ices_data_sf <- st_read(
  dsn = 'data-raw/ICES_area',
  layer = 'ICES_Areas_20160601_cut_dense_3857'
) %>%
  st_transform(
    crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
  )

saveRDS(
  object = ices_data_sf,
  file = "inst/ices_data_sf.rds"
)
