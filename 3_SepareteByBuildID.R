#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                                                         ##
##                 Function: Create a table for            ##
##                 each of the buildings                   ##
##                                                         ##
##                 Related scripts:                        ##
##                 PreprocessWiFi.R                        ##
##                 ModelForBuildingID.R                    ##
##                                                         ##
##                 Reviewer:                               ##
##                 date of review:                         ##
##                                                         ##
##                 source of the data:                     ##
##                                                         ##
##   UJI -Institute of New Imaging Technologies            ##  
##                                                         ##
##                        UPV                              ##
##    Departamento de Sistemas Informáticos y Computación  ##
##   Universitat Politècnica de València, Valencia, Spain. ##
##                                                         ##
##---------------------------------------------------------##
##-------------------Outputs---------------------------------
##
##  Three data tables with the information of one bulding  
##  each to use to predict the floor and the Longitute and 
##  latitute
##  
##
## Train0Building.csv : table with the data from B0  
## Train1Building.csv : table with the data from B1  
## Train2Building.csv : table with the data from B2
##
##
## Vali0Building.csv : table with the Validation data B0
## Vali1Building.csv : table with the Validation data B1
## Vali2Building.csv : table with the Validation data B2
##
##
#------------------script  Elements---------------------
#  TrainingDataBuild0 : table with the TrainData from B0
#  TrainingDataBuild1 : table with the TrainData from B1
#  TrainingDataBuild2 : table with the TrainData from B2
#  ValidationDataBuild0 : table with the ValiData from B0
#  ValidationDataBuild0 : table with the ValiData from B1
#  ValidationDataBuild0 : table with the ValiData from B2

#------------------Require library-------------------------
# function pacman confirm if the package is installed and
# if not, it will install the require packages
# 
# used packages until 13/12/2018 are:
# caret, tidyverse, magrittr, BBmisc

if (!require(pacman)) install.packages("pacman")
pacman::p_load(caret, tidyverse, magrittr,BBmisc)

#-------------------Data Set --------------------------------

DataFiles <- list.files(path = "Dataset/",
                        pattern = "Loc.csv")

for (i in seq_along(DataFiles)) {
  
  assign(paste(DataFiles[i]),
         read.csv(paste("./Dataset", DataFiles[i],
                        sep = "/"),
                  header =  TRUE,
                  sep =",",
                  stringsAsFactors = F,
                  colClasses = c("BUILDINGID" = "factor" )))
}

##--------------Training Building data table ----------------------
## to make the modeling party faster and use the information 
# that the prediction of the Building provide I choose to separete 
# the Tables by building, and predict the floor and 
# longitude and latitude using them

## table for training bulding 0
TrainingDataBuild0 <- TrainDataLoc.csv %>% filter(BUILDINGID == 0)

## table for Training Bulding 1
TrainingDataBuild1 <- TrainDataLoc.csv %>% filter(BUILDINGID == 1)

## table for training bulding 2
TrainingDataBuild2 <- TrainDataLoc.csv %>% filter(BUILDINGID == 2)



##--------------Validation Building data table ----------------------
## for the validation Table I will use the Models to filter the 
#  Data

## this is the best model that I develop in the script
#  ModelsforBuildingID.R

load("BIDmodel.rda")


ValiDataLoc.csv$PredBuildingID <- predict(
  ModelKnnForBID, newdata = ValiDataLoc.csv)


## table for Validation bulding 0
ValidationDataBuild0 <- ValiDataLoc.csv %>%
  filter(PredBuildingID == 0)
  

## table for Validation Bulding 1
ValidationDataBuild1 <- ValiDataLoc.csv %>%
  filter(PredBuildingID == 1)
 

## table for Validation bulding 2
ValidationDataBuild2 <- ValiDataLoc.csv %>%
  filter(PredBuildingID == 2) 
  

##------------Waps by bulding 0-------------------------


write.csv(TrainingDataBuild0, "./Dataset/Train0Building.csv",
          row.names = F)

write.csv(ValidationDataBuild0, "./Dataset/Vali0Building.csv",
          row.names = F)

##------------Waps by bulding 1-------------------------


write.csv(TrainingDataBuild1, "./Dataset/Train1Building.csv",
          row.names = F)

write.csv(ValidationDataBuild1, "./Dataset/Vali1Building.csv",
          row.names = F)

##------------Waps by bulding 2-------------------------


write.csv(TrainingDataBuild2, "./Dataset/Train2Building.csv",
          row.names = F)

write.csv(ValidationDataBuild2, "./Dataset/Vali2Building.csv",
          row.names = F)
