# install.packages("usethis")
# install.packages("rlang")
# usethis::edit_r_environ()
# install.packages("dplyr") 
# install.packages("openxlsx") 
# install.packages("readr")
library(rlang)
library(dplyr)
library(openxlsx)
library(readr)
dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data")

# 언어 삭제/변경(인코딩 오류)
Sys.setlocale("LC_ALL", "C") 
Sys.setlocale("LC_ALL", "Korean")

DRUG <- read.csv(
  file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/drug/drug.csv",
  header = TRUE, sep = ",")

DRUG_HIRA <- read.csv(
  file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/drug/drughira.csv",
  header = TRUE, sep = ",")

# 조인키 열이름 맞추기
names(DRUG_HIRA)
names(DRUG_HIRA) <- c("researcher","code","source_code","concept_id_hira", "local_name_hira", "concept_name_hira", "matching", "concept_id_kids", "concept_name_kids", "final_concept_id", "X", "X.1", "final_concept_name", "comment")

# source_code로 조인
DRUG_HIRA$source_code <- as.character(DRUG_HIRA$source_code)
JOIN <- left_join(DRUG, DRUG_HIRA, by = "source_code")

# DRUG 필요 열만 추출
colnames(JOIN)
JOIN <- JOIN[,c(1,2,3,4,5,6,7,8,9,10,11,20,24)]

# target_concept_id 변경없는 경우, NA로 통일
JOIN$final_concept_id = ifelse(
  JOIN$target_concept_id == JOIN$final_concept_id,
  NA,
  JOIN$final_concept_id
)

# UPDATE: 업데이트 데이터 + 업데이트와 무관한 전체 데이터 / PREUPDATE: 업데이트 전 데이터 
UPDATE <- JOIN  
PREUPDATE <- JOIN

# NA 들어있는 행 삭제
is.na(PREUPDATE$comment) = 0
PREUPDATE <- na.omit(PREUPDATE)

# 업데이트 전 테이블에 invalid_reason "U" 작성
PREUPDATE$invalid_reason <- "U"
UPDATE$invalid_reason <- NA

# final_concept_id가 NA가 아니라면, final_concept_id 값을 target_concept_id 에 할당
UPDATE$target_concept_id <- ifelse(
  is.na(UPDATE$final_concept_id),
  UPDATE$target_concept_id,
  UPDATE$final_concept_id
)

# valid_start_date 작성
UPDATE$valid_start_date <- ifelse(
  is.na(UPDATE$final_concept_id),
  "2021-03-06",
  "2022-10-20"
)

# valid_end_date 작성
UPDATE$valid_end_date <- ifelse(
  is.na(UPDATE$final_concept_id),
  "2022-10-19",
  NA
)

readr::write_tsv(x = PREUPDATE, file = file.path(dataFolder, "CompleteMapping2022.10.27.csv"),  na = "")
readr::write_tsv(x = UPDATE, file = file.path(dataFolder, "IncompleteMapping2022.10.27.csv"),  na = "")

# concept_id 변경과 변경없음 합체
conMap <- rbind(PREUPDATE, UPDATE)

# 제품명 오름차순, 동일 시 시작일 오름차순
conMap[order(conMap$source_code_description, conMap$valid_start_date),]

colnames(conMap)
conMap <- conMap[,c(1,2,3,4,5,6,7,8,9,10,13)]

# 파일 tsv로 저장
readr::write_tsv(x = conMap, file = file.path(dataFolder, "SourceToConceptMap2022.10.27.csv"))

#======================================================================================
concept <- read.csv(file.path(dataFolder, "OmopVoca2022.10.25/CONCEPT.csv"), sep = "\t") #,nrows=10
conMap <- readr::read_tsv(file = file.path(dataFolder, "SourceToConceptMap2022.10.27.csv"))

# source_code와 concept_code 일치여부 확인 
conMap[which(conMap$source_code %in% concept$concept_code == FALSE),]

# source_concept_id와 concept_id 일치여부 확인(모두 일치)
conMap[which(conMap$source_concept_id %in% concept$concept_id == FALSE),]

# 조인키 열이름 맞추기
names(concept)
names(concept) <- c("source_concept_id", "concept_name", "domain_id", "vocabulary_id", "concept_class_id", "standard_concept", "concept_code", "valid_start_date", "valid_end_date",   "invalid_reason")

# source_concept_id로 조인
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
concept$target_concept_id <- as.double(concept$target_concept_id)
union <- left_join(conMap, concept, by = "target_concept_id")
conMap$target_vocabulary_id <- union$vocabulary_id

# target_code_description 작성
conMap$target_code_description <- union$concept_name

# target_concept_domain 추가
conMap$target_concept_domain <- union$domain_id

# 열 순서 변경(concept_class_id, vocabulary_id, source_concept_domain)
conMap <- conMap %>% relocate(source_concept_class_id, .before = source_vocabulary_id) 
conMap <- conMap %>% relocate(source_concept_domain, .after = source_vocabulary_id)
conMap <- conMap %>% relocate(target_concept_domain, .after = target_vocabulary_id)
conMap <- conMap %>% relocate(target_code_description, .after = target_concept_domain)
conMap <- conMap %>% relocate(comment, .after = invalid_reason)

# NA값 정리
conMap[conMap$source_concept_id == 0, "source_concept_id"] = NA
conMap[conMap$source_concept_class_id == "Undefined", "source_concept_class_id"] = NA
conMap[conMap$source_vocabulary_id == "None", "source_vocabulary_id"] = NA
conMap[conMap$source_concept_domain == "Metadata", "source_concept_domain"] = NA

write.csv(conMap, file = "C:/Users/yijoo0320/Desktop/conMap.csv", na = "")
readr::write_tsv(x = conMap, file = file.path(dataFolder, "SourceToConceptMap2022.10.27.csv"),  na = "")

