import nbformat
import pytest
import warnings
import numpy as np
from nbconvert.preprocessors import ExecutePreprocessor
import asyncio
import pprint
import sys
if sys.platform.startswith('win'):
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

@pytest.mark.parametrize('notebook', ['notebook-5.ipynb'])
def test_notebook_exec(notebook):
    """Test that the notebook executes without raising errors."""
    with open(notebook, encoding='utf-8') as f:
        nb = nbformat.read(f, as_version=4)
        ep = ExecutePreprocessor(timeout=600, kernel_name='python3')
        try:
            assert ep.preprocess(nb) is not None, f'Got empty notebook for {notebook}'
        except Exception as e:
            pytest.fail(f'Failed executing {notebook}: {e}')

def get_notebook_namespace(notebook_path):
    """Execute notebook cells and return the resulting global namespace."""
    with open(notebook_path, encoding='utf-8') as f:
        nb = nbformat.read(f, as_version=4)
    namespace = {}
    for cell in nb.cells:
        if cell.cell_type == 'code':
            exec(cell.source, namespace)
    return namespace
RESULTS = {
    "XGBoost": {
        "best_params": {
            "colsample_bytree": 0.9,
            "gamma": 0.025,
            "learning_rate": 0.02,
            "max_depth": 2,
            "n_estimators": 400,
            "reg_alpha": 0.0,
            "reg_lambda": 1.0,
            "subsample": 0.7,
        },
        "mae": 6.5079,
        "r2": 0.8027,
    },
    "LightGBM": {
        "best_params": {
            "colsample_bytree": 0.7,
            "learning_rate": 0.03,
            "max_depth": 2,
            "n_estimators": 300,
            "num_leaves": 160,
            "reg_alpha": 0.0,
            "reg_lambda": 2.0,
            "subsample": 0.8,
        },
        "mae": 6.7636,
        "r2": 0.7948,
    },
    "CatBoost": {
        "best_params": {
            "depth": 2,
            "iterations": 500,
            "l2_leaf_reg": 4,
            "learning_rate": 0.03,
            "subsample": 0.6,
        },
        "mae": 6.3755,
        "r2": 0.8071,
    },
    "ExtraTrees": {
        "best_params": {"max_depth": 20, "min_samples_split": 10, "n_estimators": 100},
        "mae": 6.7962,
        "r2": 0.7911,
    },
}
GROUPS = [
    ["Vehicle_Type"],
    ["Vehicle_Type", "Time_of_Day"],
    ["Distance_bin", "Traffic_Level"],
]
FEATURES_OHE = [
    "Distance_km",
    "Preparation_Time_min",
    "Courier_Experience_yrs",
    "Distance_km_sq",
    "Distance_km_sqrt",
    "traffic_ord",
    "dist_x_traffic",
    "Weather_was_missing",
    "Traffic_Level_was_missing",
    "Time_of_Day_was_missing",
    "Courier_Experience_yrs_was_missing",
    "Vehicle_Type_Scooter",
    "Weather_Foggy",
    "Weather_Rainy",
    "Weather_Snowy",
    "Weather_Windy",
    "Traffic_Level_Low",
    "Traffic_Level_Medium",
    "Time_of_Day_Evening",
    "Time_of_Day_Morning",
    "Time_of_Day_Night",
]
FEATURES_CAT = [
    "Distance_km",
    "Preparation_Time_min",
    "Courier_Experience_yrs",
    "Vehicle_Type",
    "Weather",
    "Traffic_Level",
    "Time_of_Day",
    "Distance_km_sq",
    "Distance_km_sqrt",
    "traffic_ord",
    "dist_x_traffic",
    "Weather_was_missing",
    "Traffic_Level_was_missing",
    "Time_of_Day_was_missing",
    "Courier_Experience_yrs_was_missing",
]

