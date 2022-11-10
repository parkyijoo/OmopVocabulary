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

dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data/drug")

# 언어 삭제/변경(인코딩 오류)
Sys.setlocale("LC_ALL", "C") 
Sys.setlocale("LC_ALL", "Korean.utf8")

DRUG <- read.csv(
  file = file.path(dataFolder, "drug.csv"),
  header = TRUE, sep = ",")

DRUG_HIRA <- read.csv(
  file = file.path(dataFolder, "drughira.csv"),
  header = TRUE, sep = ",")

## export the concept of OmopVoca ##
concept <- read.csv(file.path(dataFolder, "OmopVoca2022.10.27/CONCEPT.csv"), 
                    quote = "",
                    row.names = NULL, sep = "\t") #,nrows=10

# Join by source_code
names(DRUG_HIRA)
names(DRUG_HIRA) <- c("researcher","code","source_code","concept_id_hira", "local_name_hira", "concept_name_hira", "matching", "concept_id_kids", "concept_name_kids", "final_concept_id", "X", "X.1", "final_concept_name", "comment")

DRUG_HIRA$source_code <- as.character(DRUG_HIRA$source_code)
JOIN <- left_join(DRUG, DRUG_HIRA, by = "source_code")
colnames(JOIN)
JOIN <- JOIN[,c(1,2,3,4,5,6,7,8,9,10,11,20,24)]


# seperate data to complete/incomplete data
CompleteData <- JOIN  
IncompleteData <- JOIN

## Complete ##
CompleteData$final_concept_id = ifelse(
  CompleteData$target_concept_id == CompleteData$final_concept_id,
  NA,
  CompleteData$final_concept_id
)

# NA 들어있는 행 삭제
CompleteData$comment <- ifelse(
  is.na(CompleteData$comment),
  0,
  CompleteData$comment
)
CompleteData <- na.omit(CompleteData)

# invalid_reason NA
CompleteData$invalid_reason <- NA

# final_concept_id가 NA가 아니라면, final_concept_id 값을 target_concept_id 에 할당
CompleteData$target_concept_id <- ifelse(
  is.na(CompleteData$final_concept_id),
  CompleteData$target_concept_id,
  CompleteData$final_concept_id
)

# valid_start_date 작성
CompleteData$valid_start_date <- "2022-10-20"

# valid_end_date 작성
CompleteData$valid_end_date <- NA

## Incomplete ##
IncompleteData$final_concept_id <- ifelse(
  union(CompleteData$target_concept_id = IncompleteData$target_concept_id,
        IncompleteData$final_concept_id = NA),
  NA,
  IncompleteData$final_concept_id
)

IncompleteData$invalid_reason <- ifelse(
  IncompleteData$final_concept_id != IncompleteData$target_concept_id,
  "U",
  NA
)

# valid_start_date 작성
IncompleteData$valid_start_date <- "2021-03-06"

# valid_end_date 작성
IncompleteData$valid_end_date <- "2022-10-19"

# concept_id 변경과 변경없음 합체
conMap <- rbind(IncompleteData, CompleteData)

# 제품명 오름차순, 동일 시 시작일 오름차순
conMap[order(conMap$source_code_description, conMap$valid_start_date),]

colnames(conMap)
conMap <- conMap[,c(1,2,3,4,5,6,7,8,9,10,13)]


# 조인키 열이름 맞추기
names(concept)
names(concept) <- c("source_concept_id", "concept_name", "domain_id", "vocabulary_id", "concept_class_id", "standard_concept", "concept_code", "valid_start_date", "valid_end_date",   "invalid_reason")

# source_concept_id로 조인
conMap$source_concept_id <- as.integer(conMap$source_concept_id)
concept$source_concept_id <- as.double(concept$source_concept_id)
union <- left_join(conMap, concept, by = "source_concept_id")

# source_vocabulary_id 작성
conMap$source_vocabulary_id <- union$vocabulary_id

# source_concept_domain 추가
conMap$source_concept_domain <- union$domain_id

# source_concept_class_id 추가
conMap$source_concept_class_id <- union$concept_class_id

# comment 추가
conMap$comment <- union$comment

# target_vocabulary_id에 vocabulary_id 작성
names(concept) <- c("target_concept_id", "concept_name", "domain_id", "vocabulary_id", "concept_class_id", "standard_concept", "concept_code", "valid_start_date", "valid_end_date",   "invalid_reason")
conMap$target_concept_id <- as.double(conMap$target_concept_id)
concept$target_concept_id <- as.double(concept$target_concept_id)
union <- left_join(conMap, concept, by = "target_concept_id")
conMap$target_vocabulary_id <- union$vocabulary_id

# target_code_description 작성
conMap$target_code_description <- union$concept_name

# target_concept_domain 추가
conMap$target_concept_domain <- union$domain_id

CompleteData <-  conMap[conMap$valid_start_date == "2022-10-20",]

# 열 순서 변경(concept_class_id, vocabulary_id, source_concept_domain)
conMap <- conMap %>% relocate(source_concept_class_id, .before = source_vocabulary_id) 
conMap <- conMap %>% relocate(source_concept_domain, .after = source_vocabulary_id)
conMap <- conMap %>% relocate(target_concept_domain, .after = target_vocabulary_id)
conMap <- conMap %>% relocate(target_code_description, .after = target_concept_domain)
conMap <- conMap %>% relocate(comment, .after = invalid_reason)

# NA값 정리
conMap$source_concept_id <- replace(conMap$source_concept_id == 0, NA)
conMap$source_concept_class_id <- replace(conMap$source_concept_class_id == "Undefined", NA)
conMap$source_vocabulary_id <- replace(conMap$source_vocabulary_id == "None", NA)
conMap$source_concept_domain <- replace(conMap$source_concept_domain == "Metadata", NA)

# UpdateCodes
CompleteData <- conMap[union(which(conMap$invalid_reason == "U"),
                             which(conMap$valid_start_date == "2022-10-20")),]

readr::write_csv(x = conMap, file = file.path(dataFolder, "SourceToConceptMap_drug2022.11.10.csv"),  na = "", fileEncoding = "UTF-8")
readr::write_csv(x = CompleteData, file = file.path(dataFolder, "CompleteMapping_drug2022.11.10.csv"),  na = "", fileEncoding = "UTF-8")
readr::write_csv(x = IncompleteData, file = file.path(dataFolder, "IncompleteMapping_drug2022.11.10.csv"),  na = "", fileEncoding = "UTF-8")

