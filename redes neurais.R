##Atualização
source("Documentos/Github/ic/Redes Neurais/helpers.R")

library(readxl)
tbl=read_excel("20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx", skip=2)
tbl=tbl[,-c(2:11)]
dados=apply(tbl[,-1], 2, as.double)
nms=colnames(dados)
nms=gsub("--", "-", nms)
colnames(dados)=nms



### Para Unique peptides maior que e dps maior do que 5
tbl_10=tbl[which(tbl$`Unique peptides`>=10),]
tbl_5=tbl[which(tbl$`Unique peptides`>=5),]

## Para unique peptides maiores que 10
tbl_10=tbl_10[,-c(2:11)]
dados_10=apply(tbl_10[,-1], 2, as.double)
nms=colnames(dados_10)
nms=gsub("--", "-", nms)
colnames(dados_10)=nms

names=tbl_10[[1]]
names = sapply(strsplit(names, ";"), '[', 1)
names=gsub("--", "-", names)
rownames(dados_10)=names
rm(names, nms, tbl)

names=tbl[[1]]
names = sapply(strsplit(names, ";"), '[', 1)
names=gsub("--", "-", names)
rownames(dados)=names
rm(names, nms, tbl)

data=data.frame(t(dados))
rm(dados)

nms=rownames(data)
data$amostras = sapply(strsplit(nms, "-"), '[', 1)
library(plyr)
data=ddply(data, .(amostras), function(mdf) {
  idx=grep("amostras", names(mdf))
  colMeans(mdf[,-idx])
})
rm(nms)

#Grupo de afetados é 1, 0 se controle
rownames(data)=data[[1]]
id=substr(data$amostras, start = 1, stop = 1)!="C"
#grepl("^C", data$amostras)
#regularexpression
id=as.factor(id)
data$amostras=id

set.seed(148255)
##Separando 20% do banco de dados para predição
# ind=sample(1:dim(data)[1], 0.2*dim(data)[1])
# pred=data[ind,]
# dados=data[-ind,]

##Separando 20% do banco de dados para validação
ind=sample(1:dim(data)[1], 0.2*dim(data)[1])
valid=data[ind,]
train=data[-ind,]
#rm(data, ind, id)

#Transformando os dados em h2o
library(h2o)
h2o.init(nthreads = 2, max_mem_size = "2G")

#pred=as.h2o(pred)
#train=as.h2o(train)
valid=as.h2o(valid)
data=as.h2o(data)


hidden_opt = lapply(1:100, function(x)10+sample(50,
  sample(10), replace=TRUE))

l1_opt = seq(1e-6,1e-3,1e-6)
hyper_params = list(hidden = hidden_opt, l1 = l1_opt)

search_criteria = list(strategy = "RandomDiscrete",
  max_models = 10, max_runtime_secs = 100,
  seed=123456)

#####################################################################################
##Modelo com banco de dados de treinamento e validação
model_grid=redeNeural("mygrid", hyper_params, search_criteria, data, valid)


#Elencando os grids de acordo com o maior AUC
grid_models=lapply(model_grid@model_ids, function(mid){
  model=h2o.getModel(mid)
})

#Selecionando o melhor grid de acordo com o maior AUC
#grids=h2o.getGrid(grid_id = model_grid, sort_by = "auc", decreasing = T)

bestmodel=h2o.getModel(model_grid@model_ids[[1]])

#AUC do modelo
h2o.auc(bestmodel)
#[1] 1

###################################################################################
##Modelo com cross validation
model_gridcv <- h2o.grid("deeplearning"
  ,grid_id = "mygrid"
  ,hyper_params = hyper_params
  ,search_criteria = search_criteria
  ,x = names(data)[-1]
  ,y = "amostras"
  ,distribution = "bernoulli"
  ,training_frame = data
  ,score_interval = 2
  ,epochs = 1000
  ,stopping_rounds = 3
  ,stopping_tolerance = 0.05
  ,stopping_metric = "misclassification"
  ,nfolds=5
)

#Elencando os grids de acordo com o maior AUC
grid_models2=lapply(model_gridcv@model_ids, function(mid){
  model=h2o.getModel(mid)
})

#Selecionando o melhor grid de acordo com o maior AUC
#grids2=h2o.getGrid(grid_id = model_gridcv, sort_by = "auc", decreasing = T)

bestmodel2=h2o.getModel(model_gridcv@model_ids[[1]])

#AUC do modelo
h2o.auc(bestmodel2)

#Testando a performance do modelo com os dados novos
perf=h2o.performance(model = bestmodel, newdata = valid)
