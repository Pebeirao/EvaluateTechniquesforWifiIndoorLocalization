#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                                                         ##
##                 Develop a model to predict Floor        ##
##                 in the bulding 2                        ##
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
##  one model for predicting building 2 
##    
##  
##  
##
##  one table with 3 different models prediction to compare  
##   
##  
##   
##  
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
                        pattern = "2Building.csv")

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
# signals that are weaker than 0.70  


# wap table from the bulding 2

WapsBuilding2 <- Train2Building.csv %>%
  select(starts_with("WAP"))
# transforming all the values lower than 0.7 to 0

WapsBuilding2 <- as.data.frame(lapply(WapsBuilding2,function(x){
  ifelse(x < 0.70, 0, x)}))

# Remaking the table with WapsB2 and Loc

Train2Building.csv<- bind_cols(WapsBuilding2,Train2Building.csv %>%
                                 select(FLOOR))







##------------TrControl Config-----------------------------
# to be faster and save memory I choose to have only one repeticion


TrOneRepeats <- trainControl(
  method = "repeatedcv", number = 3, repeats = 1 )

##------------DataSet For Confusion matrix----------------
# Table with the Building ID of the validation 
# and will be add the prediction with different models 
# to compare

B2FloorPred <- subset(Vali2Building.csv, 
                      select = (FLOOR))


##------------Model Knn -----------------------------------

set.seed(123)

ModelKnnForB2Floor <- train( FLOOR~.,
                             data = Train2Building.csv %>%
                               select(starts_with("WAP"),
                                      FLOOR),
                             method = "knn",
                             trControl = TrOneRepeats,
                             tuneLength=3)

##------------Knn prediction------------------------------
##        Accuracy: 0.9478 and kappa : 0.9293

B2FloorPred$IDFloorKNN <- predict(
  ModelKnnForB2Floor, newdata = Vali2Building.csv)

confusionMatrix(data = B2FloorPred$IDFloorKNN,
                B2FloorPred$FLOOR)


##----------Model Ranger----------------------------------


set.seed(123)

ModelRangerForB2Floor <- train( FLOOR~.,
                                data = Train2Building.csv %>%
                                  select(starts_with("WAP"),
                                         FLOOR),
                                method= "ranger",
                                trControl =TrOneRepeats,
                                tuneLength=3)

##------------Ranger prediction------------------------------
##        Accuracy: 0.9254 and kappa : 0.8992

B2FloorPred$IDFloordRanger <- predict(
  ModelRangerForB2Floor,
  newdata = Vali2Building.csv)

confusionMatrix(data = B2FloorPred$IDFloordRanger,
                B2FloorPred$FLOOR)

##----------Model gbm----------------------------------


set.seed(123)

ModelGbmForB2Floor <- train( FLOOR~.,
                             data = Train2Building.csv %>%
                               select(starts_with("WAP"),
                                      FLOOR),
                             method= "gbm",
                             trControl =TrOneRepeats,
                             tuneLength=3)

##------------gbm prediction------------------------------
##        Accuracy: 0.9403 and kappa : 0.9182

B2FloorPred$IDFloorGbm <- predict(
  ModelGbmForB2Floor, newdata = Vali2Building.csv)

confusionMatrix(data = B2FloorPred$IDFloorGbm,
                B2FloorPred$FLOOR)

##------------outputs ----------------------------------------

## data set with the different predictions to compare 


write.csv(B2FloorPred, "./Dataset/Building2Floorpred.csv",
          row.names = F)
## best model files 

save(ModelKnnForB2Floor, file = "B2FloorModel.rda")