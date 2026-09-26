library(caret)
library(rpart)
library(rpart.plot)
library(randomForest)
library(e1071)
library(class)

data <- read.csv("data/transactions.csv")

data$fraud_label <- factor(
  data$fraud,
  levels = c(0, 1),
  labels = c("Normal", "Fraud")
)

data$transaction_type <- factor(data$transaction_type)

model_data <- data[, c(
  "amount",
  "transaction_hour",
  "international",
  "new_device",
  "location_changed",
  "previous_fraud",
  "transaction_type",
  "fraud_label"
)]

set.seed(42)

idx <- createDataPartition(
  model_data$fraud_label,
  p = 0.80,
  list = FALSE
)

train <- model_data[idx, ]
test <- model_data[-idx, ]

cat("\nORIGINAL TRAINING DISTRIBUTION\n")
print(table(train$fraud_label))

# Balance ONLY the training data
balanced_train <- upSample(
  x = train[, setdiff(names(train), "fraud_label")],
  y = train$fraud_label
)

names(balanced_train)[ncol(balanced_train)] <- "fraud_label"

cat("\nBALANCED TRAINING DISTRIBUTION\n")
print(table(balanced_train$fraud_label))

# -----------------------------
# Logistic Regression
# -----------------------------

log_model <- glm(
  fraud_label ~ .,
  data = balanced_train,
  family = binomial
)

log_prob <- predict(
  log_model,
  test,
  type = "response"
)

log_pred <- factor(
  ifelse(log_prob >= 0.5, "Fraud", "Normal"),
  levels = c("Normal", "Fraud")
)

# -----------------------------
# Decision Tree
# -----------------------------

tree_model <- rpart(
  fraud_label ~ .,
  data = balanced_train,
  method = "class"
)

tree_pred <- predict(
  tree_model,
  test,
  type = "class"
)

# -----------------------------
# Random Forest
# -----------------------------

set.seed(42)

rf_model <- randomForest(
  fraud_label ~ .,
  data = balanced_train,
  ntree = 200,
  importance = TRUE
)

rf_pred <- predict(
  rf_model,
  test
)

# -----------------------------
# SVM
# -----------------------------

set.seed(42)

svm_model <- svm(
  fraud_label ~ .,
  data = balanced_train,
  kernel = "radial",
  probability = TRUE
)

svm_pred <- predict(
  svm_model,
  test
)

# -----------------------------
# KNN
# -----------------------------

x_train <- balanced_train[
  ,
  setdiff(names(balanced_train), "fraud_label")
]

x_test <- test[
  ,
  setdiff(names(test), "fraud_label")
]

dummy <- dummyVars(~ ., data = x_train)

x_train_num <- predict(dummy, x_train)
x_test_num <- predict(dummy, x_test)

pre <- preProcess(
  x_train_num,
  method = c("center", "scale")
)

x_train_scaled <- predict(pre, x_train_num)
x_test_scaled <- predict(pre, x_test_num)

knn_pred <- knn(
  train = x_train_scaled,
  test = x_test_scaled,
  cl = balanced_train$fraud_label,
  k = 15
)

# -----------------------------
# Evaluation
# -----------------------------

evaluate <- function(actual, predicted, model_name) {

  cm <- confusionMatrix(
    predicted,
    actual,
    positive = "Fraud"
  )

  data.frame(
    Model = model_name,
    Accuracy = unname(cm$overall["Accuracy"]),
    Precision = unname(cm$byClass["Precision"]),
    Recall = unname(cm$byClass["Recall"]),
    F1 = unname(cm$byClass["F1"]),
    TP = cm$table["Fraud", "Fraud"],
    FP = cm$table["Fraud", "Normal"],
    FN = cm$table["Normal", "Fraud"],
    TN = cm$table["Normal", "Normal"]
  )
}

results <- rbind(

  evaluate(
    test$fraud_label,
    log_pred,
    "Logistic Regression"
  ),

  evaluate(
    test$fraud_label,
    tree_pred,
    "Decision Tree"
  ),

  evaluate(
    test$fraud_label,
    rf_pred,
    "Random Forest"
  ),

  evaluate(
    test$fraud_label,
    svm_pred,
    "SVM"
  ),

  evaluate(
    test$fraud_label,
    knn_pred,
    "KNN"
  )
)

dir.create(
  "results",
  showWarnings = FALSE
)

write.csv(
  results,
  "results/model_metrics_v2.csv",
  row.names = FALSE
)

cat("\n==============================\n")
cat("MODEL COMPARISON - V2\n")
cat("==============================\n\n")

print(results)

# Random Forest confusion matrix

cat("\n==============================\n")
cat("RANDOM FOREST CONFUSION MATRIX\n")
cat("==============================\n\n")

rf_cm <- confusionMatrix(
  rf_pred,
  test$fraud_label,
  positive = "Fraud"
)

print(rf_cm)