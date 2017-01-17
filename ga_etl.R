##Initialize Pkg
library(RGoogleAnalytics)
library(lubridate)

##OAuth token 
##oauth_token <- Auth(client.id = "1022326553653-ifco0947ujiqcp5rqdar63lfq2jrip99.apps.googleusercontent.com",client.secret = "oqtdJKw_zgQV0kyU3v4D1caf")
##save(oauth_token, file ="./token_file")


#set the working directory
setwd("C:/Users/austin.mcculloch/Documents/R_Projects")

#Load saved oauth_token from working directory
load("./token_file")

#Validate the token
ValidateToken(oauth_token)

##Get Table id profiles
##GetProfiles(oauth_token)

##Create variable for yesterday
#yesterday <- Sys.Date() - 1
#yesterday <- as.character(yesterday)


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
end_date <- as.character(end_date + 1)




##Create GA_Traffic_AWP
paramsTraffic <- Init(start.date = start_date, end.date = end_date,
               dimensions = c("ga:date", "ga:dimension2"),
               metrics = c("ga:sessions", "ga:avgSessionDuration"),
               sort = "ga:dimension2",
               table.id = "ga:99898278",
               max.results = 30000)

query <- QueryBuilder(paramsTraffic)

GA_Traffic_AWP <- GetReportData(query, oauth_token, split_daywise = TRUE)

##Add origin 
GA_Traffic_AWP$Origin <- "AWP"

##Change Column Names
names(GA_Traffic_AWP) <- c("date", "program_pcid", "sessions", "avg_session_duration", "origin")

##Convert AvgSessionDuration seconds to minutes
GA_Traffic_AWP$avg_session_duration <- GA_Traffic_AWP$avg_session_duration/60


##Create GA_Events_AWP
paramsEvents <- Init(start.date = start_date, end.date = end_date,
                      dimensions = c("ga:date", "ga:dimension2", "ga:dimension5", "ga:dimension9"),
                      metrics = c("ga:totalEvents", "ga:eventValue"), 
                      table.id = "ga:99898278",
                      sort = "ga:dimension2",
                      max.results = 30000)

queryEvents <- QueryBuilder(paramsEvents)
GA_Events_AWP <- GetReportData(queryEvents, oauth_token, split_daywise = TRUE)

GA_Events_AWP$Origin <- "AWP"
names(GA_Events_AWP) <- c("date", "program_pcid", "brand_id", "savings_category", "redeems", "event_value", "origin")



##Create GA_Traffic_Mobile
paramsMobile <- Init(start.date = start_date, end.date = end_date,
                      dimensions = c("ga:date", "ga:dimension2"),
                      metrics = c("ga:sessions", "ga:avgSessionDuration"), 
                      table.id = "ga:120621676",
                      sort = "ga:dimension2",
                      max.results = 30000)

queryTrafficMobile <- QueryBuilder(paramsMobile)

GA_Traffic_MObile <- GetReportData(queryTrafficMobile, oauth_token, split_daywise = TRUE)
GA_Traffic_MObile$Origin <- "Mobile"

names(GA_Traffic_MObile) <- c("date", "program_pcid", "sessions", "avg_session_duration", "origin")
GA_Traffic_MObile$avg_session_duration <- GA_Traffic_MObile$avg_session_duration/60


##Create GA_Events_Mobile
paramsEventsMobile <- Init(start.date = start_date, end.date = end_date,
                     dimensions = c("ga:date", "ga:dimension2", "ga:dimension19", "ga:dimension13"),
                     metrics = c("ga:totalEvents", "ga:eventValue"), 
                     table.id = "ga:120621676",
                     sort = "ga:dimension2",
                     max.results = 30000)

queryEventsMobile <- QueryBuilder(paramsEventsMobile)
GA_Events_Mobile <- GetReportData(queryEventsMobile, oauth_token, split_daywise = TRUE)
GA_Events_Mobile$Origin <- "Mobile"

names(GA_Events_Mobile) <- c("date", "program_pcid", "brand_id", "savings_category", "redeems", "event_value","origin")



##Combine Dataframes
ga_traffic <- rbind(GA_Traffic_AWP, GA_Traffic_MObile)

ga_traffic$date <- as.character(ga_traffic$date)
ga_traffic$date <- ymd(ga_traffic$date)
ga_traffic$date <- as.character(ga_traffic$date)

ga_events <- rbind(GA_Events_AWP, GA_Events_Mobile)

ga_events$date <- as.character(ga_events$date)
ga_events$date <- ymd(ga_events$date)
ga_events$date <- as.character(ga_events$date)

ga_events$brand_id <- as.character(ga_events$brand_id)

ga_traffic$sessions <- as.integer(ga_traffic$sessions)

ga_events$redeems <- as.integer(ga_events$redeems)

#library("RODBC")
#dbhandler <- odbcConnect("AmazonRedshiftDSN", "etl_user","MoveThatD@t@1!")

#sqlDrop(dbhandler, "etl_stage.ga_traffic")
#sqlSave(dbhandler, ga_traffic, tablename = "etl_stage.ga_traffic")

#sqlDrop(dbhandler, "etl_stage.ga_events")
#sqlSave(dbhandler, ga_events, tablename = "etl_stage.ga_events")

#odbcClose(dbhandler)

library(mailR)
send.mail(from = "austin.mcculloch@accessdevelopment.com",
          to = c("austin.mcculloch@accessdevelopment.com", "ken.lauritzen@accessdevelopment.com"),
          subject = "ga_etl",
          body = "ga_etl ran today",
          authenticate = TRUE,
          smtp = list(host.name = "smtp.office365.com", port = 587,
                      user.name = "austin.mcculloch@accessdevelopment.com",
                      passwd = "Wake0569829@", tls = TRUE))

