library(shiny)
library(plotly)
library(heatmaply)
alph <- c("A"=1, "C"=2, "G"=3, "T"=4, "I"=5, "U"=6, "N"=7)
seq <- factor(names(alph), unique(names(alph)))

# matsample <- cbind(c("A","A","A","T"),c("A","A","A","T"),c("A","A","A","G"))
NPSSP_mat <- rbind(
  data.frame(scenario = "NPSSP1",
             x = c(0,3,3,2,2,0,0),
             y = c(0,0,2,2,3,3,0)),
  data.frame(scenario = "NPSSP2",
             x = c(2,4,4,2,2),
             y = c(2,2,4,4,2)),
  data.frame(scenario = "NPSSP3",
             x = c(4,6,6,3,3,4,4),
             y = c(3,3,6,6,4,4,3)),
  data.frame(scenario = "NPSSP4",
             x = c(3,6,6,4,4,3,3),
             y = c(0,0,3,3,2,2,0)),
  data.frame(scenario = "NPSSP5",
             x = c(0,0,2,2,3,3,0),
             y = c(6,3,3,4,4,6,6))
  )
NPSSP_mat <- rbind(
  data.frame(scenario = "NPSSP1",
             x = c(0,3,3,1.5,1.5,0,0),
             y = c(0,0,1.5,1.5,3,3,0)),
  data.frame(scenario = "NPSSP2",
             x = c(1.5,4.5,4.5,1.5,1.5),
             y = c(1.5,1.5,4.5,4.5,1.5)),
  data.frame(scenario = "NPSSP3",
             x = c(4.5,6,6,3,3,4.5,4.5),
             y = c(3,3,6,6,4.5,4.5,3)),
  data.frame(scenario = "NPSSP4",
             x = c(3,6,6,4.5,4.5,3,3),
             y = c(0,0,3,3,1.5,1.5,0)),
  data.frame(scenario = "NPSSP5",
             x = c(0,0,1.5,1.5,3,3,0),
             y = c(6,3,3,4.5,4.5,6,6))
)
lab_data <-data.frame(
  x = c(1.5,3,4.5,4.5,1.5),
  y = c(1,3,5,1,5),
  label = c("NPSSP1","NPSSP2","NPSSP3",
         "NPSSP4","NPSSP5")
)

ui        <-  plotlyOutput("matimage", width = 800,height = 600)

server <- shinyServer(function(input, output, session) {
  
  output$matimage <- renderPlotly({
    ggplot(NPSSP_mat)+geom_polygon(aes(x=x,y=y,fill=scenario))+theme_minimal()+
      scale_fill_brewer() +
      geom_text(data = lab_data,aes(label = label, x = x, y = y),size=6) +
      labs(y="wellbeing & ecosystem based targets             Economic & single spp targets\n<-- (Low)  challenges to EBM / SES based goals (high) -->",
           x="<--- Low                                                                                High --->\nChallenges to Management effectiveness   ",
           title = "North Pacific Shared Socioeconomic Profiles")
    
  })
})


shinyApp(ui = ui, server = server)