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
##  one model for predicting Longitude on building 0 
##  one model for predicting Latitude on building 0  
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

B0LongLatiPred <- subset(Vali0Building.csv, 
                         select = c(LONGITUDE, LATITUDE))


##------------Model Long Knn -----------------------------------

set.seed(123)

ModelKnnForB0Long <- train( LONGITUDE~.,
                            data = Train0Building.csv %>%
                              select(starts_with("WAP"),
                                     LONGITUDE),
                            method = "knn",
                            trControl = TrOneRepeats,
                            tuneLength=3)

##------------Knn Long prediction------------------------------
##          RMSE  Rsquared       MAE 
##      6.0080070 0.9493212 3.9828469 

B0LongLatiPred$IDLongKNN <- predict(
  ModelKnnForB0Long, newdata = Vali0Building.csv)

postResample(B0LongLatiPred$IDLongKNN,
             B0LongLatiPred$LONGITUDE)

##------------Model Lati Knn -----------------------------------

set.seed(123)

ModelKnnForB0Lati <- train( LATITUDE~.,
                            data = Train0Building.csv %>%
                              select(starts_with("WAP"),
                                     LATITUDE),
                            method = "knn",
                            trControl = TrOneRepeats,
                            tuneLength=3)

##------------Knn Latitu prediction------------------------------
##            RMSE Rsquared      MAE 
##         5.001173 0.975650 3.283168 

B0LongLatiPred$IDLatiKNN <- predict(
  ModelKnnForB0Lati, newdata = Vali0Building.csv)

postResample(B0LongLatiPred$IDLatiKNN,
             B0LongLatiPred$LATITUDE)


##----------Model Long Ranger----------------------------------


set.seed(123)

ModelRangerForB0Long <- train( LONGITUDE~.,
                               data = Train0Building.csv %>%
                                 select(starts_with("WAP"),
                                        LONGITUDE),
                               method= "ranger",
                               trControl =TrOneRepeats,
                               tuneLength=3)

##------------Ranger Long prediction------------------------------
##         RMSE     Rsquared       MAE 
##       6.3343395 0.9448028 4.4664935 

B0LongLatiPred$IDLongRanger <- predict(
  ModelRangerForB0Long,
  newdata = Vali0Building.csv)

postResample(B0LongLatiPred$IDLongRanger,
             B0LongLatiPred$LONGITUDE)

##----------Model Latitude Ranger----------------------------------


set.seed(123)

ModelRangerForB0Long <- train( LATITUDE~.,
                               data = Train0Building.csv %>%
                                 select(starts_with("WAP"),
                                        LATITUDE),
                               method= "ranger",
                               trControl =TrOneRepeats,
                               tuneLength=3)

##------------Ranger Long prediction------------------------------
##         RMSE     Rsquared       MAE 
##       5.2413759 0.9744266 3.6674054 

B0LongLatiPred$IDLatiRanger <- predict(
  ModelRangerForB0Long,
  newdata = Vali0Building.csv)

postResample(B0LongLatiPred$IDLatiRanger,
             B0LongLatiPred$LATITUDE)

##----------Model Long gbm----------------------------------


set.seed(123)

ModelGbmForB0Long <- train( LONGITUDE~.,
                            data = Train0Building.csv %>%
                              select(starts_with("WAP"),
                                     LONGITUDE),
                            method= "gbm",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------gbm Longitude prediction------------------------------
##         RMSE  Rsquared       MAE 
##      8.2266399 0.9063053 6.0137200

B0LongLatiPred$IDLongGbm <- predict(
  ModelGbmForB0Long, newdata = Vali0Building.csv)

postResample(B0LongLatiPred$IDLongGbm,
             B0LongLatiPred$LONGITUDE)

##----------Model latitude gbm----------------------------------


set.seed(123)

ModelGbmForB0Lati <- train( LATITUDE~.,
                            data = Train0Building.csv %>%
                              select(starts_with("WAP"),
                                     LATITUDE),
                            method= "gbm",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------gbm Latitude prediction------------------------------
##        RMSE  Rsquared       MAE 
##     7.7953231 0.9408349 5.8753597 

B0LongLatiPred$IDLatiGbm <- predict(
  ModelGbmForB0Lati, newdata = Vali0Building.csv)

postResample(B0LongLatiPred$IDLatiGbm,
             B0LongLatiPred$LATITUDE)

##------------outputs ----------------------------------------

## data set with the different predictions to compare 


write.csv(B0LongLatiPred, "./Dataset/Building0LongLatipred.csv",
          row.names = F)
## best model files 

save(ModelKnnForB0Long, file = "B0LongModel.rda")

save(ModelKnnForB0Lati, file = "B0LatiModel.rda")