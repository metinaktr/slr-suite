# Manual Reference Coding and Classification Evaluation Protocol

This protocol must be completed with independently coded records before any accuracy claim is reported.

1. Freeze the evaluation datasets and record their provenance and inclusion criteria.
2. Draw a reproducible sample using a recorded random seed.
3. Give two independent coders the codebook without model predictions.
4. Record labels in separate copies of `manual_coding_template.csv` and reconcile only after independent coding is complete.
5. Document disagreements and create a consensus reference label.
6. Run `Rscript experiments/evaluate_classification.R <completed.csv> <metrics.csv>`.
7. Report the sample size, class prevalence, Cohen's kappa, precision, recall, and F1 with the evaluation date and software commit.

Empty template rows are examples, not validation evidence. No metric may be presented as an independent result until the completed coding file and protocol record are archived.
