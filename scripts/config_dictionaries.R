# =====================================================
# scripts/config_dictionaries.R
# TCCM and Bibliometric Analysis Dictionary Configuration
# =====================================================

TCCM_DICTIONARIES <- list(
  "Theory" = list(
    "Utilitarian Ethics"      = c("utilitarian", "utility", "consequence[- ]based", "greatest happiness"),
    "Deontological Ethics"    = c("deontolog", "duty[- ]based", "categorical imperative", "moral duty"),
    "Virtue Ethics"           = c("virtue ethic", "aristotle", "phronesis", "character virtue"),
    "Rights-Based Ethics"     = c("human right", "autonomy", "privacy right", "moral rights"),
    "Care Ethics"             = c("ethic(s)? of care", "care ethic", "empathy", "relational ethic"),
    "Social Contract Theory"  = c("social contract", "contractarian", "societal agreement", "legitimacy")
  ),
  "Context" = list(
    "Tourism"         = c("tourism", "hospitality", "travel", "destination", "hotel"),
    "Healthcare"      = c("healthcare", "hospital", "medical", "patient"),
    "Banking/Finance" = c("bank(ing)?", "fintech", "financial", "insurance"),
    "SMEs"            = c("\\bsme(s)?\\b", "small and medium", "kobi"),
    "Public Sector"   = c("public sector", "government", "municipality"),
    "IT/IS"           = c("\\bit\\b", "information systems?", "software development")
  ),
  "Characteristics" = list(
    "Ethical AI"      = c("fairness", "bias", "accountability", "transparency", "responsible ai"),
    "Privacy"         = c("privacy", "data protection", "confidentiality"),
    "Trust & Safety"  = c("trust", "reliability", "integrity", "safety"),
    "Sustainability"  = c("sustainab", "csr", "triple bottom line"),
    "Dark Side"       = c("surveillance", "addiction", "autonomy loss")
  ),
  "Methodology" = list(
    "Survey"          = c("survey", "questionnaire"),
    "PLS-SEM"         = c("pls[- ]sem", "partial least squares"),
    "Qualitative"     = c("qualitative", "interview", "content analysis"),
    "Experiment"      = c("experiment", "lab study"),
    "Bibliometric"    = c("bibliometric", "systematic review", "\\bslr\\b")
  ),
  "Moderators" = list(
    "Age"        = c("\\bage\\b", "young", "old", "elderly"),
    "Gender"     = c("\\bgender\\b", "male", "female", "woman", "man"),
    "Culture"    = c("culture", "cultural", "cross[- ]cultural")
  )
)

message(">> [CONFIG] Academic dictionaries were loaded successfully.")
