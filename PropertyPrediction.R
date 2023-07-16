library(ggplot2)
library(dplyr)
library(caret)
#install.packages("nnet")
library(nnet)
library(corrplot)
library(rpart)
library(clusterGeneration)
library(devtools)
library(rpart.plot)
library(Metrics)
library(e1071)

data <- read.csv(file = 'melb_data.csv')
View(data)

#vemos las variables y los tipos de datos
sapply(data,"class")
summary(data)
str(data)

#miramos las valores nulos que hay en el dataset
sapply(data, function(x) sum(is.na(x)))

#nos damos cuenta que hay variables que contienen muchos NAN y otras variables que no nos sirven
cols_eliminadas=c("Address","BuildingArea","YearBuilt","CouncilArea","Suburb","SellerG")

#guardamos el dataset modificado
data = data[,!(names(data) %in% cols_eliminadas) ]

sapply(data, function(x) sum(is.na(x)))

#cambiamos los char en factor y luego a numericos
data$Type <- factor(data$Type,levels=c('h','u','t'),labels=c(1,2,3))
data$Type <- as.numeric(data$Type)
print(data$Type)

data$Method <- factor(data$Method,levels=c('PI','S','SA','SP','VB'),labels=c(1,2,3,4,5))
data$Method <- as.numeric(data$Method)
print(data$Method)

#data$Regionname <- as.factor(data$Regionname)



#nos queda por tratar los outliers de la variable Car(carspots)
summary(data$Car)
boxplot(data$Car, col = "pink", main="With Outliers") #con outliers

p75 = quantile(data$Car,0.75, na.rm = TRUE)
p25 = quantile(data$Car,0.25, na.rm = TRUE)
iqr = p75-p25
data$Car = ifelse(data$Car<p25-1.5*iqr,ave(data$Car, FUN = function(x) p25-1.5*iqr),data$Car)
data$Car = ifelse(data$Car>p75+1.5*iqr,ave(data$Car, FUN = function(x) p75+1.5*iqr),data$Car)


boxplot(data$Car, col ="lightblue", main="Without Outliers") #sin outliers
summary(data$Car)

#por ultimo los valores NaN los sustituimos por la media al ser numeros
data$Car = ifelse(is.na(data$Car),ave(data$Car, FUN = function(x) mean(x, na.rm=TRUE)),data$Car)
summary(data$Car)

#para limpiar un poco mas el dataset, limpiamos de outliers varibles que nos importan como Room y Price

#Room
summary(data$Rooms)

boxplot(data$Rooms, col = "pink", main="With Outliers") #con with Outliers

p75 = quantile(data$Rooms,0.75, na.rm = TRUE)
p25 = quantile(data$Rooms,0.25, na.rm = TRUE)
iqr = p75-p25

data$Rooms = ifelse(data$Rooms<p25-1.5*iqr,ave(data$Rooms, FUN = function(x) p25-1.5*iqr),data$Rooms)
data$Rooms = ifelse(data$Rooms>p75+1.5*iqr,ave(data$Rooms, FUN = function(x) p75+1.5*iqr),data$Rooms)

boxplot(data$Rooms, col ="lightblue", main="Without Outliers") #sin outliers

summary(data$Rooms)

#Price

summary(data$Price)
boxplot(data$Price, col = "pink", main="With Outliers") #con outliers

p75 = quantile(data$Price,0.75, na.rm = TRUE)
p25 = quantile(data$Price,0.25, na.rm = TRUE)
iqr = p75-p25

data$Price = ifelse(data$Price<p25-1.5*iqr,ave(data$Price, FUN = function(x) p25-1.5*iqr),data$Price)
data$Price = ifelse(data$Price>p75+1.5*iqr,ave(data$Price, FUN = function(x) p75+1.5*iqr),data$Price)

boxplot(data$Price, col ="lightblue", main="Without Outliers") #sin outliers

summary(data$Price)



data$Date <- as.Date(data$Date,format="%d/%m/%Y")
data$year <- as.numeric(format(data$Date,"%Y"))
data$month <- as.numeric(format(data$Date,"%m"))
data$day <- as.numeric(format(data$Date,"%d"))


