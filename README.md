# Getting-and-Cleaning-Data-Course-Project
This repo contains results for my Course Project (coursera "Getting and Cleaning Data").
It consists of 3 files
+ this ReadMe
+ the R script "run_analysis.R" to read in data (for data source - see below),
process that data and finally produce a tidy data set (see description of R script below in ReadMe for details)
+ a Codebook "Codebook_tidydata.pdf" which describes the variables of the data set produced by the R script

## Data used for this Course Project
The data source is
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## Precondition for the sourcefile to run correctly is:
* Data is unzipped, working directory is set to main folder (of unzipped files);
this folder should contain the following files
  + features.txt
  + activity_labels.txt
  + subfolder train with files X_train.txt, Y_train.txt, subject_train.txt
  + subfolder test with files X_test.txt, Y_test.txt, subject_test.txt
## R Script run_analysis.R
1. Read Files from unzipped data source and merge training and test sets to one data set;  
the feature names from file features.txt are used as column names for read.table of X_train.txt and X_test.txt;
therefore these columns already have headers which are used in step 4 (see below)!   
the resulting data set consists of 1 column for subject, 1 column for activity and 561 columns for the measurements
(=> features from source data)  
result: data frame **"alldata"**
2. From dataframe "alldata" select only measurements (= features) which are mean or standard deviation;  
i.e. choose features with "mean()" or "std()" in name but not "meanFreq()" as these are weighted averages according to features_info.txt
from the data source.  
result: data frame **"alldataselmeanstd"**   
3. Use descriptive activity names to name the activities in column activity (which currently contains numbers)   
In the resulting data set "alldataselmeanstd" the activity names are in new column "actname", column "activity" is removed
from  former dataframe;   
result: data frame **"alldataactname"**
4. Create data set based on data set from step 3 with descriptive variable names  
Note: feature names from original data were already included in step 1 as column names for features;  
So in this step only some of the obsolete dots are removed (which were created by read.table(features.txt) in step 1) 
result: data frame **"alldataactname"**
5. Create independent tidy data set based on data set from step 4 with the average of each variable for each activity
and each subject   
-> See Codebook in this repo for description of each variable in this data set;   
write this data frame with write.table to file "tidydata.txt" in main folder;   
result: data frame **"tidydata"**
