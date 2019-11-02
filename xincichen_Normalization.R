$ git fetch origin
# Fetches updates made to an online repository
$ git merge origin Master# Merges updates made online with your local work

library(readxl)
library(tidyverse)
library(DBI)
library(RSQLite)

#Read Data
Direct <- read_xlsx("~/Desktop/MA615/Assignments/sql/Top MA Donors 2016-2020.xlsx",sheet = "Direct Contributions & JFC Dist")
JFC <- read_xlsx("~/Desktop/MA615/Assignments/sql/Top MA Donors 2016-2020.xlsx",sheet = "JFC Contributions (DO NOT SUM W")

#Initial Exploration
fam_summary <- Direct %>% group_by(fam) %>% summarize(n=n())
fam_summary

type_summary <- Direct %>% group_by(type) %>% summarize(n=n())
type_summary

recipcode_summary <- Direct %>% group_by(recipcode) %>% summarize(n=n())
recipcode_summary

lastname_summary <- Direct %>% group_by(lastname) %>% summarize(n=n())
dim(lastname_summary)
lastname_summary

#Data clean

Direct %>% mutate(lastname=sapply(Direct$lastname,tolower,simplify = TRUE,USE.NAMES=FALSE))

### Credit to Kerui Cao, clean contribution names

mini = function(x){ 
  
  len = x %>%unique%>% sapply(nchar) 
  
  opt = unique(x) 
  
  mod = head(opt[which(len==min(len))],1) 
  
  return(mod)
  
}

contrib = Direct %>% group_by(contribid,fam)%>% summarise(contrib = mini(contrib))

Direct = Direct %>% select(-"contrib")

Direct = left_join(Direct,contrib,by = c("contribid","fam"))

Direct['contrib'] = gsub(Direct$contrib,pattern = ", ",replacement = ",")

Direct['contrib'] = gsub(Direct$contrib,pattern = "\\s\\w*",replacement = "")


### Credit to Shixin Liang, clean the "Fecoccemp" variable!!!!

# fix "." problem and case-sensitive problem. 

Direct$Fecoccemp <- gsub(Direct$Fecoccemp, pattern = "[:.:]\\s", replacement = "")  

Direct$Fecoccemp <- gsub(Direct$Fecoccemp, pattern = "[:.:]", replacement = "")  

Direct$Fecoccemp <- na.omit(Direct$Fecoccemp)  

Direct$Fecoccemp <- toupper(Direct$Fecoccemp)  

# get a 6-letter occupation/employer names list from Fecoccemp

Fecoccemp_list <- substring(Direct$Fecoccemp, 1, 6) 

Fecoccemp_list <- toupper(Fecoccemp_list)

Fecoccemp_list <- unique(Fecoccemp_list)

Fecoccemp_list <- Fecoccemp_list[-112] # fix blank value

# match with Fecoccemp

for (i in Fecoccemp_list){  
  
  index_Fecoccemp <- grep(i, Direct$Fecoccemp) # get the location of the matched data
  
  replacename_Fecoccemp <- Direct$Fecoccemp[index_Fecoccemp[1]] # get the replace name
  
  for (j in index_Fecoccemp){  
    
    Direct$Fecoccemp[j] <- replacename_Fecoccemp # replace Fecoccemp with the replace name
    
  }  
  
}  

# fix wrongly written characters

Direct$Fecoccemp[Direct$Fecoccemp=="0"] <- NA

Direct$Fecoccemp[Direct$Fecoccemp=="N / A"] <- NA

Direct$Fecoccemp[Direct$Fecoccemp==""] <- NA

Direct$Fecoccemp[Direct$Fecoccemp=="ADSVENTURES"] <- "ADS VENTURES"

Direct$Fecoccemp[Direct$Fecoccemp=="ALERE, INC"] <- "ALERE"

Direct$Fecoccemp[Direct$Fecoccemp=="ALERE INC"] <- "ALERE"

Direct$Fecoccemp[Direct$Fecoccemp=="AT-HOME"] <- "AT HOME"

Direct$Fecoccemp[Direct$Fecoccemp=="BLUE HAVEN INSTITUTE"] <- "BLUE HAVEN INITIATIVE"

Direct$Fecoccemp[Direct$Fecoccemp=="BLUEHAVEN INITIATIVE"] <- "BLUE HAVEN INITIATIVE"

Direct$Fecoccemp[Direct$Fecoccemp=="COMM OF MASS"] <- "COMMONWEALTH OF MASSACHUSETTS"

Direct$Fecoccemp[Direct$Fecoccemp=="E-SCRIPTION"] <- "ESCRIPTION"

Direct$Fecoccemp[Direct$Fecoccemp=="GLOBL PETROLEUM CORP"] <- "GLOBAL PARTNERS LP"

Direct$Fecoccemp[Direct$Fecoccemp=="GLOPAL P CORP"] <- "GLOBAL PARTNERS LP"

Direct$Fecoccemp[Direct$Fecoccemp=="GOBAL PETROLEUM CORP"] <- "GLOBAL PARTNERS LP"

Direct$Fecoccemp[Direct$Fecoccemp=="LUIRADX"] <- "LUMIRADX"

Direct$Fecoccemp[Direct$Fecoccemp=="MCCLEAN HOSPITAL"] <- "MCLEAN HOSPITAL"

Direct$Fecoccemp[Direct$Fecoccemp=="NOT-EMPLOYED"] <- "NOT EMPLOYED"

Direct$Fecoccemp[Direct$Fecoccemp=="PHIANTHROPIST"] <- "PHILANTHROPIST"

Direct$Fecoccemp[Direct$Fecoccemp=="PILOTHOUSE ASSOCIATES"] <- "PILOT HOUSE ASSOCIATES"

Direct$Fecoccemp[Direct$Fecoccemp=="PILOT HOUSE ASSOCIATION"] <- "PILOT HOUSE ASSOCIATES"

Direct$Fecoccemp[Direct$Fecoccemp=="SELF"] <- "SELF EMPLOYED"

Direct$Fecoccemp[Direct$Fecoccemp=="SELF-EMPLOYED"] <- "SELF EMPLOYED"

Direct$Fecoccemp[Direct$Fecoccemp=="SULFFOLK CONSTRUCTION COMPANY"] <- "SUFFOLK CONSTRUCTION CO, INC"

Direct$Fecoccemp[Direct$Fecoccemp=="TAAL  CAPITAL"] <- "TAAL CAPITAL"

Direct$Fecoccemp[Direct$Fecoccemp=="TUTFS UNIVERSITY"] <- "TUFTS UNIVERSITY"

Direct$Fecoccemp[Direct$Fecoccemp=="TUTS UNIVERSITY"] <- "TUFTS UNIVERSITY"

Direct$Fecoccemp[Direct$Fecoccemp=="UNEMPLOYED"] <- "NOT EMPLOYED"

Direct$Fecoccemp[Direct$Fecoccemp==""] <- NA 

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
