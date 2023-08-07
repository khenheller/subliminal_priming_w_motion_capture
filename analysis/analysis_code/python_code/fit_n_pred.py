import time
import numpy as np
import scipy.io as sio
from calc_d_prime import calc_d_prime
import os as os
import pandas as pd
from sklearn.naive_bayes import GaussianNB
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.linear_model import LogisticRegression
from xgboost import XGBClassifier

# Ignore warnings ----------------------------
import warnings
warnings.filterwarnings(action='ignore', category=FutureWarning)

# Define params.------------------------------
p = dict()
# Subs
EXP_4_1_SUBS = np.hstack((47, np.arange(49,86), np.arange(87,91)))
p['SUBS'] = EXP_4_1_SUBS
p['SUBS_STRING'] = '_'.join(map(str, p['SUBS']))
p['DAY'] = 'day2'
# Paths
p['DATA_FOLDER'] = os.path.abspath('../../../raw_data/')
p['PROC_DATA_FOLDER'] = os.path.abspath('../../processed_data/')

# Load data.------------------------------
good_subs = sio.loadmat(os.path.join(p['PROC_DATA_FOLDER'], f"good_subs_{p['DAY']}_target_x_to_subs_{p['SUBS_STRING']}.mat"))['good_subs'][0]

# Ensemble learning ------------------------------
# Desired models: e.g. LogisticRegression(), XGBClassifier(max_depth=2), GaussianNB().
models = [LogisticRegression(), XGBClassifier(max_depth=2)]
# Models names: e.g. 'LogisticRegression', 'XGBClassifier'
models_names = ['LogisticRegression', 'XGBClassifier']
# Weights for each of the models in the ensemble.
weights = [1, 0.3]
iters = 100
avg_r_d_prime = np.full(iters, np.NaN)
avg_k_d_prime = np.full(iters, np.NaN)
# Run many classifications.
iters_start_time = time.time()
for i_iter in range(iters):
    class_time = time.time()
    r_d_prime = np.full(max(p['SUBS'])+1, np.NaN)
    k_d_prime = np.full(max(p['SUBS'])+1, np.NaN)
    for iSub in good_subs:
        r_d_prime[iSub] = calc_d_prime(iSub, 'reach', weights, models, models_names, p)
        k_d_prime[iSub] = calc_d_prime(iSub, 'keyboard', weights, models, models_names, p)
    avg_r_d_prime[i_iter] = np.nanmean(r_d_prime[:])
    avg_k_d_prime[i_iter] = np.nanmean(k_d_prime[:])
    print(f'Done iter {i_iter}. took {time.time() - class_time} sec')
print(f'Done all classification iterations. {time.time() - iters_start_time} sec')

d_prime = np.hstack((avg_r_d_prime, avg_k_d_prime))
measure = np.hstack((np.repeat("reach", len(avg_r_d_prime)), np.repeat("keyboard", len(avg_k_d_prime))))
df = pd.DataFrame({"d_prime":d_prime, "measure":measure})
sns.stripplot(x="measure", y="d_prime", data=df, color='tab:orange')
sns.pointplot(x="measure", y="d_prime", data=df, estimator="nanmean", errorbar="se", join=False).set(title=f'd prime after {iters} iters')
plt.show()

# # Gradient Boosting ------------------------------
# # Define hyperparameters to be twiked.
# PARAM_GRID = {'max_depth':[2],
#               'learning_rate':[0.1, 0.2, 0.6],
#               'n_estimators':[100, 200, 500]
#              }

# # Create grid search object. We will feed it data and it will find the params that best predict that data.
# boost_searcher = GradientBoostingClassifier(random_state=0,
#                                             verbose=1, # Print progress.
#                                             max_features='sqrt' # Use sqrt(n_features) when assesing each split.
#                                             )
# # Run CV for each paramteres combination and find the one that yields the best accuracy.
# boost_searcher.fit(ft_train, labels_train)
# boost_estimator = boost_searcher.best_estimator_

# print("Best parameters are: ", boost_searcher.best_params_)
# print("ROC AUC on the test set is: ", boost_searcher.score(ft_test, groups_test))#@@@@@ F score @@@@
