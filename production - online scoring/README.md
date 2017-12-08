Production - Online Scoring
===============================

<img src="/zzz-images/plummer-female.png" width = 150, height = 150, align = "right" />

## Project

- Online scoring allows downstream applications, specially those that do not run R, to benefit from the insights gained during analysis
- The `plumber` package can be used to create an API using R
- The code for this project should follow more stringent patterns of development-testing-production 

## Execution

The *Plumber.R* script contains the API that reads in the model, and uses it to return the lower, fit and upper values.  To try it out, switch the working directory to this folder and run the following: 

```r
p <- plumber::plumb('plumber.R')$run(port = 8000)
```

THE REST API can be published in RStudio Connect:

- http://colorado.rstudio.com:3939/content/810/survive?sex=female&pclass=second&is_five=no

- http://colorado.rstudio.com:3939/content/810/__swagger__/

To publish to RStudio Connect, use the following:

```r
rsconnect::deployAPI(".", server = '[Server URL w/o the port numer]', account = rstudioapi::askForPassword("Enter Connect Username:"))
```