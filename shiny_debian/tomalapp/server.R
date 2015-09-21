library(shiny)
library(DT)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(RPostgreSQL)
library(dplyr)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
set.seed(100)
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
connection <- dbConnect( PostgreSQL( max.con = 100),
                        host = "192.168.99.100",
                        port = 5432,
                        user = "postgres",
                        password = "helloNSA",
                        dbname = "tomala" )

shinyServer(function(input, output, session) {

  ## Interactive Map ###########################################

  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -103.35, lat = 20.68, zoom = 12)
  })

  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  observe({
    colorBy <- input$color
    sizeBy <- input$size

    if (sizeBy == "heatmap") {
    strQuery <- sprintf("SELECT ST_X(geom) as longitude,
                ST_Y(geom) as latitude,
                geom, type_name as reporttype,
                array_length(CloserThan(geom,0.5,'%1$s'),1) as nevents,
                HeatMapValue(geom,0.5,'%1$s') as heatmap
                FROM reportes WHERE type_name='%1$s';",input$color)
    dfreportes <- dbGetQuery( connection, strQuery )
    longitude <- dfreportes$longitude
    latitude <- dfreportes$latitude
    heatmap <- dfreportes$heatmap
    reportes <- data.frame(latitude,longitude,heatmap,superzip=0,zipcode=44210)
    print(reportes)
    zipdata = reportes
    colorData <- ifelse(zipdata$heatmap >= (0.5), "Alto", "Bajo")
    pal <- colorFactor("Reds", colorData)
    radius <- ((zipdata[[sizeBy]] / max(zipdata[[sizeBy]]))^2) * 300
    oppacity <- 0.5
    leafletProxy("map", data = zipdata) %>%
      clearShapes() %>%
      clearMarkers() %>%
      addCircles(~longitude, ~latitude, radius=radius, layerId=~zipcode,
                 stroke=FALSE, fillOpacity=oppacity, fillColor=pal(colorData)) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                layerId="colorLegend")
      # Radius is treated specially in the "superzip" case.
      #radius <- ifelse(zipdata$centile >= (100 - input$threshold), 30000, 3000)
    } else {
      strQuery <- sprintf("SELECT ST_X(geom) as longitude,
                ST_Y(geom) as latitude,
                geom, type_name as reporttype
                FROM reportes WHERE type_name='%1$s';",input$color)
      dfreportes <- dbGetQuery( connection, strQuery )
      longitude <- dfreportes$longitude
      latitude <- dfreportes$latitude
      reportes <- data.frame(latitude,longitude,event=1,superzip=0,zipcode=44210)

      zipdata = reportes
      colorData <- ifelse(zipdata$event >= (0.5), input$color, "Bajo")
      pal <- colorFactor("Greens", colorData)
      radius <- 75
      oppacity <- 0.8
      leafletProxy("map", data = zipdata) %>%
        clearShapes() %>%
        clearMarkers() %>%
        addMarkers(~longitude, ~latitude, layerId=~zipcode) %>%
        addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
                  layerId="colorLegend")
    }


  })

  # Show a popup at the given location
  showZipcodePopup <- function(zipcode, lat, lng) {
    strQuery <- sprintf("SELECT
                count(array_length(CloserThan(geom,0.4,'%1$s'),1)) as nevents
                FROM reportes WHERE type_name='%1$s'
                AND ST_Y(geom)-%2$f < 0.00001 AND ST_X(geom)-(%3$f)<0.00001;",input$color, lat, lng)
    dfreportes <- dbGetQuery( connection, strQuery )
    content <- as.character(tagList(
      tags$h4("Eventos:", as.integer(dfreportes$nevents))
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  }

  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()

    isolate({
      showZipcodePopup(event$id, event$lat, event$lng)
    })
  })
})
