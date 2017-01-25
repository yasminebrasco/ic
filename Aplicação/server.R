#Parte servidora da aplicação

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
    shinyjs::useShinyjs()
    shinyjs::hide("panel1")
    shinyjs::hide("density")
    shinyjs::hide("correlation")
    shinyjs::hide("check")
    shinyjs::hide("again")
    shinyjs::hide("view")
    shinyjs::hide("volcano")
    shinyjs::hide("graf")
    shinyjs::hide("panel2")
    
#Botão Start ----
    #Quando usuário clicar em 'Começar' mudar para página Análises
    observeEvent (input$start, {
      updateTabItems(session, "sidebar_1", "analises") #Levo o usuário da página de avisos para a página de análises
    })

#Botão Load ----
    suppressWarnings(
      observeEvent(input$load,{
        delay(ms = 1000,expr = c(shinyjs::hide("datafile"),shinyjs::hide("load")))
        if(is.null(input$datafile)) return(NULL)
        new = paste0(input$datafile$datapath, ".xlsx")
        file.rename(input$datafile$datapath, new)
        table <- loadData(input$datafile$datapath)
        values$filedata = table
        output$slider1 <- renderUI({
          sliderInput("slider1","Contagem Total de Peptídeos"
                      ,min = range(values$filedata$`Peptide count`)[1]
                      ,max = range(values$filedata$`Peptide count`)[2]
                      ,value = c(range(values$filedata$`Peptide count`)[1],range(values$filedata$`Peptide count`)[2])
                    )
        })
        output$slider2 <- renderUI({
          sliderInput("slider2",label = "Contagem de Peptídeos Únicos"
                      ,min = range(values$filedata$`Unique peptides`)[1]
                      ,max = range(values$filedata$`Unique peptides`)[2]
                      ,value = c(range(values$filedata$`Unique peptides`)[1],range(values$filedata$`Unique peptides`)[2])
          )
        })
        shinyjs::show("check")
      })
    )
    
#Botão Check ----
    suppressWarnings(
      observeEvent(input$check,{
        n.dados=filtro(values$filedata, input$slider1, input$slider2)
        values$filedata=n.dados %>% na.omit()
        shinyjs::hide("slider1")
        shinyjs::hide("slider2")
        shinyjs::show("panel1")
        shinyjs::show("density")
        shinyjs::show("correlation")
        shinyjs::hide("check")
        shinyjs::show("panel2")
        shinyjs::show("view")
        shinyjs::show("graf")
        shinyjs::show("volcano")
        shinyjs::show("again")
      
##Gráfico de Densidade ----
        output$density <- renderPlot({
          if(is.null(values$filedata)) return(NULL)
          plotDensity(values$filedata)
        })
  
  ##Gráfico de Correlações ----
        output$correlation <- renderPlot({
          if(is.null(values$filedata)) return(NULL)
          plotCorr(values$filedata, 1, 10)
        })
        
  # ##Slider para selecionar indivíduos ----
  #       sliderInput("slider3","Indivíduos"
  #                   ,min = 1
  #                   ,max = indRep(values$filedata)
  #                   ,value = c(1,10)
  #       )
    
  ##Teste de Hipótese ----
        output$view <- renderDataTable({
          if(is.null(values$filedata)) return(NULL)
          data=identRep(values$filedata)
          testeHip(data) %>% 
            datatable() %>% 
            formatRound(columns=c('logFC', 'AveExpr', 't', 'P.Value', 'adj.P.Val', 'B'), digits=4)
        })
        
        output$graf <- renderPlot({
          if(is.null(topP)) return(NULL)
          topP=testeHip(as.data.frame(values$filedata))
          ggplot(topP, aes(x=AveExpr, y=logFC, col=((abs(topP$logFC)>1)&(topP$adj.P.Val<0.05)))) + geom_point() + theme(legend.position="none")
        })
        
        output$vulcano <- renderPlot({
          if(is.null(topP)) return(NULL)
          topP=testeHip(as.data.frame(values$filedata))
          ggplot(topP, aes(x=logFC, y=(-(10*log(adj.P.Val))), col=((abs(topP$logFC)>1)&((-10*log(topP$adj.P.Val))>-10*log(0.05))))) + geom_point() + geom_vline(xintercept = c(-1,1)) + geom_hline(yintercept = -10*log(0.05))  + ylab("-10*log(p-valor)") + theme(legend.position="none")
        })
      })
    )
    observeEvent (input$again, {
      updateTabItems(session, "sidebar_1", "analises")
      shinyjs::show('datafile')
      shinyjs::show('load')
      shinyjs::hide("panel1")
      shinyjs::hide("density")
      shinyjs::hide("correlation")
    })
})