cols_eliminadas=c("Date","Regionname")
data = data[,!(names(data) %in% cols_eliminadas) ]



#Correlaciones
#round(cor(x=data$Price,y=data$Rooms,method = "pearson"),3)
#round(cor(x=data$Rooms,y=data$Bathroom,method = "pearson"),3)
#round(cor(x=data$Price,y=data$Car,method = "pearson"),3)
str(data)
corrplot(cor(data[1:16]), method = "color", addCoef.col = "darkgray", order = "AOE")


#MODELO1
#aplicamos un modelo de clasificacion a una variable categorica
#el modelo se est� entrenando para predecir la variable "Type" (que puede tomar tres valores diferentes)
#dividimos el conjunto de datos en un conjunto de entrenamiento y un conjunto de validaci�n
set.seed(4000)
train <- sample_frac(data, .7)
test <-setdiff(data,train)


modelo <- multinom(Type ~ ., family=binomial(link='logit'), data=train)
summary(modelo)

prediccion <- predict(modelo, newdata = test)

test$Type <- factor(test$Type,levels=c(1,2,3))
#al utilizar un modelo de clasificacion, utilizamos confusionMatrix
#importante dar prioridad al kappa, medida mas precisa por concordancia con posibiladad al azar
confusionMatrix(prediccion,test$Type)

print(tasa_aciertos <- matriz_confusion$overall[1])




#MODELO2
#en este segundo modelo aplicamos la validacion cruzada e intentamos predecir la variable Type
#dividimos el conjunto de datos en un conjunto de entrenamiento y un conjunto de validaci�n
set.seed(3000)
split <- createDataPartition(data$Type, p = 0.7, list = FALSE)

X_train <- data[split,]
y_train <- data$Type[split]
X_val <- data[-split,]
y_val <- data$Type[-split]

# Establecemos el control de validaci�n cruzada con k = 10 folds
control <- trainControl(method = "cv", number = 10)

# Entrenamos el modelo utilizando la validaci�n cruzada
modelo2 <- multinom(Type~., family=binomial(link='logit'), data=X_train,trControl = control)

#modelo2 <- multinom(Type ~ Bathroom+Price+Bedroom2+Rooms+Car+Longtitude+Distance, family=binomial(link='logit'), data=X_train,trControl = control)
#si metemos variables conseguimos un peor resultado


# Realizamos predicciones en el conjunto de validaci�n
prediccion2 <- factor(predict(modelo2, newdata = X_val))
y_val <- factor(y_val, levels = levels(prediccion2))

# Creamos la matriz de confusi�n
#al utilizar un modelo de clasificacion, utilizamos confusionMatrix
print(matriz_confusion <- confusionMatrix(prediccion2, y_val))
print(tasa_aciertos <- matriz_confusion$overall[1])



#modelo3
#aplicamos modelo de regresion a una variable continua como Price
#dividimos el conjunto de datos en un conjunto de entrenamiento y un conjunto de validaci�n
split <- createDataPartition(data$Price, p = 0.7, list = FALSE)

X_train <- data[split,]
y_train <- data$Price[split]
X_val <- data[-split,]
y_val <- data$Price[-split]


# Creamos el modelo de regresi�n lineal
modelo3 <- lm(Price ~ ., data = X_train)
summary(modelo3)
# Hacemos predicciones en el conjunto de prueba
prediccion3 <- predict(modelo3, newdata = X_val)


#Para evaluar el rendimiento de un modelo de regresi�n no se puede usar matriz de confusion

# Obtenemos el resumen del modelo
model_summary <- summary(modelo3)

# Imprimimos el valor de R-squared
print(model_summary$r.squared)

# C�lculo del MAE
print(mae <- mae(prediccion3, y_val))
# C�lculo del MSE
print(mse <- mse(prediccion3, y_val))

#no podemos predecir bien con este modelo
#r2 tiene un valor aceptable pero mae y mse tienen valores muy altos
#MAE alto puede tener una mayor dispersi�n en sus errores
#significa que algunas predicciones estar�n muy lejos del valor real, mientras que otras estar�n m�s cerca.










