# install.packages("usethis")
# install.packages("rlang")
# usethis::edit_r_environ()

dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data")

concept <- read.csv(file.path(dataFolder, "OmopVoca2022.10.24/CONCEPT.csv"), sep = "\t") #,nrows=10
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
View(union)

# korean EDI -> EDI 로 변경
conMap$source_vocabulary_id <- ifelse(conMap$source_vocabulary_id == "Korean EDI", "EDI")

# comment에 concept_name 작성
conMap$comment <- union$concept_name
con
View(conMap)

# target_vocabulary_id에 vocabulary_id 작성
union1 <- left_join(conMap, concept, by = "target_concept_id")
conMap$target_vocabulary_id <- union1$vocabulary_id
View(conMap)


write.csv(conMap, file = "C:/Users/yijoo0320/Desktop/conMap.csv", fileEncoding = "UTF-8", na = "")

readr::write_tsv(x = conMap, file = file.path(dataFolder, "EdiConceptToMap2022.10.24.csv"), na = "")
