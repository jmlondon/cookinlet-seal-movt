get_land_osm <- function(locs_data_filt) {
  #create a couple temp files
  temp <- tempfile()
  temp2 <- tempfile()
  #download the zip folder from the internet save to 'temp' 
  options(timeout = max(1000, getOption("timeout")))
  download.file("https://osmdata.openstreetmap.de/download/land-polygons-complete-4326.zip",
                temp, method = "libcurl")
  #unzip the contents in 'temp' and save unzipped content in 'temp2'
  unzip(zipfile = temp, exdir = temp2)
  #finds the filepath of the shapefile (.shp) file in the temp2 unzip folder
  #the $ at the end of ".shp$" ensures you are not also finding files such as .shp.xml 
  osm_SHP_file<-list.files(paste(temp2,"land-polygons-complete-4326",sep="/"), 
                           pattern = ".shp$",
                           full.names=TRUE)
  
  bb_ll <- locs_data_filt %>% st_convex_hull() %>% st_buffer(250000) %>% 
    st_transform(4326) %>% st_bbox()
  
  #read the shapefile. Alternatively make an assignment, such as f<-sf::read_sf(your_SHP_file)
  osm_land <- sf::read_sf(osm_SHP_file) %>% 
    st_crop(bb_ll) %>% 
    st_union() %>% 
    st_transform(crs=3338)
  
  land_simp <- rmapshaper::ms_simplify(osm_land, keep=0.50)
}