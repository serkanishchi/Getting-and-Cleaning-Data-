# Getting and Cleaning Data Course Project

The purpose of this project is to prepare tidy data that can be used for later analysis from [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) dataset

## Getting Started

These instructions will provide you a step by step guide on how to get and tidy [this](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) dataset.  

### Load necessary libraries
Load necessary libraries for cleaning, processing, and manipulating data.
```Rscript
library(tidyr)
library(dplyr)
```

### Download the dataset
Download the dataset and unzip files to a local directory if doesn't exist.
```R
if(!dir.exists("./UCI HAR Dataset"))
{
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    dir.create("./UCI HAR Dataset")
    download.file(fileURL, "UCI HAR Dataset.zip")
    unzip("./UCI HAR Dataset.zip")
}
```

### Merge the training and the test sets to create one data set
Read training and test sets which are contains subject who performed the activity(subject), features (X) and label(y) fragments.

Read training set fragments.
```R
trainSubject<-read.table(file = "./UCI HAR Dataset/train/subject_train.txt")
trainX<-read.table(file = "./UCI HAR Dataset/train/X_train.txt")
trainy<-read.table(file = "./UCI HAR Dataset/train/y_train.txt")
```
Combine subject, label, and features columns of the train set in a one table.
```R
train<-cbind(trainSubject, trainy, trainX)
```
Read test set fragments. 
```R
testSubject<-read.table(file = "./UCI HAR Dataset/test/subject_test.txt")
testX<-read.table(file = "./UCI HAR Dataset/test/X_test.txt")
testy<-read.table(file = "./UCI HAR Dataset/test/y_test.txt")
```
Combine subject, features and label columns of the test set in a one table.
```R
test<-cbind(testSubject, testy, testX)
```
Merge the training and the test sets to create one data set.
```R
dataset<-rbind(train, test)
```

### Extract only the measurements on the mean and standard deviation for each measurement
Read column names from features.txt.
```R
features<-read.table(file = "./UCI HAR Dataset/features.txt")
features<-as.character(features$V2)
```
Define the column names.
```R
names(dataset)<-c("SubjectID", "Activity", features)
```
Select the columns which are contains mean and standart deviation.
```R
selectedColumns<-features[grep("-mean\\(\\)|-std\\(\\)", x=features)]
columns<-c("SubjectID", "Activity", selectedColumns)
dataset <- subset(dataset, select = columns)
```

### Use descriptive activity names to name the activities in the data set
Read activity labels from activity_label.txt.
```R
activityLabels<-read.table(file = "./UCI HAR Dataset/activity_labels.txt")
```
For more readable activity names replace "_" with " ".
```R
activityLabels<-gsub("_", " ", activityLabels$V2)
dataset$Activity<-activityLabels[dataset$Activity]
```

### Appropriately labels the data set with descriptive variable names
Get column names of the dataset.
```R
columnNames<-names(dataset)
```
For more readable column names clean features from parentheses "(", ")", replace  dash "-" and comma "," with dot ".".
```R
columnNames<-gsub("\\(|\\)","",gsub("-|\\,", ".", columnNames))
```
For more descriptive column names, replace abbreviations.
```R
columnNames<-gsub("^t", "Time", columnNames)
columnNames<-gsub("^f", "Frequency", columnNames)
columnNames<-gsub(".std", "StandartDeviation", columnNames)
columnNames<-gsub(".mean", "Mean", columnNames)
columnNames<-gsub("Acc", "Accelerometer", columnNames)
columnNames<-gsub("Mag", "Magnitude", columnNames)
columnNames<-gsub("Gyro", "Gyroscope", columnNames)
```
Set the descriptive column names for the dataset.
```R
names(dataset)<-columnNames
```

### Create a second, independent tidy data set with the average of each variable for each activity and each subject.
Group the dataset by subject ID and activity and calculate mean for all subgroups. 
```R
secondDataset<-dataset %>%
    group_by(SubjectID, Activity) %>%
    summarise_all(mean)
```

### Store created tidy datasets
Write created tidy datasets to txt files.
```R
write.table(dataset, "TidyDataset.txt")
write.table(secondDataset, "TidySecondDataset.txt", row.names = FALSE)
```
