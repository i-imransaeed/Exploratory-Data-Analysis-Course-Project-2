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

mergerEmissionAndClass <-  merge(emissionsData, srcClassCodeData, by="SCC")
srcAsCoalGrep <- grepl("coal", mergerEmissionAndClass$Short.Name, ignore.case=TRUE)
subsetMergerEmissionAndClass <- mergerEmissionAndClass[srcAsCoalGrep, ]

sumByYearAndSrcAsCoal <- aggregate(Emissions ~ year, subsetMergerEmissionAndClass, sum)

graphicPlot <- ggplot(sumByYearAndSrcAsCoal, aes(factor(year), Emissions))
graphicPlot <- graphicPlot + geom_bar(stat="identity") +
  xlab("year") +
  ylab(expression('Total PM'[2.5]*" Emissions")) +
  ggtitle('Total Emissions from coal sources from 1999 to 2008')
print(graphicPlot)

dev.copy(png, file = "plot4.png")
dev.off()
