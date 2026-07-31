import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error
import joblib
import os

def train_model(data_path='sales_data.csv', model_path='sales_model.joblib'):
    # Load data
    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Data file {data_path} not found. Run data_generator.py first.")
    
    df = pd.read_csv(data_path)
    df['date'] = pd.to_datetime(df['date'])
    
    # Feature engineering
    df['day_of_year'] = df['date'].dt.dayofyear
    df['day_of_week'] = df['date'].dt.dayofweek
    df['month'] = df['date'].dt.month
    df['year'] = df['date'].dt.year
    
    # For seasonality, sine/cosine transformations are often better
    df['day_of_year_sin'] = np.sin(2 * np.pi * df['day_of_year'] / 365.25)
    df['day_of_year_cos'] = np.cos(2 * np.pi * df['day_of_year'] / 365.25)
    df['day_of_week_sin'] = np.sin(2 * np.pi * df['day_of_week'] / 7)
    df['day_of_week_cos'] = np.cos(2 * np.pi * df['day_of_week'] / 7)

    # Features and Target
    X = df[['day_of_year', 'day_of_week', 'month', 'year', 
            'day_of_year_sin', 'day_of_year_cos', 
            'day_of_week_sin', 'day_of_week_cos']]
    y = df['sales']
    
    # Split data (using time-based split for time series)
    split_idx = int(len(df) * 0.8)
    X_train, X_test = X.iloc[:split_idx], X.iloc[split_idx:]
    y_train, y_test = y.iloc[:split_idx], y.iloc[split_idx:]
    
    # Train model
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    mae = mean_absolute_error(y_test, y_pred)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    
    print(f"Model trained successfully.")
    print(f"Mean Absolute Error (MAE): {mae:.2f}")
    print(f"Root Mean Squared Error (RMSE): {rmse:.2f}")
    
    # Save model
    joblib.dump(model, model_path)
    print(f"Model saved to {model_path}")
    
    return model, mae, rmse

if __name__ == "__main__":
    train_model()
