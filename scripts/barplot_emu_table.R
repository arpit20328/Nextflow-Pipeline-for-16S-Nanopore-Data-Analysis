#!/usr/bin/env Rscript

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if a file path was provided
if (length(args) == 0) {
  stop("Please provide the path to the TSV file as an argument.\nUsage: Rscript script.R <path_to_file.tsv>", call. = FALSE)
}

file_to_read <- args[1]

# Verify the file exists
if (!file.exists(file_to_read)) {
  stop(paste("The file", file_to_read, "does not exist."), call. = FALSE)
}

# Load data
data <- read.csv(file_to_read, sep = '\t')

# Rest of your script...

# Keep only relevant columns
data <- data[, c(1,2,3)] 

# Rename the column
colnames(data)[2] <- "Relative_Abundance"

# Convert to percentage
data$Relative_Abundance <- data$Relative_Abundance * 100

# Sort by abundance
data <- data[order(data$Relative_Abundance, decreasing = TRUE), ]
data$Relative_Abundance  <- round(data$Relative_Abundance, 3)
#Save TSV file 
write.table(data,"Published_EMU_table.tsv" ,sep = '\t' , col.names = T , row.names = F)

row = which(data[,2] == 0)
data = data[-row,]

#sort top 25 or <top 25 species
if(dim(data)[1] >= 25) { data_temp = data[1:25,] }
if(dim(data)[1] < 25) { data_temp = data }

# Open PDF device
pdf("Top 25 Microbial Species Barplot.pdf", width = 12, height = 6)

# Create the barplot with narrower bars and more space
bp <- barplot(height = data_temp$Relative_Abundance,
              names.arg = FALSE,
              ylab = "Relative Abundance (%)",
              main = paste("Top" ,dim(data_temp)[1],"Microbial Species by Relative Abundance"),
              col = "steelblue",
              axes = TRUE,
              ylim = c(0, 100),
              width = 0.5,          # Make bars narrower
              space = 1.5)          # Increase spacing between bars

# Add slanted species names below bars
text(x = bp, y = par("usr")[3] - 1.5,
     labels = data_temp$species,
     srt = 45, adj = 1, xpd = TRUE, cex = 0.7)

# Add slanted abundance values above bars
text(x = bp, y = data_temp$Relative_Abundance + 2,
     labels = paste0(round(data_temp$Relative_Abundance, 3), "%"),
     srt = 45, adj = 0, xpd = TRUE, cex = 0.7, col = "black")

# Close the PDF device
dev.off()
