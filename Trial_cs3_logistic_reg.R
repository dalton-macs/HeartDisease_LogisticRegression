
library(caret)
library(qcc)
library(ggfortify)
library(ggplot2)
library(dplyr)

setwd("C:/Users/dalton/OneDrive - Worcester Polytechnic Institute (wpi.edu)/DS501/HW/Case Study 3")

# https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction
heart = read.csv('data/heart.csv')


# Check if any value is null (no nulls)
any(is.na(heart))

#Check unique values of categorical variables
unique(heart$Sex)
unique(heart$ChestPainType)
unique(heart$FastingBS)
unique(heart$RestingECG)
unique(heart$ST_Slope)

# One hot encode categorical columns
# One hot encode categorical columns
factor_cols = c("Sex", "ChestPainType", "RestingECG", "ExerciseAngina", "ST_Slope")
heart <- heart %>% mutate_at(vars(factor_cols), factor)

dmy = dummyVars(" ~ .", data = heart)
heart.onehot = data.frame(predict(dmy, newdata = heart))


# Split the data
set.seed(123)
intrain = createDataPartition(y = heart.onehot$HeartDisease, p= 0.7, list = FALSE)
training = heart.onehot[intrain,]
testing = heart.onehot[-intrain,]

dim(training);
dim(testing);

# Convert the target var to factor for classification rather than regression
training[['HeartDisease']] = factor(training[['HeartDisease']])
testing[['HeartDisease']] = factor(testing[['HeartDisease']])

# train the linear SVM with cross val
logistic_reg <- glm(HeartDisease ~., data = training, family = 'binomial')
summary(logistic_reg)

# Predict using trained SVM
test_pred_prob <- predict(logistic_reg, newdata = testing %>% select(-HeartDisease), type = "response")
test_pred_class = ifelse(test_pred_prob>0.61,1,0)

testing_meta = testing %>%
  mutate(prediction = factor(test_pred_class)) %>%
  mutate(prediction_str = ifelse(prediction==1, "1", "0")) %>%
  mutate(correct_meta = ifelse(HeartDisease == prediction, T, F)) %>%
  mutate(correct = as.factor(as.character(correct_meta)))%>%
  mutate(dot_color = ifelse(HeartDisease==1, "lightblue", "darkblue")) %>%
  mutate(outline_color = ifelse(correct==T, dot_color, "red")) 
# %>%
#   mutate(shape_col = ifelse(
#     prediction==1 & HeartDisease ==1, 'Correctly Predicted Heart Disease',), ifelse(
#       prediction == 1 & HeartDisease == 0, 'Incorrectly Predicted Heart Disease', ifelse(
#         prediction == 0 & HeartDisease == 1, 'Incorrectly Predicted Normal'
#       )
#     ))

confusionMatrix(table(test_pred_class, testing$HeartDisease))

testing 


# PCA for 2d visualization
testingMC = apply(testing %>% select(-HeartDisease), 2, function(y) y - mean(y))
head(testingMC)

pca = prcomp(testing %>% select(-HeartDisease), center=T, scale.=T)
str(pca)

pcs = data.frame(pca$x)
str(pcs)

cov = round(pca$sdev^2/sum(pca$sdev^2)*100, 2)
cov = data.frame(c(1:20),cov)
names(cov)[1] = 'PCs'
names(cov)[2] = 'Variance'
cov
sum(cov$Variance)

PCA = pca$sdev^2
names(PCA) = paste0('PC', cov$PCs)
qcc::pareto.chart(PCA)

autoplot(pca, data = testing, color = 'HeartDisease')

the_plot = autoplot(pca, data = testing_meta) +
  geom_point(aes(fill=prediction_str), color= testing_meta$outline_color,pch=21, size=3) + 
  scale_fill_manual(values = c("1" = "lightblue", "0" = "darkblue"))

the_plot = autoplot(pca, data = testing_meta) +
  geom_point(aes(fill=outline_color, shape = correct, color = prediction_str), size = 3) + 
  scale_color_manual(values = c("1" = "lightblue", "0" = "darkblue")) +
  scale_fill_manual(values = c("lightblue" = "lightblue", "darkblue" = "darkblue", "red" = "red")) + 
  scale_shape_manual(values = c(24, 19))


the_plot
 