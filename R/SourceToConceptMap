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
  header = TRUE, sep = ",", fileEncoding = "euc-kr")

colnames(DRUG)
DRUG <- DRUG[, -c(1,15)]

DRUG_HIRA <- read.csv(
  file = file.path(dataFolder, "drughira.csv"),
  header = TRUE, sep = ",", fileEncoding = "utf-8")

## export the concept of OmopVoca ##
concept <- read.csv("C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/OmopVoca2022.10.27/CONCEPT.csv", 
                    quote = "",
                    row.names = NULL, sep = "\t") #,nrows=10

# Join by source_code
names(DRUG_HIRA)[2] <- c("source_code")
DRUG_HIRA$source_code <- as.character(DRUG_HIRA$source_code)
JOIN <- left_join(DRUG, DRUG_HIRA, by = "source_code")
colnames(JOIN)
JOIN <- JOIN[,-c(14,15,16,17,18,19,20)]

names(JOIN)[15] <- c("target_code_description") 
JOIN <- JOIN %>% relocate(source_domain_id, .before = source_vocabulary_id) 
JOIN <- JOIN %>% relocate(source_code, .before = source_concept_id) 
JOIN <- JOIN %>% relocate(target_code_description, .after = target_vocabulary_id) 

# 조인키 열이름 맞추기
names(concept)
names(concept)[1] <- c("source_concept_id")
concept <- concept[,-c(6,7,8,9,10)]

# source_concept_id로 조인
JOIN$source_concept_id <- as.character(JOIN$source_concept_id)
concept$source_concept_id <- as.character(concept$source_concept_id)
union <- left_join(JOIN, concept, by = "source_concept_id")

# source_vocabulary_id 작성
JOIN$source_vocabulary_id <- union$vocabulary_id

# source_domain_id 추가
JOIN$source_domain_id <- union$domain_id

# source_concept_class_id 추가
JOIN$source_concept_class_id <- union$concept_class_id
JOIN <- JOIN %>% relocate(source_concept_class_id, .before = source_code_description) 

# final_concept_id가 NA가 아니라면, final_concept_id 값을 target_concept_id 에 할당
JOIN$target_concept_id <- ifelse(
  is.na(JOIN$final_concept_id),
  JOIN$target_concept_id,
  JOIN$final_concept_id
)

# target_vocabulary_id에 vocabulary_id 작성
names(concept)[1] <- c("target_concept_id")
union1 <- left_join(JOIN, concept, by = "target_concept_id")

# target_vocabulary_id 작성
JOIN$target_vocabulary_id <- union1$vocabulary_id

JOIN$target_code_description <- union1$concept_name

# target_domain_id 추가
JOIN$target_domain_id <- union1$domain_id
JOIN <- JOIN %>% relocate(target_domain_id, .before = target_vocabulary_id) 

# target_concept_class_id 추가
JOIN$target_concept_class_id <- union1$concept_class_id
JOIN <- JOIN %>% relocate(target_concept_class_id, .before = target_code_description) 

names(JOIN)
JOIN <- JOIN[,-c(18)]

write.table(JOIN,file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/drug/SourceToConceptMap_drug2022.11.16.csv", fileEncoding = "euc-kr", na = "" , sep = "\t")
