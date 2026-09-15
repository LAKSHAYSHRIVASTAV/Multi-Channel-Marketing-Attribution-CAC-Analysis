"""
Multi-Channel Marketing Attribution -- Data Generator
--------------------------------------------------------
SYNTHETIC DATA, clearly documented as such. Simulates multi-touch
customer journeys across 7 acquisition channels leading to conversion
(or not), with a DELIBERATE, documented "ground truth" channel role
structure baked in:

  - Some channels are strong AWARENESS/OPENER channels (valuable
    early in a journey, e.g. Paid Social, Display) but weak closers.
  - Some channels are strong CLOSER channels (valuable at the final
    touch, e.g. Direct, Email, Paid Search-branded) but weak openers.
  - This mirrors a well-documented real phenomenon in marketing
    analytics: last-touch attribution systematically OVER-credits
    closer channels and UNDER-credits opener channels, because it
    only looks at the final touchpoint.

The point of building this in deliberately: the analysis script will
apply several attribution models WITHOUT knowing this ground truth,
then the comparison will show which model's credit allocation comes
closest to the true generative structure -- a genuine, demonstrable
lesson about why last-touch attribution alone is misleading.
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta

SEED = 21
np.random.seed(SEED)

N_USERS = 20000
CAMPAIGN_START = datetime(2025, 1, 1)
CAMPAIGN_DAYS = 90

CHANNELS = ["Paid Social", "Display", "Organic Search", "Referral", "Paid Search", "Email", "Direct"]
PAID_CHANNELS = {"Paid Search", "Paid Social", "Display"}

CHANNEL_PROFILE = {
    "Paid Social":    {"opener": 0.90, "closer": 0.20, "middle": 0.40},
    "Display":        {"opener": 0.70, "closer": 0.15, "middle": 0.30},
    "Organic Search": {"opener": 0.50, "closer": 0.50, "middle": 0.40},
    "Referral":       {"opener": 0.50, "closer": 0.40, "middle": 0.40},
    "Paid Search":    {"opener": 0.30, "closer": 0.80, "middle": 0.40},
    "Email":          {"opener": 0.10, "closer": 0.70, "middle": 0.50},
    "Direct":         {"opener": 0.20, "closer": 0.90, "middle": 0.30},
}

COST_PARAMS = {
    "Paid Search": {"mean": 28, "sigma": 0.4},
    "Paid Social": {"mean": 9,  "sigma": 0.5},
    "Display":     {"mean": 3.5,"sigma": 0.5},
}

def sample_channel(role):
    weights = np.array([CHANNEL_PROFILE[c][role] for c in CHANNELS])
    weights = weights / weights.sum()
    return np.random.choice(CHANNELS, p=weights)

touchpoints = []
users_summary = []

for i in range(N_USERS):
    user_id = f"U{i:06d}"
    journey_len = np.random.choice([1,2,3,4,5], p=[0.30,0.30,0.20,0.13,0.07])

    channels_in_journey = []
    for pos in range(journey_len):
        if journey_len == 1:
            role = "closer"
        elif pos == 0:
            role = "opener"
        elif pos == journey_len - 1:
            role = "closer"
        else:
            role = "middle"
        channels_in_journey.append((sample_channel(role), role))

    score = sum(CHANNEL_PROFILE[ch][role] for ch, role in channels_in_journey)
    length_penalty = 0.08 * max(journey_len - 2, 0)
    logit = -3.2 + 1.15 * score - length_penalty
    p_convert = 1 / (1 + np.exp(-logit))
    converted = np.random.random() < p_convert

    revenue = 0.0
    if converted:
        revenue = round(float(np.random.lognormal(mean=np.log(3000), sigma=0.4)), 2)

    journey_start = CAMPAIGN_START + timedelta(days=int(np.random.randint(0, CAMPAIGN_DAYS - 7)))
    ts = journey_start
    for pos, (channel, role) in enumerate(channels_in_journey):
        ts = ts + timedelta(hours=float(np.random.exponential(20))) if pos > 0 else journey_start
        cost = 0.0
        if channel in PAID_CHANNELS:
            p = COST_PARAMS[channel]
            cost = round(float(np.random.lognormal(mean=np.log(p["mean"]), sigma=p["sigma"])), 2)
        touchpoints.append({
            "user_id": user_id,
            "touch_order": pos + 1,
            "journey_length": journey_len,
            "channel": channel,
            "timestamp": ts.strftime("%Y-%m-%d %H:%M:%S"),
            "cost": cost,
            "converted": int(converted),
            "revenue": revenue if pos == journey_len - 1 else 0.0,
        })

    users_summary.append({"user_id": user_id, "journey_length": journey_len, "converted": int(converted), "revenue": revenue})

touchpoints_df = pd.DataFrame(touchpoints)
users_df = pd.DataFrame(users_summary)

touchpoints_df.to_csv("/home/claude/project8/touchpoints.csv", index=False)
users_df.to_csv("/home/claude/project8/users_summary.csv", index=False)

print(f"Generated {len(touchpoints_df)} touchpoints across {len(users_df)} users")
print(f"Overall conversion rate: {users_df['converted'].mean():.2%}")
print(f"Total conversions: {users_df['converted'].sum()}")
print(f"Total attributed revenue (all converters): Rs.{users_df['revenue'].sum():,.0f}")
print()
print("Total spend by channel:")
print(touchpoints_df.groupby('channel')['cost'].sum().sort_values(ascending=False).round(0))
print()
touchpoints_df['role'] = np.where(touchpoints_df['touch_order']==1, 'first',
                           np.where(touchpoints_df['touch_order']==touchpoints_df['journey_length'], 'last', 'middle'))
print("Touch frequency by channel and role position:")
print(touchpoints_df.groupby(['channel','role']).size().unstack(fill_value=0))
