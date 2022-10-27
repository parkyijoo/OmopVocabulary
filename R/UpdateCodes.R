library(dplyr)
library(readr)
dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data")

concept <- read.csv(file.path(dataFolder, "OmopVoca2022.10.25/CONCEPT.csv"), sep = "\t") #,nrows=10
conMap <- readr::read_tsv(file = file.path("./data", "SourceToConceptMap2022.10.27.csv"),  na = "")
PREUPDATE <- readr::read_tsv(file = file.path("./data", "CompleteMapping2022.10.27.csv"),  na = "")
UPDATE <- readr::read_tsv(file = file.path("./data", "IncompleteMapping2022.10.27.csv"),  na = "")

# code 불일치 행 추출
codeFalse <- conMap[which(conMap$source_code %in% concept$concept_code == FALSE),]
View(codeFalse)

# 매핑이 필요한 데이터
incomplete <- 

# 매핑 완료한 데이터
complete <- rbind(PREUPDATE, )

readr::write_tsv(x = complete, file = file.path(dataFolder, "CompleteMapping2022.10.27.csv"),  na = "")
readr::write_tsv(x = incomplete, file = file.path(dataFolder, "IncompleteMapping2022.10.27.csv"),  na = "")
