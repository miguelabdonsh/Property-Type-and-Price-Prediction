# Property-Type-and-Price-Prediction

This repository contains an R script that performs preprocessing and analysis on a real estate dataset. The script first cleans the data, removing null and outliers, and then converts certain categorical attributes to numeric.

From these processed features, classification and regression models are implemented and evaluated. The goal of the model is to predict the type of property (houses, apartments, etc.) and its price, based on various characteristics, such as the number of bedrooms, bathrooms, and parking spaces.

## Code
The R code performs the following main tasks:

1. **Loading and preparing data**: The data is read, unnecessary columns are removed, and null values are handled.

2. **Conversion of categorical variables to numeric**: Some categorical variables such as 'Type' and 'Method' are converted to numeric format for use in machine learning models.

3. **Treatment of outliers**: Outliers are identified and treated in the variables 'Car', 'Rooms' and 'Price' using the quartile method.

4. **Creation and evaluation of machine learning models**: Three machine learning models are implemented (two classification and one regression), which are trained and evaluated. The classification models predict the type of property, while the regression model predicts the price of the property.

## Requirements
The code is implemented in R and uses the following libraries:

-ggplot2
-dplyr
- caret
-nnet
-corrplot
-rpart
-clusterGeneration
-devtools
-rpart.plot
-Metrics
-e1071

The data file 'melb_data.csv' must be available in the same directory as the R script for it to run.
