library(reshape2)
library(data.table)

## Create one R script called run_analysis.R that does the following. 
## 1)  Merges the training and the test sets to create one data set.
## 2)  Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3)  Uses descriptive activity names to name the activities in the data set
## 4)  Appropriately labels the data set with descriptive variable names. 
## 5)  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Create a function to read in the subject, data, and activity files from a given directory:

read_data_tables <- function(dirname, test_or_train = "test") { 

    ## This reads all required data from the test and train data sets
    ## If the variable test_or_train == "test", read the test data set.
    ## If the variable test_or_train == "train", read the train data set.

    ## This also creates good names for everything, because it's easiest to do it now.
    

## Stuff to implement if I have time:
#PJH# if (! file.exists("./data")) {
#PJH#     dir.create("./data") }
#PJH# fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#PJH# download.file(fileUrl,destfile="./data/getdata_projectfiles_UCI_HAR_Dataset.zip",method="curl")
#PJH# unzip

    dirname <- paste(dirname, test_or_train, "/", sep = "")
    fullname <- paste(dirname, "subject_", test_or_train, ".txt", sep = "") 
    subject.table <- data.table(read.table(fullname,                      # Single column w/ subject ids    # dim 1 matches X_features.table
                                           header = FALSE, sep = "", col.names=c("Subject")))

    fullname <- paste(dirname, "y_", test_or_train, ".txt", sep = "") 
    activity.table <- data.table(read.table(fullname,                     # Single column w/ activity ids   # dim 1 matches X_features.table
                                            header = FALSE, sep = "", col.names=c("Activity")))

    ## 3) Use descriptive activity names to name the activities in the data set
    ##    Make the activity column into a factor with good labels from the file activity_labels.txt
    ##    Yes, I know I'm supposed to do that later, but IME (programmer since 1985) that leads to bugs.  Label it now when it's easier
    
    activity.table$Activity <- factor(activity.table$Activity, 
                                      labels = c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))

    ## 4) Appropriately labels the data set with descriptive variable names. 
    ##    Define feature_names -- I put this into its own file, feature_names.R  because it's a lot!
    ##    See the file features_names.R  for documentation on these names and how they are derived from features.txt names.

    if (! exists("feature_names")) {
        source("feature_names.R")
    }

    ## Read in the data with the "features" -- X_test.txt or X_train.txt
    ## This is the summarized information derived from the inertial information
    ## which was derived from the raw accelerometer and gyroscopic signals.

    
    fullname <- paste(dirname, "X_", test_or_train, ".txt", sep ="") 
    X_features.table <- data.table(read.table(fullname,                                  # dim(X_features.table) [1] 2947  561  # test version
                                              header = FALSE, sep ="", col.names = feature_names))    #          [1] 7352  561  # train version


    ## We weren't asked to preserve information about the phase, but I hate information loss.
    phase <- data.table(Phase = rep(ifelse (test_or_train == "test", 1, 2), each = dim(activity.table)[1]))
    phase$Phase <- factor(phase$Phase, levels = c(1, 2), labels = c("test", "train"))
 
    out.table <- cbind(subject.table, phase, activity.table, X_features.table)
}

test.table <- read_data_tables("data/UCI HAR Dataset/", "test")
train.table <- read_data_tables("data/UCI HAR Dataset/", "train")

## 1) Merge training and test sets to create one data set 
all.table <- rbind(test.table, train.table)

# 2) Extracts only the measurements on the mean and standard deviation for each measurement. 
wanted_cols <- colnames(all.table) %like% "[Mm]ean|std"

# preserve the first three columns which are id columents
wanted_cols[1:3] <- TRUE

all.table <- all.table[,colnames(all.table)[wanted_cols], with = FALSE]

## Now take all the "Features", turn them sideways, and make a long dataset out of them.
measure_names <- colnames(all.table)
measure_names <- measure_names[4:length(measure_names)]
all.table <- melt(all.table, measure.vars = measure_names, variable.name="Feature", value.name="Value")

## A long dataset; these are more flexible than wide ones.
## Subject, Phase, Activity, and Feature are id variables; Value is the measurement variable
## 
## melted all.table
##         Subject Phase         Activity              Feature      Value
##      1:       2  test         STANDING     tBodyAcc.mean_.X 0.25717778
##      2:       2  test         STANDING     tBodyAcc.mean_.X 0.28602671
##      3:       2  test         STANDING     tBodyAcc.mean_.X 0.27548482
##      4:       2  test         STANDING     tBodyAcc.mean_.X 0.27029822
##      5:       2  test         STANDING     tBodyAcc.mean_.X 0.27483295
##     ---                                                               
## 885710:      30 train WALKING_UPSTAIRS angle_Z.gravityMean_ 0.04981914
## 885711:      30 train WALKING_UPSTAIRS angle_Z.gravityMean_ 0.05005256
## 885712:      30 train WALKING_UPSTAIRS angle_Z.gravityMean_ 0.04081119
## 885713:      30 train WALKING_UPSTAIRS angle_Z.gravityMean_ 0.02533948
## 885714:      30 train WALKING_UPSTAIRS angle_Z.gravityMean_ 0.03669484

## 5) From the data set in step 4, creates a second, independent tidy data set with the
## average of each (feature) variable for each activity and each subject.

tidy.table <- all.table[, mean(Value), by = .(Subject, Activity, Feature)]
write.table(tidy.table, file="data/verytidytable.txt", row.name=FALSE) 

