library(shiny)
library(shinydashboard)
library(ggplot2)


shinyUI(dashboardPage(skin="blue",
          
  dashboardHeader(title="Application en Market Basket Analysis",titleWidth = 600,
                  tags$li(a(href = 'http://www.targa-consult.com/',
                            img(src = 'logo.png',
                                title = "", height = "80px")),

                          tags$style(".main-header {max-height: 100px}"),
                          tags$style(".main-header .logo {height: 110px;}"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarSearchForm(label="Recherche","searchText","searchButton"),
    sidebarMenu(
      menuItem(h4("Base de Données"),tabName="Base",icon=icon("table")),
      menuItem(h4("Règles d'association"),tabName="Règles",icon=icon("arrows-h")),
      menuItem(h4("Visualisation"),tabName="Visualisation",icon=icon("bar-chart-o"))
      ),
    
    sliderInput("slider1", label = h3("Support"), min = 0, 
                max = 1, value = 0.005,step=0.001),
    sliderInput("slider2", label = h3("Confiance"), min = 0, 
                max = 1, value = 0.8,step=0.001)
    
),
    
   dashboardBody(
      tags$head(tags$style(HTML('
      .main-header .logo {
                                font-family: "Georgia", Times, "Times New Roman", serif;
                                font-weight: bold;
                                font-size: 24px;
                        }'))),
      fileInput("file", label = h2(p(strong("Entrée de fichier")))),
             tabItems(
                tabItem(tabName = "Base",
  box(title=h4(p(strong("Instructions: Veuillez importer votre fichier .csv 
    en respectant ces instructions sur les colonnes")),
               tags$ol(
                 tags$li("Villes"), 
                 tags$li("Catégories des clients"), 
                 tags$li("ID des transactions"),
                 tags$li("Transactions")
               )      
              
               ),status="primary",solidHeader = F,collapsible = F,width=14),
    
                        
                        h2(p(strong("Affichage de la base de données"))),
                        
                        DT::dataTableOutput("tab")),
                tabItem(tabName = "Règles",
                        h2(p(strong("Affichage des règles d'association"))),
                        DT::dataTableOutput("table"),
                        
                        fluidRow(
box(title="Liste des villes",solidHeader=TRUE,status="primary",DT::dataTableOutput("newtable")),
box(title="Liste des catégories des clients",solidHeader=TRUE,status="primary",DT::dataTableOutput("newtab")) 
                          )
                       ),
               tabItem(tabName="Visualisation",
                       h2(p(strong("Visualisation des règles d'association"))),
                       plotOutput("barplot"),
                       downloadButton(outputId="download",label="Téléchargement")
               )),
              tags$style(type="text/css",
                             ".shiny-output-error { visibility: hidden; }",
                             ".shiny-output-error:before { visibility: hidden; }")
      ))
  )
          
          


