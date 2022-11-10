## Set .Renviron to hide important information
# install.packages("usethis")
# usethis::edit_r_environ()

## Install required packages ##
# install.packages("rlang")
# install.packages("dplyr") 
# install.packages("openxlsx") 
# install.packages("readr")
library(rlang)
library(dplyr)
library(openxlsx)
library(readr)

dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data/device")

# 언어 삭제/변경(인코딩 오류)
Sys.setlocale("LC_ALL", "C") 
Sys.setlocale("LC_ALL", "en_US.UTF-8")

DEVICE <- read.csv(
  file = file.path(dataFolder, "device.csv"),
  header = TRUE, sep = ",")

## export the concept of OmopVoca ##
concept <- read.csv("C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/OmopVoca2022.10.27/CONCEPT.csv", 
                    quote = "",
                    row.names = NULL, sep = "\t") #,nrows=10

conMap <- DEVICE


# 조인키 열이름 맞추기
names(concept)
names(concept) <- c("source_concept_id", "concept_name", "domain_id", "vocabulary_id", "concept_class_id", "standard_concept", "concept_code", "valid_start_date", "valid_end_date",   "invalid_reason")

# source_concept_id로 조인
conMap$source_concept_id <- as.character(conMap$source_concept_id)
concept$source_concept_id <- as.character(concept$source_concept_id)
union <- left_join(conMap, concept, by = "source_concept_id")

## export the concept of OmopVoca ##
synonym <- read.csv("C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/OmopVoca2022.10.27/CONCEPT_SYNONYM.csv", 
                     quote = "",
                     row.names = NULL, sep = "\t") #,nrows=10

# 조인키 열이름 맞추기
names(synonym)
names(synonym) <- c("source_concept_id", "concept_synonym_name", "language_concept_id")

# source_concept_id로 조인
union$source_concept_id <- as.character(union$source_concept_id)
synonym$source_concept_id <- as.character(synonym$source_concept_id)
union <- left_join(union, synonym, by = "source_concept_id")

## Complete ##

union$source_vocabulary_id <- union$vocabulary_id
union$source_concept_class_id <- union$concept_class_id
colnames(union)
union <- union[,c(1,2,3,4,5,6,7,8,9,10,11,21,23)]

union1 <- union
union1$target_concept_id_1 = ifelse(
  union1$target_concept_id_1 == 0,
  NA,
  union1$target_concept_id_1
)

union1$target_vocabulary_id = ifelse(
  is.na(union1$target_vocabulary_id),
  0,
  union1$target_vocabulary_id
)

union1$invalid_reason.x = ifelse(
  is.na(union1$invalid_reason.x),
  0,
  union1$invalid_reason.x
)


union1$concept_synonym_name = ifelse(
  is.na(union1$concept_synonym_name),
  0,
  union1$concept_synonym_name
)

# NA 들어있는 행 삭제
union1 <- na.omit(union1)
CompleteData <- na.omit(union1)

# invalid_reason NA
colnames(CompleteData)
names(CompleteData)<- c("source_domain_id", "source_code", "source_concept_id", "source_vocabulary_id",  "source_code_description", "target_concept_id", "target_vocabulary_id", "valid_start_date", "valid_end_date", "invalid_reason", "seq","concept_synonym_name","source_concept_class_id")

# valid_start_date 작성
CompleteData$valid_start_date <- "2022-10-20"

# valid_end_date 작성
CompleteData$valid_end_date <- NA


# 조인키 열이름 맞추기
names(concept)
names(concept) <- c("target_concept_id", "concept_name", "domain_id", "vocabulary_id", "concept_class_id", "standard_concept", "concept_code", "valid_start_date", "valid_end_date",   "invalid_reason")


# target_concept_id로 조인
CompleteData$target_concept_id <- as.character(CompleteData$target_concept_id)
concept$target_concept_id <- as.character(concept$target_concept_id)
union1 <- left_join(CompleteData, concept, by = "target_concept_id")

CompleteData$target_vocabulary_id <- union1$vocabulary_id
CompleteData$target_code_description <- union1$concept_name
CompleteData$target_domain_id <- union1$domain_id

