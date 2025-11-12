# Food Delivery Time Prediction

This project implements a machine learning pipeline to predict food delivery times using XGBoost and LightGBM models. The pipeline includes data preprocessing, feature engineering, hyperparameter tuning, and model evaluation.

## Features

- Data preprocessing and feature engineering for food delivery data
- Hyperparameter tuning using RandomizedSearchCV
- Comparison of XGBoost and LightGBM models
- Model evaluation with metrics like MAE, RMSE, and R²

## Dataset

The dataset `food-delivery-times.csv` contains information about food deliveries, including features like distance, weather conditions, traffic, and actual delivery times.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/DrJohnWagner/food-delivery.git
   cd food-delivery
   ```
2. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

   If `requirements.txt` is not present, install the following packages:

   - pandas
   - numpy
   - scikit-learn
   - xgboost
   - lightgbm
   - jupyter

## Usage

1. Open the Jupyter notebook:

   ```bash
   jupyter notebook notebook.ipynb
   ```
2. Run the cells in order to preprocess data, train models, and evaluate performance.
3. To run tests:

   ```bash
   pytest test_notebook.py -v
   ```

## Project Structure

- `notebook.ipynb`: Main Jupyter notebook with the ML pipeline
- `test_notebook.py`: Test script to validate notebook functionality
- `input_data/food-delivery-times.csv`: Dataset
- `Makefile`: Build automation (if applicable)

## Contributing

No contributions are being sought at this time.

## License

This project is licensed under the MIT License.
