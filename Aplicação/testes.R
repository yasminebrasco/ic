x=loadData("20160718_BPDunifesp_proteinsmeasurements_nofilter.xlsx")
uniqp=c(1:1209)
contp=c(0:374)
y=filtro(x, uniqp, contp)





setwd("~/Documentos/Estatística/2S2016/Curso R/teste/data")
filedata = data.frame()
save(filedata, file="filedata.RData")
#saveRDS(filedata, file=paste(rootPath, "filedata.RDS", sep="/"))

#rootPath = '/home/yasmine/Documentos/Estatística/2S2016/Curso R/data'

#rootPath = 'data'




###tentativa Welliton
#Reactive values meio que salva o arquivo filedata no "ambiente" da aplicação e por conta
#disso conseguimos alterar esse arquivo.
values=reactiveValues(
  filedata = NULL
)



#Leitura do banco de dados
# filedata() <- reactive({
#   infile <- input$datafile
#   if (is.null(infile)) {
#     # User has not uploaded a file yet
#     return(NULL)
#   }
#   rootpath = "Users/yasmine/Documentos/Estatística/2S2016/Curso-R/teste/data"
#   write(data, file = rootpath)
#   data = read.csv(infile$datapath, header = T)
# })
# 

# observeEvent(input$load)({
#   if(is.null(input$file1)) return(NULL)
#   table <- read.csv(input$file1$datapath)
#   filedata = table
# })

# output$value <- reactive({
#   if(is.null(input$file)) return(NULL)
#   read.csv(input$file$datapath)
# })
# 
# filedata = output$value


# filedata<- reactive({
#   write.csv("/home/yasmine/Documentos/Estatística/2S2016/Curso R/teste/data/filedata().csv",file=input$datafile)
#   dados=read.csv ("/home/yasmine/Documentos/Estatística/2S2016/Curso R/teste/data/filedata().csv", header = T, sep=",")
#   })
# 


#shinyjs::hide("density")
#shinyjs::hide("correlation")

# observeEvent(input$load, {
#   if(is.null(input$file1)) {
#     showModal(modalDialog(title = "Upload file",
#                           "A file should be informed."))
#     return(NULL)
#   }
# })