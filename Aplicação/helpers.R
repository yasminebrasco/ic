library(readxl)

#Função para carregar o arquivo
#ENTRADA: arquivo em xlsx
#SAÍDA: data frame dos dados
loadData = function(filename){
  tbl=read_excel(paste0(filename, ".xlsx"), skip = 2)
  tab=tbl[,-c(4:11)]
  dados=apply(tab[,-1], 2, as.double)
  dados=as.data.frame(dados)
  colnames(dados) = gsub("--", "-", colnames(dados))
  return(dados)
}

#Função para definir o filtro dos dados
#ENTRADA: número de peptídeos únicos e a contagem de peptídeos
#SAÍDA: dados filtrados
filtro = function(dados, uniqp, contp){
  ndados = dados[which((dados$`Unique peptides`>=uniqp[1])&(dados$`Unique peptides`<=uniqp[2])
                       &(dados$`Peptide count`>=contp[1])&(dados$`Peptide count`<=contp[2])),]
  ndados=ndados[,-c(1,2)]
}

#Função para transformação da abundância
#ENTRADA: número ou vetor com os valores da abundância
#SAÍDA: valores transformados
tran = function(x) log2(x+1)

#Função para gráfico das densidades da abundâncias
#ENTRADA: dados
#SAÍDA: gráfico das densidades
plotDensity = function (data){
  n.dados=apply(data, 2, tran)
  fit=apply(n.dados, 2, density)
  matx=sapply(fit, '[[', 'x')
  maty=sapply(fit, '[[', 'y')
  return(matplot(matx,maty, type='l', lty=1))
}

#Função para gráfico de correlações
#ENTRADA: dados, primeiro indivíduo, último indivíduo
#SAÍDA: gráfico da sequência de entrada
plotCorr = function (data, f, l){
  data=tran(data)
  x=cor(data[,f:l])
  corrplot(x, method="ellipse")
}

#Função para identificar a existencia de replicas
#ENTRADA: Os dados do upload
#SAÍDA: Um data frame sem indivíduos que não possuem réplicas
identRep = function(data){
  nms=colnames(data)
  replicas = sapply(strsplit(nms, "-"), '[', 2) #Separando as replicas
  out=NULL
  for (i in 1:length(nms)) {
    if(is.na(replicas[i])) out=i #identificando indivíduos sem replicas
  }
  data=data[,-out]
  return(data)
}

#Função para realizar o teste de hipóteses
#ENTRADA: data frame contendo somente os dados da abundância
#SAÍDA: um data table com as proteínas com diferença mais significativa primeiro
testeHip = function(data){
  data=tran(data)
  pd=data.frame(id=names(data), #informações para matriz de desenho
    status=ifelse (grepl("^C", names(data)), "controle", "caso"),
    replica=ifelse (grepl("1$", names(data)), "1", "2"))
  status=model.matrix(~status+replica, data = pd) #matriz de desenho  
  fit=lmFit(as.matrix(data), design=status)
  cfit=eBayes(fit)
  topP=topTable(cfit, coef = 2, number=Inf)
}

#Função para contabilizar quantos indivíduos na amostra possuem réplicas
#ENTRADA: data frame com os dados
#SAÍDA: um número se referindo a quantidade de indivíduos que possuem réplicas
indRep = function(data){
  nms=colnames(data)
  replicas = sapply(strsplit(nms, "-"), '[', 2) #Separando as replicas
  out=NULL
  for (i in 1:length(nms)) {
    if(is.na(replicas[i])) out=i #identificando indivíduos sem replicas
  }
  length(nms)-out
}