library(shiny)
library(shinydashboard)
library(DBI)
library(RSQLite)
library(titanic)
library(dplyr)
library(DT)
library(ggplot2)

con <- dbConnect(SQLite(), dbname = "/tmp_shared/titanic.sqlite")

titanic <- tbl(con, "titanic")
scoring <- tbl(con, "scoring")

all <- titanic %>%
  inner_join(scoring, by = "PassengerId") %>%
  select(
    -PassengerId,
    -Cabin
  ) %>%
  collect() %>%
  mutate(
    fit_label   = paste0(round(fit   * 100), "%"),
    lower_label = paste0(round(lower * 100), "%"),
    upper_label = paste0(round(upper * 100), "%")
  ) 


ui <- dashboardPage(
  dashboardHeader(
    title = "Titanic Survivors"
  ),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tabsetPanel(id = "tabs",
        tabPanel(
          title = "Main",
          fluidRow(
            valueBoxOutput("passengers"),
            valueBoxOutput("survivors")
            ),
          fluidRow(
            column(width = 5, plotOutput("gender")),
            column(width = 5, plotOutput("class"))),
          fluidRow(
            column(width = 10, plotOutput("age"))
          )
  
          
        ),
        tabPanel(
          title = "Data",
          dataTableOutput("data")
        )
      
    )
   
  )
)

server <- function(input, output) {
  
  
  output$data <- renderDataTable({
    datatable(
      all %>%
        select(
          -fit_label,
          -lower_label,
          -upper_label
        )
      )
  })

  output$passengers <- renderValueBox({
    valueBox(
      value = nrow(all),
      subtitle = "Passengers",
      color = "blue",
      icon = icon("ship")
    )
  })
  
  output$survivors <- renderValueBox({
    valueBox(
      value = nrow(filter(all, survived == "Yes")),
      subtitle = "Predict will survive",
      color = "green",
      icon = icon("user")
    )
  })
  
  output$gender <- renderPlot({
    all %>%
      mutate(survived = ifelse(survived == "Yes", 1, 0)) %>%
      group_by(Sex) %>%
      summarise(
        actual = sum(survived),
        survived = sum(survived) / n(),
        total = n()) %>%
      ggplot() +
      geom_col(aes(x = Sex, y = survived, fill = Sex)) +
      geom_text(aes(x = Sex, y = 0.5, label = paste0(round(survived   * 100, 2), "%\n", actual ," of ", total))) +
      labs(title = "Predicted Survival by Gender", 
           x = "", 
           y = "Survived %") +
      scale_y_continuous(breaks = c(0, 0.2, 0.75), labels = c("0%", "20%", "75%")) +
      theme(legend.position = "none")
  })
  
  output$class <- renderPlot({
    all %>%
      mutate(survived = ifelse(survived == "Yes", 1, 0)) %>%
      group_by(Pclass) %>%
      summarise(
        actual = sum(survived),
        survived = sum(survived) / n(),
        total = n()) %>%
      ggplot() +
      geom_col(aes(x = Pclass, y = survived, fill = as.factor(Pclass))) +
      geom_text(aes(x = Pclass, y = 0.2, label = paste0(round(survived   * 100, 2), "%\n", actual ," of ", total))) +
      labs(title = "Predicted Survival by Cabin Class", 
           x = "", 
           y = "Survived %") +
      scale_y_continuous(breaks = c(0, 0.2, 0.50), labels = c("0%", "20%", "50%")) +
      scale_x_continuous(breaks = c(1,2,3), labels = c("First", "Second", "Third")) +
      theme(legend.position = "none")
  })
  
  
  output$age <- renderPlot({
    all %>%
      mutate(survived = ifelse(survived == "Yes", 1, 0),
             age_bin = cut(Age, breaks = c(0, 5,  40,  80))) %>%
      group_by(age_bin) %>%
      summarise(
        actual = sum(survived),
        survived = sum(survived) / n(),
        total = n()) %>%
      ggplot() +
      geom_col(aes(x = age_bin, y = survived, fill = as.factor(age_bin))) +
      geom_text(aes(x = age_bin, y = 0.2, label = paste0(round(survived   * 100, 2), "%\n", actual ," of ", total))) +
      labs(title = "Predicted Survival by Age Range", 
           x = "", 
           y = "Survived %") +
      scale_y_continuous(breaks = c(0, 0.3, 0.6), labels = c("0%", "30%", "60%")) +
      theme(legend.position = "none")
  })
  

}

shinyApp(ui, server)