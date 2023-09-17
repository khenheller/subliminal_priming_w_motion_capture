import numpy as np


# Creats a simulated trajectory.
# Input:
#   sim_type - 'linear': linear triangular traj.
#              'linear_acc': linear triangular traj wih acceleration > 0.
#              'curved': curved trajectory, imitates real mvmnt.
def simulate_traj(right, congruent, sim_type, rng):
    from scipy.stats import norm
    # Mvmnt range for X,Y,Z axes.
    x_rng = [26, 36] if right else [26, 16]
    y_rng = [-7, 15]
    z_rng = [35, 0]
    # Cameras sample rate in sec.
    s_rate_sec = 0.01
    # Random number of traj samples.
    con_mvmnt_time = (41.6, 3)  # Mean, SD
    incon_mvmnt_time = (42.9, 2.8)
    norm_dist = con_mvmnt_time if congruent else incon_mvmnt_time
    n_samples = round(rng.normal(*norm_dist))
    # Mvmnt duration.
    t_end = n_samples * s_rate_sec
    # Time vec.
    t = np.array(np.linspace(0, n_samples * s_rate_sec, n_samples))

    # X for linear/linear_acc trajs.
    if congruent:
        xs = np.linspace(*x_rng, n_samples)
    else:
        xs = np.hstack((np.repeat(x_rng[0], np.ceil(n_samples/2).astype(int)),
                        np.linspace(*x_rng, np.floor(n_samples/2).astype(int)+1)[1:]))

    # Linear traj for congruent, triangular traj for incongruent. Acceleration = 0.
    if sim_type == 'linear':
        ys = np.linspace(*y_rng, n_samples)
        zs = np.linspace(*z_rng, n_samples)
    # Linear traj for congruent, triangular traj for incongruent. Acceleration > 0.
    elif sim_type == 'linear_acc':
        ys = np.linspace(*y_rng, n_samples)
        # acceleration necessary to reach the screen in 'n_samples' samples.
        a = (z_rng[1] - z_rng[0]) * 2 / (t_end**2)
        # Z Position as func of time and acceleration.
        zs = z_rng[0] + 0.5 * a * (t**2)
    # Rounded trajs to imitate real reachings.
    else:
        # Shape a traj in range X,Z = 0-1.
        func = np.vectorize(lambda x: ((abs(x)) ** 0.5))
        amp = 0.2 * rng.uniform(low=0, high=1) # Values larget hen 0.2 create a large distorton in traj.
        freq = rng.uniform(low=0, high=1)
        sin_noise = amp * np.sin(freq * 2 * np.pi * np.linspace(0,1,n_samples))
        gaussian_sin_noise = sin_noise * 2.5 * norm.pdf(np.linspace(-3,3,n_samples), loc=0, scale=1)  # Normal dist resets(=0) at -3 and 3. Dist multi by 2.5 to set range between 0-1.
        traj_z = func(np.linspace(0,1,n_samples) * 0.9) + rng.choice([-1, 1]) * gaussian_sin_noise  # 0.9 to prevent zs from reaching 1 before the last sample.
        # Adapt to traj range.
        xs = np.linspace(*x_rng, n_samples)
        ys = np.linspace(*y_rng, n_samples)
        zs = traj_z * z_rng[1]
        
    return xs, ys, zs


def simulate_kb_time(congruent, rng):
    norm_dist = (52.55, 3.6) if congruent else (54.54, 3.3)
    return rng.normal(*norm_dist)


def fill_traj_df(reach_data, reach_traj, sub_num, sim_type, rng):
    reach_traj["sub_num"] = sub_num
    n_trials = reach_traj.loc[reach_traj["practice"] == 0, "iTrial"].max()
    for trial in range(1, n_trials + 1):
        xs, ys, zs, tcs = np.full(700, np.nan), np.full(700, np.nan), np.full(700, np.nan), np.full(700, np.nan)
        curr_trial = reach_data[
            (reach_data["practice"] == 0) & (reach_data["iTrial"] == trial)
        ]
        right = curr_trial["target_ans_left"].values[0] == 0
        congruent = curr_trial["same"].values[0] == 1
        traj = simulate_traj(right, congruent, sim_type, rng)
        traj_len = len(traj[0])
        xs[:traj_len] = traj[0] / 100
        ys[:traj_len] = traj[1] / 100
        zs[:traj_len] = traj[2] / 100
        start = reach_traj[
            (reach_traj["practice"] == 0) & (reach_traj["iTrial"] == trial)
        ]["target_timecourse_to"].iloc[0]
        tcs[:traj_len] = np.linspace(
            start, start + traj_len * 0.01, traj_len, endpoint=False
        )
        reach_traj.loc[
            (reach_traj["iTrial"] == trial) & (reach_traj["practice"] == 0),
            "target_x_to",
        ] = xs
        reach_traj.loc[
            (reach_traj["iTrial"] == trial) & (reach_traj["practice"] == 0),
            "target_y_to",
        ] = ys
        reach_traj.loc[
            (reach_traj["iTrial"] == trial) & (reach_traj["practice"] == 0),
            "target_z_to",
        ] = zs
        reach_traj.loc[
            (reach_traj["iTrial"] == trial) & (reach_traj["practice"] == 0),
            "target_timecourse_to",
        ] = tcs

    return reach_traj


def fill_reach_data_df(reach_data, reach_traj, sub_num, rng):
    reach_data["sub_num"] = sub_num
    reach_data["quit"] = 0
    reach_data["early_res"] = 0
    reach_data["late_res"] = 0
    reach_data["pas"] = 1
    reach_data["prime_correct"] = rng.integers(0, 2, reach_data.shape[0])
    reach_data["target_ans_nat"] = reach_data["target_natural"]
    reach_data["target_correct"] = 1
    reach_data["target_ans_left"] = (
        ~np.logical_xor(reach_data["natural_left"], reach_data["target_natural"])
    ).astype(int)
    reach_data["categor_time"] = reach_data["target_time"] + 0.5
    reach_data.loc[reach_data["practice"] == 0, "slow_mvmnt"] = (
        (
            reach_traj[reach_traj["practice"] == 0]
            .groupby("iTrial")
            .count()["target_x_to"]
            > 42
        )
        .astype(int)
        .values
    )

    return reach_data


def fill_keyboard_data_df(keyboard_data, sub_num, rng):
    keyboard_data["sub_num"] = sub_num
    keyboard_data["quit"] = 0
    keyboard_data["early_res"] = 0
    keyboard_data["late_res"] = 0
    keyboard_data["slow_mvmnt"] = 0
    keyboard_data["pas"] = 1
    keyboard_data["prime_correct"] = rng.integers(0, 2, keyboard_data.shape[0])
    keyboard_data["target_ans_nat"] = keyboard_data["target_natural"]
    keyboard_data["target_correct"] = 1
    keyboard_data["target_ans_left"] = (
        ~np.logical_xor(keyboard_data["natural_left"], keyboard_data["target_natural"])
    ).astype(int)
    keyboard_data["categor_time"] = keyboard_data["target_time"] + 0.5
    n_trials = keyboard_data.loc[keyboard_data["practice"] == 0, "iTrial"].max()
    for trial in range(1, n_trials + 1):
        congruent = (
            keyboard_data[
                (keyboard_data["practice"] == 0) & (keyboard_data["iTrial"] == trial)
            ]["same"].values[0]
            == 1
        )
        keyboard_data.loc[
            keyboard_data["iTrial"] == trial, "target_rt"
        ] = simulate_kb_time(congruent, rng)

    return keyboard_data
