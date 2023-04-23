
library(caret)
library(ggfortify)
library(dplyr)
library(ggplot2)
library(stringr)
library(plotly)

heart_train = read.csv('data/heart_training.csv')
heart_test = read.csv('data/heart_testing.csv')
factor_cols_master <<- c("Sex", "ChestPainType", "RestingECG", "ExerciseAngina", "ST_Slope")


one_hot_data = function(df) {
  
  factor_cols = intersect(colnames(df), factor_cols_master)
  df_factor = df %>% mutate_at(vars(factor_cols), factor)
  
  dmy = dummyVars(" ~ .", data = df_factor)
  df.onehot = data.frame(predict(dmy, newdata = df_factor))
  
  df.onehot[['HeartDisease']] = factor(df.onehot[['HeartDisease']])
  
  return(df.onehot)
  
}


train_model = function(df) {
  
  df.onehot = one_hot_data(df)
  
  logistic_reg = glm(HeartDisease ~., data = df.onehot, family = 'binomial')
  
  return(logistic_reg)
  
}


predict_model = function(df, trained_model) {
  
  df.onehot = one_hot_data(df)
  
  pred_prob <- predict(trained_model, newdata = df.onehot %>% select(-HeartDisease), type = "response")
  
  return(pred_prob)
  
}


populate_predict_df = function(df, pred_prob, thresh) {
  
  pred_class = ifelse(pred_prob>thresh,1,0)
  
  meta_df = df %>%
    mutate(prediction_model = factor(pred_class)) %>%
    mutate(Prediction = ifelse(prediction_model==1, "Heart Disease", "Normal")) %>%
    mutate(correct = ifelse(HeartDisease == prediction_model, T, F)) %>%
    mutate(dot_color = ifelse(prediction_model==1, "lightblue", "darkblue")) %>%
    mutate(outline_color = ifelse(correct==T, dot_color, "red"))
  
  
  return(meta_df)
  
}


fix_plotly_legend = function(myplot) {
  
  # Removes weird legend tuple format
  for (i in 1:length(myplot$x$data)){
    if (!is.null(myplot$x$data[[i]]$name)){
      myplot$x$data[[i]]$name =  gsub("\\(","",str_split(myplot$x$data[[i]]$name,",")[[1]][1])
    }
  }
  
  return(myplot)
  
}


make_pca_plot = function(feature_df, meta_df) {
  
  pca = prcomp(feature_df %>% select(-HeartDisease), center=T, scale.=T)
  
  the_plot = ggplotly(autoplot(pca, data = meta_df) +
    geom_point(aes(fill=Prediction, text = paste("Correct Prediction:", correct)), 
               color= meta_df$outline_color,pch=21, size=3) + 
    scale_fill_manual(values = c("Heart Disease" = "lightblue", "Normal" = "darkblue"))+
    scale_color_manual(values = meta_df$outline_color))
  
  myplot = fix_plotly_legend(the_plot)
  
  return(myplot)
  
}


make_eda_scatter = function(orig_df, meta_df, x_var, y_var) {
  
  x_str = x_var[[1]]
  y_str = y_var[[1]]
  x = meta_df[, x_var]
  y = meta_df[, y_var]
  
  the_plot = ggplotly(ggplot(data = meta_df, aes(x, y)) + 
    geom_point(aes(fill = Prediction, text = paste("", x_str, ":", x, "\n",y_str, ":", y, 
                                                   "\n Prediction:", Prediction, 
                                                   "\n Correct Prediction:", correct)
      ), 
               color = meta_df$outline_color, pch = 21, size = 3) +
    scale_fill_manual(values = c("Heart Disease" = "lightblue", "Normal" = "darkblue"))+
    scale_color_manual(values = meta_df$outline_color) +
    xlab(x_str) + ylab(y_str), tooltip = "text")
  
  myplot = fix_plotly_legend(the_plot)
  
  return(myplot)
  
}
