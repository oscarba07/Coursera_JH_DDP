library(shiny)
library(shinythemes)
library(plotly)
library(viridis)

ghg <- read.csv('data/ghg.csv', na.strings = '.')
names(ghg)[1] <- 'ccode'


ui <- fluidPage(theme = shinytheme('cerulean'),
    titlePanel(h1("Coursera_JH Developing Data Products")),
    sidebarLayout(
        sidebarPanel(helpText('Create choropleth maps with information about MTCO2 emissions.'),
                     selectInput('gas', p('Select gas'), choices = as.list(levels(ghg$gas)),
                                 selected = 'KYOTOGHG'
                                 ),
                     selectInput('sector', p('Select sector'), choices = as.list(levels(ghg$sector)),
                                 selected = 'Total'
                                 ),
                     sliderInput('year', p('Select year'), 
                                 min=min(ghg$year), max = max(ghg$year), value = 2016, step = 1, sep = ''),
                     submitButton(text = 'Apply changes')
                     ),
        
        
        mainPanel(h2('Final assignment'),
                  h5('Oscar BA. 2/7/2020'),
                  p('This is a shiny application developed for the "Developing Data Products" course
                    by Johns Hopkins University in Coursera.'),
                  h3('Documentation'),
                  p('To run the app, select the gas, sector and year you want to visualize. Then, click on "Apply changes" to
                    plot the desired data in the map.'),
                  div('The necessary packages are', code('shiny'),code('shinythemes'),code('plotly'), 'and', code('viridis')),
                  h4('Greenhouse Gases Emissions'),
                  div('Human activity has worsened the environmental quality. This app shows 
                   how have greenhouse gases emissions evolved through time. Data has been downloaded 
                    from Gutschow et al (2019) at:', a('https://dataservices.gfz-potsdam.de/pik/showshort.php?id=escidoc:3842934'), 
                      ' and is already available in the app "data" folder.\n'),
                  p('"KYOTOGHG" includes all the greenhouse gases established in the Kyoto Protocol. The sector "Total" inlcudes all
                    except for Land Use, Land Use Change and Forestry (LULUCF)'),
                 
                  plotlyOutput('map'),
                  p('Source: own elaboration with data from Gutschow et al (2019)'),
                  div('Gutschow, J., Jeffery, L., Gieseke, R., & Gunther, A. (2019). The PRIMAP-hist national 
                   historical emissions time series (1850-2017) [Data set]. GFZ Data Services. DOI:', a('https://doi.org/10.5880/PIK.2019.018')),
        )
    )
)


server <- function(input, output) {
    d_sub <- reactive({
        ghg[ghg$sector==input$sector & ghg$gas==input$gas & complete.cases(ghg) & ghg$year==input$year,]
        })
    output$map <- renderPlotly({plot_ly(d_sub(), type='choropleth', 
                                locations=d_sub()$ccode, z=d_sub()$mtco2, text=d_sub()$country, 
                                colors = inferno(20, begin = 1, end = 0)
                                ) %>% layout(title='Annual MTCO2 emissions'
                                ) 
                                           
                                })
}

# Run the application 
shinyApp(ui = ui, server = server)
