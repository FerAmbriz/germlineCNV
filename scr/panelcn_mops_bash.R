library(panelcn.mops)
args <- (commandArgs(trailingOnly = TRUE))

#============================ inputs ============================#
BAMFiles <- list.files(args[1], patter=".bam$", full.names=TRUE)
BAMFiles_control <- list.files(args[2] ,patter=".bam$", full.names=TRUE)

bed <- args[3]
countWindows <- getWindows(bed, chr = TRUE)

selectedGenes <- unlist(strsplit(args[4], split=","))
print(selectedGenes)

output_final <- paste(args[5],'Panelcnmops', sep='/')
#================================================================#

test <- countBamListInGRanges(countWindows = countWindows,
                              bam.files = BAMFiles, read.width = 150)


control <- countBamListInGRanges(countWindows = countWindows,
                                 bam.files = BAMFiles_control, read.width = 150)
panelcnmopstest <- test
elementMetadata(panelcnmopstest) <- cbind(elementMetadata(panelcnmopstest),
                                          elementMetadata(control))
sampleNames <- colnames(elementMetadata(test))
print(sampleNames)


# RESULTS, con este loop te genera un archivo con terminación "CNVPJA.txt" los CNV
# Puedes cambiarlo al nombre de tus archivos.
# resultlistPJA y resulttablePJA, lo puedes cambiar de acuerdo a la teminación
# que tu quieras, por ejemplo resultlistGuatemala o lo puedes dejar así
# Porque trabaja en el loop y al fina te da los archivos txt que se ocupan
# en el siguiente comando
for (i in c(1:length(BAMFiles))){
  resultlist <- runPanelcnMops(panelcnmopstest, testiv=c(i),
                                 countWindows = countWindows, selectedGenes = selectedGenes,
                                 I = c(0.025, 0.57, 1, 1.46,2), normType = "quant", sizeFactor = "quant",
                                 qu = 0.25, quSizeFactor = 0.75, norm = 1, priorImpact = 1, minMedianRC = 30,
                                 maxControls = 25, sex = "female")

  resulttable <- createResultTable(resultlist, panelcnmopstest,
                                    countWindows = countWindows, selectedGenes = selectedGenes, sampleNames)
  name_id <- basename(BAMFiles[i])
  output_file <- paste(output_final, name_id, sep ="/")

  write.table(resulttable, file = output_file)
}
##### Join the individual results of each sample in a single .txt file
##### Establezca la ruta donde se guardaron los archivos txt generado del
##### loop y con los siguientes comandos unes todos los archivos
##### en una sola hoja de txt

#setwd(args[15])
files <- list.files(pattern=".txt")
allresults <- lapply(files, function(I)read.table(I))
out <- do.call(rbind, allresults)

output_save <- paste(output_final,'/panelcnmops_CNVresults.txt', sep='')

write.table(out, output_save, sep = "\t")
