#------------------Code Resume-------------------------------
##                                                         ##
##                                                         ##
##                 WiFi Localization Model                 ##
##                 Developer: Pericles Beirao              ##
##                 Version:2                               ##
##                 last Version:  13/12/2018               ##
##                 Function: Preprocess the data           ##
##                 Related scripts:                        ##
##                 PredictBuilding.R                       ##
##                 ModelForBuildingID.R                    ##
##                 SliptDataByBuilding                     ##
##                                                         ##
##                 Reviewer:                               ##
##                 date of review:                         ##
##                                                         ##
##                 source of the data:                     ##
##                                                         ##
##    UJI -Institute of New Imaging Technologies           ##  
##                                                         ##
##                        UPV                              ##
##    Departamento de Sistemas Informáticos y Computación  ##
##   Universitat Politècnica de València, Valencia, Spain. ##
##                                                         ##
##---------------------------------------------------------##
##-------------------Outputs---------------------------------
##
##  .csv Table with the Waps information and 
##  localization Info for Bulding or Floor or Long/lati
##
##  TrainDataBuildID.csv : Training Data with building ID
##  after pre process
##
##  ValiDataBuildID.csv : Validation Data with building ID
##  after pre process 
##
##
##
##
##
##
##
##
#------------------Preprocess Elements---------------------
# DataFiles: list .csv , training and validation
# trainingData.csv: Table with the information to train 
# the model
# validationData.csv : Table with the information to 
# validate the model 
# TrainingDF: Table with the Training Data without duplicates 
# ImpInfoDF: table with the Imput information of users 
# used to remove duplicates

# WapsTrainData : Table with only the waps Info from Train
# WapsTrainData : Table with only the waps Info from Test
# ImpWapsTrain : list of the Imput WAps in train with signal
# ImpWapsTest : list of the Imput WAps in test with signal
# ImpWapsBoth : list with Both imput that have signal 
# TrainLocData : table with the info from the Waps after 
# preprocess and localization after preprocess from Training
# TestLocData : table with the info from the Waps after 
# preprocess and localization after preprocess from Test
# TrainBIDDate : Table with WAPS and BUILDING ID
# ValiBIDDate : Table with the waps and Bulding ID for validation
#
#------------------Require library-------------------------
# function pacman confirm if the package is installed and
# if not, it will install the require packages
# 
# used packages until 13/12/2018 are:
# caret, tidyverse, magrittr, BBmisc

if (!require(pacman)) install.packages("pacman")
pacman::p_load(caret, tidyverse, magrittr,BBmisc)

#-------------------Data Set --------------------------------
# There is Two tables first one contain the fingerprint
# the second one contain localizations to be used for 
# validation of the models
#
# the data is provided on:
# http://archive.ics.uci.edu/ml/datasets/UJIIndoorLoc


DataFiles <- list.files(path = "Dataset/",
                        pattern = "Data.csv")

for (i in seq_along(DataFiles)) {

  assign(paste(DataFiles[i]),
         read.csv(paste("./Dataset", DataFiles[i],
                        sep = "/"),
                  header =  TRUE,
                  sep =",",
                  stringsAsFactors = F))
  }

##---------------Prepro Duplicates---------------------------

# it was found during the exploration of the data that
# there was duplicated information coming from a error in
# the collect sytem used 
# to have a better model it was decided to excluded this 
# duplicates from the trainingData
# and to have a better control it was created a Data Frame
# for be used when I excluded the duplicates

TrainingDF <- unique(trainingData.csv)

# Some imputs have the same Localization, Timestamp and UserID
# but different WAPS signal, I decide to remove them 
# because the information would expand the WAPS possibilities
# for each localization, making the prediction less accurate 

ImpInfoDF <- subset(TrainingDF,
                    select = c(LONGITUDE:TIMESTAMP))


TrainingDF<- TrainingDF[ duplicated(ImpInfoDF)==F,]

##---------------Prepro Var Format---------------------------
#
# defining the variables format for the one that will be use
# FLOOR it is not used as factor now because of levels 
# problems when I subset the Data table by bulding 


TrainingDF$BUILDINGID %<>% as.factor()
validationData.csv$BUILDINGID %<>% as.factor()

TrainingDF$USERID  %<>% as.factor()
validationData.csv$USERID  %<>% as.factor()

TrainingDF$PHONEID  %<>% as.factor()
validationData.csv$PHONEID  %<>% as.factor()

TrainingDF$TIMESTAMP %<>% anytime::anytime()
validationData.csv$TIMESTAMP %<>% anytime::anytime()

