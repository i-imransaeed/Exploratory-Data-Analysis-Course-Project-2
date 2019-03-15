#dplyr provides a flexible grammar of data manipulation. It's the next iteration of plyr, focused on tools for working with data frames (hence the d in the name).
listOfPackages <- c("dplyr")
newPackages <- listOfPackages[!(listOfPackages %in% installed.packages()[,"Package"])]
if(length(newPackages)) {
	message(sprintf("Going to install package(s)[ %s ]\n", newPackages))
	install.packages(newPackages) 
} else {
	message("All packages are already installed. Will skip install pahse")
}

for(package in listOfPackages){
  library(package, character.only = TRUE)
}
# Generic variables 

zipDataFileName <- "exdata%2Fdata%2FNEI_data.zip"
zipDataFilePath <- paste0(getwd(),"/", zipDataFileName)
dataFileNameEmissionsData <- "summarySCC_PM25.rds"
dataFilePathEmissionsData <- paste0(getwd(),"/", dataFileNameEmissionsData)

# STEP 1 - Get data
# Chcek if data exists in working directory.
if (!file.exists(zipDataFilePath)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(fileURL, zipDataFilePath, method="curl")
}  
# STEP 1.1 - Unzip previously obtained data
if (file.exists(zipDataFilePath) ) { 
  unzip(zipDataFilePath) 
}
emissionsData <- readRDS(dataFilePathEmissionsData)


baltimoreEmissionsData <- subset(emissionsData, fips == "24510")

sumByYear <- aggregate(Emissions ~ year, baltimoreEmissionsData, sum)

barplot(height=sumByYear$Emissions, names.arg=sumByYear$year, xlab="Years", ylab=expression('Total PM'[2.5]*' emission'),main=expression('Total PM'[2.5]*' in the Baltimore City, MD emissions at various years'))
dev.copy(png, file = "plot2.png")
dev.off()