# 열 순서 변경(concept_class_id, vocabulary_id, source_concept_domain)
CompleteData <- CompleteData %>% relocate(source_concept_class_id, .before = source_vocabulary_id) 
CompleteData <- CompleteData %>% relocate(source_domain_id, .after = source_vocabulary_id)
CompleteData <- CompleteData %>% relocate(target_domain_id, .after = target_vocabulary_id)
CompleteData <- CompleteData %>% relocate(target_code_description, .after = target_domain_id)
CompleteData <- CompleteData %>% relocate(concept_synonym_name, .before = source_code_description) 



## Incomplete ##

union$target_concept_id_1 = ifelse(
  union$target_concept_id_1 != 0,
  NA,
  union$target_concept_id_1
)

union$target_vocabulary_id = ifelse(
  is.na(union$target_vocabulary_id),
  0,
  union$target_vocabulary_id
)

union$invalid_reason.x = ifelse(
  is.na(union$invalid_reason.x),
  0,
  union$invalid_reason.x
)

union$concept_synonym_name = ifelse(
  is.na(union$concept_synonym_name),
  0,
  union$concept_synonym_name
)


# NA 들어있는 행 삭제
IncompleteData <- na.omit(union)

# invalid_reason NA
colnames(IncompleteData)
names(IncompleteData)<- c("source_domain_id", "source_code", "source_concept_id", "source_vocabulary_id",  "source_code_description", "target_concept_id", "target_vocabulary_id", "valid_start_date", "valid_end_date", "invalid_reason", "seq","concept_synonym_name", "source_concept_class_id")


# 조인키 열이름 맞추기
names(concept)
names(concept) <- c("target_concept_id", "concept_name", "domain_id", "vocabulary_id", "concept_class_id", "standard_concept", "concept_code", "valid_start_date", "valid_end_date",   "invalid_reason")


# target_concept_id로 조인
IncompleteData$target_concept_id <- as.character(IncompleteData$target_concept_id)
concept$target_concept_id <- as.character(concept$target_concept_id)
union1 <- left_join(IncompleteData, concept, by = "target_concept_id")

IncompleteData$target_vocabulary_id <- union1$vocabulary_id
IncompleteData$target_code_description <- union1$concept_name
IncompleteData$target_domain_id <- union1$domain_id

# 열 순서 변경(concept_class_id, vocabulary_id, source_concept_domain)
IncompleteData <- IncompleteData %>% relocate(source_concept_class_id, .before = source_vocabulary_id) 
IncompleteData <- IncompleteData %>% relocate(source_domain_id, .after = source_vocabulary_id)
IncompleteData <- IncompleteData %>% relocate(target_domain_id, .after = target_vocabulary_id)
IncompleteData <- IncompleteData %>% relocate(target_code_description, .after = target_domain_id)
IncompleteData <- IncompleteData %>% relocate(concept_synonym_name, .before = source_code_description) 

# concept_id 변경과 변경없음 합체
conMap <- rbind(IncompleteData, CompleteData)


# NA값 정리
conMap$source_concept_id <- replace(conMap$source_concept_id,conMap$source_concept_id == 0, NA)
conMap$target_concept_id <- replace(conMap$target_concept_id,conMap$target_concept_id == 0, NA)
conMap$concept_synonym_name <- replace(conMap$concept_synonym_name,conMap$concept_synonym_name == 0, NA)
conMap$source_concept_class_id <- replace(conMap$source_concept_class_id, conMap$source_concept_class_id == 0, NA)
conMap$source_vocabulary_id <- replace(conMap$source_vocabulary_id,conMap$source_vocabulary_id == "None", NA)
conMap$source_domain_id <- replace(conMap$source_domain_id,conMap$source_domain_id == "Metadata", NA)
conMap$target_domain_id <- replace(conMap$target_domain_id,conMap$target_domain_id == "Metadata", NA)

readr::write_csv(x = conMap, file = file.path(dataFolder, "SourceToConceptMap_device2022.11.09.csv"),  na = "")
readr::write_csv(x = CompleteData, file = file.path(dataFolder, "CompleteMapping_device2022.11.09.csv"),  na = "")
readr::write_csv(x = IncompleteData, file = file.path(dataFolder, "IncompleteMapping_device2022.11.09.csv"),  na = "")

