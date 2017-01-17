##Initialize Pkg
library(RGoogleAnalytics)
setwd("C:/Users/austin.mcculloch/Documents/R_Projects")
load("./token_file")
ValidateToken(oauth_token)

library("lubridate")

##Create start and end date variables
today <- Sys.Date()

if (month(today)-1 == 0) {
  mm <- as.character(12)
} else if (month(today)-1 < 10) {
  mm <- as.character(paste(0,month(today)-1, sep = ""))
} else {
  mm <- as.character(month(today))
}


if (mm == 12){
  yy <- as.character(year(today)-1)
} else {
  yy <- as.character(year(today))
}

ddmm <- days_in_month(today)
start_date <- paste(yy,mm,"02", sep = "-")
end_date <- as_date(paste(yy,mm,ddmm, sep = "-"))
end_date <- as.character(end_date)


#create dataframe for month unique users AWP
p <- Init(start.date = start_date, end.date = end_date,
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
p <- Init(start.date = start_date, end.date = end_date,
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

month_users$date <- as.character(month_users$date)
month_users$date <- ymd(month_users$date)
month_users$date <- as.character(month_users$date)

month_users <- month_users[,c(2,1,3,4)]

#library("RODBC")
#dbhandler <- odbcConnect("AmazonRedshiftDSN", "etl_user","MoveThatD@t@1!")

#sqlDrop(dbhandler, "etl_stage.ga_users")
#sqlSave(dbhandler, month_users, tablename = "etl_stage.ga_users")

#odbcClose(dbhandler)



