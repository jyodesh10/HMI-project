import pandas as pd

# ---- Load CSV ----
csv_path = "llm_interactions.csv"
df = pd.read_csv(csv_path)

# ---- Overall counts ----
total_prompts = len(df)
suggestion_count = df["UsedSuggestion"].sum()
revision_count = df["PromptRevision"].sum()
neither_count = total_prompts - suggestion_count - revision_count

print(f"Total prompts: {total_prompts}")
print(f"Prompt Suggestions used: {suggestion_count} ({suggestion_count/total_prompts*100:.1f}%)")
print(f"Prompt Revisions done: {revision_count} ({revision_count/total_prompts*100:.1f}%)")
print(f"Neither used: {neither_count} ({neither_count/total_prompts*100:.1f}%)\n")

# ---- Counts by LLM ----
llm_counts = df.groupby("LLM")[["UsedSuggestion", "PromptRevision"]].sum()
llm_counts["TotalPrompts"] = df.groupby("LLM")["LLM"].count()
llm_counts["SuggestionPercent"] = llm_counts["UsedSuggestion"] / llm_counts["TotalPrompts"] * 100
llm_counts["RevisionPercent"] = llm_counts["PromptRevision"] / llm_counts["TotalPrompts"] * 100

print("Breakdown by LLM:")
print(llm_counts[["UsedSuggestion", "SuggestionPercent", "PromptRevision", "RevisionPercent"]])

# ---- Check 33% types and 50/50 LLM split ----
def check_distribution(df):
    types = {
        "Suggestion": df[df["UsedSuggestion"]],
        "Revision": df[df["PromptRevision"]],
        "Neither": df[(~df["UsedSuggestion"]) & (~df["PromptRevision"])]
    }
    
    for t, subset in types.items():
        total_type = len(subset)
        cohere_count = len(subset[subset["LLM"] == "Cohere"])
        gemini_count = len(subset[subset["LLM"] == "Gemini"])
        print(f"{t}: Total={total_type}, Cohere={cohere_count} ({cohere_count/total_type*100:.1f}%), Gemini={gemini_count} ({gemini_count/total_type*100:.1f}%)")

check_distribution(df)
