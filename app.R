library(shiny)
library(dplyr)
library(ggplot2)
library(DescTools)

shinyApp(
  ui = fluidPage(class = "text-center",
                 mainPanel(
                   textAreaInput("inputcode", "Input area (multiple prints possible but only one plot)", 
                                 "iris %>% filter(Sepal.Length>7)
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width)) + geom_point()", width="600px"), 
                   h4("Results Generated"), 
                   verbatimTextOutput("ConsoleResults"),
                   plotOutput("visualisation")
                 )
  )
  ,
  server = function(input, output){
    
    shinyEnv <- environment() 
    output$displayData <- renderPrint({ head(iris) })  # prepare head(mtcars) for display on the UI
    
    # create codeInput variable to capture what the user entered; store results to codeResults
    codeInput <- reactive({ input$inputcode })
    
    
    codeResults <- renderPrint({
      #Just simulating assignment not being printed by console, but in the future a better implementation is necessary
      for (i in 1:length(parse(text=codeInput()))) {
        if (parse(text=codeInput())[i] %like% "%<-%") {
          eval(parse(text=codeInput())[i], envir=shinyEnv)
        } else {
          print(eval(parse(text=codeInput())[i], envir=shinyEnv))      
        }       
      }
      
    })
    
    output$ConsoleResults <- codeResults
    output$visualisation <- renderPlot(codeResults())
    
  },
  options = list(height = 900)
)