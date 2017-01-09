##Initialize Pkg
library(RGoogleAnalytics)
setwd("C:/Users/austin.mcculloch/Documents/R_Projects")
load("./token_file")
ValidateToken(oauth_token)

#create initial dataframe for february - AWP
p <- Init(start.date = "2016-02-01", end.date = "2016-02-28",
          dimensions = c("ga:dimension2", "ga:yearMonth"),
          metrics = "ga:users",
          table.id = "ga:99898278",
          sort = "ga:dimension2",
          max.results = 50000)

query <- QueryBuilder(p)

users <- GetReportData(query, oauth_token)


monthly_users <- users


#Loop through all the other months and create master dataframe - AWP
for (x in c("01","03","04","05","06","07","08","09","10","11","12")){
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

#Create dataframe using first month of available data for mobile
m <- Init(start.date = "2016-05-20", end.date = "2016-05-30",
          dimensions = c("ga:dimension2", "ga:yearMonth"),
          metrics = "ga:users",
          table.id = "ga:120621676",
          sort = "ga:dimension2",
          max.results = 50000)

q <- QueryBuilder(m)

users_m <- GetReportData(q, oauth_token)


monthly_users_m <- users_m



#Loop through months for mobile
for (z in c("06","07","08","09","10","11","12")){
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

#Add origin to dataframes
monthly_users$origin <- "AWP"
monthly_users_m$origin <- "Mobile"

#Combine dataframes
totalmonthlyusers <- rbind(monthly_users, monthly_users_m)

names(totalmonthlyusers) <- c("program_pcid","month","users","origin")

#Write csv file
write.csv(totalmonthlyusers, file = "monthly_users.csv")


