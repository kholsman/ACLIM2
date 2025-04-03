library(shiny)
library(ggplot2)
library(dplyr)
library(viridis)
library(bslib)
library(plotly)


source("MakeACLIM_HCRdata_functions.R")
HCR_choices <- seq(1,length(HCRscen_levels))
names(HCR_choices)<-c(HCRscen_levels)

#plodat_all <- readRDS("data/plodat_all.rds")

# getdata<- reactive({source("MakeACLIM_HCRdata_functions.R")})
# 
# output$data <- renderDataTable(
#   plodat_all <- getdata()$plodat_all
#   
#   
#   "Then call all your if statements and such on the function using Pitch"
# )
# 

# UI
ui <- page_sidebar(
 
  # App title ----
  title = "Harvest Control Rule (HCR) Explorer",
  
  # Sidebar panel for inputs ----
  sidebar = sidebar(
    width = "30%",
   # actionButton("run", "Update Plot", class = "btn-primary"),
   #  actionButton("reset_input", "Reset inputs"),
    uiOutput('resetable_input'),
    sliderInput("mhw", "delta SST (deg c)",
                min = -4, max = 4, value = 0,step=.1),
    checkboxInput(inputId = "showbase", label = "Show Status Quo on each plot",
                  value = T, width = NULL),
                    #---- right inputs
                   card(
                     card_header("HCR Visualization"),
                     # checkboxGroupInput("hcrScenarios", "HCR Scenarios to Display",
                     #               # choices = c("HCR1a: Status Quo" = "HCR1a: Status Quo",
                     #               #             "HCR1b: Status Quo + SSL" = "HCR1b: Status Quo + SSL"),
                     #               c("Custom",HCR_levels),
                     #               selected = c("HCR1a: Status Quo", "HCR1b: Status Quo + SSL")),
                     selectInput("hcrScenarios", "HCR Scenarios to Display",
                                 # choices = c("HCR1a: Status Quo" = "HCR1a: Status Quo",
                                 #             "HCR1b: Status Quo + SSL" = "HCR1b: Status Quo + SSL"),
                                 c("Custom",HCR_levels),
                                 multiple = TRUE,
                                 selected = c("HCR1a: Status Quo", "HCR1b: Status Quo + SSL")),
                     sliderInput("B_y", "Display B2B0 (Current SSBiomass Status relative to B_0)",
                                  value = 0.6, min = 0, max = 2, step = .3)
                     ),
                    card(
                      card_header("Optional Custom Inputs"),
                      selectInput("hcrType", "Select Custom HCR Type", HCR_choices),
                                  # choices = c("Type 1: Status Quo" = "1",
                                  #             "Custom" = "0")),
                      numericInput("alpha", "Alpha", value = 0.05, min = 0, max = 1, step = 0.01),
                      
                      numericInput("gamma", "gamma", value = 0, min =-1, max = 10, step = 0.01),
                      numericInput("omega1", "omega1", value = 0, min = 0, max = 10, step = 0.01),
                      numericInput("omega2", "omega2", value = 0, min = 0, max = 10, step = 0.01),
                      numericInput("omega3", "omega3", value = 0, min = 0, max = 10, step = 0.01),
                      numericInput("theta", "theta", value = 0, min = 0, max = 10, step = 0.01),
                    
                      numericInput("b2b0_lim", "B2B0 Limit", value = 0.2, min = 0, max = 1, step = 0.01),
                      numericInput("b2b0_target", "B2B0 Target", value = 0.4, min = 0, max = 1, step = 0.01)
              
                      
                      # numericInput("fabc", "F ABC", value = 0.3, min = 0, max = 1, step = 0.01)
                      )
        ), # end sidebar
    # Main panel for displaying outputs ----
  # Output: A tabset that combines three panels ----
  navset_card_underline(
  # nav card ----
    title = " ",
    # Panel with plot ----
    nav_panel("Plot", 
              card(
                card_header("HCR Visualization"),
                plotlyOutput("hcrPlot", height = "500px")
              ),
              card(
                card_header("Explanation"),
                markdown("
                  ## About Harvest Control Rules
                  Harvest Control Rules (HCRs) are pre-agreed guidelines that determine how much fishing can take place based on the current status of the fish stock.
            
                  - **B/B0** represents the current biomass relative to the unfished biomass
                  - **F_adj** represents the HCR adjusted F_ABC (F_ABC = F_adj*F_maxABC)
                  - **Alpha** is the minimum F adjustment at low stock sizes
                  - **B2B0 Limit** is the threshold below which fishing is reduced to 0
                  - **B2B0 Target** is the threshold at which F_adj = F_maxABC fishing is allowed

                  ")),
              ), # end panel
        nav_panel("Compare Plot", 
                  card(
                    card_header("HCR Comparison"),
                    plotlyOutput("hcrPlotCompare", height = "500px")
                  ),
                  # card(
                  #   card_header("Explanation"),
                  #   markdown("
                  #       ## About Harvest Control Rules
                  #       Harvest Control Rules (HCRs) are pre-agreed guidelines that determine how much fishing can take place based on the current status of the fish stock.
                  # 
                  #       - **B/B0** represents the current biomass relative to the unfished biomass
                  #       - **F/F ABC** represents the fishing mortality relative to the acceptable biological catch
                  #       - **Alpha** is the minimum F adjustment at low stock sizes
                  #       - **B2B0 Limit** is the threshold below which fishing is reduced to alpha
                  #       - **B2B0 Target** is the threshold at which full fishing is allowed
                  # 
                  #       ")),
        ), # end panel

    
    # Panel with summary ----
      nav_panel("Summary", 
        markdown("
            ## About Harvest Control Rules
            
             During ACLIM phase 2 (2019-2022), modelers evaluated a suite of Harvest 
                  Control Scenarios (1-5), in 2025 in coordination with GOACLIM we added 
                  three addition HCRs to the set.Below is a list of those standardized 
                  harvest control rules and the equations used to derive the curves. 

                    - ABC+HCR 1: Status quo  
                    - ABC+HCR 2: Lagged recovery to estimate emergency relief financing needs  
                    - ABC+HCR 3: Long-term resilience (stronger reserve) $F_{target}$  
                    - ABC+HCR 4: CE informed sloping rate, e.g., MHW category alpha  
                    - ABC+HCR 5: climate sensitivity reserve (buffer shocks)  
                    - ABC+HCR 6: MHW slope + climate sensitivity reserve (buffer shocks)  
                    - ABC+HCR 7: R/S variability adjusted HCR based on covariate effects on R/S
                    - ABC+HCR 8: Adjust effective spawning biomass (rather than adjust B_target)

            ")
        ), # end panel
    # Panel with info ----
      nav_panel(
        "Detailed Information",
         #shiny::includeHTML("HCR_demo.html")
        shiny::includeCSS("HCR_demo.html")
      ) # end panel
    ) # end  navset_card_underline
) # end  to page_sidebar io

# Server
if(1==10){
  input <- list()
  
  input$mhw <- 10
  input$showbase <- T
  input$hcrScenarios <-c( "HCR1a: Status Quo", "HCR1b: Status Quo + SSL")
  input$B_y <- 0.6
  input$hcrType <- HCR_choices[1]
  input$alpha <-   0.05
  input$b2b0_lim <- .2
  input$b2b0_target <-0.4
  
}

# server <- function(input, output, session) {
server <- shinyServer(function(input, output, session) {
  # Reactive values to store plotting data
 plotData <- reactiveVal(NULL)

  # Update plot on button click
   # observeEvent(input$run, {
    observe({
    
    # Create data for selected scenarios
    plotdat <- data.frame()
    # plotdat <- reactive({
    
      if ("Custom" %in% input$hcrScenarios) {
        
         tmp_custom <- data.frame(
          B2B0 = B2B0,
          F_adj = unlist(lapply(
              B2B0, ACLIM_HCR, 
              type = as.numeric(input$hcrType),
              alpha = input$alpha, 
              B2B0_lim = input$b2b0_lim,
              B2B0_target = input$b2b0_target,
              invlogit_gamma  = inv.logit(input$gamma),
              log_omega1  = log(input$omega1),
              log_omega2  = log(input$omega2),
              log_omega3  = log(input$omega3),
              log_theta   = log(input$theta),
              cov =input$mhw,
            )),
          
          alpha = input$alpha, B2B0_lim = input$b2b0_lim, 
          B2B0_target = input$b2b0_target)
         
         tmp_custom <- tmp_custom%>%
          mutate(
            HCR = paste("Custom",names(HCR_choices)[ as.numeric(input$hcrType)]),
            HCRscen = names(HCR_choices)[ as.numeric(input$hcrType)], 
            subtxt = "")
        
        
        print(input$hcrType )
        print(names(HCR_choices)[ as.numeric(input$hcrType)])
       print(head(tmp_custom))
        coluse <- col_line%>%filter(HCRscen ==  names(HCR_choices)[ as.numeric(input$hcrType)])
       coluse$col <- "orange"
        col_lineC <- rbind(data.frame(HCR   = tmp_custom$HCR[1],
                                    HCRscen = tmp_custom$HCRscen[1], 
                                    subtxt  = tmp_custom$subtxt[1],
                                    col     = coluse$col[1],
                                    line    = "solid",
                                    size    = 1),
                          col_line)
                                    
        print(head(col_lineC))
        
          plotdat <- rbind( plotdat_all%>%filter(HCR%in% input$hcrScenarios),
                            tmp_custom%>%left_join( col_lineC, by = c("HCR", "HCRscen", "subtxt")))
          
        }else{
          
          plotdat <- plotdat_all%>%filter(HCR%in% input$hcrScenarios)
        
        }
      # return(plotdat)
      # })
    # Update the reactive value
    plotData(plotdat)
    
  })
 
   # get HTML
 # output$inc <- renderUI(includeHTML("HCR_demo.html"))
  
  
  # Render the HCR plot
  output$hcrPlot <- renderPlotly({
    req(plotData())
    plot_title <- ("Harvest Control Rule")
    # plot_HCR_shiny(dataIN = plotdat, plotTitle = plot_title, showbase = input$showbase,B2B0_ref = input$B_y)
    gg <- plot_HCR_shiny(dataIN = plotData(), 
                         plotTitle = plot_title, showbase = input$showbase)
    ggplotly(gg)%>%plotly::layout(legend=list(x=0, 
                                              xanchor='left',
                                              yanchor='bottom',
                                              orientation='h')) 
   
  })
  
  output$hcrPlotCompare <- renderPlotly({
    req(plotData())
    #plot_title <- paste0("Harvest Control Rule (Type ", input$hcrType, ")")
    plot_title <- ("Harvest Control Rule")
    gg <- plot_HCR_shiny(dataIN = plotData(), plotTitle = plot_title, showbase = input$showbase,wrapit = T)
    # ggplotly(gg) %>%
    #   plotly::layout(legend=list(x=0, 
    #                              xanchor='left',
    #                              yanchor='bottom',
    #                              orientation='h')) 
    ggplotly(gg)%>%plotly::layout(legend = list(orientation = 'h', 
                                                xanchor='left',
                                                yanchor='bottom',x = 0, y =-.2))
     })
  

  # Initialize the plot on app start - if needed
  observe({
    # Trigger initial plot creation after app launches
    if (is.null(plotData())) {
      # You can set an initial value here if needed
      # Or use updateActionButton to simulate a click:
      # shiny::click("run")
      hcr1a <- data.frame(
        B2B0 = B2B0,
        F_adj = unlist(lapply(B2B0, ACLIM_HCR, 
                              type = 1,
                              alpha = .05, 
                              B2B0_lim = .2,
                              B2B0_target = .4)),
        alpha = .05, B2B0_lim = .2, B2B0_target = .4)%>%
        mutate(
          HCR = "",
          HCRscen = "HCR1" ,
          subtxt = "")
      
      coluse <- col_line%>%filter(HCRscen == hcr1a$HCRscen[1] )
      col_lineC <- rbind(data.frame(HCR    = hcr1a$HCR[1],
                                    HCRscen = hcr1a$HCRscen[1], 
                                    subtxt  = hcr1a$subtxt[1],
                                    col     = coluse$col[1],
                                    line    = "solid",
                                    size    = 1),
                         col_line)
      
      #"B_y" 
      
      plotdat <- hcr1a%>%left_join( col_lineC, by = c("HCR", "HCRscen", "subtxt"))
      plotData(plotdat)
    }
  })
  # output$resetable_input <- renderUI({
  #   times <- input$reset_input
  #   div(id=letters[(times %% length(letters)) + 1],
  #       actionButton("run", "Update Plot", class = "btn-primary"),
  #       actionButton("reset_input", "Reset inputs"),
  #       uiOutput('resetable_input'),
  #       sliderInput("mhw", "example covariate: SST (deg c)",
  #                   min = -2, max = 30, value = 10),
  #       checkboxInput(inputId = "showbase", label = "Show Status Quo on each plot",
  #                     value = T, width = NULL),
  #       #---- right inputs
  #       card(
  #         card_header("HCR Visualization"),
  #         selectInput("hcrScenarios", "HCR Scenarios to Display", 
  #                     c("Custom",HCR_levels),
  #                     multiple = TRUE,
  #                     selected = c("HCR1a: Status Quo", "HCR1b: Status Quo + SSL")),
  #         sliderInput("B_y", "Display B2B0 (Current SSBiomass Status relative to B_0)", 
  #                     value = 0.6, min = 0, max = 2, step = .3)
  #       ),
  #       card(
  #         card_header("Optional Custom Inputs"),
  #         selectInput("hcrType", "Select Custom HCR Type", HCR_choices),
  #         numericInput("alpha", "Alpha", value = 0.05, min = 0, max = 1, step = 0.01),
  #         numericInput("b2b0_lim", "B2B0 Limit", value = 0.2, min = 0, max = 1, step = 0.01),
  #         numericInput("b2b0_target", "B2B0 Target", value = 0.4, min = 0, max = 1, step = 0.01)
  #         # numericInput("fabc", "F ABC", value = 0.3, min = 0, max = 1, step = 0.01)
  #       )
  #   )
  # })
  
})


# Run the application
shinyApp(ui = ui, server = server)


