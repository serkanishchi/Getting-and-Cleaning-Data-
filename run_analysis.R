## run_analysis.R script file, getting dataset from  
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## and unzip files to a local directory and does the following
## 1. Merges the training and the test sets to create one data set
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## And stores created tidy datasets.

## Load necessary libraries for cleaning, processing, and manipulating data 
library(tidyr)
library(dplyr)

## Download the dataset and unzip files to a local directory if doesn't exist 
if(!dir.exists("./UCI HAR Dataset"))
{
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    dir.create("./UCI HAR Dataset")
    download.file(fileURL, "UCI HAR Dataset.zip")
    unzip("./UCI HAR Dataset.zip")
}

## 1. Merges the training and the test sets to create one data set.
## Read training and test sets which are contains 
## subject who performed the activity(subject), features (X) and label(y) fragments
## Read training set fragments 
trainSubject<-read.table(file = "./UCI HAR Dataset/train/subject_train.txt")
trainX<-read.table(file = "./UCI HAR Dataset/train/X_train.txt")
trainy<-read.table(file = "./UCI HAR Dataset/train/y_train.txt")
## Combine subject, features and label columns of the train set in a one table
train<-cbind(trainSubject, trainy, trainX)
## Read test set fragments 
testSubject<-read.table(file = "./UCI HAR Dataset/test/subject_test.txt")
testX<-read.table(file = "./UCI HAR Dataset/test/X_test.txt")
testy<-read.table(file = "./UCI HAR Dataset/test/y_test.txt")
## Combine subject, features and label columns of the test set in a one table
test<-cbind(testSubject, testy, testX)
## Merge the training and the test sets to create one data set
dataset<-rbind(train, test)

## 2.Extracts only the measurements on the mean and standard deviation for each measurement.
## Read column names from features.txt
features<-read.table(file = "./UCI HAR Dataset/features.txt")
features<-as.character(features$V2)
## Define the column names
names(dataset)<-c("SubjectID", "Activity", features)
## Select the columns which are contains mean and standart deviation
selectedColumns<-features[grep("-mean\\(\\)|-std\\(\\)", x=features)]
columns<-c("SubjectID", "Activity", selectedColumns)
dataset <- subset(dataset, select = columns)

## 3.Uses descriptive activity names to name the activities in the data set
## Read activity labels from activity_label.txt
activityLabels<-read.table(file = "./UCI HAR Dataset/activity_labels.txt")
## For more readable activity names replace "_" with " "
activityLabels<-gsub("_", " ", activityLabels$V2)
dataset$Activity<-activityLabels[dataset$Activity]

## 4.Appropriately labels the data set with descriptive variable names.
columnNames<-names(dataset)
## For more readable column names clean features from parentheses "(", ")" and 
## replace  dash "-" and comma "," with dot "."
columnNames<-gsub("\\(|\\)","",gsub("-|\\,", ".", columnNames))
## For more descriptive column names, replace abbreviations
columnNames<-gsub("^t", "Time", columnNames)
columnNames<-gsub("^f", "Frequency", columnNames)
columnNames<-gsub(".std", "StandartDeviation", columnNames)
columnNames<-gsub(".mean", "Mean", columnNames)
columnNames<-gsub("Acc", "Accelerometer", columnNames)
columnNames<-gsub("Mag", "Magnitude", columnNames)
columnNames<-gsub("Gyro", "Gyroscope", columnNames)
## Set the descriptive column names for the dataset
names(dataset)<-columnNames

## 5.From the data set in step 4, creates a second, independent tidy data set with the
## average of each variable for each activity and each subject.
secondDataset<-dataset %>%
    group_by(SubjectID, Activity) %>%
    summarise_all(mean)

## Store created tidy datasets
write.table(dataset, "TidyDataset.txt")
write.table(secondDataset, "TidySecondDataset.txt", row.names = FALSE)
