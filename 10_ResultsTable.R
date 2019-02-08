#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                                                         ##
##                 Create a .csv with the predictions      ##
##                 for the localization                    ##
##                                                         ##
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
##                        UJI                              ##
##        Institute of New Imaging Technologies            ##  
##                                                         ##
##                        UPV                              ##
##    Departamento de Sistemas Informáticos y Computación  ##
##   Universitat Politècnica de València, Valencia, Spain. ##
##                                                         ##
##---------------------------------------------------------##
##-------------------Outputs---------------------------------
##
##  .csv file with the predictions outcomes  
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
# Data provided by the PreprocessWiFi.R
# I only will use the Validation data here 



DataFiles <- list.files(path = "Dataset/",
                        pattern = "Vali[012]Building.csv")

for (i in seq_along(DataFiles)) {
  
  assign(paste(DataFiles[i]),
         read.csv(paste("./Dataset", DataFiles[i],
                        sep = "/"),
                  header =  TRUE,
                  sep =",",
                  stringsAsFactors = F,
                  colClasses = c("BUILDINGID" = "factor",
                                 "FLOOR" = "factor")))
}

#---------------Load the Models------------------------------

ModelFiles<- list.files(pattern = ".rda")

for (m in seq_along(ModelFiles)) {
  load(ModelFiles[m])
}

##----------------Table with Predictions ------------------

##-------------------Floor Predictions----------------------
#-------------Bulding 0 Floor Prediction--------------------

Vali0Building.csv$PredFloor <- predict(ModelRangerForB0Floor,
                                       newdata = Vali0Building.csv )


#-------------Bulding 1 Floor Prediction--------------------

Vali1Building.csv$PredFloor <- predict(ModelKnnForB1Floor,
                                       newdata = Vali1Building.csv )

#-------------Bulding 2 Floor Prediction--------------------

Vali2Building.csv$PredFloor <- predict(ModelKnnForB2Floor,
                                       newdata = Vali2Building.csv )
##-------------------Longitude predi------------------------
#-------------Bulding 0 Longi Prediction--------------------

Vali0Building.csv$PredLongitude <- predict(ModelKnnForB0Long,
                                       newdata = Vali0Building.csv )


#-------------Bulding 1 Longi Prediction--------------------

Vali1Building.csv$PredLongitude <- predict(ModelKnnForB1Long,
                                       newdata = Vali1Building.csv )

#-------------Bulding 2 Longi Prediction--------------------

Vali2Building.csv$PredLongitude <- predict(ModelKnnForB2Long,
                                       newdata = Vali2Building.csv )

##-------------------Latitude predi------------------------
#-------------Bulding 0 latitude Prediction--------------------

Vali0Building.csv$PredLatitude <- predict(ModelKnnForB0Lati,
                                           newdata = Vali0Building.csv )


#-------------Bulding 1 latitude Prediction--------------------

Vali1Building.csv$PredLatitude <- predict(ModelKnnForB1Lati,
                                           newdata = Vali1Building.csv )

#-------------Bulding 2 latitude Prediction--------------------

Vali2Building.csv$PredLatitude <- predict(ModelKnnForB2Lati,
                                           newdata = Vali2Building.csv )

## --------------Binding 3 tables in one--------------------------

# some variables will be convert to chr variables to fit together

ValidationDF <- bind_rows(Vali0Building.csv,
                       Vali1Building.csv,
                       Vali2Building.csv)


# converting them back to factor
ValidationDF$FLOOR %<>% as.factor()
ValidationDF$PredFloor %<>% as.factor()
ValidationDF$BUILDINGID %<>% as.factor()
ValidationDF$PredBuildingID %<>% as.factor()

##-----------------Accuracy Building Prediction------------
#              Accuracy : 1 
#              Kappa : 1 
confusionMatrix(data = ValidationDF$BUILDINGID,
                ValidationDF$PredBuildingID  )


##-----------------Accuracy Floor Prediction------------
#                Accuracy : 0.955 
#                Kappa : 0.9366

## biggests errors are in the ground floor and 4 floor 

confusionMatrix(data = ValidationDF$FLOOR,
                ValidationDF$PredFloor  )


##----------------Error distance metric --------------

# to better understand the error from the longitude
# latitude it was decided to create a metric 
# of the mediam of the distance error from the position

##--------- difference between Longi and Predi Long ----
ValidationDF$DiffLong <- (ValidationDF$LONGITUDE -
                         ValidationDF$PredLongitude)

##--------- difference between Lati and Predi Lati ----
ValidationDF$DiffLati <- (ValidationDF$LATITUDE -
                             ValidationDF$PredLatitude)

##--------- distance error metric----------------------
# The distance error is equal sqrt of the sum of the 
# Difference between Real and predi on ^2
# Min. 1st Qu.  Median    Mean  3rd Qu.    Max. 
#0.000   3.121   5.936   8.417  10.759   76.798 

ValidationDF <- mutate(ValidationDF,
                       DistanceError = sqrt(DiffLong^2 +
                                            DiffLati^2) )


summary(ValidationDF$DistanceError)

#-------------------Output----------------------------

# table only with the results 

ResultsWifi <- subset(ValidationDF %>%
                        select(BUILDINGID,PredBuildingID,
                               FLOOR, PredFloor,
                               LONGITUDE, PredLongitude,
                               LATITUDE, PredLatitude,
                               DistanceError))

write.csv(ResultsWifi, "./Dataset/ResultsWifiValidation.csv",
          row.names = F)