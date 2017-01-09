##Initialize Pkg
library(RGoogleAnalytics)
setwd("C:/Users/austin.mcculloch/Documents/R_Projects")
load("./token_file")
ValidateToken(oauth_token)

library("lubridate")

lastmonth <- month(as.character(Sys.Date())) -1


if (lastmonth == 0){
  lastmonth <- 12
}

long <- c(1,3,5,7,8,10,12)

if (lastmonth == 2){
  endday <- "28"
} else if (lastmonth %in% long){
  endday <- "31"
} else {
  endday <- "30"
}


if (nchar(lastmonth) == 1){
  lastmonth <- paste(0,lastmonth, sep = "")
}

if(lastmonth == 12){
  yeardate <- year(Sys.Date())-1
} else {
  yeardate <- year(Sys.Date())
}


start <- paste(yeardate,lastmonth,"01", sep = "-")
end <- paste(yeardate, lastmonth, endday, sep = "-")



#create dataframe for month unique users AWP
p <- Init(start.date = start, end.date = end,
          dimensions = c("ga:dimension2", "ga:yearMonth"),
          metrics = "ga:users",
          table.id = "ga:99898278",
          sort = "ga:dimension2",
          max.results = 50000)

query <- QueryBuilder(p)

users_awp <- GetReportData(query, oauth_token)
users_awp$origin <- "AWP"

names(users_awp) <- c("program_pcid", "date","users", "origin")
users_awp$date <- paste(users_awp$date,"01",sep = "")


#create dataframe for month unique users Mobile
p <- Init(start.date = start, end.date = end,
          dimensions = c("ga:dimension2", "ga:yearMonth"),
          metrics = "ga:users",
          table.id = "ga:120621676",
          sort = "ga:dimension2",
          max.results = 50000)

query <- QueryBuilder(p)

users_mobile <- GetReportData(query, oauth_token)
users_mobile$origin <- "Mobile"

names(users_mobile) <- c("program_pcid", "date","users", "origin")
users_mobile$date <- paste(users_mobile$date,"01",sep = "")

month_users <- rbind(users_awp, users_mobile)

library("RODBC")
dbhandler <- odbcConnect("AmazonRedshiftDSN", "etl_user","MoveThatD@t@1!")

sqlDrop(dbhandler, "etl_stage.ga_users")
sqlSave(dbhandler, ga_users, tablename = "etl_stage.ga_users")

odbcClose(dbhandler)



