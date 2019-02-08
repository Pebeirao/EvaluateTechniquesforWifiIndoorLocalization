#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                                                         ##
##                 Develop a model to predict Floor        ##
##                 in the bulding 1                        ##
##                                                         ##
##                 Related scripts:                        ##
##                 PreprocessWiFi.R                        ##
##                 ModelForBuildingID.R                    ##
##                 SliptDataByBuilding                     ##
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
##  Two Models one for predict the floors in Building 0  
##  and one to predict Longtitude and Latitude  
##  
##  
##
##  Two tables one with the results from the 3 models  
##  to predict the floor, to compare the them 
##  and anothe table 
##  with the prediction of 3 models for Latitude and 
##  Longitude 
## 
## 
## 
##
##
#------------------Script  Elements---------------------



#------------------Require library-------------------------
# function pacman confirm if the package is installed and
# if not, it will install the require packages
# 
# used packages until 13/12/2018 are:
# caret, tidyverse, magrittr, BBmisc

if (!require(pacman)) install.packages("pacman")
pacman::p_load(caret, tidyverse, magrittr,BBmisc)

#-------------------Data Set --------------------------------
# Data provided by the SplitByBuilding.R
# Floor was transform in a factor to make a classification model 

DataFiles <- list.files(path = "Dataset/",
                        pattern = "1Building.csv")

for (i in seq_along(DataFiles)) {
  
  assign(paste(DataFiles[i]),
         read.csv(paste("./Dataset", DataFiles[i],
                        sep = "/"),
                  header =  TRUE,
                  sep =",",
                  stringsAsFactors = F,
                  colClasses = c("BUILDINGID" = "factor",
                                 "FLOOR" = "factor" )))
}
## ------------pre process for this bulding ------------------
#
# this bulding has a lot of interference from the other two
# mostly because he has a open space center 
# to try to minimize that it was decided to cancel all the 
# signals that are not the strongest 1 


# wap table from the bulding 1

WapsBuilding1 <- Train1Building.csv %>%
  select(starts_with("WAP"))
# transforming all the values lower than 1 to 0

WapsBuilding1 <- as.data.frame(lapply(WapsBuilding1,function(x){
  ifelse(x < 0.99, 0, x)}))

# Remaking the table with WapsB1 and Loc

Train1Building.csv<- bind_cols(WapsBuilding1,Train1Building.csv %>%
                                 select(FLOOR))







##------------TrControl Config-----------------------------
# to be faster and save memory I choose to have only one repeticion


TrOneRepeats <- trainControl(
  method = "repeatedcv", number = 3, repeats = 1 )

##------------DataSet For Confusion matrix----------------
# Table with the Building ID of the validation 
# and will be add the prediction with different models 
# to compare

B1FloorPred <- subset(Vali1Building.csv, 
                      select = (FLOOR))


##------------Model Knn -----------------------------------

set.seed(123)

ModelKnnForB1Floor <- train( FLOOR~.,
                         data = Train1Building.csv %>%
                           select(starts_with("WAP"),
                                  FLOOR),
                         method = "knn",
                         trControl = TrOneRepeats,
                         tuneLength=3)

##------------Knn prediction------------------------------
##        Accuracy: 0.9251 and kappa : 0.8876

B1FloorPred$IDFloorKNN <- predict(
  ModelKnnForB1Floor, newdata = Vali1Building.csv)

confusionMatrix(data = B1FloorPred$IDFloorKNN,
                B1FloorPred$FLOOR)


##----------Model Ranger----------------------------------


set.seed(123)

ModelRangerForB1Floor <- train( FLOOR~.,
                            data = Train1Building.csv %>%
                              select(starts_with("WAP"),
                                     FLOOR),
                            method= "ranger",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------Ranger prediction------------------------------
##        Accuracy: 0.9251 and kappa : 0.8876

B1FloorPred$IDFloordRanger <- predict(
  ModelRangerForB1Floor,
  newdata = Vali1Building.csv)

confusionMatrix(data = B1FloorPred$IDFloordRanger,
                B1FloorPred$FLOOR)

##----------Model gbm----------------------------------


set.seed(123)

ModelGbmForB1Floor <- train( FLOOR~.,
                         data = Train1Building.csv %>%
                           select(starts_with("WAP"),
                                  FLOOR),
                         method= "gbm",
                         trControl =TrOneRepeats,
                         tuneLength=3)

##------------gbm prediction------------------------------
##        Accuracy: 0.6124 and kappa : 0.4489

B1FloorPred$IDFloorGbm <- predict(
  ModelGbmForB1Floor, newdata = Vali1Building.csv)

confusionMatrix(data = B1FloorPred$IDFloorGbm,
                B1FloorPred$FLOOR)

##------------outputs ----------------------------------------

## data set with the different predictions to compare 


write.csv(B1FloorPred, "./Dataset/Building1Floorpred.csv",
          row.names = F)
## best model files 

save(ModelKnnForB1Floor, file = "B1FloorModel.rda")