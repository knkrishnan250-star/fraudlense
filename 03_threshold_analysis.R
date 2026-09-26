library(caret)

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

balanced_train <- upSample(
  x = train[, setdiff(names(train), "fraud_label")],
  y = train$fraud_label
)

names(balanced_train)[ncol(balanced_train)] <- "fraud_label"

log_model <- glm(
  fraud_label ~ .,
  data = balanced_train,
  family = binomial
)

probabilities <- predict(
  log_model,
  test,
  type = "response"
)

thresholds <- seq(0.10, 0.90, by = 0.10)

threshold_results <- data.frame()

for (threshold in thresholds) {

  predictions <- factor(
    ifelse(
      probabilities >= threshold,
      "Fraud",
      "Normal"
    ),
    levels = c("Normal", "Fraud")
  )

  cm <- confusionMatrix(
    predictions,
    test$fraud_label,
    positive = "Fraud"
  )

  row <- data.frame(
    Threshold = threshold,
    Accuracy = unname(cm$overall["Accuracy"]),
    Precision = unname(cm$byClass["Precision"]),
    Recall = unname(cm$byClass["Recall"]),
    F1 = unname(cm$byClass["F1"])
  )

  threshold_results <- rbind(
    threshold_results,
    row
  )
}

print(threshold_results)

dir.create(
  "results",
  showWarnings = FALSE
)

write.csv(
  threshold_results,
  "results/threshold_metrics.csv",
  row.names = FALSE
)

dir.create(
  "plots",
  showWarnings = FALSE
)

png(
  "plots/threshold_analysis.png",
  width = 1000,
  height = 700
)

matplot(
  threshold_results$Threshold,
  threshold_results[, c(
    "Accuracy",
    "Precision",
    "Recall",
    "F1"
  )],
  type = "b",
  pch = 19,
  lty = 1,
  xlab = "Classification Threshold",
  ylab = "Score",
  ylim = c(0, 1),
  main = "FraudLens: Threshold Analysis"
)

legend(
  "bottomleft",
  legend = c(
    "Accuracy",
    "Precision",
    "Recall",
    "F1"
  ),
  lty = 1,
  pch = 19,
  bty = "n"
)

dev.off()