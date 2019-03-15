#dplyr provides a flexible grammar of data manipulation. It's the next iteration of plyr, focused on tools for working with data frames (hence the d in the name).
listOfPackages <- c("dplyr","ggplot2")
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

dataFileSrcClassificationCode <- "Source_Classification_Code.rds"
dataFilePathClassificationData <- paste0(getwd(),"/", dataFileSrcClassificationCode)

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
srcClassCodeData <- readRDS(dataFilePathClassificationData)


vehicles <- grepl("vehicle", srcClassCodeData$SCC.Level.Two, ignore.case=TRUE)
vehiclesSrcClassCode <- srcClassCodeData[vehicles,]$SCC
emmissionSubSetVehicles <- emissionsData[emissionsData$SCC %in% vehiclesSrcClassCode,]

baltimoreVehiclesEmmissions <- emmissionSubSetVehicles[emmissionSubSetVehicles$fips=="24510",]
baltimoreVehiclesEmmissions$city <- "Baltimore City"

laVehiclesEmmissions <- emmissionSubSetVehicles[emmissionSubSetVehicles$fips=="06037",]
laVehiclesEmmissions$city <-"Los Angeles County"

combinedBMANDLA <- rbind(baltimoreVehiclesEmmissions,laVehiclesEmmissions)

graphicPlot <- ggplot(combinedBMANDLA, aes(x=factor(year), y=Emissions, fill=city)) +
 geom_bar(aes(fill=year),stat="identity") +
 facet_grid(scales="free", space="free", .~city) +
 guides(fill=FALSE) + theme_bw() +
 labs(x="Year", y=expression("Total PM"[2.5]*" Emission (Kilo-Tons)")) + 
 labs(title=expression("PM"[2.5]*" Motor Vehicle Source Emissions in Baltimore & LA, 1999-2008"))
 
print(graphicPlot)


dev.copy(png, file = "plot6.png")
dev.off()
