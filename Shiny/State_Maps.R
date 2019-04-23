library(flexdashboard)
library(rmarkdown)
library(knitr)
library(Hmisc)
library(DT)
library(shiny)
library(shinythemes)      # Bootswatch color themes for shiny
library(choroplethr)      # Creating Choropleth Maps in R
library(choroplethrMaps)  # Maps used by the choroplethr package
library(dplyr)
library(data.table)
library(rsconnect)


dat <- read.csv(url("https://raw.githubusercontent.com/Victoriaxyan/machine-churning/master/Data/State_Data/ILINet.csv"))
dat$month<-lubridate::month(as.Date(paste0(dat$YEAR, "-", dat$WEEK, "-", 10), 
                                    format = "%Y-%U-%u"))
dat$date <- paste0(dat$YEAR, "-", dat$month, "-01")		
dat$date <- as.Date(dat$date, "%Y-%m-%d")
dat <- as.data.table(dat)
dat$ILITOTAL <- as.numeric(dat$ILITOTAL)
dat$'TOTAL.PATIENTS' <- as.numeric(dat$'TOTAL.PATIENTS')

data <- dat %>% 
  group_by(REGION, YEAR) %>%                           
  summarise_at(c("ILITOTAL", "TOTAL.PATIENTS"), sum, na.rm = TRUE)

data$ili.percent <- data$ILITOTAL / data$TOTAL.PATIENTS
data$region <- data$REGION
data$region <- sapply(data$region, tolower)
data$REGION <- NULL
data$YEAR <- as.integer(data$YEAR)
data <- as.data.frame(data)

ui <- fluidPage(title = 'My First App!',
                theme = shinythemes::shinytheme('flatly'),
                
                sidebarLayout(
                  sidebarPanel(width = 3,
                               sliderInput("years",
                                           "Choose a year:",
                                           min = 2010,
                                           max = 2019,
                                           value = 1,
                                           sep = ""),
                               selectInput("select", 
                                           label = "Select Variable:", 
                                           choices = colnames(data)[2:4], 
                                           selected = 1)),
                  
                  mainPanel(width = 9, 
                            tabsetPanel( 
                              tabPanel(title = 'Output Map', 
                                       plotOutput(outputId = "map")),
                              tabPanel(title = 'Data Table', 
                                       dataTableOutput(outputId = 'table'))))))

server <- function(input, output) {
  
  
  
  output$map <- renderPlot({
    data_20 <- data[data$YEAR == input$years,]
    data_20$value <- data_20[, input$select]
    state_choropleth(data_20,
                     title = input$select,
                     num_colors    = 7)
  })
  
  output$table <- renderDataTable({
    data_20 <- data[data$YEAR == input$years,]
    data_20$value <- data_20[, input$select]
    data_20[order(data_20[input$select]), ]
  })
}

shinyApp(ui = ui, server = server)