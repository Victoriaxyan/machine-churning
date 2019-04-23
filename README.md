# Testing Github

#What are the answers we are trying to find?
We will predict weekly ILINet levels for season 2018-2019 at national and state level. This will help us get answers to the following questions:

1.	Season onset: For 2018 -2019, what would be the first week when ILInet would be above baseline and will remain there for at least two more weeks? We will find the season onset at national level and also the season onset for the states that have been historically most affected by flu?

2.	Peak week: For 2018- 2019, which week had the highest ILINet during the whole season at the national level? Is there a possiblity to have more than one peak week in a given season.

3.	Peak intensity: What is the highest value that ILINet  will reach during the season at national level and for key states?

By marrying these results into our EDA of the CDC data, we will be able to offer some exciting insights. e.g.  New York is going to be affected majorly by flu. The season onset will be week xx and the predicted ILINet for the entire season is xx. We are aware that age group xx gets affected the most in NY. Additionally, our analysis shows that virus xx affects NY the most. Precautionary measures should be taken accordingly.

Some interesting visualizations:
-Comparing season onsets and peak intensities state wise


#Some thoughts for the visualization
- Part 1: look at the time plot of the weekly total reported ILI from 2010-2018

- Part 2:
  - 1. Focus on those years with high total ILI, and show percentage of total reported ILI to total         population by HHS Region/State (in shiny, we can change year + flu type)
  - 2. For the region that was hit the most, break down by age group



- Part 3:
  -1. 2018's vaccine was only 36% effective against influenza A and B, and 25% effective against the       most common strain, H3N2.
  -2.  Look at 2018 data by state/HHS region and identify those regions that were most influenced by       A/B/H3N2.






# Checkpoint 2

## Data Files of Git collaborations

- Uncleaned and Cleaned Data

## Topic
How can we predict the intensity of the 2018-2019 flu season given data from previous flu seasons?

## Links
https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html

This is the CDC’s Flu Portal Dashboard. It provides data and visualizations of flu incidence in the USA.

https://www.cdc.gov/flu/fluvaxview/reportshtml/trends/index.html

This link, also from the CDC, provides data on the amount of people in America who received the flu vaccine each year.

https://www.cdc.gov/flu/about/burden/index.html?CDC_AA_refVal=https%3A%2F%2Fwww.cdc.gov%2Fflu%2Fabout%2Fdisease%2Fburden.htm

This link provides data on the number of flu deaths each year.

## Description 

The CDC provides data on influenza in the United States from 1997 to 2018 (we are using 2010 to 2018 for our project due to missing data prior to 2010). The flu incidence data is broken down by HHS Region, Census Division, and State, and by either public health or clinical laboratory. It includes variables such as the weekly total number of specimens tested, the number of positive influenza tests, and the percent positive by influenza virus type. The flu vaccination data provides information on the % of people vaccinated for each state and nationwide during each month of flu season, and has subgroup data as well such as the % vaccinated for children and adults. Finally the number of flu deaths is just the number of people nationwide who have died of flu from 2010 to 2018, although the CDC notes that these numbers tend to be underestimates.

## Overview

### Part I: Shiny interactive data visualization:

We want to first look at the total flu cases over the past 10 years using a time series plot and identify unusual patterns. For example, the 2018 flu season was the worst since the 2009 swine flu pandemic, and roughly 7.7% of all U.S. citizens seeking medical care experienced flu-like symptoms. 

Then the question becomes--is there a way to figure out who was most at risk for contracting a specific type of virus? We plan to break down the outbreak across different states and try to explore the distributions of various flu cases among different age groups. We will try to build interactive plots such as maps, area plots, and bar graphs.

### Part II: Predict the intensity of the 2018-2019 flu season given data from previous flu seasons: 

After we gain some basic knowledge of the data, we think it’s necessary to predict the intensity of the 2018-19 flu season. We plan to build time series forecasting models that use data for the past 10 years (such as number of people with type A flu) in order to predict number of people who will catch a specific type of flu in the 2018-19 season for each age group by state/region. 

One way to come up with a reasonable dataset is that we try to use number of people who have type X flu from 2010-2017 as predictors, and the same variable for 2018 as response. For example, some potential predictors would be : # of people (age 18-64) who have type A, B, or C flu from 2010-2017 or the % of people (age 18-64) who were vaccinated from 2010-2017. Then, the response would be: # of people (age 18-64) who have type A flu in 2018. The reason for doing this is that we believe for the same state, values of one variable in the past may contribute to that same variable in the future.

The goal of our modeling strategy is to build a variety of different time series forecasting models and select the best one. We will develop some stochastic models such as autoregressive (AR), moving average (MA), and autoregressive-moving average (ARIMA) in order to forecast seasonal influenza in the USA. Then we will use AIC to select the best parameter configuration of the models, use that model to forecast the 2018-2019 flu season, and compare our predictions to the actual results.

## Summary of Progress

We have already finished the data collecting, and moving on to data cleaning parts. The data we have downloaded includes three sets:
- Influenza Positive Tests Reported to CDC by Public Health Laboratories and ILI( influenza-like illness) Activity, from year 2010 to 2019;
- Percentage of visits for ILI, from year 2010 to 2019;
- Total number of people vaccinated, from year 2010 to 2019.

We have done some preliminary data cleaning, such as merging yearly datasets of the percentage of influenza visits nationwide into one large dataset. We have also done some exploratory research on prior time series models, in particular for influenza to see if there are some best practices and underexplored avenues of research that we can pursue. 

# Checkpoint 3

## Topic

How can we predict the intensity of the 2018-2019 flu season given data from previous flu seasons?

## Link to Data

https://github.com/Victoriaxyan/machine-churning/tree/master/UncleanedData

## Current State of the Project

We have cleaned our data already, converting the weekly records into monthly, for two types of illness - H1N1 and H3. Accordingly, we created SARIMA time series models for nation-wide positive tests of H1N1 and H3, from 2010 to 2018. Based on the models we created, we made predictions of positive tests of these illnesses from 2018 to 2019. We are moving on to creating machine learning models to make more precise predictions.

## Overview of Models

The model we have already built is a SARIMA model. We divided our data into a training set (Jan 2010 - Dec 2017) and a validation set (Jan 2018 - Dec 2018). We differenced the training data once, make the seasonality to be 12 (12 months in a year), chose the parameters of Auto Regressive and Moving Average parts according to AICC criteria. The final model we used for H1N1 data is SARIMA(1,0,1)x(0,1,1)_12.
The variable for our model is simply the time variable: our goal is to see how the influence of illnesses changes over time. Core codes can be found in this link: https://github.com/Victoriaxyan/machine-churning/blob/master/Final-Project.R

## Plans for improving the project
- What machine learning models can be used to predict the illnesses? We want more accurate results.
- How to design our Rshiny for representing our analysis?
- Can we explore more on the relationship between vaccines and illnesses?
