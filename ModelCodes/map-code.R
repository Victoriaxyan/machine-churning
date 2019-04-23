library(maptools)
library(maps)
library(rgdal)
library(mapproj)

area = readOGR("cb_2015_us_division_500k.shp")
area = fortify(area)

#need to exclude non continental area for the map display
caliArea = area %>% filter(group==5.2)
area = area%>%filter(id!=5)
area=rbind(area,caliArea)

area$Division = factor(area$id,
                       levels = c(0,1,2,3,4,5,6,7,8),
                       labels = c("New England","Mid-Atlantic","West North Central","South Atlantic","Mountain","Pacific","East South Central","West South Central","East North Central")
)

