# 🔐 FraudLens

### Explainable Machine Learning for Transaction Fraud Detection

FraudLens is an educational machine-learning project that simulates a banking fraud-detection workflow using synthetic transaction data.

The project demonstrates how multiple classification algorithms can be trained, compared, evaluated, and used to score a new transaction.

> **Important:** The dataset is synthetic and does not represent real banking data.

## 🎯 Problem

A bank receives thousands of transactions and wants to identify transactions that may be fraudulent.

Given transaction characteristics such as:

- Transaction amount
- Transaction hour
- International transaction
- New device
- Location change
- Previous fraud history
- Transaction type

the model predicts:

**Normal** or **Fraud**

## 🧠 Machine Learning Models

FraudLens compares:

- Logistic Regression
- Decision Tree
- Random Forest
- Support Vector Machine (SVM)
- K-Nearest Neighbors (KNN)

## 📊 Evaluation

Because fraud is a minority class, accuracy alone is not enough.

FraudLens reports:

- Accuracy
- Precision
- Recall
- F1-score
- True Positives
- False Positives
- False Negatives
- True Negatives

### Why these metrics matter

**Precision:** Of transactions flagged as fraud, how many were actually fraud?

**Recall:** Of all actual fraudulent transactions, how many did the model detect?

**F1-score:** A balance between precision and recall.

**Accuracy:** How many predictions were correct overall?

## 🔄 ML Pipeline

```text
Synthetic Transaction Data
            ↓
      Data Exploration
            ↓
       Preprocessing
            ↓
       Train/Test Split
            ↓
       Model Training
            ↓
         Prediction
            ↓
     Confusion Matrix
            ↓
Accuracy / Precision / Recall / F1
            ↓
       Model Comparison
```

## 📁 Project Structure

```text
FraudLens/
├── data/
│   └── transactions.csv
├── R/
│   ├── 01_explore_data.R
│   ├── 02_train_models.R
│   └── 03_predict_new_transaction.R
├── plots/
├── results/
├── README.md
└── LICENSE
```

## 🚀 Running the Project

Open RStudio in the project folder.

Install dependencies once:

```r
install.packages(c(
  "caret",
  "rpart",
  "rpart.plot",
  "randomForest",
  "e1071"
))
```

Run:

```r
source("R/01_explore_data.R")
source("R/02_train_models.R")
source("R/03_predict_new_transaction.R")
```

The model comparison will be saved to:

```text
results/model_metrics.csv
```

and visualizations will be saved in:

```text
plots/
```

## ⚠️ Educational Scope

This project is designed to demonstrate machine-learning concepts.

Real banking fraud systems require substantially more data, continuous monitoring, advanced feature engineering, cost-sensitive learning, security controls, human review, and regulatory/privacy considerations.

## 🛠️ Tech Stack

- R
- caret
- rpart
- randomForest
- e1071
- CSV
- Machine Learning
- Classification
