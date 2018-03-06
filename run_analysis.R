      ######################################################################################################################################
      #                 Step 1
      #                 Read Files and merge training and test sets to one data set
      #                 result: data frame "alldata"
      ######################################################################################################################################
      
      library(dplyr)
      
      # read file "features.txt", to get all 561 feature names
      features <- read.table("features.txt")
      # str(features)
      # 'data.frame':	561 obs. of  2 variables:
      #      $ V1: int  1 2 3 4 5 6 7 8 9 10 ...
      # $ V2: Factor w/ 477 levels "angle(tBodyAccJerkMean),gravityMean)",..: 243 244 245 250 251 252 237 238 239 240 ...
      # head(features[,"V2"], 50)
      # [1] tBodyAcc-mean()-X          tBodyAcc-mean()-Y          tBodyAcc-mean()-Z          tBodyAcc-std()-X           tBodyAcc-std()-Y          
      # [6] tBodyAcc-std()-Z           tBodyAcc-mad()-X           tBodyAcc-mad()-Y           tBodyAcc-mad()-Z           tBodyAcc-max()-X
     
      
      # read file "activity_labels.txt", to get the 6 activity names
      activities <- read.table("activity_labels.txt")
      activities <- sub("_", "", activities[,"V2"]) # remove "_" in descriptive activity names
      
      #### Read Files from training set

      setwd("./train")
      
      traindata <- read.table("X_train.txt", header = FALSE, col.names = features[,"V2"]) 
      # traindata is dataframe of 7352 observations and 561 variables
      
      trainlabels <- read.table("y_train.txt", header = FALSE, col.names = c("activity"))
      # str(trainlabels)
      #data.frame':	7352 obs. of  1 variable:
      #$ V1: int  5 5 5 5 5 5 5 5 5 5 ...
      # for each observation in traindata, trainlabels contains the number of the activity
      
      trainsubjects <- read.table("subject_train.txt", header = FALSE, col.names = c("subject"))
      #  str(subjects)
      # data.frame':	7352 obs. of  1 variable:
      #      $ V1: int  1 1 1 1 1 1 1 1 1 1 ...
      # for each observation in traindata, trainsubjects contains the number of the subject, i.e. integer in range 1:30
      
      # create dataframe consisting of column subjects, column activity and 561 columns of measurements from traindata
      alltraindata <- bind_cols(trainsubjects, trainlabels, traindata) 
      
      #### Read Files from test set
      
      setwd("../test")
      testdata <- read.table("X_test.txt", header = FALSE, col.names = features[,"V2"])
      # testdata is data.frame of 2947 obs. of  561 variables
      
      testlabels <- read.table("y_test.txt", header = FALSE, col.names = c("activity"))
      # str(testlabels)
      # data.frame':	2947 obs. of  1 variable
      # for each observation in testdatat, testlabels contains the number of the activity
      
      testsubjects <- read.table("subject_test.txt", header = FALSE, col.names = c("subject"))
      # str(testsubjects)
      #data.frame':	2947 obs. of  1 variable:
      #      $ V1: int  2 2 2 2 2 2 2 2 2 2 ...
      # for each observation in testdata, testsubjects contains the number of the subject, i.e. integer in range 1:30
      
      # create dataframe consisting of column subjects, column activity and 561 columns of measurements from testdata
      alltestdata <- bind_cols(testsubjects, testlabels, testdata) 
      
      #### put together train and test data in one data frame
      alldata <- bind_rows(alltraindata, alltestdata)
      
      ######################################################################################################################################
      #                 Step 2
      #                 Extract only measurements on the mean and standard deviation for each measurement
      #                 result: data frame "alldataselmeanstd"
      ######################################################################################################################################
      # select only columns which are mean and standard deviation for each measurement
      # according to features_info.text these are variables with "mean()"/ "std()" in variable name
      # I do not choose variables with "meanFreq()" in variable name as these are wheighted averages
      
      # create vector with variables which should be selected from data frame "alldata"
      pattern <- "(mean|std)\\()" # search pattern to get all feature names with substring "mean()" or "std()"
      colmeanstd <- grep(pattern, features[,"V2"], value = TRUE)
      colmeanstd <- make.names(colmeanstd) # make syntactically valid names as are used by read.table from features.txt;
                                           # this replaces invalid chars "()" and "-" by "."
      
      # create dataframe with subject and activity information and all columns for mean() and std() variables
      alldataselmeanstd <-select(alldata, "subject", "activity", colmeanstd)
      
      ######################################################################################################################################
      #                 Step 3
      #                 use descriptive activity names to name the activities in the data set "alldataselmeanstd"
      #                 result: data frame "alldataactname"
      ######################################################################################################################################
      
      setactivityname <- function( act_number){activities[act_number]}
      # add column "actname" including descriptive activity names via function setactivityname
      alldataselmeanstdactname <- mutate(alldataselmeanstd, actname = setactivityname(activity)) 
      # put column "actname" ast second column; note: column "activity" not selected, i.e. removed
      alldataactname <- select(alldataselmeanstdactname, "subject", "actname", 3:68) 
                                                                                    
      
      ######################################################################################################################################
      #                 Step 4 
      #                 data set from step 3 with descriptive variable names
      #                 (feature names were already included in step 1 as column names!)
      #                 remove some of the obsolete dots
      #                 result: data frame "alldataactname"
      ######################################################################################################################################
      for (i in 3:68)
      {
            newname <- sub("\\.\\.\\.", "\\.", names(alldataactname)[i])
            newname <- sub("\\.\\.", "", newname)
            names(alldataactname)[i] <- newname
      }
      
      ######################################################################################################################################
      #                 Step 5
      #                 create independent tidy data set based on data set from step 4 with the average of each variable for each activity
      #                 and each subject
      #                 result: data frame "tidydata"
      ######################################################################################################################################
      
      # Create dataframe with mean for all 66 columns with mean/std of measurements for each subject and each activity
      tidydata <- aggregate(. ~subject + actname, data = alldataactname, mean)
      # result is dataframe with 180 rows (30 subjects * 6 activities) and 68 variables ("subject", "actname", 66 columns with average values)
      
      # write tidydata to file in source directory
      setwd("../")
      write.table(tidydata, file = "tidydata.txt", row.names = FALSE)
