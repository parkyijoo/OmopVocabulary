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

dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data/procedure")

# 언어 삭제/변경(인코딩 오류)
Sys.setlocale("LC_ALL", "C") 
Sys.setlocale("LC_ALL", "Korean.utf8")

PROCEDURE <- read.csv(
  file = file.path(dataFolder, "procedure.csv"),
  header = TRUE, sep = ",")

## export the concept of OmopVoca ##
concept <- read.csv("C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/OmopVoca2022.10.27/CONCEPT.csv", 
                    quote = "",
                    row.names = NULL, sep = "\t") #,nrows=10

conMap <- PROCEDURE


# 조인키 열이름 맞추기
names(concept)
names(concept)[1] <- c("source_concept_id")
names(conMap)[6] <- c("target_concept_id")
concept <- concept[,c(1,2,3,4,5,7)]

# source_concept_id로 조인
conMap$source_concept_id <- as.character(conMap$source_concept_id)
concept$source_concept_id <- as.character(concept$source_concept_id)
union <- left_join(conMap, concept, by = "source_concept_id")

# source_vocabulary_id 작성
conMap$source_vocabulary_id <- union$vocabulary_id

# source_domain_id 추가
conMap$source_domain_id <- union$domain_id

conMap$source_concept_class_id <- union$concept_class_id

conMap <- conMap %>% relocate(source_domain_id, .before = source_vocabulary_id) 
conMap <- conMap %>% relocate(source_code, .before = source_concept_id) 
conMap <- conMap %>% relocate(source_code_description, .after = source_vocabulary_id) 
conMap <- conMap %>% relocate(source_concept_class_id, .after = source_vocabulary_id) 

## export the concept of OmopVoca ##
synonym <- read.csv("C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/OmopVoca2022.10.27/CONCEPT_SYNONYM.csv", 
                    quote = "",
                    row.names = NULL, sep = "\t") #,nrows=10

# 조인키 열이름 맞추기
names(synonym)
names(synonym)[1] <- c("source_concept_id")

# source_concept_id로 조인
conMap$source_concept_id <- as.character(conMap$source_concept_id)
synonym$source_concept_id <- as.character(synonym$source_concept_id)
union1 <- left_join(conMap, synonym, by = "source_concept_id")

conMap <- union1
conMap <- conMap[,-c(14)]
names(conMap)[13] <- c("source_concept_synonym")
conMap <- conMap %>% relocate(source_concept_synonym, .before = source_code_description) 


# target_vocabulary_id에 vocabulary_id 작성
conMap$target_concept_id <- as.character(conMap$target_concept_id)
names(concept)[1] <- c("target_concept_id")
union1 <- left_join(conMap, concept, by = "target_concept_id")

# target_vocabulary_id 작성
conMap$target_vocabulary_id <- union1$vocabulary_id

conMap$target_code_description <- union1$concept_name

# target_domain_id 추가
conMap$target_domain_id <- union1$domain_id

# target_concept_class_id 추가
conMap$target_concept_class_id <- union1$concept_class_id

conMap <- conMap %>% relocate(target_domain_id, .before = target_vocabulary_id) 
conMap <- conMap %>% relocate(target_concept_class_id, .after = target_vocabulary_id)
conMap <- conMap %>% relocate(target_code_description, .after = target_concept_class_id) 

readr::write_tsv(conMap,file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/procedure/SourceToConceptMap_procedure2022.11.16", na = "")


