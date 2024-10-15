import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import GridSearchCV
import os
from joblib import dump

def train_and_save_model(prefix, model_details, save_dir, cv=5, scoring='precision', task='classification'):
    # Determine model and parameter grid
    model = model_details['model']
    param_grid = model_details['param_grid']

    # Ensures that the directory exists
    os.makedirs(f'inst/extdata/{save_dir}', exist_ok=True)
    
    # Load the training dataset
    data = pd.read_csv(f'inst/extdata/modeval_data_set/{prefix}_train.csv')

    # Separate features and target
    X = data.drop(columns=['outcome', 'id'])  # Exclude the identifier column "id" and the target "outcome"
    y = data['outcome'].astype(float if task == 'regression' else int)

    # Standardize features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Save the scaler for future use
    scaler_path = f'inst/extdata/{save_dir}/{prefix}_scaler.joblib'
    dump(scaler, scaler_path)
    print(f"Scaler saved at {scaler_path}")

    # Train the model with cross-validation
    grid_search = GridSearchCV(estimator=model, param_grid=param_grid, cv=cv, scoring=scoring, n_jobs=-1)
    grid_search.fit(X_scaled, y)

    # Best model from grid search
    best_model = grid_search.best_estimator_

    # Save the trained model
    model_path = f'inst/extdata/{save_dir}/{prefix}_best_model.joblib'
    dump(best_model, model_path)
    print(f"Model saved at {model_path}")



import pandas as pd
from joblib import load
import os

def load_and_predict(prefix, dataset, prediction_type='label', save_dir='default'):
    # Load the scaler and model
    scaler = load(f'inst/extdata/{save_dir}/{prefix}_scaler.joblib')
    best_model = load(f'inst/extdata/{save_dir}/{prefix}_best_model.joblib')
    
    # Load the new dataset for prediction
    X_new = pd.read_csv(f'inst/extdata/modeval_data_set/{prefix}_{dataset}.csv')
    
    # Assume the new data also excludes 'id' and 'outcome' columns
    X_new = X_new.drop(columns=['id', 'outcome'], errors='ignore')
    
    # Standardize the new dataset using the same scaler
    X_new_scaled = scaler.transform(X_new)

    # Determine type of prediction and process accordingly
    if prediction_type == 'label':
        # Make predictions
        predictions = best_model.predict(X_new_scaled)
        # Convert predictions to a DataFrame
        predictions_df = pd.DataFrame(predictions, columns=['prediction'])
        # Define file suffix and DataFrame to save
        file_suffix = '_predictions.csv'
        result_df = predictions_df
    elif prediction_type == 'probability':
        # Make probability predictions
        if hasattr(best_model, 'predict_proba'):
            probabilities = best_model.predict_proba(X_new_scaled)[:, 1]  # Assumes binary classification
            result_df = pd.DataFrame(probabilities, columns=['predicted_probability'])
            file_suffix = '_prob.csv'
        else:
            raise ValueError("This model does not support probability predictions.")
    else:
        raise ValueError("Invalid prediction type specified. Use 'label' or 'probability'.")

    # Save the results to a CSV file
    results_path = f'inst/extdata/{save_dir}/{prefix}_{dataset}{file_suffix}'
    result_df.to_csv(results_path, index=False)
    print(f"Results saved at {results_path}")


