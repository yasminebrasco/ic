
###Função para leitura de dados de acordo com a contagem de Unique Peptides
readData=function(filename, uniqp){
  tbl=read_excel(paste0(filename, ".xlsx"), skip = 2)
  tabela=tbl[,-c(4:11)]
  tab=tabela[which(tbl$`Unique peptides`>uniqp),]
  tab=tab[,-c(2,4)]
  dados=as.data.frame(apply(tab[,-1], 2, as.double))
}

###Função pra rede neural com banco de dados de validação e treinamento
redeNeural=function(grid_id, hyper_params, search_criteria, data, valid){
  h2o.grid("deeplearning",
     grid_id = "grid_id"
    ,hyper_params = hyper_params
    ,search_criteria = search_criteria
    ,x = names(data)[-1]
    ,y = "amostras"
    ,distribution = "bernoulli"
    ,training_frame = data
    ,validation_frame = valid
    ,score_interval = 2
    ,epochs = 1000
    ,stopping_rounds = 3
    ,stopping_tolerance = 0.05
    ,stopping_metric = "misclassification"
  )
}

###Função pra rede neural com validação cruzada
redeNeuralV=function(grid_id, hyper_params, search_criteria, data, nfolds){
  h2o.grid("deeplearning"
    ,grid_id = "grid_id"
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
    ,nfolds=nfolds
  )
}