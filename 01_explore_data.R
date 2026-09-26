data <- read.csv("data/transactions.csv")

cat("Dataset dimensions:", nrow(data), "rows x", ncol(data), "columns\n\n")
print(head(data))
cat("\nFraud distribution:\n")
print(table(data$fraud))
cat("\nFraud percentage:\n")
print(prop.table(table(data$fraud)) * 100)

data$fraud_label <- factor(data$fraud, levels = c(0, 1),
                           labels = c("Normal", "Fraud"))

print(summary(data$amount))
print(table(data$transaction_type))
