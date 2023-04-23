library(ggplot2)
library(shiny)
library(plotly)
source("global.R")

server = function(input, output, session) {

  continuous_columns = c("Age", "RestingBP", "Cholesterol", "MaxHR", "Oldpeak")
  
  observe({updateSelectInput(session, 'x1', choices = intersect(input$features, continuous_columns))})
  observe({updateSelectInput(session, 'y1', choices = setdiff(intersect(input$features, continuous_columns), input$x1))})
  
  observe({updateSelectInput(session, 'x2', choices = intersect(input$features, continuous_columns))})
  observe({updateSelectInput(session, 'y2', choices = setdiff(intersect(input$features, continuous_columns), input$x2))})
  
  train = reactive({
    validate(need(length(input$features)>=2, "Please select at least two features."))
    
    train_features = heart_train[, c(input$features, "HeartDisease"), drop = F]
    return(train_features)

    })

  test = reactive({
    validate(need(length(input$features)>=2, "Please select at least two features."))
    
    test_features = heart_test[, c(input$features, "HeartDisease"), drop = F]
    return(test_features)

    })

  
  trained_model = reactive({train_model(train())})
  
  predicted_probability = reactive({predict_model(test(), trained_model())})
  
  thresh = reactive(input$thresh)
  
  test_meta = reactive({populate_predict_df(test(), predicted_probability(), input$thresh)})
  
  
  
  output$model_accuracy = renderUI({HTML(paste0("<b>", round(sum(test_meta()$correct)/length(test_meta()$correct), 4), "</b>"))})
  
  output$PCAPlot = renderPlotly({make_pca_plot(one_hot_data(test()), test_meta())})
  
  output$scatter1 = renderPlotly({make_eda_scatter(test(), test_meta(), input$x1, input$y1)})
  output$scatter2 = renderPlotly({make_eda_scatter(test(), test_meta(), input$x2, input$y2)})
  
}