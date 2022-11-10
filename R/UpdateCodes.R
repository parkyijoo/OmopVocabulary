library(dplyr)
library(readr)
dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data/drug")

concept <- read.csv("C:/Users/yijoo0320/git/dr-you-group/OmopVocabulary/data/OmopVoca2022.10.27/CONCEPT.csv", sep = "\t" )#,nrows=10
conMap <- readr::read_tsv(file = file.path(dataFolder, "SourceToConceptMap/SourceToConceptMap2022.10.31.csv"),  na = "")
CompleteData <- readr::read_tsv(file = file.path(dataFolder, "CompleteMapping/CompleteMapping2022.10.31.csv"),  na = "")
IncompleteData <- readr::read_tsv(file = file.path(dataFolder, "IncompleteMapping/IncompleteMapping2022.10.31.csv"),  na = "")

# source_concept_id로 조인
colnames(concept)[1] <- "target_concept_id"
concept$target_concept_id <- as.character(concept$target_concept_id)
CompleteData$target_concept_id <- as.character(CompleteData$target_concept_id)
unionC <- left_join(CompleteData, concept, by = "target_concept_id")

##CompleteData##
# 열 순서 변경(concept_class_id, vocabulary_id, source_concept_domain)
colnames(unionC)
unionC <- unionC[,c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)]
names(unionC) <- c("source_domain_id", "source_code", "source_concept_id", "source_concept_class_id", "source_vocabulary_id", "source_concept_domain", "source_code_description", "target_concept_id" , "target_vocabulary_id", "target_concept_domain", "target_code_description", "valid_start_date", "valid_end_date", "invalid_reason", "comment")
unionC <- unionC %>% relocate(source_concept_class_id, .before = source_vocabulary_id) 
unionC <- unionC %>% relocate(source_concept_domain, .after = source_vocabulary_id)
unionC <- unionC %>% relocate(target_concept_domain, .after = target_vocabulary_id)
unionC <- unionC %>% relocate(target_code_description, .after = target_concept_domain)
unionC <- unionC %>% relocate(comment, .after = invalid_reason)

# NA값 정리
unionC$source_concept_id <- replace(unionC$source_concept_id == 0, NA)
unionC$source_concept_class_id <- replace(unionC$source_concept_class_id == "Undefined", NA)
unionC$source_vocabulary_id <- replace(unionC$source_vocabulary_id == "None", NA)
unionC$source_concept_domain <- replace(unionC$source_concept_domain == "Metadata", NA)

##IncompleteData##
unionC$target_concept_id <- as.double(unionC$target_concept_id)
unionC$valid_start_date <- as.Date(unionC$valid_start_date)
unionC$valid_end_date <- as.Date(unionC$valid_end_date)
unionI <- conMap[!(conMap$source_code %in% unionC$source_code),]

# NA값 정리
unionI[unionI$source_concept_id == 0, "source_concept_id"] = NA
unionI[unionI$source_concept_class_id == "Undefined", "source_concept_class_id"] = NA
unionI[unionI$source_vocabulary_id == "None", "source_vocabulary_id"] = NA
unionI[unionI$source_concept_domain == "Metadata", "source_concept_domain"] = NA

# 코드명 오름차순
unionC <- unionC[order(unionC$source_code_description), ]

CompleteData <- unionC
IncompleteData <- unionI

nrow(IncompleteData[IncompleteData$target_vocabulary_id == "ATC",])
nrow(conMap[conMap$source_domain_id == "Drug",])
sum(is.na(IncompleteData$target_vocabulary_id))

write.csv(IncompleteData, file = file.path(dataFolder, "incompletedata"))
readr::write_tsv(x = CompleteData, file = file.path(dataFolder, "CompleteMapping/CompleteMapping2022.10.31.csv"),  na = "")
readr::write_tsv(x = IncompleteData, file = file.path(dataFolder, "IncompleteMapping/IncompleteMapping2022.10.31.csv"),  na = "")

