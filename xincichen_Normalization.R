library(readxl)
library(tidyverse)
library(DBI)
library(RSQLite)

Direct <- read_xlsx("~/Desktop/MA615/Assignments/sql/Top MA Donors 2016-2020.xlsx",sheet = "Direct Contributions & JFC Dist")
JFC <- read_xlsx("~/Desktop/MA615/Assignments/sql/Top MA Donors 2016-2020.xlsx",sheet = "JFC Contributions (DO NOT SUM W")

#Normalization
primary_key <- select(Direct,fectransid,contribid,Zip,Fecoccemp,date,amount,recipid)

Contribute_Info_1 <-select(Direct,contribid,fam,contrib,lastname)

Contribute_Info_2 <-select(Direct,contribid,type)

Address_Info <- select(Direct,Zip,City,State)

Company_Info <- select(Direct,Fecoccemp,orgname,ultorg)

Time_Info <- select(Direct,date,cycle)

Recipient_Info <- select(Direct,recipid,recipient,party,recipcode,cmteid)


#Generate Database
XC <- dbConnect(SQLite(), "xincichen_database.sqlite",header=TRUE, overwrite=TRUE)
dbWriteTable(XC, "primary_key ", primary_key,header=TRUE, overwrite=TRUE)
dbWriteTable(XC, "Contribute_Info_1 ", Contribute_Info_1,header=TRUE, overwrite=TRUE)
dbWriteTable(XC, "Contribute_Info_2 ", Contribute_Info_2,header=TRUE, overwrite=TRUE)
dbWriteTable(XC, "Address_Info ", Address_Info,header=TRUE, overwrite=TRUE)
dbWriteTable(XC, "Company_Info  ", Company_Info,header=TRUE, overwrite=TRUE)
dbWriteTable(XC, "Time_Info", Time_Info,header=TRUE, overwrite=TRUE)
dbWriteTable(XC, "Recipient_Info", Recipient_Info,header=TRUE, overwrite=TRUE)
dbListTables(XC)


