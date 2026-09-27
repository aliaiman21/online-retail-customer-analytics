import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ---- style (used by every chart) ----
BLUE, ORANGE, GREY = "#2a78d6", "#eb6834", "#b9b8b3"
plt.rcParams.update({
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.grid": True,
    "grid.color": "#e6e5e0",
    "axes.axisbelow": True,
    "font.size": 11,
})

# ---- CHART 1: RFM segments ----
df = pd.read_csv("outputs/tables/05_segment_summary.csv")
df = df.iloc[::-1]                       # reverse, so the biggest segment ends up on top
y = np.arange(len(df))                   # bar positions: 0, 1, 2, ...

fig, ax = plt.subplots(figsize=(10, 5.5))
ax.barh(y + 0.2, df.pct_customers, height=0.38, color=GREY, label="% of customers")
ax.barh(y - 0.2, df.pct_revenue,   height=0.38, color=BLUE, label="% of revenue")

# number labels at the end of each bar
for yi, c, r in zip(y, df.pct_customers, df.pct_revenue):
    ax.text(c + 0.8, yi + 0.2, f"{c:.0f}%", va="center", color="#52514e")
    ax.text(r + 0.8, yi - 0.2, f"{r:.0f}%", va="center", fontweight="bold")

ax.set_yticks(y, df.segment)
ax.set_xlim(0, 75)
ax.xaxis.set_major_formatter(lambda x, pos: f"{x:.0f}%")
ax.grid(axis="y", visible=False)
ax.legend(frameon=False, loc="lower right")
ax.set_title("A quarter of customers (Champions) bring in two-thirds of revenue",
             loc="left", fontweight="bold")

fig.tight_layout()
fig.savefig("outputs/charts/01_rfm_segments.png", dpi=160)
print("saved outputs/charts/01_rfm_segments.png")

# ---- CHART 2: monthly revenue ----
df = pd.read_csv("outputs/tables/02_monthly_kpis.csv", parse_dates=["order_month"])
labels = df.order_month.dt.strftime("%b %y")                     # e.g. "Nov 11"
colors = [GREY if partial else (ORANGE if m in (9, 10, 11) else BLUE)
          for partial, m in zip(df.is_partial_month, df.order_month.dt.month)]

fig, ax = plt.subplots(figsize=(10, 5))
ax.bar(labels, df.revenue, color=colors, width=0.7)
ax.yaxis.set_major_formatter(lambda x, pos: f"£{x/1000:.0f}k")
ax.grid(axis="x", visible=False)
ax.text(len(df) - 1, df.revenue.iloc[-1] + 20000, "partial\n(1-9 Dec)", ha="center", fontsize=9)
ax.tick_params(axis="x", labelsize=9)
ax.set_title("Sep-Nov is peak season: 37% of the year's revenue in 3 months", loc="left", fontweight="bold")

fig.tight_layout()
fig.savefig("outputs/charts/02_monthly_revenue.png", dpi=160)
print("saved outputs/charts/02_monthly_revenue.png")

# ---- CHART 3: cohort retention heatmap ----
df = pd.read_csv("outputs/tables/03_cohort_retention.csv", parse_dates=["cohort_month"])
grid = df.pivot(index="cohort_month", columns="months_since_first", values="retention_pct")
grid = grid.drop(columns=0).dropna(how="all")                    # month 0 is always 100%

fig, ax = plt.subplots(figsize=(11, 6.5))
ax.grid(False)
im = ax.imshow(grid.values, cmap="Blues", vmin=0, vmax=45, aspect="auto")
for i in range(grid.shape[0]):                                   # write the % in each cell
    for j in range(grid.shape[1]):
        v = grid.values[i, j]
        if not np.isnan(v):
            ax.text(j, i, f"{v:.0f}", ha="center", va="center", fontsize=9,
                    color="white" if v > 28 else "black")
ax.set_xticks(range(grid.shape[1]), [f"+{m}" for m in grid.columns])
ax.set_yticks(range(grid.shape[0]), grid.index.strftime("%b %Y"))
ax.set_xlabel("Months after first order")
fig.colorbar(im, ax=ax, label="% of cohort ordering again")
ax.set_title("Only about 1 in 5 new customers orders again the next month", loc="left", fontweight="bold")

fig.tight_layout()
fig.savefig("outputs/charts/03_cohort_retention.png", dpi=160)
print("saved outputs/charts/03_cohort_retention.png")

# ---- CHART 4: Pareto curve ----
rfm = pd.read_csv("outputs/tables/04_rfm_segments.csv").sort_values("monetary", ascending=False)
x = np.arange(1, len(rfm) + 1) / len(rfm) * 100                  # % of customers
y = rfm.monetary.cumsum() / rfm.monetary.sum() * 100             # cumulative % of revenue

fig, ax = plt.subplots(figsize=(10, 5))
ax.plot(x, y, color=BLUE, linewidth=2.2)
ax.plot([0, 100], [0, 100], color=GREY, linestyle="--")          # "everyone spends the same" line
ax.text(62, 52, "if every customer\nspent the same", color="#52514e")

pts = pd.read_csv("outputs/tables/06_pareto_customers.csv")
for _, r in pts[pts.top_pct_of_customers.isin([1, 20])].iterrows():
    ax.plot(r.top_pct_of_customers, r.pct_of_revenue, "o", color=BLUE, markersize=8)
    ax.annotate(f"Top {r.top_pct_of_customers:.0f}% of customers\n= {r.pct_of_revenue:.0f}% of revenue",
                (r.top_pct_of_customers, r.pct_of_revenue),
                xytext=(r.top_pct_of_customers + 6, r.pct_of_revenue - 16),
                arrowprops=dict(arrowstyle="-"))

ax.set_xlim(0, 100); ax.set_ylim(0, 102)
ax.xaxis.set_major_formatter(lambda v, pos: f"{v:.0f}%")
ax.yaxis.set_major_formatter(lambda v, pos: f"{v:.0f}%")
ax.set_xlabel("Customers, ranked by spend")
ax.set_ylabel("Cumulative share of revenue")
ax.set_title("The top 1% of customers generate a third of revenue", loc="left", fontweight="bold")

fig.tight_layout()
fig.savefig("outputs/charts/04_pareto.png", dpi=160)
print("saved outputs/charts/04_pareto.png")