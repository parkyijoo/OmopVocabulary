## Set .Renviron to hide important information
#install.packages("usethis")
#usethis::edit_r_environ()

## Install required packages ##
# install.packages("rlang")
# install.packages("dplyr") 
# install.packages("openxlsx") 
# install.packages("readr")
library(rlang)
library(dplyr)
library(openxlsx)
library(readr)
library(tidyverse)

dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data/drug")

# 언어 삭제/변경(인코딩 오류)
Sys.setlocale("LC_ALL", "C") 
Sys.setlocale("LC_ALL", "Korean.utf8")

DRUG <- read.csv(
  file = file.path(dataFolder, "SourceToConceptMap_drug2022.11.16.csv"),
  header = TRUE, sep = ",", fileEncoding = "euc-kr")

# seperate data to complete/incomplete data
CompleteData <- DRUG  
IncompleteData <- DRUG

CompleteData %>% str_detect(CompleteData$target_vocabulary_id, "RX")
## Complete ##
CompleteData$target_vocabulary_id = ifelse(str_detect(CompleteData$target_vocabulary_id, "Rx")|str_detect(CompleteData$target_vocabulary_id, "SNOMED"),
       CompleteData$target_vocabulary_id,
       NA
)

CompleteData <- na.omit(CompleteData)

# invalid_reason NA
CompleteData$invalid_reason <- "U"

# valid_start_date 작성
CompleteData$valid_start_date <- "2022-10-20"

# valid_end_date 작성
CompleteData$valid_end_date <- NA


## Incomplete ##
IncompleteData$target_vocabulary_id = ifelse(
  str_detect(IncompleteData$target_vocabulary_id, "Rx")|str_detect(IncompleteData$target_vocabulary_id, "SNOMED"),
  NA,
  IncompleteData$target_vocabulary_id
)

IncompleteData <- na.omit(IncompleteData)

write.csv(JOIN,file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/drug/CompleteMapping_drug2022.11.16.csv", fileEncoding = "euc-kr", na = "")
write.csv(JOIN,file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/drug/IncompleteMapping_drug2022.11.16.csv", fileEncoding = "euc-kr", na = "")


