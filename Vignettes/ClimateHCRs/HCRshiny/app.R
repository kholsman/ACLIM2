library(shiny)
library(ggplot2)
library(dplyr)
library(viridis)
library(bslib)
library(plotly)
library(reshape)
library(writexl)
 # tmpdir<-getwd(); setwd("/Users/KKH/Documents/GitHub_mac/ACLIM2/Vignettes/ClimateHCRs/HCRshiny")
source("R/MakeACLIM_HCRdata_functions.R")

HCR_choices        <- seq(1,length(HCRscen_levels))
names(HCR_choices) <- c(HCRscen_levels)

# UI
ui <- bslib::page_sidebar(
  # App title ----
  title = "Harvest Control Rule (HCR) Explorer",
  # App header ---
  
  # card(card_header("",card_image(file = "ACLIMGOABadges2.png", width = '100%'))),
  # Sidebar panel for inputs ----
     sidebar = sidebar(
       width = "30%",
       # actionButton("run", "Update Plot", class = "btn-primary"),
       # actionButton("reset_input", "Reset inputs"),
       downloadButton("dl_input", "Download HCR Parameters (HCRpar.xlsx) "),
       #downloadButton("dl_Rfun", "Download HCR R function ( HCR_ACLIM() ) "),
       downloadButton("dl_output", "Download HCR plot data"),
       uiOutput("tab"),
       
          uiOutput('resetable_input'),
          checkboxInput(inputId = "showbase", label = "Show Status Quo on each plot",
                        value = T, width = NULL),
          checkboxInput(inputId = "showcustom", label = "Show Custom HCR",
                       value = T, width = NULL),
                    #---- right inputs35
                   card(
                     card_header("HCR Visualization"),
                     selectInput("hcrScenarios", "HCR Scenarios to Display",
                                 HCR_levels,
                                 multiple = TRUE,
                                 selected = c("HCR1a: Status Quo", "HCR1b: Status Quo + SSL"))
                     # sliderInput("B_y", "Display B2B0 (Current SSBiomass Status relative to B_0)",
                     #              value = 0.6, min = 0, max = 2, step = .01)
                     ),
                    card(
                      #card_header("Optional Custom Inputs"),
                      card_header(markdown("## Optional Custom Inputs")),
                      selectInput("hcrType", "Select Custom HCR Type", HCR_choices, selected = HCR_choices[6]),
                                  # choices = c("Type 1: Status Quo" = "1",
                                  #             "Custom" = "0")),
                      markdown("### HCR 1-8 base inputs
                        - **B2B0_lim**: lower biomass threshold (e.g., B_20% = 0.2); 
                        - **B2B0_target**: Target biomass/MSY proxy
                        - **Flim**: input of F harvest mortality rate to adjust with the HCR 
                        - **alpha**: default is 0.05, this is the slope of the HCR"),
                      numericInput("b2b0_lim", "B2B0 Limit", value = 0.2, min = 0, max = 1, step = 0.01),
                      numericInput("b2b0_target", "B2B0 Target", value = 0.4, min = 0, max = 1, step = 0.01),
                      numericInput("alpha", "Alpha", value = 0.05, min = 0, max = 1, step = 0.01),
                      markdown("### HCR 5 & 6 & 9 additional inputs
                      - **gamma**: log of the gamma parameter default is 0; gamma decay rate value is between 0 and 1"),
                      sliderInput("gamma", "gamma", value = .7, min =0.01, max = 4, step = 0.01),
                      markdown("### HCR 7 & 9 additional inputs
                      - **cov**: this is a scaled (z-scored) covariate such as SST, cold pool or BT"),
                      sliderInput("cov", "covariate value",
                                  min = -2, max = 2, value = .7, step=.01),
                      markdown("### HCR 7 additional inputs
                        - **omega1**: omega1 is >0 covariate linked penalty on Flim for HCR 7
                        - **omega2**: covariate linked penalty on B2B0_target for HCR 7
                        - **omega3**: covariate linked penalty on B2B0_lim for HCR 7"),
                      sliderInput("omega1", "omega1", value = .7, min = -1, max = 1, step = 0.01),
                      sliderInput("omega2", "omega2", value = .5, min =-1, max = 1, step = 0.01),
                      sliderInput("omega3", "omega3", value = .3, min = -1, max = 1, step = 0.01),
                      markdown("### HCR 8 additional inputs
                               - **theta** is a scaler on SSB, should be >0"),
                      sliderInput("theta", "theta", value = 0.8, min = 0, max = 2, step = 0.001)
                    
              
                      
                      # numericInput("fabc", "F ABC", value = 0.3, min = 0, max = 1, step = 0.01)
                      )
        ),# end sidebar
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
      # nav_panel("Summary", 
      #   markdown("
      #       ## About Harvest Control Rules
      #       
      #        During ACLIM phase 2 (2019-2022), modelers evaluated a suite of 
      #        Harvest Control Scenarios (1-5), in 2025 in collaboration with 
      #        GOA-CLIM2 we added a number of additional HCRs to the set. Below 
      #        is a list of those standardized harvest control rules and the 
      #        equations used to derive the curves. 
      # 
      #               - ABC+HCR 1: Status quo  
      #               - ABC+HCR 2: Lagged recovery to estimate emergency relief financing needs  
      #               - ABC+HCR 3: Long-term resilience (stronger reserve) $F_{target}$  
      #               - ABC+HCR 4: CE informed sloping rate, e.g., MHW category alpha  
      #               - ABC+HCR 5: climate sensitivity reserve (buffer shocks)  
      #               - ABC+HCR 6: MHW slope + climate sensitivity reserve (buffer shocks)  
      #               - ABC+HCR 7: R/S variability adjusted HCR based on covariate effects on R/S
      #               - ABC+HCR 8: Adjust effective spawning biomass (rather than adjust B_target)
      #               - ABC+HCR 9: Forecast informed version of HCR 5
      # 
      #       ")
      #   ), # end panel
    nav_panel(
      "Detailed Information",
      #shiny::includeHTML("HCR_demo.html")
      shiny::includeCSS("HCR_demo.html")
    )

    ) # end  navset_card_underline
) # end  to page_sidebar io

# Server
if(1==10){
  input <- list()
  
  input$showcustom <- T
  input$showbase <- T
  input$hcrScenarios <-c( "HCR1a: Status Quo", "HCR1b: Status Quo + SSL")
  input$B_y <- 0.6
  input$hcrType <- 10; # HCR_choices[6]
  input$alpha <-   0.05
  input$b2b0_lim <- .2
  input$b2b0_target <-0.4
  input$gamma <- .7
  input$omega1 <- .7
  input$omega2 <- .5
  input$omega3 <-.3
  input$theta <- .7
  input$cov <- .4
  
}

# server <- function(input, output, session) {
server <- shinyServer(function(input, output, session) {
  # Reactive values to store plotting data
  
 plotData <- reactiveVal(NULL)
 outPar   <- reactiveVal(NULL)
 
     url <- a("ACLIM2 HCR R function", href="https://github.com/kholsman/ACLIM2/blob/main/Vignettes/ClimateHCRs/HCRshiny/R/HCR_ACLIM.R")
     output$tab <- renderUI({
      # tagList("URL link:", url)
       tagList(url)
     })
 
    observe({
       HCRpar_out <-  HCRpar_out <- HCRpar%>%
         dplyr::select(-Species2,-Species3)%>%
         dplyr::rename(value = Species1)
       
      if (input$showcustom) {
         # append input file
       
         tmpsub <- HCRpar_out%>%dplyr::filter(HCR==10, sub=="a")
         HCRpar_custom <- 
           data.frame(rbind(
             c("alpha_ABC" , input$alpha), 
             c("alpha2_ABC",tmpsub%>%filter(Parm == "alpha2_ABC")%>%select(value)%>%as.numeric()), 
             c("alpha_OFL",tmpsub%>%filter(Parm == "alpha_OFL")%>%select(value)%>%as.numeric()), 
             c("log_gamma",round(log(input$gamma),4)),
             c("omega1",(input$omega1)),
             c( "omega2" , (input$omega2)),
             c("omega3"  , (input$omega3)),
             c("log_theta"   , round(log(input$theta),4)),
             c("minBlimMult" ,input$b2b0_lim),
             c("Btarget" , input$b2b0_target),
             c("hcr_cov" , input$cov) ))
         
         colnames(HCRpar_custom) <- names(tmpsub)[1:2]
         
         HCRpar_custom$HCR <- as.numeric(input$hcrType)
         HCRpar_custom$sub <- ""
         HCRpar_custom$HCR_sub <- "Custom HCR"
         
         HCRpar_out <- rbind(HCRpar_out,HCRpar_custom)
         
        }
       outPar(HCRpar_out)
      
     })


  # Update plot on button click
   # observeEvent(input$run, {
    observe({
    
    # Create data for selected scenarios
    plotdat <- data.frame()
    # plotdat <- reactive({
    
      if (input$showcustom) {
         # append input file
       
         tmp_custom <- data.frame(
          B2B0 = B2B0,
          F_adj = unlist(lapply(
              B2B0, ACLIM_HCR, 
              type = as.numeric(input$hcrType),
              alpha = input$alpha, 
              B2B0_target = input$b2b0_target,
              B2B0_lim = input$b2b0_lim,
              log_gamma  = log(input$gamma),
              omega1  = (input$omega1),
              omega2  = (input$omega2),
              omega3  = (input$omega3),
              log_theta   = log(input$theta),
              cov = input$cov,
            )),
          
          alpha       = input$alpha, 
          B2B0_target = input$b2b0_target,
          cov = input$cov,
          log_gamma  = log(input$gamma),
          log_theta   = log(input$theta), 
          B2B0_lim    = input$b2b0_lim,
          omega1  = (input$omega1),
          omega2  = (input$omega2),
          omega3  = (input$omega3)
          )
         
         tmp_custom <- tmp_custom%>%
          mutate(
            HCR     = paste("Custom",names(HCR_choices)[ as.numeric(input$hcrType)]),
            HCRscen = paste("Custom",names(HCR_choices)[ as.numeric(input$hcrType)]), 
            subtxt  = "")
        
        
        print(input$hcrType )
        print(names(HCR_choices)[ as.numeric(input$hcrType)])
        print(head(tmp_custom))
        coluse     <- col_line%>%
          filter(HCRscen ==  names(HCR_choices)[ as.numeric(input$hcrType)])
        coluse$col <- "orange"
        col_lineC  <- rbind(data.frame(HCR   = tmp_custom$HCR[1],
                                    HCRscen  = tmp_custom$HCRscen[1], 
                                    subtxt   = tmp_custom$subtxt[1],
                                    col      = coluse$col[1],
                                    line     = "solid",
                                    size     = 1),
                          col_line)
                                    
        print(head(col_lineC))
        
        HCR_tmp <- c(input$hcrScenarios,paste("Custom",names(HCR_choices)[ as.numeric(input$hcrType)]))
  
        plotdat <- rbind( plotdat_all%>%select(-Species,-alpha_OFL,-alpha2_ABC,-type)%>%filter(HCR%in% input$hcrScenarios),
                            tmp_custom%>%left_join( col_lineC, by = c("HCR", "HCRscen", "subtxt")) )%>%mutate(HCR = factor(HCR,levels = HCR_tmp))
      
          
        }else{
          
          plotdat <- plotdat_all%>%filter(HCR%in% input$hcrScenarios)
        
        }
    
    
    plotData(plotdat)
    
  })

     # Render the HCR plot
     output$hcrPlot <- renderPlotly({
    req(plotData())
    plot_title <- ("Harvest Control Rule")
    
    # plot_HCR_shiny(dataIN = plotdat, plotTitle = plot_title, showbase = input$showbase,B2B0_ref = input$B_y)
    gg <- plot_HCR_shiny(dataIN = plotData(), 
                         plotTitle = plot_title, showbase = input$showbase)
    ggplotly(gg)%>%plotly::layout(legend=list(x = 0, 
                                              xanchor='left',
                                              yanchor='bottom',
                                              orientation='h')) 
   
  })
     
     output$dl_input <- downloadHandler(
       filename = function() { "HCRpar.xlsx"},
       content = function(file) {write_xlsx(outPar(), path = file)}
     )
     # output$dl_Rfun <- downloadHandler(
     #   filename = function() { "HCR_ACLIM_function.R"},
     #   content = function(file) {save(HCR_ACLIM, path = file)}
     # ) 
     output$dl_output <- downloadHandler(
       filename = function() { "HCRplotData.xlsx"},
       content = function(file) {write_xlsx(plotData(), path = file)}
     )

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
  #                     value = 0.6, min = 0, max = 2, step = .01)
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


