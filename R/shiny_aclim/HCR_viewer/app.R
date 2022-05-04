#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(heatmaply)
library("shiny" )
library("timevis")
library("plotly")
library("stringi")
library("readxl")
library("dplyr")
library("RColorBrewer")

HCR <-function(x, alpha=0.05, B2B0_lim = 0.2, B2B0_target=0.4,Flim=1){
    B2B40    <- x/B2B0_target
    if(B2B40>1.){
        maxFabc=Flim
    }else{
        if(alpha<B2B40){
            maxFabc=Flim*((B2B40-alpha)/(1.-alpha))
        }else{
            maxFabc=0.0
        }
    }
    if(B2B40<=(B2B0_lim/B2B0_target))
        maxFabc=0.0
    return(maxFabc)
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("ACLIM2 ABC+HCR Methods"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # numericInput("alpha","alpha", min = 0,max = 1,value = .05,step=.01),
            # numericInput("alpha_rb","alpha (rebuilding)", min = 0,max = 1,value = .05,step=.01),
            # numericInput("B2B0_lim","B2B0 Limit", min = 0,max = 1,value = .2,step=.01),
            # numericInput("B2B0_lim_rb","B2B0 Limit (rebuilding)", min = 0,max = 1,value = .2,step=.01),
            # numericInput("B2B0_target","B2B0 Target", min = 0,max = 1,value = .4,step=.01),
            # numericInput("B2B0_target_rb","B2B0 Target (rebuilding)", min = 0,max = 1,value = .5,step=.01),
            #helpText("For more info see p8 : https://apps-afsc.fisheries.noaa.gov/Plan_Team/2021/BSAIintro.pdf"),
            actionButton("reset_input", "Reset inputs"),
            uiOutput('resetable_input')
        ),

        # Show a plot of the generated distribution
        mainPanel(fluidRow(
                verticalLayout(
                    textOutput("text"),
                    hr(),
                    plotlyOutput("matimage", width = 600,height = 300),
                   # hr(),
                    #plotlyOutput("matimage", width = 600,height = 300),
                           hr(),
                   helpText("For more info see p8 : https://apps-afsc.fisheries.noaa.gov/Plan_Team/2021/BSAIintro.pdf")
#                    helpText("F_abc = F_adj*F_target, where if alpha < B/B_target: (B/B_taget  - alpha)/(1-alpha), or 0 if if B/B_target < alpha " ),
#                    helpText("For Tiers (1-3), the coefficient ‘α’ is set at a
# default value of 0.05, with the understanding that the SSC may establish a different value for a specific
# stock or stock complex as merited by the best available scientific information. "),
#                    helpText("Two other scenarios are needed to satisfy the MSFCMA’s requirement to determine whether a stock is
# currently in an overfished condition or is approaching an overfished condition. These two scenarios are as
# follow (for Tier 3 stocks, the MSY level is defined as B35%):"),
#                    helpText("Scenario 6: In all future years, F is set equal to FOFL. (Rationale: This scenario determines
# whether a stock is overfished. If the stock is 1) above its MSY level in 2020 or 2) above 1/2 of its
# MSY level in 2020 and expected to be above its MSY level in 2030 under this scenario, then the
# stock is not overfished.)"),
#                    helpText("
# Scenario 7: In 2021 , F is set equal to max FABC, and in all subsequent years, F is set equal to
# FOFL. (Rationale: This scenario determines whether a stock is approaching an overfished
# condition. If the stock is 1) above its MSY level in 2022 or 2) above 1/2 of its MSY level in 2022
# and expected to be above its MSY level in 2032 under this scenario, then the stock is not
# approaching an overfished condition.)")
                ))
            )
    )
)
if(1==10){
input <- list()
input$Ftarget <- 1
input$Label2 <- "HCR3"
input$Label1 <- "HCR2"
input$alpha <- .05
input$alpha_rb <- .1
input$B2B0_lim <- input$B2B0_lim_rb <- .2
input$B2B0_target <- .4
input$B2B0_target_rb <- .5
}
# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
    plotdat <- reactive({
        B2B0    <- seq(0,.75,.001)
        F_adj0  <- unlist(lapply(B2B0, HCR, alpha = 0.05, 
                                 B2B0_lim = .2, B2B0_target=.4,Flim=1))
        F_adj1  <- unlist(lapply(B2B0, HCR, alpha = input$alpha, 
                                 B2B0_lim = input$B2B0_lim, B2B0_target=input$B2B0_target,Flim=1))
        F_adj2  <- unlist(lapply(B2B0, HCR, alpha = input$alpha_rb, 
                                 B2B0_lim = input$B2B0_lim_rb, B2B0_target=input$B2B0_target_rb,Flim=1))
        
        out  <- rbind(
          rbind(
          data.frame(B2B0=B2B0,F_adj = F_adj1*input$Ftarget, type=input$Label1),
          data.frame(B2B0=B2B0,F_adj = F_adj2*input$Ftarget, type=input$Label2)),
          data.frame(B2B0=B2B0,F_adj = F_adj0*input$Ftarget, type=input$Label0))
        out$type <- factor(out$type, levels = c(input$Label2,input$Label1,input$Label0))
        
        col1 <- RColorBrewer::brewer.pal(11,"Spectral")[c(9,2)]
        #sq$type <- factor(sq$type, levels = c(input$Label2,input$Label1,"Status Quo"))
        
        return(list(dat=out,B_target = input$B2B0_target, B_target_rb = input$B2B0_target_rb,col1=col1))
    })
    
    output$matimage <- renderPlotly({
        ggplot()+
            theme_minimal()+
            geom_line(data=plotdat()$dat, aes(x=B2B0,y=F_adj,color=type))+theme_minimal()+
            scale_fill_brewer()  +
            geom_vline(xintercept = plotdat()$B_target,linetype = "dashed")+
            geom_vline(xintercept = plotdat()$B_target_rb,linetype = "dashed")+
            coord_cartesian(ylim=c(0,1.2))+
            labs(x="B_target (B/B0)",
                 y="F_adj*F_target",
                 subtitle = "",
                 title = "")+
        scale_color_discrete()
      # +
      #   scale_color_manual(values = c(plotdat()$col1[1],plotdat()$col1[2],"gray"))+
      #   labs(color = 'HCR Methods')
      # ,
      #            caption = paste0("alpha1 = ", round(input$alpha,2),
      #                           "; B_target1 = ",100*round(input$B2B0_target,2),"%B0\n",
      #                           "alpha2 = ", round(input$alpha_rb,2),
      #                           "; B_target2 = ",100*round(input$B2B0_target_rb,2),"%B0\n \n"))
      # +
      #   theme(plot.caption =element_text(color = "green", face = "italic",hjust =.5,vjust=.5))+
        
      # +
      #   theme(plot.title = element_text(hjust = 0.5))
      #   
    })
    # output$Fplot <- renderPlotly({
    #     ggplot()+
    #         geom_line(data= plotdat()$sq,aes(x=B2B0,y=F_adj,color=type))+
    #         theme_minimal()+
    #         geom_line(data=plotdat()$dat, aes(x=B2B0,y=F_adj),color="gray")+theme_minimal()+
    #         scale_fill_brewer()  +
    #         geom_vline(xintercept = plotdat()$B_target,linetype = "dashed")+
    #         geom_vline(xintercept = plotdat()$B_target_rb,linetype = "dashed")+
    #         labs(x="B/B_0",
    #              y="F_adj/F_target",
    #              title = "")
    #     
    # })
    
    output$resetable_input <- renderUI({
        times <- input$reset_input
        div(id=letters[(times %% length(letters)) + 1],
        numericInput("Ftarget","F_target", min = 0,max = 1,value = 1,step=.01),
        textInput("Label0", "Line0 label","Status quo"),
        textInput("Label1", "Line1 label","HCR2"),
        textInput("Label2", "Line2 label","HCR3"),
        hr(),
        numericInput("alpha","alpha", min = 0,max = 1,value = .05,step=.01),
        numericInput("B2B0_lim","B2B0 Limit", min = 0,max = 1,value = .2,step=.01),
        numericInput("B2B0_target","B2B0 Target", min = 0,max = 1,value = .4,step=.01),
        hr(),
        numericInput("alpha_rb","alpha (Line2)", min = 0,max = 1,value = .05,step=.01),
        numericInput("B2B0_lim_rb","B2B0 Limit (Line2)", min = 0,max = 1,value = .2,step=.01),
        numericInput("B2B0_target_rb","B2B0 Target (Line2)", min = 0,max = 1,value = .4,step=.01))
        })
})
# Run the application 
shinyApp(ui = ui, server = server)
