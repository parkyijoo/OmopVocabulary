# install.packages("usethis")
# install.packages("rlang")
# usethis::edit_r_environ()
# install.packages("dplyr") 
# install.packages("openxlsx") 
# install.packages("readr")
library(dplyr)
library(openxlsx)

# 언어 삭제/변경(인코딩 오류)
Sys.setlocale("LC_ALL", "C") 
Sys.setlocale("LC_ALL", "Korean")

DRUG <- read.csv(
  file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/drug/drug.csv",
  header = TRUE, sep = ",")

DRUG_HIRA <- read.csv(
  file = "C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/drug/drughira.csv", header = TRUE,
  sep = ",")

# 조인키 열이름 맞추기
names(DRUG_HIRA)
names(DRUG_HIRA) <- c("researcher","code","source_code","concept_id_hira", "local_name_hira", "concept_name_hira", "matching", "concept_id_kids", "concept_name_kids", "final_concept_id", "X", "X.1", "final_concept_name", "comment")
names(DRUG_HIRA)

# source_code로 조인
DRUG_HIRA$source_code <- as.character(DRUG_HIRA$source_code)
UNION1 <- left_join(DRUG, DRUG_HIRA, by = "source_code")

# DRUG 필요 열만 추출
UNIONF <- UNION1[,c(2,3,4,5,6,7,8,9,10,11,20,24)]

# concept_id 변경없는 경우, NA로 통일
UNIONF$final_concept_id = ifelse(
  UNIONF$target_concept_id == UNIONF$final_concept_id,
  NA,
  UNIONF$final_concept_id
)

UNION10 <- UNIONF

# NA 들어있는 행 삭제
UNION10 <- na.omit(UNION10)

UNION10$invalid_reason <- ifelse(
  is.na(UNION10$final_concept_id),
  "",
  "U"
)

# final concept id가 NA가 아니라면, final concept id 값을 target concept id 에 할당
UNIONF$target_concept_id <- ifelse(
  is.na(UNIONF$final_concept_id),
  UNIONF$target_concept_id,
  UNIONF$final_concept_id
)


UNIONF$valid_start_date <- ifelse(
  is.na(UNIONF$final_concept_id),
  "2021-03-06",
  "2022-10-20"
)

UNIONF$valid_end_date <- ifelse(
  is.na(UNIONF$final_concept_id),
  "2022-10-19",
  ""
)

# concept_id 변경과 변경없음 합체
UNIONT <- rbind(UNION10, UNIONF)

# 제품명 오름차순, 동일 시 시작일 오름차순
UNIONT[order(UNIONT$source_code_description, UNIONT$valid_start_date),]
colnames(UNIONT)
UNIONT <- UNIONT[,c(1,2,3,4,5,6,7,8,9,10)]

View(UNIONT)
# 파일 tsv로 저장
readr::write_tsv(x = UNIONT, file = file.path(dataFolder, "EdiConceptToMap2022.10.25.csv"))

dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data")

concept <- read.csv(file.path(dataFolder, "OmopVoca2022.10.25/CONCEPT.csv"), sep = "\t") #,nrows=10
conMap <- readr::read_tsv(file = file.path(dataFolder, "EdiConceptToMap2022.10.22.csv"))

#head(conMap)

unique(concept$vocabulary_id)

# source_code와 concept_code 일치여부 확인 
conMap[which(conMap$source_code %in% concept$concept_code == FALSE),]

# code 불일치 행 추출
codeFalse <- conMap[which(conMap$source_code %in% concept$concept_code == FALSE),]
#View(codeFalse)
 
# source_concept_id와 concept_id 일치여부 확인(모두 일치)
conMap[which(conMap$source_concept_id %in% concept$concept_id == FALSE),]

# 조인키 열이름 맞추기
names(concept)
names(concept) <- c("target_concept_id", "concept_name", "domain_id", "vocabulary_id", "concept_class_id", "standard_concept", "concept_code", "valid_start_date", "valid_end_date",   "invalid_reason")

# source_concept_id로 조인
concept$source_concept_id <- as.double(concept$source_concept_id)
union <- left_join(conMap, concept, by = "source_concept_id")

# korean EDI -> EDI 로 변경
conMap$source_vocabulary_id <- union$vocabulary_id

# comment에 concept_name 작성
conMap$comment <- union$concept_name

# target_vocabulary_id에 vocabulary_id 작성
union1 <- left_join(conMap, concept, by = "target_concept_id")
conMap$target_vocabulary_id <- union1$vocabulary_id

# source_concept_class_id 추가
conMap$source_concept_class_id <- union1$concept_class_id

# 열 순서 변경(source_concept_class_id 맨 앞으로)
conMap <- conMap %>% relocate(source_concept_class_id, .before = source_code) 
View(conMap)


readr::write_tsv(x = conMap, file = file.path(dataFolder, "EdiConceptToMap2022.10.25.csv"),  na = "")
