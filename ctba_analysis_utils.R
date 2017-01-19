#source("../../busminer/R/gps.stops.matcher.R", echo=F)

CRAWLER_DATA_TYPE = 0
UTFPR_PROVIDED_DATA_TYPE = 1

#Special conversion function to deal with numeric data with comma instead of dot as separator.
setAs("character", "num.with.commas", 
      function(from) as.numeric(gsub(",", ".", from) ) )

get.date.from.filepath <- function(gps.data.file.path) {
    date.strs <- strsplit(strsplit(gps.data.file.path,".", fixed = TRUE)[[1]][1],"_",fixed=TRUE)[[1]]
    date <- paste(date.strs[-(1:2)],collapse ='-')
    return(date)
}

prepare.ctba.gps.data <- function(gps.data.file.path,data.format) {
    if (data.format == CRAWLER_DATA_TYPE) {
        gps.data.date <- get.date.from.filepath(gps.data.file.path)
        gps.data <- read.csv(gps.data.file.path, 
                             col.names = c("HORA","LON","PREFIXO","ADAPT","LAT","LINHA"),
                             colClasses = c("LINHA"="factor","PREFIXO"="factor","HORA"="character","LAT"="numeric","LON"="numeric","ADAPT"="factor")) %>% 
            unique() %>%
            select(PREFIXO, LAT, LON, HORA, LINHA) %>%
            mutate(HORA = paste(gps.data.date,HORA))
    } else if (data.format == UTFPR_PROVIDED_DATA_TYPE) {
        gps.data <- read.csv(gps.data.file.path, 
                             col.names = c("HORA","LON","PREFIXO","ADAPT","LAT","LINHA"), 
                             colClasses = c("COD_LINHA"="factor","VEIC"="factor","DTHR"="character","LAT"="num.with.commas","LON"="num.with.commas")) %>% 
            unique() %>%
            select(VEIC, LAT, LON, DTHR, COD_LINHA)
    }
    
    names(gps.data) <- c("bus.code", "latitude", "longitude", "timestamp", "line.code")
    
    timestamp.format <- ifelse(data.format == CRAWLER_DATA_TYPE,"ymd HMS","dmy HMS")
    
    gps.data <- prepare.gps.data(gps.data,date.time.format = timestamp.format)
    
    return(gps.data)
}

generate.day.bat <- function(gps.day.file.path,data.format,stops.data,shapes.data,output.folder.path=NULL,lcode=NULL) {
    date_str <- last(strsplit(gps.day.file.path,"/")[[1]])
    print(paste("Processing file:",gps.day.file.path))
    
    timestamp.format <- ifelse(data.format == CRAWLER_DATA_TYPE,"ymd HMS","dmy HMS")
    
    print(system.time({
        print("Reading GPS data...")
        day.gps.data <- prepare.ctba.gps.data(gps.data.file.path = gps.day.file.path,data.format) %>%
            filter(hour(timestamp) != 0)
        
        if (!missing(lcode)) {
            day.gps.data <- day.gps.data %>%
                filter(line.code == lcode)
        }
        
        print("Estimating BAT...")
        estimated.stops.arrival.time <- day.gps.data %>%
            group_by(line.code,bus.code) %>%
            arrange(timestamp) %>%
            do(estimate.bus.arrival.times(stops.data,shapes.data,., verbose = FALSE))
    }))
    
    if (!missing(output.folder.path)) {
        print("Writing BAT data to file...")
        write.csv(estimated.stops.arrival.time, paste0(output.folder.path,"/bat_",date_str), row.names = FALSE)
    }
    return(estimated.stops.arrival.time)
}