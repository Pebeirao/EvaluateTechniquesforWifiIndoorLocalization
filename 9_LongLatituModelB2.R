#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                                                         ##
##                 Develop a model to predict Longitude    ##
##                 and latitude                            ##
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
##  one model for predicting Longitude on building 2 
##  one model for predicting Latitude on building 2  
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
## ------------pre process for Building 2------------------
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
                                 select(LONGITUDE, LATITUDE))







##------------TrControl Config-----------------------------
# to be faster and save memory I choose to have only one repeticion


TrOneRepeats <- trainControl(
  method = "repeatedcv", number = 3, repeats = 1 )

##------------DataSet For Confusion matrix----------------
# Table with the Building ID of the validation 
# and will be add the prediction with different models 
# to compare

B2LongLatiPred <- subset(Vali2Building.csv, 
                      select = c(LONGITUDE, LATITUDE))


##------------Model Long Knn -----------------------------------

set.seed(123)

ModelKnnForB2Long <- train( LONGITUDE~.,
                             data = Train2Building.csv %>%
                               select(starts_with("WAP"),
                                      LONGITUDE),
                             method = "knn",
                             trControl = TrOneRepeats,
                             tuneLength=3)

##------------Knn Long prediction------------------------------
##        Accuracy: 0.9478 and kappa : 0.9293

B2LongLatiPred$IDLongKNN <- predict(
  ModelKnnForB2Long, newdata = Vali2Building.csv)

postResample(B2LongLatiPred$IDLongKNN,
                B2LongLatiPred$LONGITUDE)

##------------Model Lati Knn -----------------------------------

set.seed(123)

ModelKnnForB2Lati <- train( LATITUDE~.,
                            data = Train2Building.csv %>%
                              select(starts_with("WAP"),
                                     LATITUDE),
                            method = "knn",
                            trControl = TrOneRepeats,
                            tuneLength=3)

##------------Knn Latitu prediction------------------------------
##        Accuracy: 0.9478 and kappa : 0.9293

B2LongLatiPred$IDLatiKNN <- predict(
  ModelKnnForB2Lati, newdata = Vali2Building.csv)

postResample(B2LongLatiPred$IDLatiKNN,
                B2LongLatiPred$LATITUDE)


##----------Model Long Ranger----------------------------------


set.seed(123)

ModelRangerForB2Long <- train( LONGITUDE~.,
                                data = Train2Building.csv %>%
                                  select(starts_with("WAP"),
                                         LONGITUDE),
                                method= "ranger",
                                trControl =TrOneRepeats,
                                tuneLength=3)

##------------Ranger Long prediction------------------------------
##        Accuracy: 0.9254 and kappa : 0.8992

B2LongLatiPred$IDLongRanger <- predict(
  ModelRangerForB2Long,
  newdata = Vali2Building.csv)

postResample(B2LongLatiPred$IDLongRanger,
                B2LongLatiPred$LONGITUDE)

##----------Model Latitude Ranger----------------------------------


set.seed(123)

ModelRangerForB2Long <- train( LATITUDE~.,
                               data = Train2Building.csv %>%
                                 select(starts_with("WAP"),
                                        LATITUDE),
                               method= "ranger",
                               trControl =TrOneRepeats,
                               tuneLength=3)

##------------Ranger Long prediction------------------------------
##        Accuracy: 0.9254 and kappa : 0.8992

B2LongLatiPred$IDLatiRanger <- predict(
  ModelRangerForB2Long,
  newdata = Vali2Building.csv)

postResample(B2LongLatiPred$IDLatiRanger,
                B2LongLatiPred$LATITUDE)

##----------Model Long gbm----------------------------------


set.seed(123)

ModelGbmForB2Long <- train( LONGITUDE~.,
                             data = Train2Building.csv %>%
                               select(starts_with("WAP"),
                                      LONGITUDE),
                             method= "gbm",
                             trControl =TrOneRepeats,
                             tuneLength=3)

##------------gbm Longitude prediction------------------------------
##        Accuracy: 0.9403 and kappa : 0.9182

B2LongLatiPred$IDLongGbm <- predict(
  ModelGbmForB2Long, newdata = Vali2Building.csv)

postResample(B2LongLatiPred$IDLongGbm,
                B2LongLatiPred$LONGITUDE)

##----------Model latitude gbm----------------------------------


set.seed(123)

ModelGbmForB2Lati <- train( LATITUDE~.,
                            data = Train2Building.csv %>%
                              select(starts_with("WAP"),
                                     LATITUDE),
                            method= "gbm",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------gbm Latitude prediction------------------------------
##        Accuracy: 0.9403 and kappa : 0.9182

B2LongLatiPred$IDLatiGbm <- predict(
  ModelGbmForB2Lati, newdata = Vali2Building.csv)

postResample(B2LongLatiPred$IDLatiGbm,
                B2LongLatiPred$LATITUDE)

##------------outputs ----------------------------------------

## data set with the different predictions to compare 


write.csv(B2LongLatiPred, "./Dataset/Building2LongLatipred.csv",
          row.names = F)
## best model files 

save(ModelKnnForB2Long, file = "B2LongModel.rda")

save(ModelKnnForB2Lati, file = "B2LatiModel.rda")