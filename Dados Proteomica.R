library(readxl)
tabela=read_excel("20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx")
colnames(tabela)=tabela[2,]
tabela1=tabela[-c(1:2, 5557:9645),-c(2:11)]
dados=apply(tabela1[,-1], 2, as.double)
row.names(dados)=tabela1[[1]]

tran = function(x) log2(x+1)
n.dados=apply(dados, 2, tran)
plot(density(n.dados))


##deu certo
plot(density(n.dados[,1]), ylim=c(0,0.14))
for (i in 2:dim(n.dados)[2]) {
  lines(density(n.dados[,i]), col=i)  
}

graf=function(x) lines(density(x), col=sample(1:10000, 1))
plot(density(n.dados[,1]), ylim=c(0,0.14))
apply(n.dados, 2, graf)

##Benilton
fit=apply(n.dados, 2, density)
matx=sapply(fit, '[[', 'x')
maty=sapply(fit, '[[', 'y')
matploy(matx,maty, type='l', lty=1)


install.packages("sm")
library(sm)
sm.density.compare(n.dados[,2], n.dados[,3])


#Graficos de correlação

#com for
data=data[,-75]
x=rep(0,length(data)/2)
for (i in 1:(length(data)/2)) {
  x[i]=cor(data[,2*i-1],data[,2*i])
}
plot(x)


data=as.data.frame(n.dados, row.names =tabela1[[1]], col.names=tabela[2,])
x=cor(data)
#install.packages("corrplot")
library(corrplot)
corrplot(x, type="upper", order="hclust", tl.col="black", tl.srt=45)

#outro grafico de correlação

library(corrplot)
y=cor(data[,1:10])
corrplot(y, method="ellipse")


#outro tipo

z=cor(data[1:10])
require(lattice)
levelplot(z)

#outro

library(ggplot2)
library(reshape)
z.m = melt(x)
ggplot(z.m, aes(X1, X2, fill = value)) + geom_tile() + 
  scale_fill_gradient(low = "blue",  high = "yellow")


nms = colnames(dados)
nms = gsub("--", "-", nms)
amostras = sapply(strsplit(nms, "-"), '[', 1)
replicas = sapply(strsplit(nms, "-"), '[', 2)
table(amostras, replicas)

##Limma

#Criando indicadoras para controle e afetados
status=c(rep(0,17),rep(1,21))
dm=model.matrix(~status, data)
fit=lmFit(dm)
cfit=eBayes(fit)
x=topTable(cfit, coef = 1)


#correlação
cor=duplicateCorrelation(data, ndups=2)
cor2=as.data.frame(cor)
#corrplot(cor2, method="ellipse") ???

