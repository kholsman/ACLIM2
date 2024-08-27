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
alph <- c("A"=1, "C"=2, "G"=3, "T"=4, "I"=5, "U"=6, "N"=7)
seq <- factor(names(alph), unique(names(alph)))
B2B0 <- seq(0,.75,.001)
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

# B2B40        = Bnow/(Btarget*B0_set(k));  // biomass in current year/ target B
# 
# RETURN_ARRAYS_INCREMENT();
# 
# dvariable maxFabc;
# if(Bratio>1.){
#     maxFabc=Flim;
# }else{
#     if(alpha<Bratio){
#         maxFabc=Flim*((Bratio-alpha)/(1.-alpha));
#     }else{
#         maxFabc=0.0;
#     }
# }
# if(Bratio<=Cbeta){
#     maxFabc=0.0; 
#     //cout<<"Bration < "<<Cbeta<<"maxFabc = 0"<<maxFabc<<endl;
# } 
# RETURN_ARRAYS_DECREMENT();
# return(maxFabc); 
HCR1 <-function(x, alpha=0.05, B2B0_lim = 0.2, B2B0_target=0.4){
    B2B40    <- x
    Fout <- 1
    if(B2B40 < (B2B0_lim)){
        Fout <- ((x/B2B0_target)-alpha)/(1-alpha)
    }
    if(B2B40 < (B2B0_lim))
        Fout <- 0
    return(Fout)
}
F_adj <- unlist(lapply(B2B0, HCR, alpha = 0.05, B2B0_lim = 0.2, B2B0_target=0.4))
plotdat <- data.frame(B2B0=B2B0,F_adj = F_adj)
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
            # #helpText("Double click on the graph to reset to original extent "),
            actionButton("reset_input", "Reset inputs"),
            uiOutput('resetable_input')
        ),

        # Show a plot of the generated distribution
        mainPanel(fluidRow(
                verticalLayout(
                    hr(),
                    plotlyOutput("matimage", width = 600,height = 300),
                   # hr(),
                    #plotlyOutput("matimage", width = 600,height = 300),
                           hr()
                ))
            )
    )
)
if(1==10){
input <- list()
input$alpha <- .05
input$alpha_rb <- .1
input$B2B0_lim <- input$B2B0_lim_rb <- .2
input$B2B0_target <- .4
input$B2B0_target_rb <- .5
}
# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
    plotdat <- reactive({
        B2B0     <- seq(0,.75,.001)
        classic      <- unlist(lapply(B2B0, HCR, alpha = 0.05, B2B0_lim = .2, B2B0_target=.4,Flim=1))
        
        F_adj    <- unlist(lapply(B2B0, HCR, alpha = input$alpha, B2B0_lim = input$B2B0_lim, B2B0_target=input$B2B0_target,Flim=1))
        F_adj_rebuild    <- unlist(lapply(B2B0, HCR, alpha = input$alpha_rb, B2B0_lim = input$B2B0_lim_rb, B2B0_target=input$B2B0_target_rb,Flim=1))
        
        out  <- rbind(data.frame(B2B0=B2B0,F_adj = F_adj, type="Regular"),
                          data.frame(B2B0=B2B0,F_adj = F_adj_rebuild, type="Rebuilding"))
        sq <- data.frame(B2B0=B2B0,F_adj = classic, type="Status Quo")
        
        
        
        return(list(dat=out,B_target = input$B2B0_target, sq = sq))
    })
    
    output$matimage <- renderPlotly({
        ggplot()+
            geom_line(data= plotdat()$sq,aes(x=B2B0,y=F_adj),color="gray")+
            theme_minimal()+
            geom_line(data=plotdat()$dat, aes(x=B2B0,y=F_adj,color=type))+theme_minimal()+
            scale_fill_brewer()  +
            geom_vline(xintercept = plotdat()$B_target,linetype = "dashed")+
            labs(x="B/B_0",
                 y="F_adj/F_target",
                 title = "North Pacific Shared Socioeconomic Profiles")
        
    })
    output$Fplot <- renderPlotly({
        ggplot()+
            geom_line(data= plotdat()$sq,aes(x=B2B0,y=F_adj),color="gray")+
            theme_minimal()+
            geom_line(data=plotdat()$dat, aes(x=B2B0,y=F_adj,color=type))+theme_minimal()+
            scale_fill_brewer()  +
            geom_vline(xintercept = plotdat()$B_target,linetype = "dashed")+
            labs(x="B/B_0",
                 y="F_adj/F_target",
                 title = "North Pacific Shared Socioeconomic Profiles")
        
    })
    
    output$resetable_input <- renderUI({
        times <- input$reset_input
        div(id=letters[(times %% length(letters)) + 1],
        numericInput("alpha","alpha", min = 0,max = 1,value = .05,step=.01),
        numericInput("alpha_rb","alpha (rebuilding)", min = 0,max = 1,value = .05,step=.01),
        numericInput("B2B0_lim","B2B0 Limit", min = 0,max = 1,value = .2,step=.01),
        numericInput("B2B0_lim_rb","B2B0 Limit (rebuilding)", min = 0,max = 1,value = .2,step=.01),
        numericInput("B2B0_target","B2B0 Target", min = 0,max = 1,value = .4,step=.01),
        numericInput("B2B0_target_rb","B2B0 Target (rebuilding)", min = 0,max = 1,value = .4,step=.01))
        })
})
# Run the application 
shinyApp(ui = ui, server = server)
