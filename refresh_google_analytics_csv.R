##Initialize Pkg
library(RGoogleAnalytics)
setwd("C:/Users/austin.mcculloch/Documents/R_Projects")
load("./token_file")
ValidateToken(oauth_token)


##Create variable for two days ago
enddate <- as.character(Sys.Date() - 2)


##Create GA_Traffic_AWP
paramsTraffic <- Init(start.date = "2016-01-01", end.date = enddate,
                      dimensions = c("ga:date", "ga:dimension2"),
                      metrics = c("ga:sessions", "ga:avgSessionDuration"),
                      sort = "ga:dimension2",
                      table.id = "ga:99898278",
                      max.results = 50000)

query <- QueryBuilder(paramsTraffic)

GA_Traffic_AWP <- GetReportData(query, oauth_token, split_daywise = TRUE, paginate_query = TRUE)

##Add origin 
GA_Traffic_AWP$Origin <- "AWP"

##Change Column Names
names(GA_Traffic_AWP) <- c("date", "program_pcid", "sessions", "avg_session_duration", "origin")

##Convert AvgSessionDuration seconds to minutes
GA_Traffic_AWP$avg_session_duration <- GA_Traffic_AWP$avg_session_duration/60


##Create GA_Events_AWP
paramsEvents <- Init(start.date = "2016-01-01", end.date = enddate,
                     dimensions = c("ga:date", "ga:dimension2", "ga:dimension5", "ga:dimension9"),
                     metrics = c("ga:totalEvents", "ga:eventValue"), 
                     table.id = "ga:99898278",
                     sort = "ga:dimension2",
                     max.results = 30000)

queryEvents <- QueryBuilder(paramsEvents)
GA_Events_AWP <- GetReportData(queryEvents, oauth_token, split_daywise = TRUE, paginate_query = TRUE)

GA_Events_AWP$Origin <- "AWP"
names(GA_Events_AWP) <- c("date", "program_pcid", "brand_id", "savings_category", "redeems", "event_value","origin")

##Create GA_Traffic_Mobile
paramsMobile <- Init(start.date = "2016-05-20", end.date = enddate,
                     dimensions = c("ga:date", "ga:dimension2"),
                     metrics = c("ga:sessions", "ga:avgSessionDuration"), 
                     table.id = "ga:120621676",
                     sort = "ga:dimension2",
                     max.results = 30000)

queryTrafficMobile <- QueryBuilder(paramsMobile)

GA_Traffic_MObile <- GetReportData(queryTrafficMobile, oauth_token, split_daywise = TRUE, paginate_query = TRUE)
GA_Traffic_MObile$Origin <- "Mobile"

names(GA_Traffic_MObile) <- c("date", "program_pcid", "sessions", "avg_session_duration", "origin")
GA_Traffic_MObile$avg_session_duration <- GA_Traffic_MObile$avg_session_duration/60

##Create GA_Events_Mobile
paramsEventsMobile <- Init(start.date = "2016-05-20", end.date = "2016-08-13",
                           dimensions = c("ga:date", "ga:dimension2", "ga:dimension19", "ga:dimension13"),
                           metrics = c("ga:totalEvents", "ga:eventValue"), 
                           table.id = "ga:120621676",
                           sort = "ga:dimension2",
                           max.results = 30000)

queryEventsMobile <- QueryBuilder(paramsEventsMobile)
GA_Events_Mobile_a <- GetReportData(queryEventsMobile, oauth_token, split_daywise = TRUE, paginate_query = TRUE)
GA_Events_Mobile_a$Origin <- "Mobile"

names(GA_Events_Mobile_a) <- c("date", "program_pcid", "brand_id", "savings_category", "redeems", "event_value", "origin")


##Create GA_Events_Mobile
paramsEventsMobile <- Init(start.date = "2016-08-17", end.date = enddate,
                           dimensions = c("ga:date", "ga:dimension2", "ga:dimension19", "ga:dimension13"),
                           metrics = c("ga:totalEvents", "ga:eventValue"), 
                           table.id = "ga:120621676",
                           sort = "ga:dimension2",
                           max.results = 30000)

queryEventsMobile <- QueryBuilder(paramsEventsMobile)
GA_Events_Mobile_b <- GetReportData(queryEventsMobile, oauth_token, split_daywise = TRUE, paginate_query = TRUE)
GA_Events_Mobile_b$Origin <- "Mobile"

names(GA_Events_Mobile_b) <- c("date", "program_pcid", "brand_id", "savings_category", "redeems","event_value","origin")


##Combine Dataframes
GA_Events_Mobile <- rbind(GA_Events_Mobile_a, GA_Events_Mobile_b)

ga_traffic <- rbind(GA_Traffic_AWP, GA_Traffic_MObile)

ga_events <- rbind(GA_Events_AWP, GA_Events_Mobile)

ga_traffic$sessions <- as.integer(ga_traffic$sessions)

ga_events$redeems <- as.integer(ga_events$redeems)

write.csv(ga_traffic, file = "ga_traffic_complete.csv")
write.csv(ga_events, file = "ga_events_complete.csv")



