#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#  runApp("/Users/kholsman/Documents/GitHub/ACLIM2/R/shiny_aclim/ACLIM2_indices/app.R")

library(shiny)
library(plotly)
#library(heatmaply)
library("dplyr")
library("RColorBrewer")

#data.path <- "../../../Data/out"
data.path <- "data"
plothist <- TRUE
print(getwd())
load(file.path(data.path,"K20P19_CMIP6/allEBS_means/ACLIM_annual_fut_mn.Rdata"))
ACLIM_annual_fut<- ACLIM_annual_fut%>%rename(scen=RCP)
plotvars   <- unique(ACLIM_annual_fut$var)
gcms       <- unique(ACLIM_annual_fut$GCM)
CMIPs      <- unique(ACLIM_annual_fut$CMIP)
scens      <- unique(ACLIM_annual_fut$secn)
basins    <-  unique(ACLIM_annual_fut$basin)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("ACLIM2 Indices"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            helpText("plots take a few seconds to load"),
            # hr(),
            # selectInput("type","ACLIM2 Index Type",selected=c("annual"),
            #     choices=c("annual","seasonal" ,"monthly","weekly" , "surveyrep"), multiple=T),
            # selectInput("CMIP","CMIP",selected=c("K20P19_CMIP6"),choices=c("K20P19_CMIP5","K20P19_CMIP6"), multiple=T),
            # selectInput("bc","bias corrected or raw",selected=c("raw","bias corrected"),choices=c("raw","bias corrected"), multiple=T),
            # selectInput("GCM","GCM",selected=c("miroc","gfdl","cesm"),choices=c("miroc","gfdl","cesm"), multiple=T),
            # selectInput("scen","climate scenario",selected=c("ssp126","ssp585"),choices=c("ssp126","ssp585"), multiple=T),
            # selectInput("plotvar","variable to plot",selected=c("temp_bottom5m"),choices= plotvars, multiple=F),
            # selectInput("plotbasin","basin",selected=c("SEBS"),choices=c("SESB","NEBS"), multiple=F),
            # selectInput("facet_row","row",selected=c("bc"),choices=c("bc","basin","scen"), multiple=F),
            # selectInput("facet_col","col",selected=c("scen"),choices=c("bc","basin","scen"), multiple=F),
            hr()
            ,
            actionButton("reset_input", "Reset inputs"),
            uiOutput('resetable_input')
        ),

        # Show a plot of the generated distribution
        mainPanel(fluidRow(
                verticalLayout(
                    textOutput("text"),
                    hr(),
                    plotlyOutput("matimage", width = 1000,height = 570),
                   # hr(),
                    #plotlyOutput("matimage", width = 600,height = 300),
                           hr(),
                   helpText("Please ignore error on load, app takes ~1 min to load data.\n For more info on indices see https://kholsman.github.io/ACLIM2")
#                   
                ))
            )
    )
)
if(1==10){
input<-list()
input$bcIN         <- c("raw","bias corrected")
input$GCMIN        <- c("miroc","gfdl","cesm")
input$scenIN       <- c("ssp126","ssp585")
input$typeIN       <- "annual"
input$CMIPIN       <- c("K20P19_CMIP6")
input$plotvarIN    <- "temp_bottom5m"
input$plotbasinIN  <- "SEBS"
input$facet_rowIN  <- "bc"
input$facet_colIN  <- "scen"
input$plothist     <- FALSE
}
# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {

    load(file.path(data.path,"K20P19_CMIP6/allEBS_means/ACLIM_annual_fut_mn.Rdata"))
  ACLIM_annual_fut<-ACLIM_annual_fut%>%rename(scen=RCP)
    plotvars <- unique(ACLIM_annual_fut$var)
    gcms     <- unique(ACLIM_annual_fut$GCM)
    CMIPs    <- unique(ACLIM_annual_fut$CMIP)
    scens    <- unique(ACLIM_annual_fut$scen)
    scens    <- c("ssp126","ssp585","rcp45","rcp85")
    basins   <- unique(ACLIM_annual_fut$basin)
    months   <- seasons <- weeks <-"all"
    opts     <- dir("data")

    output$resetable_input <- renderUI({
         times  <-  input$reset_input
         # load("data/K20P19_CMIP6/allEBS_means/ACLIM_annual_fut_mn.Rdata")
         # months  <-  outdat()$months
         # weeks   <-  outdat()$weeks
         # seasons <-  outdat()$seasons

        div(id=letters[(times %% length(letters)) + 1],
            selectInput("plotbasinIN","basin",selected=basins[2],choices=basins, multiple=T),
            selectInput("plothist","Plot historical runs too?",
                        selected="FALSE",choices=c(TRUE,FALSE), multiple=F),
            selectInput("removeyr1","Remove first year of projection ( burn in)",
                        selected="TRUE",choices=c(TRUE,FALSE), multiple=F),
             selectInput("typeIN","ACLIM2 Index Type",selected=c("annual"),
                choices=c("annual","seasonal" ,"monthly","weekly" , "surveyrep"), multiple=F),
            selectInput("plotvarIN","variable to plot",selected=c("temp_bottom5m"),choices= plotvars, multiple=F),
            selectInput("monthIN","Month",selected=months,choices=months, multiple=T),
            selectInput("weekIN","Week",selected=weeks,choices=weeks, multiple=T),
            selectInput("SeasonIN","Season",selected=seasons,choices=seasons, multiple=T),
            selectInput("CMIPIN","Model & CMIP",selected=c("K20P19_CMIP6"),choices=opts, multiple=F), #"K20P19_CMIP5_C","K20P19_CMIP5","H16_CMIP5"
            selectInput("bcIN","bias corrected or raw",selected=c("raw","bias corrected"),choices=c("raw","bias corrected"), multiple=T),
            selectInput("GCMIN","GCM",selected=gcms,choices=gcms, multiple=T),
            selectInput("scenIN","climate scenario",selected=c("ssp126","ssp585"),choices=scens, multiple=T),
            sliderInput("jday_rangeIN", label = h3("Julian Day"), min = 0, max = 365, value = c(0, 365)),
            
            selectInput("facet_rowIN","row",selected=c("bc"),choices=c("bc","basin","scen"), multiple=F),
            selectInput("facet_colIN","col",selected=c("scen"),choices=c("bc","basin","scen"), multiple=F),
            hr()
            )
        })


    outdat <- reactive({
        typeIN       <- input$typeIN
        plothist     <- input$plothist
        bcIN         <- input$bcIN
        GCMIN        <- input$GCMIN
        scenIN       <- input$scenIN
        plotvar      <- input$plotvarIN
        plotbasin    <- input$plotbasinIN
        facet_row    <- input$facet_rowIN
        facet_col    <- input$facet_colIN
        jday_rangeIN <- input$jday_rangeIN
        
        for(c in 1:length(input$CMIPIN)){
            load(file.path(data.path,paste0(input$CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_hind_mn.Rdata")))
            if(plothist) load(file.path(data.path,paste0(input$CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_hist_mn.Rdata")))
            load(file.path(data.path,paste0(input$CMIPIN[c],"/allEBS_means/ACLIM_",typeIN,"_fut_mn.Rdata")))
            
            
            eval(parse(text = paste0("dhindIN <- ACLIM_",typeIN,"_hind")))
            if(plothist)
             eval(parse(text = paste0("dhistIN <- ACLIM_",typeIN,"_hist")))
            eval(parse(text = paste0("dfut <- ACLIM_",typeIN,"_fut")))
            plotvars   <- unique(dfut$var)
                dfut$GCM <- gsub("MIROC", "miroc",dfut$GCM)
                dfut$GCM <- gsub("GFDL", "gfdl",dfut$GCM)
                dfut$GCM <- gsub("CESM", "cesm",dfut$GCM)
            
                dfut <- dfut%>%rename(scen = RCP)
                
            gcms       <- unique(dfut$GCM)
            CMIPs      <- unique(dfut$CMIP)
            scens      <- unique(dfut$scen)
            basins    <-  unique(dfut$basin)
            
            
            #load(paste0("../Data/out/out/",input$CMIP[c],"/allEBS_means/ACLIM_annual_fut_mn.Rdata"))
            #plotvars   <- unique(ACLIM_annual_hind$var)
            if(typeIN == "monthly"){
              months <- unique(dhind$mo)
              seasons <- unique(dhind$season)}


               if(typeIN == "seasonal"){
              seasons <- unique(dhind$season)}

              if(typeIN == "weekly"){
              weeks <- unique(dhind$wk)
              months <- unique(dhind$mo)
              seasons <- unique(dhind$season)}


              if(input$removeyr1){
                yrin <- sort(unique(dfut$year))[1]
                dfut  <- dfut%>%dplyr::filter(year>yrin)
            }
            CMIP       <- input$CMIPIN[c]

            for(s in 1:length(scenIN)){
               
                if(s ==1){
                    dhind <- dhindIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hind",GCM ="hind")
                    if(plothist) dhist <- dhistIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hist")
                }
                if(s>1){
                    dhind <- rbind(dhind,dhindIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hind",GCM ="hind"))
                    if(plothist) dhist <- rbind(dhist,dhistIN%>%dplyr::mutate(scen = scenIN[s],gcmcmip="hist"))
                }
            }

            hind     <- dhind%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type)
            if(plothist) hist     <- dhist%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type)
            fut      <- dfut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type)
           
            plotdat    <- rbind(hind,fut)%>%mutate(bc = "raw")
            if(plothist) 
              plotdat    <- rbind(hind,hist,fut)%>%mutate(bc = "raw")
           
            hind_bc    <- dhind%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, jday,mnDate,mn_val, sim,gcmcmip,GCM,scen,sim_type)%>%mutate(bc="bias corrected")
            fut_bc     <- dfut%>%dplyr::filter(var ==plotvar,basin==plotbasin)%>%select(basin,year, jday,mnDate,val_biascorrected, sim,gcmcmip,GCM,scen,sim_type)
            fut_bc     <- fut_bc%>%mutate(bc="bias corrected")%>%rename(mn_val = val_biascorrected)
            fut_bc     <- rbind(hind_bc,fut_bc)

            plotdat          <- rbind(plotdat,fut_bc)
            plotdat$bc       <- factor(plotdat$bc, levels =c("raw","bias corrected"))
            plotdat$GCM_scen <- paste0(plotdat$GCM,"_",plotdat$scen) 

            plotdat$GCM_scen_sim <- paste0(plotdat$GCM,"_",plotdat$scen,"_",plotdat$sim_type) 
            plotdat$CMIP         <- input$CMIPIN[c]

            if(c ==1 ){
                plotdatout <- plotdat
            }else{
                plotdatout <- rbind(plotdatout,plotdat)
            }

        }
        gcmlist<- c("hind",GCMIN)
        if(plothist)
            gcmlist<- c("hind","hist",GCMIN)
        plotdatout <- plotdatout%>%filter(
            scen%in%scenIN,GCM%in%gcmlist,
            bc%in%bcIN,
            dplyr::between(jday, jday_rangeIN[1], jday_rangeIN[2]))
        # if(!plothist)
        #     plotdatout<- plotdatout%>%dplyr::filter(gcmcmip!="hist")
        # units <- plotdatout$units[1]

        nyrs <- length(unique(plotdatout$year))
        spanIN <- 5/nyrs

        return(list(dat=plotdatout,nyrs = nyrs, units = "",spanIN=spanIN, weeks=weeks,months=months,seasons=seasons,
            plotvar = plotvar,facet_row=facet_row,facet_col=facet_col,plotbasin=plotbasin))
    })
    
    output$matimage <- renderPlotly({

        pp<- ggplot(outdat()$dat)+
          
          geom_line(aes(x=mnDate,y=mn_val,color= GCM_scen,linetype = basin),alpha = 0.6,show.legend = FALSE)+
          geom_smooth(aes(x=mnDate,y=mn_val,color= GCM_scen,fill=GCM_scen_sim,linetype = basin),alpha=0.1,method="loess",formula='y ~ x',span = .5)+
          theme_minimal() + 
          labs(x="Date",
                 y=paste(outdat()$plotvar,"(",outdat()$units,")"),
                 subtitle = "",
                 legend = "",
                 title = paste(outdat()$plotvar,"(",outdat()$plotbasin,",",input$typeIN,")"))+
        scale_color_discrete()
        eval(parse(text = paste0("pp <-pp+facet_grid(",outdat()$facet_row,"~",outdat()$facet_col,")") ))
        pp
    })
    
})
# Run the application 
shinyApp(ui = ui, server = server)
