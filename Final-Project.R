library(lubridate)
library(epitools)
library(dplyr)
library(lubridate)
library(ggplot2)
library(forecast)
library(WeightedPortTest)
library(shinythemes)

#combined
combined$month<-lubridate::month(as.Date(paste0(combined$YEAR, "-", combined$WEEK, "-", 10), format = "%Y-%U-%u"))
combined<-combined[,-2]

#ili
ili2<-ILINet[641:1121,]
ili2$month<-lubridate::month(as.Date(paste0(ili2$YEAR, "-", ili2$WEEK, "-", 10), format = "%Y-%U-%u"))


#
fluview<-flu_view_line_Topright_Chart_national
fluview$month<-lubridate::month(as.Date(paste0(fluview$YEAR, "-", fluview$WEEK, "-", 10), format = "%Y-%U-%u"))

# time series model for national-H1N1 only
#1. create the date variable:
combined$date<-paste(combined$YEAR,combined$month,1,sep="-")
combined$date<-as.Date(combined$date,"%Y-%m-%d")
str(combined)

#
aggts<-ts(combined$`A (2009 H1N1)`,start=c(2010,1),freq=12)
plot(aggts, type='o', pch=20)
aggts.log<-log(aggts+1)
aggts.sqrt<-sqrt(aggts)

par(mfrow=c(1,1))

##probably do the log transformation?
plot(diff(aggts.log), type='l', pch=20, cex=.15)

par(mfrow=c(1,2))
acf(diff(diff(aggts.log),lag=12),na.action = na.pass)
pacf(diff(diff(aggts.log),lag=12),na.action = na.pass)

###use Jan-Dec 2018 as test set, anytime before that as training set...
agg.train <- window(aggts.log, start=c(2010,1),end=c(2017,12),freq=12)   
agg.test <- window(aggts.log, start=c(2018,1), end=c(2018,12),freq=12)



#1.deterministic model
TIME <- 1:length(agg.train)
SIN <- COS <- matrix(nrow=length(agg.train), ncol=6, 0)
SEASONS <- cycle(agg.train)
for(i in 1:6) {
  COS[,i] <- cos(2*pi*i*TIME/12)
  SIN[,i] <- sin(2*pi*i*TIME/12)
}
SIN <- SIN[,-6]
lm <- lm(agg.train ~ TIME + COS + SIN )
summary(lm)

#1) keep TIME
lm <- lm(agg.train ~ TIME)
summary(lm)
par(mfrow=c(1,2))
acf(lm$residuals, lwd=2, na.action=na.pass)  ##kind of cuts off after lag 1
pacf(lm$residuals, lwd=2, na.action=na.pass) ##also kind of cuts off after lag 1
plot(lm$residuals, type='l', main="Residuals in Time Plot", pch=20)



####fit MA1 /AR1 to the residuals
ma1.1 <- Arima(lm$residuals, order=c(0,0,1), include.mean=FALSE)
ma1.1 #AAIC=328.72   AICc=328.85   BIC=333.84
ar1.1 <- Arima(lm$residuals, order=c(1,0,0), include.mean=FALSE) 
ar1.1 #AIC=187.45   AICc=187.57   BIC=192.57




#####Now fit everything
XREG1 <- cbind(TIME) ###keep TIME

fit1<- Arima(agg.train, order=c(1,0,0),xreg=XREG1)
summary(fit1) #AIC=207.8   AICc=208.24   BIC=218.05
acf(fit1$residuals, na.action=na.pass)  
pacf(fit1$residuals, na.action=na.pass)

#maybe no
fit2<-Arima(agg.train, order=c(0,0,1), xreg=XREG1)
summary(fit2) #AIC=337.44   AICc=337.88   BIC=347.7
acf(fit2$residuals, na.action=na.pass)  
pacf(fit2$residuals, na.action=na.pass)


##based on AIC/BIC, probably model with TIME+AR1 is better?
#check the weighted box test for all of them
Weighted.Box.test(fit1$residuals, lag=20, type="Ljung")


####Now, use the SARIMA method########################v########
#1. need differencing?
plot(agg.train)
plot(diff(agg.train), type="l", pch=20)

