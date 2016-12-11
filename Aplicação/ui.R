#Interface de usuário da minha aplicação!
#Atualização: 27/11

library(shiny)
library(shinydashboard)
library(shinyjs)

#Início Dashboard ----
dashboardPage(
   dashboardHeader(disable = FALSE)

#Menu lateral ----
  ,dashboardSidebar(
     sidebarMenu(
       menuItem("Introdução", tabName = "intro", icon = icon("book"))
      ,menuItem("Análises Gráficas", tabName = "analises", icon = icon("bar-chart"))
      ,menuSubItem("Testes", tabName = "test", icon = icon("tasks"))
      ,menuItem("Sobre", tabName = "about", icon = icon("gear"))
      ,menuItem("Contato", tabName = "cont", icon = icon("envelope-o"))
      ,id = "sidebar_1"
    )
  )

#Início do corpo da aplicação ----
  ,dashboardBody(
    useShinyjs()
    ,tags$head( # turn the background of dashboardBody into some specific colour/image
      tags$style(HTML('
                 .content-wrapper
                ,.right-side {
                    background-color: #ffffff;
                }
      '))
    )
    ,fluidPage(
      style="background-color: rgb(255,255,255)"
      ,tabItems(

#Introdução ----
        tabItem(tabName="intro"
          ,fluidRow(
            style="background-color: rgb(0,146,172); color: white; text-align:center"
            ,h3("Apap - Aplicação para Análise Proteômica")
            #,br()
            )
          ,br()
          ,p("Caro usuário, bem vindo ao APAP! Espero que através dele você consiga realizar suas análises de maneira fácil e rápida! Para que seus dados sejam analisados você deve se certificar que:")
          ,p("- O arquivo esteja em formato CSV separado por vírgulas e aspas duplas;")
          ,p("- Caso ele tenha cabeçalho, ele deve ser a primeira linha do arquivo;")
          ,p("- Caso ele não tenha cabeçalho, sua primeira linha não esteja em branco;")
          ,p("- O arquivo não exceda 30MB.")
          ,br()
          ,actionButton("start", "Começar!", style="aling: center")
          ,hr()
        )

#Analises Descritivas ----
        ,tabItem(tabName = "analises"
          ,fluidRow(
            style="background-color: rgb(0,146,172); color: white; text-align:center"
            ,h3("Análises")
            #,br()
          )
          ,br()
          ,fluidRow(
            fileInput('datafile', 'Encontrar arquivo:',
              accept=c('text/csv', 'text/comma-separated-values,text/plain'))
          ,sliderInput("slider1", label = "Contagem Total de Peptídeos", min = 0, 
            max = 100, value = c(0,100)
          )
          ,sliderInput("slider2", label = "Contagem de Peptídeos Únicos", min = 0, 
            max = 100, value = c(0,100)
          )
          ,actionButton("load", "Carregar")
          ,actionButton("check", "Confirmar", icon=icon("check"))
          )
          ,br()
          ,tabBox(id="panel"
            ,tabPanel("Densidades", plotOutput("density"))
            ,tabPanel("Correlações", plotOutput("correlation"))
            ,width = 12
          )
        )

#Testes de Hipóteses ----
        ,tabItem("test"
          ,fluidRow(
            box(width = 12
              ,solidHeader = TRUE
              ,title = "Proteínas Discrepantes"
              ,dataTableOutput("view")
            )
          )
          ,fluidRow(
            tabBox(id="panel"
                    ,tabPanel("Gráfico", plotOutput("graf"))
                    ,tabPanel("Gráfico 'Vulcão'", plotOutput("vulcano"))
                    ,width = 12
          ))
        )

#"Sobre" ----
        ,tabItem("about"
          ,fluidRow(
            style="background-color: rgb(0,146,172); color: white; text-align:center"
            ,h3("Sobre")
            #,br()
          )
          ,br()
          ,p("Essa ferramenta utiliza métodos estatísticos para cada uma de suas análises. Foi utilizado o pacote 'limma' para modelar e realizar os testes apresentados.")
          ,p("Ela foi criada em 'R', software estatístico de livre acesso. Apap foi desenvolvida por Yasmine Abboudi Brasco, contudo sua realização não seria possível sem a contribuição de algumas pessoas. Agradecimentos a:")
          ,p("André Blazko;")
          ,p("Benilton de Sá Carvalho;")
          ,p("Felipe Hipolito;")
          ,p("Monica Quast;")
          ,p("Obrigada!")
          ,br()
        )

#Contato ----
        ,tabItem("contact"
          ,p("Caso você tenha algum problema ou dúvida entre em contato através do endereço:")
          ,br()
          ,infoBox("E-mail", "yasminebrasco@gmail.com", icon=icon("envelope"), color = 'blue', width = 7)
        )
      )
  )
))

