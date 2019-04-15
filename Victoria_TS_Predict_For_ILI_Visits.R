visits <- read.csv("~/Desktop/Columbia/GR5243/Final/Final_git/UncleanedData/flu_view_line(Topright  Chart)_national.csv")
View(visits)

#Converting weekly records to monthly
visits$month<-lubridate::month(as.Date(paste0(visits$YEAR, "-", visits$WEEK, "-", 10), format = "%Y-%U-%u"))
visits$date <- paste(visits$YEAR,visits$month,sep="-")
visits <- as.data.table(visits)

#percentage of visits for ILI, National
ili.percent <- visits[,.(percent = ILITOTAL/TOTAL.PATIENTS)]
ili.percent.ts <- ts(ili.percent[,percent]) #converting to time series
plot(ili.percent.ts)

#Variance isn't nearly constant. Try taking log
log.ili <- log(ili.percent.ts)
plot(log.ili)

#seems much better. Takes difference once 
log.ili.d1 <- diff(log.ili,1)
plot(log.ili.d1)

#acf of data.
acf(log.ili.d1, lag.max = 100, main = "acf of first 100 lags")
acf(log.ili.d1, lag.max = 50, main = "acf of first 50 lags")

#strong seasonality at 52, take difference
log.ili.d2 <- diff(log.ili.d1, 52)
plot(log.ili.d2)
acf(log.ili.d2,lag.max = 300) #seasonal part, tails off
acf(log.ili.d2, lag.max = 52) #non-seasonal part, tails off
pacf(log.ili.d2, lag.max = 400) #seasonal part, cuts off after lag 1s
pacf(log.ili.d2, lag.max = 60) #non-seasonal part, cutss off after lag 1

#try model SARIMA(1,1,0)*(1,0,0)_52
m <- arima(log.ili, order = c(1, 1, 0), seasonal = list(order = c(1, 0, 0), period = 52))
#try other models using auto.arima
m.auto <- auto.arima(ts(ili.percent[,percent], frequency = 52), trace = T)$model
tsdiag(m)
tsdiag(m.auto)
