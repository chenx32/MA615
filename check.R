courses <- read.csv("~/Desktop/MA615/class26/courses.csv",header = TRUE,stringsAsFactors = FALSE)

enrollment <- read.csv("~/Desktop/MA615/class26/enrollment.csv",header = TRUE,stringsAsFactors = FALSE) 

persons <- read.csv("~/Desktop/MA615/class26/persons.csv",header = TRUE,stringsAsFactors = FALSE) 

sessions <- read.csv("~/Desktop/MA615/class26/sessions.csv",header = TRUE,stringsAsFactors = FALSE) 

library(odbc)
library(DBI)

con <- dbConnect(odbc(),"MS",UID="Lee",PWD="0123@Lee")