#!/usr/bin/env Rscript

#INSTALL BUSMINER LIB
#install.packages("devtools")
#library(devtools)
#install_github("analytics-ufcg/busminer")

log <- function(msg) {
    print(paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S ->"),msg))
}

log("-------------------------- NEW EXECUTION LOG ------------------------")

args = commandArgs(trailingOnly = TRUE)

MIN_NUM_ARGS = 5
BASE_GPS_FILENAME = "gps_data_"
CSV_EXT = ".csv"

if (length(args) != MIN_NUM_ARGS) {
    stop(paste("Wrong number of arguments!",
               "Usage: RScript estimate_yesterday_bat.R <base.code.folder.path> <gtfs.folder.path> <input.data.folder.path> <output.data.folder.path> <data.format: CRAWLER = 0, UTFPR = 1>",sep="\n"))
}

require(busminer)

get.yesterday.gps.file.name <- function() {
    yesterday <- today() - days(1)
    yesterday.str <- format(yesterday, "%Y_%m_%d")
    return(paste0(BASE_GPS_FILENAME,yesterday.str,CSV_EXT))
}



############################ MAIN CODE ############################

base.code.folder.path = args[1]
gtfs.folder.path = args[2]
input.data.folder.path = args[3]
output.data.folder.path = args[4]
data.format = as.integer(args[5])

source (paste0(base.code.folder.path,"/ctba_analysis_utils.R"), echo=F)

tryCatch(
    proc.time <- system.time({
        input.data.file.name <- get.yesterday.gps.file.name()
        input.data.file.path <- paste(input.data.folder.path,input.data.file.name,sep="/")

        log(paste("Processing file:",input.data.file.path))

        stops.data <- prepare.stops.data(gtfs.folder.path)
        shapes.data <- read.csv(paste(gtfs.folder.path,"shapes.txt",sep="/"))
        generate.day.bat(input.data.file.path,data.format,stops.data,shapes.data,output.data.folder.path)
    }),
    error=function(e) log(e)
)

log(paste("Processing Time:",proc.time[3]))

