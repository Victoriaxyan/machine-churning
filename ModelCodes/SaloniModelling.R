# library
library(forecast)
library(data.table)
library(DT)


visits <- read.csv("../UncleanedData/flu_view_line(Topright  Chart)_national.csv")

######################
####Data Cleaning#####
######################

#----Converting weekly records into monthly------
visits$month<-lubridate::month(as.Date(paste0(visits$YEAR, "-", visits$WEEK, "-", 10), 
                                       format = "%Y-%U-%u"))
visits$date <- paste(visits$YEAR,visits$month,sep="-")
visits <- as.data.table(visits)
head(visits)

#-----preparing data for modeling------

#Part 1 (time series data): percentage of visits for ILI, National
ili.percent <- visits[,.(percent = ILITOTAL/TOTAL.PATIENTS)]

#Part 2 (age group data): ILI visits according to age group
age.groups <- names(visits)[c(4:6,8:9)]
ili.age <- visits[,c(2:6,8:9,15:16)]
head(ili.age)

#################################
####Exploratory Data Analysis####
#################################

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# time series model for percentage of total ILI visits, weekly
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ts.ili.percent <- ts(ili.percent, frequency = 52)

#fitting a model using auto.arima
m.auto <- auto.arima(ts.ili.percent)
m.auto #best model: (2,0,1)(0,1,1)[52]
arma <- m.auto$arma #subtracts the orders of SARIMA model

#forecast
m <- arima(ts.ili.percent, order = c(arma[1], arma[6], arma[2]), 
           seasonal = list(order = c(arma[3], arma[7], arma[4]), period = 52)) 
predictions <- predict(m, n.ahead = 52)$pred

par(mfrow = c(2,1))
plot(1:(length(ts.ili.percent) + length(predictions)), 
     c(ts.ili.percent, predictions), type = 'l', col = 1, 
     xlab = "week number", ylab = "ILI visits percentage",
     main = "predictions of ILI visits percentage")
points((length(ts.ili.percent) + 1) : (length(ts.ili.percent) + length(predictions)), 
       predictions, type = 'l', col = 2)

plot(1:length(predictions), 
     predictions, type = 'l', col = 2, 
     xlab = "week number starting from 13th week, 2019", 
     ylab = "ILI visits percentage",
     main = "predictions of ILI visits percentage")

# > Conclusion: Strong Seasonality in ILI. Percentage of patients visiting the hospital for ILI may drop from now through summer, and getting back in the fall.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ILI visits: Distribution by Age Groups
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



