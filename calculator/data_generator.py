import pandas as pd
import numpy as np
from datetime import datetime, timedelta

def generate_sales_data(n_days=1000, start_date='2020-01-01'):
    """
    Generates synthetic sales data with trend and seasonality.
    """
    np.random.seed(42)
    dates = pd.date_range(start=start_date, periods=n_days, freq='D')
    
    # Trend component: linear increase
    trend = np.linspace(10, 100, n_days)
    
    # Seasonality component: yearly and weekly cycles
    # Yearly seasonality (sine wave)
    yearly_seasonality = 20 * np.sin(2 * np.pi * dates.dayofyear / 365.25)
    # Weekly seasonality (sine wave)
    weekly_seasonality = 5 * np.sin(2 * np.pi * dates.dayofweek / 7)
    
    # Noise
    noise = np.random.normal(0, 5, n_days)
    
    # Total sales
    sales = trend + yearly_seasonality + weekly_seasonality + noise
    # Ensure no negative sales
    sales = np.maximum(sales, 0)
    
    df = pd.DataFrame({
        'date': dates,
        'sales': sales
    })
    
    # Feature engineering for training
    df['day_of_year'] = df['date'].dt.dayofyear
    df['day_of_week'] = df['date'].dt.dayofweek
    df['month'] = df['date'].dt.month
    df['year'] = df['date'].dt.year
    
    return df

if __name__ == "__main__":
    df = generate_sales_data()
    df.to_csv('sales_data.csv', index=False)
    print("Generated sales_data.csv with 1000 days of data.")
