library(shiny)
library(leaflet)

# Choices for drop-downs
reporttype <- c(
  "Luz encendida de día" = "LUZ ENCENDIDA DE DÍA",
  "Luz apagada de noche" = "LUZ APAGADA DE NOCHE",
  "Bache" = "BACHE",
  "Animal muerto" = "ANIMAL MUERTO",
  "Basura" = "BASURA",
  "Pavimento en mal estado" = "PAVIMENTO EN MAL ESTADO",
  "Llantas" = "LLANTAS",
  "Escombro" = "ESCOMBRO",
  "Cacharro" = "CACHARRO",
  "Maleza" = "MALEZA"
  )
formattype <- c(
  "Eventos individuales" = "events",
  "Mapa de Calor" = "heatmap"
)


shinyUI(navbarPage("Tómala", id="nav",

                   tabPanel("Mapa Interactivo",
                            div(class="outer",
                                tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")
                                ),

                                leafletOutput("map", width="100%", height="100%"),

                                # Shiny versions prior to 0.11 should use class="modal" instead.
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = "auto",

                                              h2("Explorador de campañas"),

                                              selectInput("color", "Tipo de Reporte", reporttype),
                                              selectInput("size", "Formato", formattype, selected = "events")#,
                                              #conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
                                                               # Only prompt for threshold when coloring or sizing by superzip
                                              #                 numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
                                              #),

                                              #plotOutput("histCentile", height = 200),
                                              #plotOutput("scatterCollegeIncome", height = 250)
                                ),

                                tags$div(id="cite",
                                         'Data compiled by ', tags$em('Tómala'), '  (2015).'
                                )
                            )
                   ),
                   conditionalPanel("false", icon("crosshair"))
))
