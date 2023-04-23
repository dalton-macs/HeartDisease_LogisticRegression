library(plotly)
library(markdown)
library(shinythemes)

dashboard_panel = tabPanel(
  icon("home"),
  
  sidebarPanel(
    
    width = 3,
    
    selectInput(
      inputId = "features", 
      label = "Select Model Features to Train and Test on:",
      choices = colnames(heart_train)[!colnames(heart_train) %in% c("HeartDisease")],
      selected = colnames(heart_train)[!colnames(heart_train) %in% c("HeartDisease")],
      multiple = TRUE
    ),
    
    
    sliderInput(
      inputId = "thresh",
      label = "Select Model Threshold",
      value = 0.5,
      min = 0,
      max = 1,
      step = 0.01
  
    )
    
  ),
  
  mainPanel(
    h1(strong("Model Performance and Exploratory Data Analysis"), align = "center"),
    br(),
    h3(strong("Model Accuracy:")),
    htmlOutput("model_accuracy"),
    br(),
    h3(strong("PCA Plot Using Selected Features"), align = "left"),
    p(strong("Red outlines means the datapoint was misclassified")),
    plotlyOutput("PCAPlot"),
    br(),
    h3(strong("2-Dimensional Exploratory Data Analysis"), align = "center"),
    br(),
    fluidRow(
      column(
        width = 6,
        fluidRow(
          column(
            width = 4,
            selectInput(
              inputId = 'x1',
              label = "Select X Variable",
              choices = NULL,
              selected = NULL
              
            )
            ),
          column(
            width = 4,
            selectInput(
              inputId = 'y1',
              label = "Select Y Variable",
              choices = NULL,
              selected = NULL
              
            )
          ),
       ),
       plotlyOutput("scatter1")
       ),
      
      column(
        width = 6,
        fluidRow(
          column(
            width = 4,
            selectInput(
              inputId = 'x2',
              label = "Select X Variable",
              choices = NULL,
              selected = NULL
              
            )
          ),
          column(
            width = 4,
            selectInput(
              inputId = 'y2',
              label = "Select Y Variable",
              choices = NULL,
              selected = NULL
              
            )
          ),
        ),
        plotlyOutput("scatter2")
      )

    ),
    
  ),
  
)

tab2 = tabPanel("Description",
                # Display the contents of the markdown file as HTML
                HTML(markdownToHTML(readLines("www/description.md"), fragment.only = TRUE)))

tab3 = tabPanel("Motivations and Methods",
                # Display the contents of the markdown file as HTML
                HTML(markdownToHTML(readLines("www/motivations.md"), fragment.only = TRUE)))



ui = shinyUI(fluidPage(theme = shinytheme("cerulean"),
                       titlePanel("Using Logistic Regression to Predict Heart Disease"),
                       navbarPage("Let's get started",
                                  dashboard_panel, tab2, tab3)
)
)
