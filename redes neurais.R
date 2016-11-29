
library(readxl)
tbl=read_excel("20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx", skip=2)
tbl=tbl[,-c(2:11)]
dados=apply(tbl[,-1], 2, as.double)
nms=colnames(dados)
nms=gsub("--", "-", nms)
colnames(dados)=nms

names=tbl[[1]]
names = sapply(strsplit(names, ";"), '[', 1)
names=gsub("--", "-", names)
rownames(dados)=names
rm(names, nms, tbl)

data=data.frame(t(dados))
rm(dados)