def test_notebook_variables():
    """Test that the 'results' dictionary is correctly populated for all models."""
    ns = get_notebook_namespace('notebook-5.ipynb')
    assert 'results' in ns, "Variable 'results' not found in notebook namespace."
    results = ns['results']
    assert isinstance(results, dict), f"'results' should be a dict, got {type(results)}"
    for model in ['XGBoost', 'LightGBM', 'CatBoost', 'ExtraTrees']:
        assert model in results, f"'{model}' not found in results."
        model_result = results[model]
        pprint.pprint(model_result)
        assert isinstance(model_result, dict), f"results['{model}'] should be a dict, got {type(model_result)}"
        for key in ['best_params', 'mae', 'r2', 'fit_time_s']:
            assert key in model_result, f"Key '{key}' missing in results['{model}']"
        assert isinstance(model_result['best_params'], dict), f"results['{model}']['best_params'] should be a dict"
        for float_key in ['mae', 'r2', 'fit_time_s']:
            assert isinstance(model_result[float_key], (float, np.floating)), f"results['{model}']['{float_key}'] should be a float"
        assert model_result['mae'] > 0, f'MAE for {model} should be positive.'
        assert -1 <= model_result['r2'] <= 1, f'R2 for {model} should be between -1 and 1.'
        assert model_result['fit_time_s'] > 0, f'Fit time for {model} should be positive.'
        expected = RESULTS[model]
        actual_params = model_result['best_params']
        expected_params = expected['best_params']
        assert set(actual_params.keys()) == set(expected_params.keys()), f'Parameter keys for {model} do not match expected.'
        for key in ['mae', 'r2']:
            actual = model_result[key]
            exp = expected[key]
            print(str(actual) + ' actual/expected ' + str(exp))
            assert abs(actual - exp) < 0.001, f"results['{model}']['{key}']={actual} does not match expected {exp}"

def test_notebook_datasets():
    """Test that all data splits exist and have correct, aligned shapes."""
    ns = get_notebook_namespace('notebook-5.ipynb')
    required_vars = ['data_split_ohe', 'data_split_cat', 'target_series']
    for var in required_vars:
        assert var in ns, f"Variable '{var}' not found in notebook namespace."
    data_split_ohe = ns['data_split_ohe']
    data_split_cat = ns['data_split_cat']
    target_series = ns['target_series']
    assert data_split_ohe.X_train.shape[0] == data_split_ohe.y_train.shape[0], 'OHE train X and y row count mismatch'
    assert data_split_ohe.X_probe.shape[0] == data_split_ohe.y_probe.shape[0], 'OHE probe X and y row count mismatch'
    assert data_split_cat.X_train.shape[0] == data_split_cat.y_train.shape[0], 'CatBoost train X and y row count mismatch'
    assert data_split_cat.X_probe.shape[0] == data_split_cat.y_probe.shape[0], 'CatBoost probe X and y row count mismatch'
    assert data_split_ohe.X_train.shape[1] != data_split_cat.X_train.shape[1], 'OHE and CatBoost train sets should have different column counts'
    assert data_split_ohe.X_probe.shape[1] != data_split_cat.X_probe.shape[1], 'OHE and CatBoost probe sets should have different column counts'

def test_notebook_groups():
    """Test that the 'groups' variable for feature aggregation is defined correctly."""
    ns = get_notebook_namespace('notebook-5.ipynb')
    assert 'groups' in ns, "Variable 'groups' not found in notebook namespace."
    groups = ns['groups']
    assert isinstance(groups, list), f"'groups' should be a list, got {type(groups)}"
    assert groups == GROUPS, 'The defined groups for aggregation do not match the expected structure.'

def test_notebook_feature_dfs():
    """Test that the initial feature DataFrames are created with the correct columns."""
    ns = get_notebook_namespace('notebook-5.ipynb')
    assert 'features_df_ohe' in ns, "Variable 'features_df_ohe' not found."
    assert 'features_df_cat' in ns, "Variable 'features_df_cat' not found."
    features_df_ohe = ns['features_df_ohe']
    ohe_cols = list(features_df_ohe.columns)
    base_features = ['Distance_km', 'Preparation_Time_min', 'Courier_Experience_yrs', 'Distance_km_sq', 'Distance_km_sqrt', 'traffic_ord', 'dist_x_traffic', 'Weather_was_missing', 'Traffic_Level_was_missing', 'Time_of_Day_was_missing', 'Courier_Experience_yrs_was_missing']
    cat_prefixes = ['Vehicle_Type_', 'Weather_', 'Traffic_Level_', 'Time_of_Day_']
    unexpected = []
    for col in ohe_cols:
        if col in base_features:
            continue
        if any((col.startswith(prefix) for prefix in cat_prefixes)):
            continue
        unexpected.append(col)
    assert not unexpected, f'OHE features contain unexpected columns: {unexpected}'
    features_df_cat = ns['features_df_cat']
    cat_cols = list(features_df_cat.columns)
    assert set(cat_cols) == set(FEATURES_CAT), f'CatBoost features do not match expected.\nGot: {set(cat_cols)}\nExpected: {set(FEATURES_CAT)}'
