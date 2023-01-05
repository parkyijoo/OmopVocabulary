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
library(stringr)

dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data/device")

# 언어 삭제/변경(인코딩 오류)
Sys.setlocale("LC_ALL", "C") 
Sys.setlocale("LC_ALL", "Korean.utf8")

device <- read.csv(file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/device/SourceToConceptMap_device2022.11.17.csv", sep = ",", fileEncoding = "euc-kr")

# seperate data to complete/incomplete data
CompleteData <- device
IncompleteData <- device

## Complete ##
CompleteData$target_vocabulary_id = ifelse(str_detect(CompleteData$target_vocabulary_id, "SNOMED"),
                                           CompleteData$target_vocabulary_id,
                                           NA
)

CompleteData$invalid_reason <-  0
CompleteData$source_code <-  ifelse(is.na(CompleteData$source_code), 0, CompleteData$source_code)
CompleteData$source_concept_id <-  ifelse(is.na(CompleteData$source_concept_id), 0, CompleteData$source_concept_id)
CompleteData$source_domain_id <-  ifelse(is.na(CompleteData$source_domain_id), 0, CompleteData$source_domain_id)
CompleteData$source_vocabulary_id <-  ifelse(is.na(CompleteData$source_vocabulary_id), 0, CompleteData$source_vocabulary_id)
CompleteData$source_concept_class_id <-  ifelse(is.na(CompleteData$source_concept_class_id), 0, CompleteData$source_concept_class_id)
CompleteData$source_concept_synonym <-  ifelse(is.na(CompleteData$source_concept_synonym), 0, CompleteData$source_concept_synonym)
CompleteData$source_code_description <-  ifelse(is.na(CompleteData$source_code_description), 0, CompleteData$source_code_description)
CompleteData$target_code_description <-  ifelse(is.na(CompleteData$target_code_description), 0, CompleteData$target_code_description)
CompleteData$target_concept_id <-  ifelse(is.na(CompleteData$target_concept_id), 0, CompleteData$target_concept_id)
CompleteData$target_domain_id <-  ifelse(is.na(CompleteData$target_domain_id), 0, CompleteData$target_domain_id)
CompleteData$target_concept_class_id <-  ifelse(is.na(CompleteData$target_concept_class_id), 0, CompleteData$target_concept_class_id)
CompleteData$valid_end_date <-  ifelse(is.na(CompleteData$valid_end_date), 0, CompleteData$valid_end_date)




CompleteData <- na.omit(CompleteData)

# invalid_reason NA
CompleteData$invalid_reason <- "U"

# valid_start_date 작성
CompleteData$valid_start_date <- "2022-10-20"

# valid_end_date 작성
CompleteData$valid_end_date <- NA

write.csv(CompleteData,file = file.path(dataFolder, "CompleteMapping_device2022.11.17.csv"),
          na = "", fileEncoding = "euc-kr")

## Incomplete ##
IncompleteData$target_vocabulary_id = ifelse(is.na(IncompleteData$target_vocabulary_id),
                                             0,
                                             IncompleteData$target_vocabulary_id)
IncompleteData$target_vocabulary_id = ifelse(str_detect(IncompleteData$target_vocabulary_id, "SNOMED"),
                                             NA,
                                             IncompleteData$target_vocabulary_id
)
IncompleteData$invalid_reason <-  0
IncompleteData$source_code <-  ifelse(is.na(IncompleteData$source_code), 0, IncompleteData$source_code)
IncompleteData$source_concept_id <-  ifelse(is.na(IncompleteData$source_concept_id), 0, IncompleteData$source_concept_id)
IncompleteData$source_domain_id <-  ifelse(is.na(IncompleteData$source_domain_id), 0, IncompleteData$source_domain_id)
IncompleteData$source_vocabulary_id <-  ifelse(is.na(IncompleteData$source_vocabulary_id), 0, IncompleteData$source_vocabulary_id)
IncompleteData$source_concept_class_id <-  ifelse(is.na(IncompleteData$source_concept_class_id), 0, IncompleteData$source_concept_class_id)
IncompleteData$source_concept_synonym <-  ifelse(is.na(IncompleteData$source_concept_synonym), 0, IncompleteData$source_concept_synonym)
IncompleteData$source_code_description <-  ifelse(is.na(IncompleteData$source_code_description), 0, IncompleteData$source_code_description)
IncompleteData$target_code_description <-  ifelse(is.na(IncompleteData$target_code_description), 0, IncompleteData$target_code_description)
IncompleteData$target_concept_id <-  ifelse(is.na(IncompleteData$target_concept_id), 0, IncompleteData$target_concept_id)
IncompleteData$target_domain_id <-  ifelse(is.na(IncompleteData$target_domain_id), 0, IncompleteData$target_domain_id)
IncompleteData$target_concept_class_id <-  ifelse(is.na(IncompleteData$target_concept_class_id), 0, IncompleteData$target_concept_class_id)
IncompleteData$valid_end_date <-  ifelse(is.na(IncompleteData$valid_end_date), 0, IncompleteData$valid_end_date)


IncompleteData <- na.omit(IncompleteData)


write.csv(IncompleteData,file = file.path(dataFolder, "IncompleteMapping_device2022.11.17.csv"), 
          na = "", fileEncoding = "euc-kr")
