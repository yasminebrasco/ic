#Interface de usuário da minha aplicação!
#Atualização: 30/10

library(shiny)
library(shinydashboard)
library(shinyjs)

dashboardPage(
   dashboardHeader(disable = FALSE)
  ,dashboardSidebar(
     sidebarMenu(
       menuItem("Introdução", tabName = "intro", icon = icon("book"))
      ,menuItem("Análises Descritivas", tabName = "analises", icon = icon("bar-chart"))
      ,menuSubItem("Testes", tabName = "test", icon = icon("tasks"))
      ,menuItem("Sobre", tabName = "about", icon = icon("gear"))
      ,menuItem("Contato", tabName = "cont", icon = icon("envelope-o"))
      ,id = "sidebar_1"
    )
  )
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
        ,tabItem(tabName = "analises"
          ,fluidRow(
            style="background-color: rgb(0,146,172); color: white; text-align:center"
            ,h3("Análises")
            #,br()
          )
          ,br()
          ,fluidRow(
            fileInput('datafile', 'Encontrar Arquivo',
                      accept=c('text/csv', 'text/comma-separated-values,text/plain'))
          ,actionButton("load", "Carregar")
          ,sliderInput("slider", label=h3("Peptide Count"), min=0, max=100, value=c(0,100))
          ,actionButton("check", "Confirmar", icon=icon("check"))
          )
          ,br()
          ,tabBox(id="panel"
            ,tabPanel("Densidades", plotOutput("density"))
            ,tabPanel("Correlações", plotOutput("correlation"))
            ,width = 12
          )
          ,fluidRow(
            box(width = 12
              ,solidHeader = TRUE
              ,title = "Proteínas Discrepantes"
              ,tableOutput("view")
            )
          )
          ,fluidRow(
            box(width = 12
                ,solidHeader = TRUE
                ,title = "Gráfico"
                ,plotOutput("graf")
            )
            ,box(width = 12
                ,solidHeader = TRUE
                ,title = "Gráfico 'Vulcão'"
                ,plotOutput("vulcano")
            )  
          )
        )
        ,tabItem("about"
          ,fluidRow(
            style="background-color: rgb(0,146,172); color: white; text-align:center"
            ,h3("Sobre")
            #,br()
          )
          ,br()
          ,p("Essa ferramenta utiliza métodos estatísticos para cada uma de suas análises. Foi utilizado o pacote 'limma' para modelar e realizar os testes apresentados.")
          ,p("Ela foi criada em 'R', software estatístico de livre acesso. Apap foi desenvolvida por Yasmine Abboudi Brasco, contudo sua realização não seria possível sem a contribuição de algumas pessoas. Agradecimentos a:")
          ,p("André Blazko")
          ,p("Benilton de Sá Carvalho")
          ,p("Felipe Hipolito")
          ,p("Monica Quast")
          ,br()
          ,p("Caso você tenha algum problema ou dúvida entre em contato através do endereço:")
          ,br()
          ,infoBox("E-mail", "yasminebrasco@gmail.com", icon=icon("envelope"), color = 'blue', width = 7)
        )
      )
  )
))

