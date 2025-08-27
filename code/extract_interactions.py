import json
import pandas as pd

# ---- Load JSON ----
with open("Hmi_project_final.json", "r", encoding="utf-8") as f:
    data = json.load(f)

rows = []

# ---- Loop through users ----
for user_id, user_info in data["data"].items():
    # user-level info
    age = user_info.get("age")
    gender = user_info.get("gender")
    occupation = user_info.get("occupation")
    experience = user_info.get("experience")
    email = user_info.get("email")

    # ---- Loop through interaction history ----
    history = user_info.get("__collections__", {}).get("history", {})
    for hist_id, hist in history.items():
        row = {
            "Age": age,
            "Gender": gender,
            "Occupation": occupation,
            "Experience": experience,
            "UsedSuggestion": hist.get("UsedSuggestion"),
            "PromptRevision": hist.get("PromptRevision"),
            "Rating": hist.get("rating"),
            "LLM": hist.get("selectedLLm"),
            "Date": hist.get("date", {}).get("__time__")
        }
        rows.append(row)

# ---- Save as CSV ----
df = pd.DataFrame(rows)
df.to_csv("llm_interactions.csv", index=False, encoding="utf-8")

print("✅ Extracted", len(df), "rows to llm_interactions.csv")
