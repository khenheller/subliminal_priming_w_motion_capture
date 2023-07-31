from sklearn.linear_model import LogisticRegression
from xgboost import XGBClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import os as os
import pandas as pd
import numpy as np
from scipy.special import ndtri


def calc_d_prime(iSub: int, measure: str, p: dict):
    """Classifies indirect measure results to con/incon with machine learning.
    Computes classification accuracy (d')

    Args:
        iSub (int): subject number
        measure (str): 'reach'/'keyboard'
    Returns:
        d prime.
    """
    data = pd.read_csv(
        os.path.join(p["PROC_DATA_FOLDER"], f"{measure[0]}_feats_labels_table_sub{iSub}.csv")
    )
    feats = data.drop("labels", axis=1)
    labels = np.where(data["labels"] == "con", 1, 0)
    # Split.
    x_train, x_test, y_train, y_test = train_test_split(
        feats, labels, test_size=0.2
    )  # You can use random=0 or any other number to have consistant results.
    # Standardize.
    scaler = StandardScaler()
    x_train_stn = scaler.fit_transform(x_train)
    x_test_stn = scaler.transform(x_test)
    # Train N predict
    models = [LogisticRegression(), XGBClassifier(max_depth=2)]
    con_prob = pd.DataFrame(columns=['LogisticRegression','XGBClassifier']) # Probability that class is 'congruent'.
    for i, m in enumerate(models):
        m.fit(x_train_stn, y_train),
        con_prob.iloc[:, i] = m.predict_proba(x_test_stn)[:, 1]
    # Avg predictions.
    weights = [1, 0.3]
    con_prob["weighted_pred"] = (con_prob * weights).sum(axis=1) / sum(weights)
    pred = con_prob["weighted_pred"] > 0.5  # 1=con, 0=incon
    # Conv to hit/fa.
    hits = pred & (y_test == 1)
    fas = pred & (y_test == 0)
    n_hits = np.sum(hits)
    n_fas = np.sum(fas)
    # Num of signal/noise trials.
    n_signal = np.sum(y_test == 1)
    n_noise = np.sum(y_test == 0)
    # Proportion of signal/noise trials.
    portion_signal = n_signal / (n_signal + n_noise)
    portion_noise = 1 - portion_signal
    # log-linear Correction for hit/fa rate of 1 or 0 (Hautus, 1995):
    # https://stats.stackexchange.com/questions/134779/d-prime-with-100-hit-rate-probability-and-0-false-alarm-probability
    hit_rate = (n_hits + portion_signal) / (n_signal + 2 * portion_signal)
    fa_rate = (n_fas + portion_noise) / (n_noise + 2 * portion_noise)
    # Calc d prime.
    return (ndtri(hit_rate) - ndtri(fa_rate))
