library(readxl)

#Função para carregar o arquivo
loadData = function(filename){
  tbl=read_excel(paste0(filename, ".xlsx"), skip = 2)
  tabela=tbl[,-c(2,4:11)]
  tab=tabela[which(tbl$`Unique peptides`>=5),]
  tab=tab[,-2]
  dados=apply(tab[,-1], 2, as.double)
  #row.names(dados)=tab[[1]]
  dados=as.data.frame(dados)
  return(dados)
}

tran = function(x) log2(x+1)

plotDensity = function (data){
  n.dados=apply(data, 2, tran)
  fit=apply(n.dados, 2, density)
  matx=sapply(fit, '[[', 'x')
  maty=sapply(fit, '[[', 'y')
  return(matplot(matx,maty, type='l', lty=1))
}

## testes
#teste <- loadData("20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx")
#plotDensity(teste)

