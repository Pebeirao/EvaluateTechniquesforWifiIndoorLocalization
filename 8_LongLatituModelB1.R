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
##  one model for predicting Longitude on building 1 
##  one model for predicting Latitude on building 1 
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
## ------------pre process for Building 1------------------
#
# this bulding has a lot of interference from the other two
# mostly because he has a open space center 
# to try to minimize that it was decided to cancel all the 
# signals that are weaker than 0.70  


# wap table from the bulding 1

WapsBuilding1 <- Train1Building.csv %>%
  select(starts_with("WAP"))
# transforming all the values lower than 0.7 to 0

WapsBuilding1 <- as.data.frame(lapply(WapsBuilding1,function(x){
  ifelse(x < 0.99, 0, x)}))

# Remaking the table with WapsB1 and Loc

Train1Building.csv<- bind_cols(WapsBuilding1,Train1Building.csv %>%
                                 select(LONGITUDE, LATITUDE))







##------------TrControl Config-----------------------------
# to be faster and save memory I choose to have only one repeticion


TrOneRepeats <- trainControl(
  method = "repeatedcv", number = 3, repeats = 1 )

##------------DataSet For Confusion matrix----------------
# Table with the Building ID of the validation 
# and will be add the prediction with different models 
# to compare

B1LongLatiPred <- subset(Vali1Building.csv, 
                         select = c(LONGITUDE, LATITUDE))


##------------Model Long Knn -----------------------------------

set.seed(123)

ModelKnnForB1Long <- train( LONGITUDE~.,
                            data = Train1Building.csv %>%
                              select(starts_with("WAP"),
                                     LONGITUDE),
                            method = "knn",
                            trControl = TrOneRepeats,
                            tuneLength=3)

##------------Knn Long prediction------------------------------
##          RMSE  Rsquared       MAE 
#        9.2862904 0.9601602 6.8154272

B1LongLatiPred$IDLongKNN <- predict(
  ModelKnnForB1Long, newdata = Vali1Building.csv)

postResample(B1LongLatiPred$IDLongKNN,
             B1LongLatiPred$LONGITUDE)

##------------Model Lati Knn -----------------------------------

set.seed(123)

ModelKnnForB1Lati <- train( LATITUDE~.,
                            data = Train1Building.csv %>%
                              select(starts_with("WAP"),
                                     LATITUDE),
                            method = "knn",
                            trControl = TrOneRepeats,
                            tuneLength=3)

##------------Knn Latitu prediction------------------------------
##        RMSE     Rsquared        MAE 
##    11.7130892  0.8911935  8.1811983 

B1LongLatiPred$IDLatiKNN <- predict(
  ModelKnnForB1Lati, newdata = Vali1Building.csv)

postResample(B1LongLatiPred$IDLatiKNN,
             B1LongLatiPred$LATITUDE)


##----------Model Long Ranger----------------------------------


set.seed(123)

ModelRangerForB1Long <- train( LONGITUDE~.,
                               data = Train1Building.csv %>%
                                 select(starts_with("WAP"),
                                        LONGITUDE),
                               method= "ranger",
                               trControl =TrOneRepeats,
                               tuneLength=3)

##------------Ranger Long prediction------------------------------
##             RMSE     Rsquared        MAE 
##         14.7275328  0.9167547 10.3351728 

B1LongLatiPred$IDLongRanger <- predict(
  ModelRangerForB1Long,
  newdata = Vali1Building.csv)

postResample(B1LongLatiPred$IDLongRanger,
             B1LongLatiPred$LONGITUDE)

##----------Model Latitude Ranger----------------------------------


set.seed(123)

ModelRangerForB1Long <- train( LATITUDE~.,
                               data = Train1Building.csv %>%
                                 select(starts_with("WAP"),
                                        LATITUDE),
                               method= "ranger",
                               trControl =TrOneRepeats,
                               tuneLength=3)

##------------Ranger Long prediction------------------------------
##        RMSE      Rsquared        MAE 
##     17.2169537  0.8122744 12.4960909

B1LongLatiPred$IDLatiRanger <- predict(
  ModelRangerForB1Long,
  newdata = Vali1Building.csv)

postResample(B1LongLatiPred$IDLatiRanger,
             B1LongLatiPred$LATITUDE)

##----------Model Long gbm----------------------------------


set.seed(123)

ModelGbmForB1Long <- train( LONGITUDE~.,
                            data = Train1Building.csv %>%
                              select(starts_with("WAP"),
                                     LONGITUDE),
                            method= "gbm",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------gbm Longitude prediction------------------------------
##            RMSE   Rsquared        MAE 
##       78.1877484  0.8530824 58.5125992 

B1LongLatiPred$IDLongGbm <- predict(
  ModelGbmForB1Long, newdata = Vali1Building.csv)

postResample(B1LongLatiPred$IDLongGbm,
             B1LongLatiPred$LONGITUDE)

##----------Model latitude gbm----------------------------------


set.seed(123)

ModelGbmForB1Lati <- train( LATITUDE~.,
                            data = Train1Building.csv %>%
                              select(starts_with("WAP"),
                                     LATITUDE),
                            method= "gbm",
                            trControl =TrOneRepeats,
                            tuneLength=3)

##------------gbm Latitude prediction------------------------------
##        RMSE   Rsquared        MAE 
##    73.5996290  0.7678965 48.8077671 

B1LongLatiPred$IDLatiGbm <- predict(
  ModelGbmForB1Lati, newdata = Vali1Building.csv)

postResample(B1LongLatiPred$IDLatiGbm,
             B1LongLatiPred$LATITUDE)

##------------outputs ----------------------------------------

## data set with the different predictions to compare 


write.csv(B1LongLatiPred, "./Dataset/Building1LongLatipred.csv",
          row.names = F)
## best model files 

save(ModelKnnForB1Long, file = "B1LongModel.rda")

save(ModelKnnForB1Lati, file = "B1LatiModel.rda")