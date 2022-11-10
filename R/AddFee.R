dataFolder <- file.path(Sys.getenv("gitFolder"), "dr-you-group/OmopVocabulary/data")

drugfee <- read.csv( file = file.path(dataFolder, "drug_fee.csv"),
          header = TRUE, sep = ",")

incomplete <- read.csv( file = file.path(dataFolder, "drug/IncompleteMapping/IncompleteMapping2022.10.31.csv"),
                        header = TRUE, sep = "\t")

names(drugfee[2]) <- "source"
a <- left_join(incomplete,drugfee, by =)