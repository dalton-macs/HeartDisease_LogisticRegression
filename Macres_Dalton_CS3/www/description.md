# Dataset Description and Model Overview

## Dataset Description

The [**Heart Disease**](https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction) dataset from kaggle combines five distinct datasets across 11 common features, making it the largest dataset available in the field with 918 unique observations. The five distinct datasets that are combined are as follows:

1. **Cleveland**
2. **Hungarian**
3. **Switzerland**
4. **Long Beach VA**
5. **Stalog (Heart) Data Set**

The 11 feature descriptions as well as the target, Heart Disease, description are shown below:

1. **Age**: age of the patient [years]
2. **Sex**: sex of the patient [M: Male, F: Female]
3. **ChestPainType**: chest pain type [TA: Typical Angina, ATA: Atypical Angina, NAP: Non-Anginal Pain, ASY: Asymptomatic]
4. **RestingBP**: resting blood pressure [mm Hg]
5. **Cholesterol**: serum cholesterol [mm/dl]
6. **FastingBS**: fasting blood sugar [1: if FastingBS > 120 mg/dl, 0: otherwise]
7. **RestingECG**: resting electrocardiogram results [Normal: Normal, ST: having ST-T wave abnormality (T wave inversions and/or ST elevation or depression of > 0.05 mV), LVH: showing probable or definite left ventricular hypertrophy by Estes' criteria]
8. **MaxHR**: maximum heart rate achieved [Numeric value between 60 and 202]
9. **ExerciseAngina**: exercise-induced angina [Y: Yes, N: No]
10. **Oldpeak**: oldpeak = ST [Numeric value measured in depression]
11. **ST_Slope**: the slope of the peak exercise ST segment [Up: upsloping, Flat: flat, Down: downsloping]
12. **HeartDisease**: output class [1: heart disease, 0: Normal]

In this RShiny app, the data has been split into a 70% train and 30% test/validation set using a random seed of 123. You can choose the features you would like to train and predict on, as well as the probability threshold to determine what constitutes an observation of Heart Disease vs. Normal.

## Model Overview

The target variable, Heart Disease, in the dataset is a binary 0 or 1 variable. This means a classification algorithm must be used to predict on the target variable. Due to the nature of this binary classification problem, logistic regression is used to model and predict on the data.

You can select up to 11 total features to train and predict the logistic regression model. However, visualizing results in over three dimensions is difficult. Principal component analysis (PCA) is used to map the features into two dimensions, representing the first two principal components, for visualization purposes.

### Logistic Regression

#### High Level Overview

At a high level, logistic regression uses the logistic, or sigmoid, function to model the binary target probability given a set of feature variables. The sigmoid function maps the inputs to a value between 0 and 1, representing the probability associated with the positive, or 1, class. A threshold can be applied to these values to then classify the input features to 0 or 1, representing the target variable. In this app, you can adjust the threshold to see how the model accuracy changes and see this visually through the PCA and 2D EDA plots.

When trained, this model learns the feature weights using maximum likelihood estimation (MLE). During prediction, the dot product is taken between the input features and learned weights. Then, the sigmoid function is applied to map the dot product output to values between 0 and 1.

#### Deeper Dive into the Statistics and Math

##### Coefficients

To first conceptualize, let us think of this classification problem in two dimensions. Let us say we want to predict heart disease given age. The y-axis, heart disease, only takes values of 0 and 1. The best shape to fit this data is an S-curve, formed by the sigmoid function, as shown below.

![Sigmoid Function](https://miro.medium.com/v2/resize:fit:460/1*klFuUpBGVAjTfpTak2HhUA.png)

The first step of logistic regression is converting the y access into the log of odds. Specifically, the log of odd of heart disease, represented by the equation **log(p/(1-p))**, also known as the **logit(p)** function. This maps the y-axis from 0 to 1 to negative infinity to positive infinity, which also transforms this S shape to a straight line. This line has a y-intercept and a slope, with units corresponding to the log odds. The slope is our weight coefficient for the age feature. The slope represents the log(odds of heart disease) increase for every increase of age (year).

For discrete or categorical variables, the method differs a little. Instead of a continuous variable on the x-axis, we have a categorical variable that takes specific values. Let us change our example to predicting heart disease based on sex. This means the x-axis takes values of 'M' and 'F', and the y-axis remains the same of values 1 and 0. The logit function is still used to map the y-axis to negative infinity to positive infinity. Now, instead of a line with an intercept and slope, we will have two horizontal lines representing the log(odds 'M') and log(odds 'F'). Then, the prediction equation becomes:

__heart disease = log(odds 'M')*B1 + |log((odds 'F)/(odds 'M'))|*B2__,

where **B1** corresponds to sex='M' and **B2** corresponds to sex='F'. The weights are the log(odds) terms before **B1** and **B2**. However, there are two caveats with discrete/categorical variables for machine learning algorithms that learn feature weights.

1. **Features must be numerical**: This means we must convert the categories to numbers.
2. **Proper encoding techniques**: The simplest way to convert categorical variables to numbers is to assign each unique category to a number. For our example this would mean 1 and 0 for 'M' and 'F' respectively. However, this implies a bias that 'M' is weighted higher than 'F'. This would make sense for ordinal variables, but for our case we do not want to introduce order to any categorical variable in the dataset. To solve this, we use one-hot encoding. This creates a new feature for every unique category of a categorical variable with the label 1 if the category is present and 0 otherwise. The sex variable would then become sex.M and sex.F, where sex.M is 1 if 'M' is present and 0 otherwise. Similarly, sex.F is 1 if 'F' is present and 0 otherwise. Below is an example of one-hot encoding:
![One-hot Encoding Example](https://datagy.io/wp-content/uploads/2022/01/One-Hot-Encoding-for-Scikit-Learn-in-Python-Explained-1024x576.png)

##### Maximum Likelihood Estimation

Using the age to predict heart disease example, the age variable is mapped to negative infinity to positive infinity using log odds. A candidate line is used with a slope and intercept. Each data point is then projected onto that candidate line, giving each datapoint a candidate log(odds) value. Then, the probabilities are calculated for each datapoint. Since **log(odds) = log(p/(1-p))**, we then get **p = e^(log(odds))/(1+e^(log(odds)))**. Now, the y-axis is mapped back to values between 0 and 1, and the datapoints reside on an S-shaped curve. The probabilities on the y-axis correspond to the probability of having heart disease. This means that datapoints with target equal to 0, or normal, have a probability belonging to 1, or heart disease, of p, and a probability of belonging to 0 of 1-p. To calculate the likelihood, the probabilities for each datapoint belonging to its respective class are multiplied together. For datapoints belonging to 1, p is used, and datapoints belonging to 0, 1-p is used.

Based on the first candidate line in log(odds) scale, a likelihood is calculated. Then the line is rotated in the log(odds) scale and the likelihood is once again calculated. This process is iteratively repeated until the maximum likelihood is found, hence maximum likelihood estimation. Algorithms such as gradient descent can be used to optimize this process of fitting the line. Below is an example of the line rotating in log(odds) scale and how it is mapped back to the p scale:

![MSE Mapping](https://miro.medium.com/v2/resize:fit:1400/1*Ba7LqnrsRnhjJyJl5LPW6Q.gif)

Once MLE is obtained, the weight vectors are set as the model attributes. During the prediction stage, the feature datapoints are projected to the fitted line using the weights and then mapped to a corresponding probability. Using two features, this line becomes a plane, and using n features, this line becomes a hyperplane.

In this app, a user can configure up to 11 features. As there are several categorical variables, choosing 11 features actually results in 20 features due to one-hot encoding. This means there are up to 20 weights that are learned in training and applied to the prediction.


### Principal Component Analysis

Principal component analysis (PCA) is a dimensionality reduction technique that can take a dataset of high dimensions and map it into lower dimensions while still containing most of the information, or variance. There are several steps involved in PCA:

1. **Standardization**: Center each variable around mean of 0 and variance of 1. **z = (value-mean)/(standard deviation)**
2. **Compute the covariance matrix**: The covariance matrix aims to find relationships/correlations between variables. It is an n-by-n square-symmetric matrix, where n is the number of dimensions. The diagonal components of this matrix will each be the variation of the initial variables. Below is an example of the covariance matrix for two and three dimensions of x, y, and z variables:

![Example Covariance Matrix](https://miro.medium.com/v2/resize:fit:1400/1*J6z7xcleH9wxHGGCLvDptg.jpeg)

3. **Find eigen vectors and values of covariance matrix**: Finding the eigen vectors and values of the covariance matrix will identify the principal components. Principal components represent the directions of the data with maximum variance. The first principal component has the most variance, the second principal component has the second most variance, and so on. In total, for an n dimensional dataset, there will be n principal components. The eigen vectors of the covariance matrix represent the direction of the principal components, and the eigen values represent the order of the principal components (highest value to lowest value). In the below example, the first principal component is the line that matches with the purple dashes. This is because most of the data variation is along that line. The second principal component is perpendicular, or orthogonal, to the first. Note that all principal components are orthogonal to each other.

![PCA Example](https://i.gifer.com/H7zW.gif)

4. **Choose the number of principal components**: Out of n principal components, choose p. This will be in the form of a matrix or vector. The data will be mapped to those p components in the next step. Ideally, take p components that represent 80-90% of the total variance. For visualization purposes, this may not always be possible.
5. **Map data to principal component axes**: Multiply the feature vector/matrix (principal components) by the original standardized data matrix to get the scaled down dataset.

[**HERE**](https://www.analyticsvidhya.com/blog/2021/09/pca-and-its-underlying-mathematical-principles/) is more information regarding the in-depth mathematical principles behind PCA.


