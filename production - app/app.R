library(shiny)
library(shinydashboard)

model <- readRDS("model.rds")

ui <- dashboardPage(
  dashboardHeader(
    title = "Titanic Survivors"
  ),
  dashboardSidebar(
    radioButtons(
      inputId = "sex",
      label = "Gender:",
      choices = c("Male", "Female")
    ),
    radioButtons(
      inputId = "five",
      label = "Under 5 years old:",
      choices = c("Yes", "No")
    ),
    radioButtons(
      inputId = "class",
      label = "Cabin class:",
      choices = c("First", "Second", "Third")
    )
  ),
  dashboardBody(
    valueBoxOutput("lwr"),
    valueBoxOutput("fit"),
    valueBoxOutput("upr"),
    valueBoxOutput("survive")
  )
)

server <- function(input, output) {
  
score <- reactive({
  df <- data.frame(
    is_five = tolower(input$five),
    pclass = tolower(input$class),
    sex = tolower(input$sex),
    stringsAsFactors = FALSE
  )
  
  pred <- predict(model, df, se.fit = TRUE)
  
  interval <- 1.96 * pred$se.fit
  
  upr <- pred$fit + interval
  lwr <- pred$fit - interval
  fit <- pred$fit
  
  data.frame(
    upr,
    lwr,
    fit
  )
}
)  

output$fit <- renderValueBox({
  valueBox(
    value = paste0(round(score()$fit * 100, 2), "%"),
    subtitle = "Fitted",
    color = "blue"
  )
})

output$lwr <- renderValueBox({
  valueBox(
    value = paste0(round(score()$lwr * 100, 2), "%"),
    subtitle = "Lower",
    color = "yellow"
  )
})
  
output$upr <- renderValueBox({
  valueBox(
    value = paste0(round(score()$upr * 100, 2), "%"),
    subtitle = "Lower",
    color = "purple"
  )
})

output$survive <- renderValueBox({
  
  s <- "Yes"
  
  if(score()$upr < 0.5)s <- "No"
  
  valueBox(
    value = s,
    subtitle = "Will Survive",
    color = ifelse(s == "Yes", "green", "red")
  )
})

}

shinyApp(ui, server)