#fit seasonal ARIMA
#1)AIC=201.87   AICc=202.38     BIC=211.6
fit3<- Arima(agg.train, order=c(1,0,1),seasonal=list(order=c(0,1,1), period=12), include.mean=FALSE)
fit3
par(mfrow=c(1,2))
acf(fit3$residuals,na.action = na.pass)
pacf(fit3$residuals,na.action = na.pass)

#2)SARIMA(1,1,1)x(1,0,1)12 == fit4
#AIC=199.57   AICc=200.24     BIC=212.33
fit4<- Arima(agg.train, order=c(1,1,1),seasonal=list(order=c(1,0,1), period=12), include.mean=FALSE)
fit4
acf(fit4$residuals,na.action = na.pass)
pacf(fit4$residuals,na.action = na.pass)

#3) SARIMA(1,1,1)x(0,1,1)12 == fit3
#AIC=195.77   AICc=196.28     BIC=205.45
fit5<- Arima(agg.train, order=c(1,1,1),seasonal=list(order=c(0,1,1), period=12), include.mean=FALSE)
fit5
acf(fit5$residuals,na.action = na.pass)
pacf(fit5$residuals,na.action = na.pass)

#4) SARIMA(1,1,0)x(0,1,1)12 == fit3
#AIC=196.58   AICc=196.89   BIC=203.84
fit6<- Arima(agg.train, order=c(1,1,0),seasonal=list(order=c(0,1,1), period=12), include.mean=FALSE)
fit6
acf(fit6$residuals,na.action = na.pass)
pacf(fit6$residuals,na.action = na.pass)



#now do the forecast
fit1.forecast<-forecast(fit1, h=10)
fit3.forecast<-forecast(fit3, h=10)
fit4.forecast<-forecast(fit4, h=10)
fit5.forecast<-forecast(fit5, h=10)
fit6.forecast<-forecast(fit6, h=10)



mspe.table <- rbind(mean((fit3.forecast$mean-agg.test)^2),
                    mean((fit4.forecast$mean-agg.test)^2),
                    mean((fit5.forecast$mean-agg.test)^2),
                    mean((fit6.forecast$mean-agg.test)^2))

colnames(mspe.table) <- "MSPE"
rownames(mspe.table) <- c("SARIMA(1,0,1)x(0,1,1)12",
                          "SARIMA(1,1,1)x(1,0,1)12",
                          "SARIMA(1,1,1)x(0,1,1)12",
                          "SARIMA(1,1,0)x(0,1,1)12")
mspe.table
#use SARIMA(1,0,1)x(0,1,1)12??

###just use the mean for all monthly precp to predict!
agg.data<-combined[,c(6,13)]
colnames(agg.data)[1]<-"monthlyH1N1"

agg.data.predict<- agg.data %>%
  group_by(month) %>%
  summarise(agg.predict=mean(monthlyH1N1,na.rm=T))
##########3


par(mfrow=c(1,1))
plot(NULL, xlim=c(2018,2019),ylim=c(0,10), bty="n", xaxt="n", yaxt="n",
     xlab="Time", ylab="Monthly Precipitation", main="Forecasts")
axis(1, seq(2010, 2025, 1))
axis(2, seq(0.00,8.00,0.5))
lines(aggts, col="gray20", lwd=1)
lines(ts1,col="orange",lwd=2,lty=1)
lines(fit1.forecast$mean^2, col="blue", lwd=2,lty=3)
lines(fit2.forecast$mean^2, col="red", lwd=2,lty=4)
lines(fit3.forecast$mean^2, col="cyan", lwd=2,lty=1)
lines(fit4.forecast$mean^2, col="green4", lwd=2,lty=1)
lines(fit5.forecast$mean^2, col="purple", lwd=2,lty=3)
lines(fit6.forecast$mean^2, col="yellow", lwd=2,lty=5)
lines(hw.forecast1$mean^2, col="brown", lwd=2,lty=1)
lines(hw.forecast2$mean^2, col="lightblue", lwd=2,lty=1)






















##########Now the machine learning part!!!!!!
#get the data







