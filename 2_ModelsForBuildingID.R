#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                 Function: Predict the buldingID         ##
##                 and compare different models for that   ##
##                 Related scripts:                        ##
##                 PreprocessWiFi.R                        ##
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
##  BIDmodel.rda: Model for be use in predicting  
##  of the Building ID
##  
##  
##
##  
##   
##  BuildingIDandPredictions.csv : with the results of 
##  diferent models to use in comparations and presentation
##
##
##
##
##
##
#------------------script  Elements---------------------
# TrainDataLoc.csv : Table with WAPS and BUILDING ID
# ValiDataLoc.csv : Table with the waps and Bulding ID for validation
# BuilIDandPred : Table with the Building ID of the validation 
# and with the predictions of the models
# ModelKnnForBID : model with Knn 
# ModelRangerForBID : Model with Ranger
# ModelGbmForBID : Model with gbm


#------------------Require library-------------------------
# function pacman confirm if the package is installed and
# if not, it will install the require packages
# 
# used packages until 13/12/2018 are:
# caret, tidyverse, magrittr, BBmisc

if (!require(pacman)) install.packages("pacman")
pacman::p_load(caret, tidyverse, magrittr,BBmisc)

#-------------------Data Set --------------------------------
# .csv made with the script PreprocessWiFi.R 
# contain the Waps information after preprocess and 
# Building ID 

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

##------------TrControl Config-----------------------------
# to be faster and save memory I choose to have only one repeticion


TrOneRepeats <- trainControl(
  method = "repeatedcv", number = 3, repeats = 1 )

##------------DataSet For Confusion matrix----------------
# Table with the Building ID of the validation 
# and will be add the prediction with different models 
# to compare

BuilIDandPred <- subset(ValiDataLoc.csv, 
                        select = (BUILDINGID))


##------------Model Knn -----------------------------------

set.seed(123)

ModelKnnForBID <- train( BUILDINGID~.,
                         data = TrainDataLoc.csv %>%
                           select(starts_with("WAP"),
                                  BUILDINGID),
                         method = "knn",
                         trControl = TrOneRepeats,
                         tuneLength=3)

##------------Knn prediction------------------------------
##        Accuracy: 100% and kappa : 100%

BuilIDandPred$IDBuildKnn <- predict(
  ModelKnnForBID, newdata = ValiDataLoc.csv)

#confusionMatrix(data = BuilIDandPred$IDBuildKnn,
#                BuilIDandPred$BUILDINGID)


##----------Model Ranger----------------------------------


set.seed(123)

ModelRangerForBID <- train( BUILDINGID~.,
                            data = TrainDataLoc.csv %>%
                              select(starts_with("WAP"),
                                     BUILDINGID),
                            method= "ranger",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------Ranger prediction------------------------------
##        Accuracy: 0.9982 and kappa : 0.9972

BuilIDandPred$IDBuildRanger <- predict(
  ModelRangerForBID,
  newdata = ValiDataLoc.csv)

confusionMatrix(data = BuilIDandPred$IDBuildRanger,
                BuilIDandPred$BUILDINGID)

##----------Model gbm----------------------------------


set.seed(123)

ModelGbmForBID <- train( BUILDINGID~.,
                            data = TrainDataLoc.csv %>%
                           select(starts_with("WAP"),
                                  BUILDINGID),
                            method= "gbm",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------gbm prediction------------------------------
##        Accuracy: .9982 and kappa : .9972

BuilIDandPred$IDBuildGbm <- predict(
  ModelGbmForBID, newdata = ValiDataLoc.csv)

confusionMatrix(data = BuilIDandPred$IDBuildRanger,
                BuilIDandPred$BUILDINGID)

##------------outputs ----------------------------------------

## data set with the different predictions to compare 


write.csv(BuilIDandPred, "./Dataset/BuildingIDandPredictions.csv",
          row.names = F)
## best model files 

save(ModelKnnForBID, file = "BIDmodel.rda")