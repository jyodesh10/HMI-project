import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ---- Load CSV ----
df = pd.read_csv("llm_interactions.csv")

# ---- Assign Category ----
def categorize(row):
    if row["UsedSuggestion"] and row["PromptRevision"]:
        return "Yes Suggestion"
    elif row["UsedSuggestion"] and not row["PromptRevision"]:
        return "No Revision"
    elif not row["UsedSuggestion"] and row["PromptRevision"]:
        return "Yes Revision"
    else:
        return "No Suggestion"

df["Category"] = df.apply(categorize, axis=1)

# ---- Categories and LLMs ----
categories = ["No Suggestion", "No Revision", "Yes Revision", "Yes Suggestion"]
llms = ["Cohere", "Gemini"]

# ---- Chart 1: All LLMs combined (step-by-step) ----
no_suggest_avg = df[df["Category"] == "No Suggestion"]["Rating"].mean()
no_revision_avg = df[df["Category"] == "No Suggestion"]["Rating"].mean()
yes_revision_avg = df[df["Category"] == "Yes Revision"]["Rating"].mean()
yes_suggest_avg = df[df["Category"] == "No Revision"]["Rating"].mean()

avg_all_df = pd.DataFrame({
    "Category": categories,
    "Rating": [no_suggest_avg, no_revision_avg, yes_revision_avg, yes_suggest_avg]
})

# ---- Plot 1 ----
sns.set_style("whitegrid")
plt.figure(figsize=(8,6))
ax = sns.barplot(
    x="Category", 
    y="Rating", 
    data=avg_all_df, 
    palette="Set2", 
    order=categories
)
plt.ylim(0,5)
plt.title("Average Rating by Category (All LLMs)")
plt.ylabel("Average Rating")
plt.xticks(rotation=15)

# ---- Add rating and n on top of each bar one by one ----

# No Suggest
patch = ax.patches[0]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[df["Category"] == "No Suggestion"])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=10)

# No Revision
patch = ax.patches[1]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[df["Category"] == "No Suggestion"])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=10)

# Yes Revision
patch = ax.patches[2]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[df["Category"] == "Yes Revision"])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=10)

# Yes Suggest
patch = ax.patches[3]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[df["Category"] == "No Revision"])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=10)

plt.tight_layout()
plt.show()


# ---- Chart 2: By LLM (step-by-step) ----
# Cohere averages
cohere_no_suggest = df[(df["LLM"]=="Cohere") & (df["Category"]=="No Suggestion")]["Rating"].mean()
cohere_no_revision = df[(df["LLM"]=="Cohere") & (df["Category"]=="No Suggestion")]["Rating"].mean()
cohere_yes_revision = df[(df["LLM"]=="Cohere") & (df["Category"]=="Yes Revision")]["Rating"].mean()
cohere_yes_suggest = df[(df["LLM"]=="Cohere") & (df["Category"]=="No Revision")]["Rating"].mean()

# Gemini averages
gemini_no_suggest = df[(df["LLM"]=="Gemini") & (df["Category"]=="No Suggestion")]["Rating"].mean()
gemini_no_revision = df[(df["LLM"]=="Gemini") & (df["Category"]=="No Suggestion")]["Rating"].mean()
gemini_yes_revision = df[(df["LLM"]=="Gemini") & (df["Category"]=="Yes Revision")]["Rating"].mean()
gemini_yes_suggest = df[(df["LLM"]=="Gemini") & (df["Category"]=="No Revision")]["Rating"].mean()

avg_llm_df = pd.DataFrame([
    {"LLM": "Cohere", "Category": "No Suggestion", "Rating": cohere_no_suggest},
    {"LLM": "Cohere", "Category": "No Revision", "Rating": cohere_no_revision},
    {"LLM": "Cohere", "Category": "Yes Revision", "Rating": cohere_yes_revision},
    {"LLM": "Cohere", "Category": "Yes Suggestion", "Rating": cohere_yes_suggest},
    {"LLM": "Gemini", "Category": "No Suggestion", "Rating": gemini_no_suggest},
    {"LLM": "Gemini", "Category": "No Revision", "Rating": gemini_no_revision},
    {"LLM": "Gemini", "Category": "Yes Revision", "Rating": gemini_yes_revision},
    {"LLM": "Gemini", "Category": "Yes Suggestion", "Rating": gemini_yes_suggest}
])

# ---- Plot 2 ----
plt.figure(figsize=(10,6))
ax = sns.barplot(
    x="Category", 
    y="Rating", 
    hue="LLM", 
    data=avg_llm_df, 
    palette="Set1",
    order=categories
)
plt.ylim(0,5)
plt.title("Average Rating by Category and LLM")
plt.ylabel("Average Rating")
plt.xticks(rotation=15)

# ---- Add numbers one by one ----

# Cohere - No Suggest
patch = ax.patches[0]  # first bar
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Cohere") & (df["Category"]=="No Suggestion")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

# Cohere - No Revision
patch = ax.patches[1]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Cohere") & (df["Category"]=="No Suggestion")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

# Cohere - Yes Revision
patch = ax.patches[2]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Cohere") & (df["Category"]=="Yes Revision")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

# Cohere - Yes Suggest
patch = ax.patches[3]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Cohere") & (df["Category"]=="No Revision")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

# Gemini - No Suggest
patch = ax.patches[4]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Gemini") & (df["Category"]=="No Suggestion")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

# Gemini - No Revision
patch = ax.patches[5]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Gemini") & (df["Category"]=="No Suggestion")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

# Gemini - Yes Revision
patch = ax.patches[6]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Gemini") & (df["Category"]=="Yes Suggestion")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

# Gemini - Yes Suggest
patch = ax.patches[7]
height = patch.get_height()
x = patch.get_x() + patch.get_width()/2
n = len(df[(df["LLM"]=="Gemini") & (df["Category"]=="No Suggestion")])
ax.text(x, height + 0.02, f"{height:.2f}\nn={n}", ha='center', va='bottom', fontsize=9)

plt.tight_layout()
plt.show()


