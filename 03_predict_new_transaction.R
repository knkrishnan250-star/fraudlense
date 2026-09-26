# Predict a new transaction using the Random Forest model

library(randomForest)

data <- read.csv("data/transactions.csv")
data$fraud_label <- factor(
  data$fraud,
  levels = c(0, 1),
  labels = c("Normal", "Fraud")
)
data$transaction_type <- factor(data$transaction_type)

model_data <- data[, c(
  "amount", "transaction_hour", "international",
  "new_device", "location_changed", "previous_fraud",
  "transaction_type", "fraud_label"
)]

set.seed(42)
idx <- sample(seq_len(nrow(model_data)), size = 0.8 * nrow(model_data))
train <- model_data[idx, ]

rf_model <- randomForest(
  fraud_label ~ .,
  data = train,
  ntree = 200,
  importance = TRUE
)

# Example transaction
new_transaction <- data.frame(
  amount = 85000,
  transaction_hour = 2,
  international = 1,
  new_device = 1,
  location_changed = 1,
  previous_fraud = 0,
  transaction_type = factor("Bank Transfer",
                            levels = levels(data$transaction_type))
)

prediction <- predict(rf_model, new_transaction, type = "response")
probability <- predict(rf_model, new_transaction, type = "prob")

cat("\n====================================\n")
cat("           FRAUDLENS RESULT\n")
cat("====================================\n")
cat("Amount          : ₹", format(new_transaction$amount, big.mark = ","), "\n")
cat("Hour            :", new_transaction$transaction_hour, "\n")
cat("International   :", ifelse(new_transaction$international, "YES", "NO"), "\n")
cat("New Device      :", ifelse(new_transaction$new_device, "YES", "NO"), "\n")
cat("Location Changed:", ifelse(new_transaction$location_changed, "YES", "NO"), "\n")
cat("Previous Fraud  :", ifelse(new_transaction$previous_fraud, "YES", "NO"), "\n")
cat("Transaction Type:", as.character(new_transaction$transaction_type), "\n")
cat("------------------------------------\n")
cat("Prediction      :", as.character(prediction), "\n")
cat("Fraud Probability:", round(probability[1, "Fraud"] * 100, 2), "%\n")
cat("====================================\n")
