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
  file = file.path(dataFolder, "procedure_map.csv"),
  header = TRUE, sep = ",")

## export the concept of OmopVoca ##
concept <- read.csv("C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/OmopVoca2022.10.27/CONCEPT_SYNONYM.csv", 
                    quote = "",
                    row.names = NULL, sep = "\t") #,nrows=10

# 조인키 열이름 맞추기
names(concept)
names(concept) <- c("source_concept_id", "concept_synonym_name", "language_concept_id")

# source_concept_id로 조인
PROCEDURE$source_concept_id <- as.character(PROCEDURE$source_concept_id)
concept$source_concept_id <- as.character(concept$source_concept_id)
union <- left_join(PROCEDURE, concept, by = "source_concept_id")

colnames(union)
union <- union[,c(2,3,4,11,16,17,18,19,20,21,22,23)]

union <- union %>% relocate(concept_synonym_name, .before = local_cd1_nm) 
union[order(union$local_cd1),]
names(union)[2] <- c("sourceCode")

#####################
injung <- read.csv("C:/Users/yijoo0320/Desktop/SourceToconceptMap_procedure_221108.csv")
names(union)
join <- left_join(union, injung, by= "sourceCode")
colnames(join)
join <- join[,c(1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28)]
join(union)[4] <- c("sourceName")


write.csv(union, file = "C:/Users/yijoo0320/desktop/procedure_synonnym.csv", fileEncoding = "euc-kr", na = "")

