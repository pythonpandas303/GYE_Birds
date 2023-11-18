# R script to parse Specieslist.txt and output .csv

   spList <- read.fwf(file = paste0(path, "/SpeciesList.txt"),
                      widths = c(7, 5, 50, 50, 50, 
                                 50, 50, 50, 50),
                      skip = 14,
                      col.names = c("Seq", "aou", "English",
                                    "French", "Spanish",
                                    "Order", "Family", "Genus", "Species"),
                      strip.white = T)
   write.csv(spList, "./spList.csv")
