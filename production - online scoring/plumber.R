
model <- readRDS("model.rds")


#* @get /survive
#* @param is_five Values: yes, no,
#* @param pclass Values: first, second, third
#* @param sex Values: male, female
survive_model <- function(
  is_five = NULL,
  pclass = NULL,
  sex = NULL
){
  
  df <- data.frame(
    is_five,
    pclass,
    sex,
    stringsAsFactors = FALSE
  )
  
  pred <- predict(model, df, se.fit = TRUE)
  
  interval <- 1.96 * pred$se.fit
  
  upr <- pred$fit + interval
  lwr <- pred$fit - interval
  fit <- pred$fit
  
  list(
    fit = fit,
    upper = upr,
    lower = lwr
  )
}


# rsconnect::deployAPI(".", server = 'colorado.rstudio.com', account = rstudioapi::askForPassword("Enter Connect Username:"))
