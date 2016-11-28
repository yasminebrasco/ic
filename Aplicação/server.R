#Parte servidora da minha aplicação

library(shiny)
library(corrplot)
library(DT)
library(limma)
library(ggplot2)
library(readr)
source("helpers.R")

options(shiny.maxRequestSize=30*1024^2)
values=reactiveValues(
  filedata = NULL
)


shinyServer(
  function(input, output, session){
    #Quando usuário clicar em 'Começar' mudar para página Análises
    shinyjs::useShinyjs()
    #shinyjs::hide("filtro")
    shinyjs::hide("panel")
    shinyjs::hide("check")
    
#Botão Start ----
    observeEvent (input$start, {
      updateTabItems(session, "sidebar_1", "analises") #Levo o usuário da página de avisos para a página de análises
    })
    # observeEvent(input$load,{
    #   delay(ms = 2000,expr = c(shinyjs::hide("datafile"),shinyjs::hide("load")))
    #   delay(ms = 2000, expr = c(shinyjs::show("slider"),shinyjs::show("check")))
    # })

#Botão Load ----
    suppressWarnings(
      observeEvent(input$load,{
        delay(ms = 2000,expr = c(shinyjs::hide("datafile"),shinyjs::hide("load")))
        delay(ms = 2000, expr = c(shinyjs::show("slider"),shinyjs::hide("filtro")))
        if(is.null(input$datafile)) return(NULL)
        new = paste0(input$datafile$datapath, ".xlsx")
        file.rename(input$datafile$datapath, new)
        table <- loadData(input$datafile$datapath)
        values$filedata = table
        shinyjs::show("panel")
      })
    )

#Gráfico de Densidade ----
    suppressWarnings(
      output$density <- renderPlot({
        if(is.null(values$filedata)) return(NULL)
        plotDensity(values$filedata)
      })
    )
    

#Gráfico de Correlações ----
    output$correlation <- renderPlot({
      if(is.null(values$filedata)) return(NULL)
      plotCorr(values$filedata, 1, 10)
    })

#Teste de Hipótese ----

    output$view <- renderDataTable({
      if(is.null(values$filedata)) return(NULL)
      data=identRep(values$filedata)
      testeHip(data)
    })
    
    # output$graf <- renderPlot({
    #   if(is.null(topP)) return(NULL)
    #   data=as.data.frame(values$filedata)
    #   data=data[,-75]
    #   pd=data.frame(id=names(data),
    #                 status=ifelse (grepl("^C", names(data)), "controle", "caso"),
    #                 replica=ifelse (grepl("1$", names(data)), "1", "2"))
    #   status=model.matrix(~status+replica, data = pd)
    #   fit=lmFit(as.matrix(data), design=status)
    #   cfit=eBayes(fit)
    #   topP=topTable(cfit, coef = 2, number=Inf)
    #   ggplot(topP, aes(x=AveExpr, y=logFC, col=((abs(topP$logFC)>1)&(topP$adj.P.Val<0.05)))) + geom_point() + theme(legend.position="none")
    # })
    # output$vulcano <- renderPlot({
    #   if(is.null(topP)) return(NULL)
    #   data=as.data.frame(values$filedata)
    #   data=data[,-75]
    #   pd=data.frame(id=names(data),
    #                 status=ifelse (grepl("^C", names(data)), "controle", "caso"),
    #                 replica=ifelse (grepl("1$", names(data)), "1", "2"))
    #   status=model.matrix(~status+replica, data = pd)
    #   fit=lmFit(as.matrix(data), design=status)
    #   cfit=eBayes(fit)
    #   topP=topTable(cfit, coef = 2, number=Inf)
    #   ggplot(topP, aes(x=logFC, y=(-(10*log(adj.P.Val))), col=((abs(topP$logFC)>1)&((-10*log(topP$adj.P.Val))>-10*log(0.05))))) + geom_point() + geom_vline(xintercept = c(-1,1)) + geom_hline(yintercept = -10*log(0.05))  + ylab("-10*log(p-valor)") + theme(legend.position="none")
    # })
})
