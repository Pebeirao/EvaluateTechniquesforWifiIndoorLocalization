#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                                                         ##
##                 Develop a model to predict Floor        ##
##                 in the bulding 0                        ##
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
##  one model for predicting Floor on building 0 
##  
##  
##
##  one table with 3 different models prediction to compare  
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


DataFiles <- list.files(path = "Dataset/",
                        pattern = "0Building.csv")

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




##------------TrControl Config-----------------------------
# to be faster and save memory I choose to have only one repeticion


TrOneRepeats <- trainControl(
  method = "repeatedcv", number = 3, repeats = 1 )

##------------DataSet For Confusion matrix----------------
# Table with the Building ID of the validation 
# and will be add the prediction with different models 
# to compare

B0FloorPred <- subset(Vali0Building.csv, 
                         select = c(FLOOR))


##------------Model Floor Knn -----------------------------------

set.seed(123)

ModelKnnForB0Floor <- train( FLOOR~.,
                            data = Train0Building.csv %>%
                              select(starts_with("WAP"),
                                     FLOOR),
                            method = "knn",
                            trControl = TrOneRepeats,
                            tuneLength=3)

##------------Knn Floor prediction------------------------------
##          accuracy : 0.9664
##           Kappa : 0.9526
B0FloorPred$IDFloorKNN <- predict(
  ModelKnnForB0Floor, newdata = Vali0Building.csv)

confusionMatrix(data = B0FloorPred$IDFloorKNN,
             B0FloorPred$FLOOR)


##----------Model Floor Ranger----------------------------------


set.seed(123)

ModelRangerForB0Floor <- train( FLOOR~.,
                               data = Train0Building.csv %>%
                                 select(starts_with("WAP"),
                                        FLOOR),
                               method= "ranger",
                               trControl =TrOneRepeats,
                               tuneLength=3)

##------------Ranger Floor prediction------------------------------
##      accuracy : 0.9757
##      kapps   :  0.9656

B0FloorPred$IDFloorRanger <- predict(
  ModelRangerForB0Floor,
  newdata = Vali0Building.csv)

confusionMatrix(data = B0FloorPred$IDFloorRanger,
             B0FloorPred$FLOOR)


##----------Model Floor gbm----------------------------------


set.seed(123)

ModelGbmForB0Floor <- train( FLOOR~.,
                            data = Train0Building.csv %>%
                              select(starts_with("WAP"),
                                     FLOOR),
                            method= "gbm",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------gbm FLOOR prediction------------------------------
##         Accuracy : 0.9646
##         Kappa  :  0.9646

B0FloorPred$IDFloorGbm <- predict(
  ModelGbmForB0Floor, newdata = Vali0Building.csv)

confusionMatrix(data = B0FloorPred$IDFloorGbm,
             B0FloorPred$FLOOR)



##------------outputs ----------------------------------------

## data set with the different predictions to compare 


write.csv(B0FloorPred, "./Dataset/Building0Floorpred.csv",
          row.names = F)
## best model files 

save(ModelRangerForB0Floor, file = "B0FloorModel.rda")

