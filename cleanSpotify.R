
rm(list = ls())

# install.packages("pdftools", dependencies = T)
# install.packages("stringr", dependencies = T)
library(pdftools)
library(stringr)
library(dplyr)
library(tidyr)


################################
### Multiple Splits Function ###
################################
strsplits <- function(x, splits, ...) {
  for (split in splits) {
    x <- unlist(strsplit(x, split, ...))
  }
  return(x[!x == ""]) # Remove empty values
}


###########################
### Construct DataFrame ###
###########################
## Read PDF Pages and Structure First Page
PDF <- pdf_text("Spotify_Royalties.pdf")

## Create Variable Labels
# vars <- c("Date", "Quantity", "Price", "Subtotal", "Partner", "Type", "Country")
vars <- c("Date", "Quantity", "Price", "Subtotal", "Partner", "Type", "Country", "Page")

## Loop Counters and Empty DataFrame
N <- 1  # Count page number
spotify <- data.frame(  # Prepare final dataframe
  Date = as.Date(character()),
  Quantity = numeric(),
  Price = numeric(),
  Subtotal = numeric(),
  Country = character(),
  Partner = character(),
  Type = character(),
  Page = as.character(),
  stringsAsFactors = F
)

## Build the DataFrame
for (N in 1:length(PDF)) {
  ## Structure PDF text
  pageN <- unlist(strsplit(PDF[N], "\r\n"))  # Split on every Carriage Return and Line Feed
  pageN <- pageN[-c(length(pageN))]  # Remove page number vector (always at the end of each page)
  if (N == 1) {
    pageN <- pageN[3:length(pageN)]  # Remove variable vectors (first two rows of first page only)
  }  
  pageN <- str_trim(pageN)  # Trim spaces at ends of each row
  
  ## Vectorize and List Data
  rows <- 1  # Count data rows on each page
  pagerows <- vector("list", length(pageN))
  for (rows in 1:length(pageN)) {
    ## Check for time-stamp error with regex and split accordingly 
    if (grepl("12:00:00 AM", pageN[rows]) == FALSE) {
      pagerows[[rows]] <- unlist(strsplit(pageN[rows], " +"))
    } else if (grepl("12:00:00 AM", pageN[rows]) == TRUE) {
      pagerows[[rows]] <- strsplits(pageN[rows], c("12:00:00 AM", "[[:space:]]"))
    }
    
    ## Final check timestamps based on dimension count and increase row-counter
    if (length(pagerows[[rows]]) > length(vars[! vars %in% "Page"])) {
      timeStamp <- c("12:00:00", "AM")
      pagerows[[rows]] <- pagerows[[rows]][! pagerows[[rows]] %in% timeStamp]
      rows <- rows + 1
    } else if (length(pagerows[[rows]]) == length(vars[! vars %in% "Page"])) {
      rows <- rows + 1
    }
  }
  
  ## Create DF From List
  pageN <- as.data.frame(
    matrix(
      unlist(pagerows), 
      nrow = length(pagerows), 
      byrow = T
    ), 
    stringsAsFactors = F
  )
  
  ## Redefine Varibale classes
  names(pageN) <- vars[! vars %in% "Page"]
  pageN$Date <- as.Date(pageN$Date, format = "%m/%d/%Y")
  pageN$Quantity <- as.integer(pageN$Quantity)
  pageN$Price <- as.numeric(pageN$Price)
  pageN$Subtotal <- as.numeric(pageN$Subtotal)
  pageN$Partner <- as.factor(pageN$Partner)
  pageN$Type <- as.factor(pageN$Type)
  pageN$Country <- as.character(pageN$Country)
  pageN$Page <- as.numeric(N)  # Create Page Number column
  
  ## Adjust Col Names and append to primary data table
  spotify <- rbind.data.frame(spotify, pageN)
  
  ## Isolate and Remove Errors
  error <- spotify[which(is.na(as.numeric(spotify$Quantity)) == T),]  # Use sum error to identify problem rows
  if (nrow(error) > 0 & nrow(error) < 2) {
    spotify <- spotify[! row.names(spotify) %in% row.names(error),]
  } else {
    N <- N + 1
  }
}
