##Initialize Pkg
library(RGoogleAnalytics)
setwd("C:/Users/austin.mcculloch/Documents/R_Projects")
load("./token_file")
ValidateToken(oauth_token)

#Create initial dataframe for AWP 2015
df <- Init(start.date = "2015-06-01", end.date = "2015-06-30",
          dimensions = c("ga:dimension2", "ga:yearMonth"),
          metrics = "ga:users",
          table.id = "ga:99898278",
          sort = "ga:dimension2",
          max.results = 50000)

query <- QueryBuilder(df)

users <- GetReportData(query, oauth_token)


monthly_users_df <- users

#Loop through all the other months with 30 days and create master dataframe - AWP
for (x in c("09","11")){
  p <- Init(start.date = paste("2015",x,"01", sep="-"), end.date = paste("2015",x,"30",sep ="-"),
            dimensions = c("ga:dimension2", "ga:yearMonth"),
            metrics = "ga:users",
            table.id = "ga:99898278",
            sort = "ga:dimension2",
            max.results = 50000)
  
  query <- QueryBuilder(p)
  
  users <- GetReportData(query, oauth_token)
  
  
  monthly_users_df <- rbind(monthly_users_df, users)
  
}

#Loop through all the other months with 31 days and create master dataframe - AWP
for (x in c("07", "08", "10", "12")){
  p <- Init(start.date = paste("2015",x,"01", sep="-"), end.date = paste("2015",x,"31",sep ="-"),
            dimensions = c("ga:dimension2", "ga:yearMonth"),
            metrics = "ga:users",
            table.id = "ga:99898278",
            sort = "ga:dimension2",
            max.results = 50000)
  
  query <- QueryBuilder(p)
  
  users <- GetReportData(query, oauth_token)
  
  
  monthly_users_df <- rbind(monthly_users_df, users)
  
}


#create initial dataframe for february - AWP
p <- Init(start.date = "2016-02-01", end.date = "2016-02-29",
          dimensions = c("ga:dimension2", "ga:yearMonth"),
          metrics = "ga:users",
          table.id = "ga:99898278",
          sort = "ga:dimension2",
          max.results = 50000)

query <- QueryBuilder(p)

users <- GetReportData(query, oauth_token)


monthly_users <- users


#Loop through all the other months with 30 days - AWP
for (x in c("04","06","09","11")){
p <- Init(start.date = paste("2016",x,"01", sep="-"), end.date = paste("2016",x,"30",sep ="-"),
                      dimensions = c("ga:dimension2", "ga:yearMonth"),
                      metrics = "ga:users",
                      table.id = "ga:99898278",
                      sort = "ga:dimension2",
                      max.results = 50000)

query <- QueryBuilder(p)

users <- GetReportData(query, oauth_token)


monthly_users <- rbind(monthly_users, users)

}

#Loop through all the other months with 31 days - AWP
for (x in c("01","03","05","07", "08", "10", "12")){
  p <- Init(start.date = paste("2016",x,"01", sep="-"), end.date = paste("2016",x,"31",sep ="-"),
            dimensions = c("ga:dimension2", "ga:yearMonth"),
            metrics = "ga:users",
            table.id = "ga:99898278",
            sort = "ga:dimension2",
            max.results = 50000)
  
  query <- QueryBuilder(p)
  
  users <- GetReportData(query, oauth_token)
  
  
  monthly_users <- rbind(monthly_users, users)
  
}



#Create dataframe using first month of available data for mobile
m <- Init(start.date = "2016-05-20", end.date = "2016-05-31",
          dimensions = c("ga:dimension2", "ga:yearMonth"),
          metrics = "ga:users",
          table.id = "ga:120621676",
          sort = "ga:dimension2",
          max.results = 50000)

q <- QueryBuilder(m)

users_m <- GetReportData(q, oauth_token)


monthly_users_m <- users_m



#Loop through months with 30 days for mobile
for (z in c("06", "09", "11")){
m <- Init(start.date = paste("2016",z,"01", sep="-"), end.date = paste("2016",z,"30",sep ="-"),
            dimensions = c("ga:dimension2", "ga:yearMonth"),
            metrics = "ga:users",
            table.id = "ga:120621676",
            sort = "ga:dimension2",
            max.results = 50000)
  
query <- QueryBuilder(m)
  
users_m <- GetReportData(query, oauth_token)
  
  
monthly_users_m <- rbind(monthly_users_m, users_m)
  
}


#Loop through months with 31 days for mobile
for (z in c("07", "08", "10", "12")){
  m <- Init(start.date = paste("2016",z,"01", sep="-"), end.date = paste("2016",z,"31",sep ="-"),
            dimensions = c("ga:dimension2", "ga:yearMonth"),
            metrics = "ga:users",
            table.id = "ga:120621676",
            sort = "ga:dimension2",
            max.results = 50000)
  
  query <- QueryBuilder(m)
  
  users_m <- GetReportData(query, oauth_token)
  
  
  monthly_users_m <- rbind(monthly_users_m, users_m)
  
}


#Add origin to dataframes
monthly_users_df$origin <- "AWP"
monthly_users$origin <- "AWP"
monthly_users_m$origin <- "Mobile"

#Combine dataframes
totalmonthlyusers <- rbind(monthly_users, monthly_users_m, monthly_users_df)

names(totalmonthlyusers) <- c("program_pcid","usg_dates","users","origin")

totalmonthlyusers$usg_dates <- as.character(totalmonthlyusers$usg_dates)
totalmonthlyusers$usg_dates <- paste(totalmonthlyusers$usg_dates, "01", sep = "")

library(lubridate)
totalmonthlyusers$usg_dates <- ymd(totalmonthlyusers$usg_dates)
totalmonthlyusers$usg_dates <- as.character(totalmonthlyusers$usg_dates)

totalmonthlyusers <- totalmonthlyusers[,c(2,1,3,4)]

#Write csv file
write.csv(totalmonthlyusers, file = "monthly_users.csv", row.names = FALSE)