#---------------Prepro WAPS process--------------------------
# 
##               Creating WAPs DFs 
#  creating DF with only the WAPS to process them 

WapsTrainData <- TrainingDF %>%
  select(starts_with("WAP"))

WapsValiData <- validationData.csv %>%
  select(starts_with("WAP"))


##         Change the Signal to Positive values
# was decided to change the signal of the waps to:
# when has no signal to be 0 and the signal to be positive 
# and not negative, this was done to be more intuitive to 
# analise the data and to have the signal in a crescent form


WapsTrainData <- as.data.frame(lapply(WapsTrainData,
                              function(x){ifelse(x == 100,
                                                 0,
                                                 x+105)}))

WapsValiData <- as.data.frame(lapply(WapsValiData,
                               function(x){ifelse(x == 100,
                                                  0,
                                                  x + 105)}))
##          List of imputs without Singal
## I do this list here before the normalization because after 
# they become NA
# List imputs that has no signal 

ImputsOhneSignal <- apply(WapsTrainData,1,var)!=0



##         Excluding bad WAPs
# during exploration, I noticed that there was WAPs
# that during the validation data collection  
# where not more working in the university 
# this WAPs  have no signal in all the imputs of validation
# but they have in the training 
# showing that in the time between the colection of 
# training and validation, six months 
# there were some atualization in the WAPs hardwares
# I decide to exclude then from the training data,
# to make the models only work with the real scenario
# of the validation

# when var is different than 0 means that the WAP has a Signal
# I make a list of all the col with WAPs with signal
# in the validation and exlude from Training 
# in the end I will only have waps that have signal in 
# both moments 

# list of waps in the Validation without signal
ImpWapsTest <- apply(WapsValiData,2,var) != 0

# exclude waps that have no signal in the Vali from Train
WapsTrainData <- WapsTrainData[,ImpWapsTest]

# list of waps in the training without signal
ImpWapsTrain <- apply(WapsTrainData,2,var) != 0

# exclude waps that have no signal from Train
WapsTrainData <- WapsTrainData[,ImpWapsTrain]

# for Dani if he reads that 
# loved the idea because in one step I exclude the WAPs with
# no var in from the Training too 

##          Rescale from 0 to 1 the signal 

# The purpose of this function is to create a scale from 
# no signal 0 to strongst signal 1 but per imput or row
# This will help to make up for the difference of the signals
# that change depends of external factors like height of the
# user or cellphone system and hardware 

# WapsTrainData <- normalize(WapsTrainData,
#                            method = "range",
#                            range = c(0,1),
#                            margin = 1,
#                            on.constant = "quiet")
# 
# WapsValiData <- normalize(WapsValiData,
#                            method = "range",
#                            range = c(0,1),
#                            margin = 1,
#                            on.constant = "quiet")
WapsTrainData <-  as.data.frame(t(apply(WapsTrainData,1,
                                function(x)
                                  (x - min(x))/(max(x)-min(x)))))

WapsValiData <- as.data.frame(t(apply(WapsValiData,1,
                                function(x)
                                  (x - min(x))/(max(x)-min(x)))))


##         excluding WAPs that moved between buldings
# during exploration we localize some waps that moved between
# the buldings, they create some fake information for the models
# of which waps are related with localizations

WapsTrainData <- subset(WapsTrainData,
                 select = -c(WAP248,WAP074,WAP070,WAP069))


##---------------  Waps & Loc DF   -------------------------

##       Bind back the Waps to the localization Imput 
#  Bind together the waps and the localization data for 
# use in the Models

TrainLocData <- bind_cols(WapsTrainData,
                        TrainingDF %>%
                          select(LONGITUDE, LATITUDE, 
                                     FLOOR, BUILDINGID))

ValiLocData <- bind_cols(WapsValiData,
                       validationData.csv %>%
                            select(LONGITUDE,LATITUDE,
                                       FLOOR,BUILDINGID)) 


##---------------Imp without signal -------------------

# There is some imputs where there is localization but 
# no signal
# they give some imputs about places without WiFi in the 
# University, but would not bring info to the models
# listed was create before and only used now because of 
#a normalization process



TrainLocData <- TrainLocData[ImputsOhneSignal,]




##--------------Localization DF------------------------------
#
# DF With WAPs and BuildingID, floor, longitude and latitude
# to use in the model to predict Building , Floor and 
# longitude and latitude



write.csv(TrainLocData, "./Dataset/TrainDataLoc.csv",
          row.names = F)

write.csv(ValiLocData, "./Dataset/ValiDataLoc.csv",
          row.names = F)

