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



import shap
import pandas as pd
from joblib import load
import os
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.neural_network import MLPClassifier

def compute_shap_values(prefix, dataset, explainer_type, save_dir='default'):
    # Load the scaler and model
    scaler_path = f'inst/extdata/{save_dir}/{prefix}_scaler.joblib'
    model_path = f'inst/extdata/{save_dir}/{prefix}_best_model.joblib'
    scaler = load(scaler_path)
    model = load(model_path)
    
    # Load the new dataset for prediction
    X_new = pd.read_csv(f'inst/extdata/modeval_data_set/{prefix}_{dataset}.csv')
    X_new = X_new.drop(columns=['id', 'outcome'], errors='ignore')
    X_new_scaled = scaler.transform(X_new)

    # Background data for explainers
    background_data = shap.sample(X_new_scaled, 100)  # Adjust as needed    
    
    # Initialize the SHAP explainer with appropriate configurations
    if explainer_type == shap.TreeExplainer and isinstance(model, (RandomForestClassifier, GradientBoostingClassifier)):
        explainer = explainer_type(model)
    elif explainer_type == shap.LinearExplainer and isinstance(model, LogisticRegression):
        masker = shap.maskers.Independent(data=background_data)
        explainer = explainer_type(model, masker)
    elif explainer_type == shap.KernelExplainer and isinstance(model, MLPClassifier):
        explainer = explainer_type(model.predict_proba, background_data)  # Use predict_proba for KernelExplainer
    else:
        raise NotImplementedError("Explainer not configured for this model type")
    
    # Compute SHAP values
    shap_values = explainer.shap_values(X_new_scaled)

    # Get the expected value (baseline prediction) from the explainer
    expected_value = explainer.expected_value
    if isinstance(expected_value, list):
        # If multiple classes, assuming interest in the second class
        expected_value = expected_value[1]

    # Handle multiple classes for classifiers
    if isinstance(shap_values, list):
        shap_values = shap_values[1]  # Assuming interest in the second class

    # Convert SHAP values to DataFrame and save
    shap_df = pd.DataFrame(shap_values, columns=X_new.columns)
    # Repeat the expected value for each instance
    shap_df['expected_value'] = [expected_value] * len(shap_df)

    # Define the filename for saving the SHAP values and expected value
    shap_csv_filename = os.path.join(f'inst/extdata/{save_dir}', f'{prefix}_{dataset}_shap_values.csv')
    shap_df.to_csv(shap_csv_filename, index=False)
    print(f"Results saved at {shap_csv_filename}")


