library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
extractedFeatures <- grep(".*mean.*|.*std.*", features[,2])
extractedFeatures.names <- features[extractedFeatures,2]
extractedFeatures.names = gsub('-mean', 'Mean', extractedFeatures.names)
extractedFeatures.names = gsub('-std', 'Std', extractedFeatures.names)
extractedFeatures.names <- gsub('[-()]', '', extractedFeatures.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[extractedFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[extractedFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
combindData <- rbind(train, test)
colnames(combindData) <- c("subject", "activity", extractedFeatures.names)

# turn activities & subjects into factors
combindData$activity <- factor(combindData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
combindData$subject <- as.factor(combindData$subject)

combindData.melted <- melt(combindData, id = c("subject", "activity"))
combindData.mean <- dcast(combindData.melted, subject + activity ~ variable, mean)

write.table(combindData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
