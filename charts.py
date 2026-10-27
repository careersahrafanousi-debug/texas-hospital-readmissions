# Charts for the README. Reads the CSVs produced by sql/04_export.sql
import pandas as pd, matplotlib.pyplot as plt
plt.rcParams.update({"font.size":11,"axes.spines.top":False,"axes.spines.right":False,"axes.titleweight":"bold","axes.titlelocation":"left"})
BLUE, GRAY = "#4E79A7", "#BAB0AC"
r = pd.read_csv("output/readmissions_by_condition.csv")
tx = r[(r.region=="Texas") & (r.excess_readmissions > 0)]
g = tx.groupby("condition")["excess_readmissions"].sum().sort_values()
ax = g.plot.barh(color=[BLUE if v > 200 else GRAY for v in g], figsize=(8,4.2))
ax.set_title("Where Texas excess readmissions come from")
ax.set_xlabel("Estimated excess readmissions (Jul 2021 - Jun 2024)"); ax.set_ylabel("")
ax.bar_label(ax.containers[0], fmt="%.0f", padding=3); plt.tight_layout(); plt.savefig("images/excess_by_condition.png", dpi=150); plt.close()

h = pd.read_csv("output/tx_hospital_summary.csv").dropna(subset=["star_rating"])
h["star_rating"] = h.star_rating.astype(int)
s = h.groupby("star_rating").apply(lambda x: 100*x.conditions_worse.sum()/x.conditions_scored.sum())
ax = s.plot.bar(color=BLUE, figsize=(7,4.2), rot=0)
ax.set_title("Lower-rated hospitals miss targets more often (TX)")
ax.set_xlabel("CMS overall star rating"); ax.set_ylabel("% of results worse than expected")
ax.bar_label(ax.containers[0], fmt="%.0f%%"); plt.tight_layout(); plt.savefig("images/worse_by_star.png", dpi=150)
