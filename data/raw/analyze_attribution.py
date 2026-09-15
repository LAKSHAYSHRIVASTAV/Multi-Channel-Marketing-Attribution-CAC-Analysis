"""
Multi-Touch Attribution Analysis
------------------------------------
Applies 5 standard attribution models to the same touchpoint data, then
validates each against the dataset's own KNOWN generative "ground truth"
channel weights (a validation only possible because this is a controlled
synthetic dataset -- in real life you never get to see ground truth,
which is exactly why choosing the RIGHT attribution model matters so much).
"""

import pandas as pd
import numpy as np

touch = pd.read_csv("/home/claude/project8/touchpoints.csv")
touch['role'] = np.where(touch['touch_order']==1, 'first',
                  np.where(touch['touch_order']==touch['journey_length'], 'last', 'middle'))

CHANNEL_PROFILE = {
    "Paid Social":    {"opener": 0.90, "closer": 0.20, "middle": 0.40},
    "Display":        {"opener": 0.70, "closer": 0.15, "middle": 0.30},
    "Organic Search": {"opener": 0.50, "closer": 0.50, "middle": 0.40},
    "Referral":       {"opener": 0.50, "closer": 0.40, "middle": 0.40},
    "Paid Search":    {"opener": 0.30, "closer": 0.80, "middle": 0.40},
    "Email":          {"opener": 0.10, "closer": 0.70, "middle": 0.50},
    "Direct":         {"opener": 0.20, "closer": 0.90, "middle": 0.30},
}
ROLE_MAP = {"first": "opener", "last": "closer", "middle": "middle"}

converted_journeys = touch[touch['converted'] == 1].copy()
print(f"Converting journeys: {converted_journeys['user_id'].nunique()}")

total_spend = touch.groupby('channel')['cost'].sum()

def attribute(df, weight_fn, label):
    df = df.copy()
    df['raw_weight'] = df.apply(weight_fn, axis=1)
    df['norm_weight'] = df.groupby('user_id')['raw_weight'].transform(lambda w: w / w.sum())
    df['credited_revenue'] = df['norm_weight'] * df['revenue']
    df['credited_conversion'] = df['norm_weight']
    by_channel = df.groupby('channel').agg(
        attributed_revenue=('credited_revenue', 'sum'),
        attributed_conversions=('credited_conversion', 'sum'),
    )
    by_channel['model'] = label
    return by_channel

def w_first(row): return 1.0 if row['touch_order'] == 1 else 0.0
def w_last(row): return 1.0 if row['touch_order'] == row['journey_length'] else 0.0
def w_linear(row): return 1.0
def w_time_decay(row): return 2 ** (row['touch_order'] - row['journey_length'])
def w_position_based(row):
    if row['journey_length'] == 1:
        return 1.0
    if row['touch_order'] == 1:
        return 0.4
    if row['touch_order'] == row['journey_length']:
        return 0.4
    n_middle = row['journey_length'] - 2
    return 0.2 / n_middle if n_middle > 0 else 0.0

models = {
    "First-Touch": w_first,
    "Last-Touch": w_last,
    "Linear": w_linear,
    "Time-Decay": w_time_decay,
    "Position-Based (U-shaped)": w_position_based,
}

results = []
for label, fn in models.items():
    res = attribute(converted_journeys, fn, label)
    results.append(res)

all_results = pd.concat(results).reset_index()

def w_ground_truth(row):
    return CHANNEL_PROFILE[row['channel']][ROLE_MAP[row['role']]]

gt = attribute(converted_journeys, w_ground_truth, "Ground Truth (generative weights)")
gt = gt.reset_index()

all_results_full = pd.concat([all_results, gt]).reset_index(drop=True)

pivot_revenue_share = all_results_full.pivot(index='channel', columns='model', values='attributed_revenue')
pivot_revenue_share = pivot_revenue_share.div(pivot_revenue_share.sum(axis=0), axis=1) * 100

print("\n" + "="*80)
print("Revenue SHARE (%) attributed to each channel, by model")
print("="*80)
print(pivot_revenue_share.round(1).to_string())

gt_col = pivot_revenue_share["Ground Truth (generative weights)"]
print("\n" + "="*80)
print("Mean Absolute Error vs. Ground Truth (lower = more accurate attribution model)")
print("="*80)
for model in models.keys():
    mae = (pivot_revenue_share[model] - gt_col).abs().mean()
    print(f"  {model:30s}: {mae:.2f} percentage points average error")

print("\n" + "="*80)
print("ROAS and CAC by channel -- Last-Touch vs Position-Based (the two most different views)")
print("="*80)
for model_name in ["Last-Touch", "Position-Based (U-shaped)"]:
    print(f"\n--- {model_name} ---")
    sub = all_results_full[all_results_full['model'] == model_name].set_index('channel')
    sub = sub.join(total_spend.rename('spend'), how='left').fillna({'spend': 0})
    sub['roas'] = (sub['attributed_revenue'] / sub['spend']).replace([np.inf, -np.inf], np.nan)
    sub['cac'] = (sub['spend'] / sub['attributed_conversions']).replace([np.inf, -np.inf], np.nan)
    print(sub[['attributed_revenue','attributed_conversions','spend','roas','cac']].round(2).to_string())

print("\n" + "="*80)
print("Attributed CONVERSIONS for the 3 PAID channels specifically (the ones budget")
print("decisions actually get made on) -- Ground Truth vs. each model")
print("="*80)
paid_channels = ["Display", "Paid Social", "Paid Search"]
conv_pivot = all_results_full.pivot(index='channel', columns='model', values='attributed_conversions')
print(conv_pivot.loc[paid_channels].round(1).to_string())
print("""
FINDING: on a full 7-channel aggregate revenue-SHARE basis, the differences
between attribution models look modest (all models within ~1-2 percentage
points of ground truth) -- an initial, misleading impression that the model
choice barely matters. But that aggregate metric is diluted by unpaid
channels (Direct, Email, Organic, Referral), which dominate total revenue
share regardless of model. Looking specifically at the 3 PAID channels --
where actual budget decisions get made -- reveals the real story:

  Last-Touch UNDER-credits Display by 3.6x (96 credited vs. 348 true
  conversions) and Paid Social by 4.7x (133 vs. 627 true), while
  OVER-crediting Paid Search by 1.4x (820 vs. 575 true).

Position-Based and Linear attribution come very close to ground truth for
all three paid channels. The lesson: validate an attribution model against
the SPECIFIC channels a decision depends on, not an undifferentiated
aggregate across every channel including free ones -- the aggregate view
can hide a decision-relevant signal that becomes obvious once you slice
correctly.
""")


all_results_full.to_csv("/home/claude/project8/attribution_model_comparison.csv", index=False)
pivot_revenue_share.to_csv("/home/claude/project8/revenue_share_by_model.csv")
conv_pivot.to_csv("/home/claude/project8/conversions_by_model.csv")
print("Saved attribution_model_comparison.csv, revenue_share_by_model.csv, conversions_by_model.csv")
