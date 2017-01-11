##Atualização
source("Documentos/Github/ic/Redes Neurais/helpers.R")

### Para Unique peptides maior que e dps maior do que 5
tbl_5=readData(filename = "20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx", 5)
tbl_5=data.frame(t(tbl_5))

## Para unique peptides maiores que 10
tbl_10=readData(filename = "20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx", 10)
tbl_10=data.frame(t(tbl_10))


## Arrumando nome das amostras para uniqp >= 5
nms=rownames(tbl_5)
tbl_5$amostras = sapply(strsplit(nms, "-"), '[', 1)
library(plyr)
tbl_5=ddply(tbl_5, .(amostras), function(mdf) {
  idx=grep("amostras", names(mdf))
  colMeans(mdf[,-idx])
})
rm(nms)

## Arrumando nome das amostras para uniqp >= 10
nms=rownames(tbl_10)
tbl_10$amostras = sapply(strsplit(nms, "-"), '[', 1)
library(plyr)
tbl_10=ddply(tbl_10, .(amostras), function(mdf) {
  idx=grep("amostras", names(mdf))
  colMeans(mdf[,-idx])
})
rm(nms)

###Grupo de afetados é 1, 0 se controle

##Para uniqp>=5
rownames(tbl_5)=tbl_5[[1]]
id=substr(tbl_5$amostras, start = 1, stop = 1)!="C"
#grepl("^C", data$amostras)
#regularexpression
id=as.factor(id)
tbl_5$amostras=id
rm(id)

##Para uniqp>=10
rownames(tbl_10)=tbl_10[[1]]
id=substr(tbl_10$amostras, start = 1, stop = 1)!="C"
#grepl("^C", data$amostras)
#regularexpression
id=as.factor(id)
tbl_10$amostras=id
rm(id)

set.seed(148255)

##Separando 20% do banco de dados para validação
ind=sample(1:dim(tbl_5)[1], 0.2*dim(tbl_5)[1])
valid_5=tbl_5[ind,]
train_5=tbl_5[-ind,]
rm(ind)

ind=sample(1:dim(tbl_10)[1], 0.2*dim(tbl_10)[1])
valid_10=tbl_10[ind,]
train_10=tbl_10[-ind,]
rm(ind)

#Transformando os dados em h2o
library(h2o)
h2o.init(nthreads = 2, max_mem_size = "2G")

valid_5=as.h2o(valid_5)
train_5=as.h2o(train_5)
tbl_5=as.h2o(tbl_5)

valid_10=as.h2o(valid_10)
train_10=as.h2o(train_10)
tbl_10=as.h2o(tbl_10)


hidden_opt = lapply(1:100, function(x)10+sample(50,
  sample(10), replace=TRUE))

l1_opt = seq(1e-6,1e-3,1e-6)
hyper_params = list(hidden = hidden_opt, l1 = l1_opt)

search_criteria = list(strategy = "RandomDiscrete",
  max_models = 10, max_runtime_secs = 100,
  seed=123456)

#########################################################################################################################
##Modelo com bando de dados de treinamento e validação para uniqp >= 5
model_grid5=redeNeural("mygrid5", hyper_params, search_criteria, train_5, valid_5)


#Elencando os grids de acordo com o maior AUC
grid_models5=lapply(model_grid5@model_ids, function(mid){
  model=h2o.getModel(mid)
})




##Modelo com banco de dados de treinamento e validação
model_grid10=redeNeural("mygrid10", hyper_params, search_criteria, train_10, valid_10)


#Elencando os grids de acordo com o maior AUC
grid_models10=lapply(model_grid10@model_ids, function(mid){
  model=h2o.getModel(mid)
})

#Selecionando o melhor grid de acordo com o maior AUC
#grids=h2o.getGrid(grid_id = model_grid, sort_by = "auc", decreasing = T)

bestmodel5=h2o.getModel(model_grid5@model_ids[[1]])

bestmodel10=h2o.getModel(model_grid10@model_ids[[1]])

#AUC do modelo
h2o.auc(bestmodel5)

h2o.auc(bestmodel10)

############################################################################################################################
##Modelo com cross validation uniqp >= 5
model_gridcv5=redeNeuralV("mygrid5", hyper_params, search_criteria, tbl_5, nfolds = 5)

##Modelo com cross validation uniqp >= 10
model_gridcv10=redeNeuralV("mygrid10", hyper_params, search_criteria, tbl_10, nfolds = 5)

#Elencando os grids de acordo com o maior AUC
grid_cv5=lapply(model_gridcv5@model_ids, function(mid){
  model=h2o.getModel(mid)
})

grid_cv10=lapply(model_gridcv10@model_ids, function(mid){
  model=h2o.getModel(mid)
})

#Selecionando o melhor grid de acordo com o maior AUC
#grids2=h2o.getGrid(grid_id = model_gridcv, sort_by = "auc", decreasing = T)

bestmodelcv5=h2o.getModel(model_gridcv5@model_ids[[1]])

bestmodelcv10=h2o.getModel(model_gridcv10@model_ids[[1]])

#AUC do modelo
h2o.auc(bestmodelcv5)

h2o.auc(bestmodelcv10)

#Testando a performance do modelo com os dados novos
#perf=h2o.performance(model = bestmodel, newdata = valid)

