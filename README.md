# jeanpaulanalytics

Auswertungen der Briefe aus dem Umfeld Jean Paul ([jeanpaul-edition.de/](jeanpaul-edition.de/)) mit Methoden der Social Media Analytics.
Es handelt sich dabei um Experimente, die im Rahmen eines Vortrags auf der Tagung "Soziales Medium Brief. Sharen, Liken, Retweeten im 18. und 19. Jahrhundert. Neue Perspektiven auf die Briefkultur" (Berlin-Brandenburgische Akademie der Wissenschaften, 24.-26.6.2021) vorgestellt wurden. Die Auswertungen entsprechen nicht denen in den Vortragsfolien, sondern zeigen die Ergebnisse, die im Rahmen eines Artikels im gleichnamigen Tagungsband publiziert wurden (hrsg. von Markus Bernauer, Selma Jahnke, Frederike Neuber und Michael Rölcke; Sommer 2023). 

# Contents

## data-source

Contains TEI files of the letters ([v.5.0](https://github.com/telota/jean_paul_briefe/releases/tag/v.5.0)) in as well as normalized TEI versions (created with [CAB](https://kaskade.dwds.de/~moocow/software/DTA-CAB/). 

The index files ('register') are currently only available within the project.

## data-analysis

Data used for analysis: TEI files reduced to metadata and various plain text collections for sentiment analysis (see ../scripts/preprocessing)

## scripts

Script for the evaluation of the metadata as well as various scripts for preprocessing of the data (The execution of the scripts is done via the .bat files, thus a Saxon processor is required. Additionally further paths (e. g. data-source) have to be adapted when reusing scripts).

## results-csv (and results-viz)

Files starting with 'metadata-' are the result of ../scripts/paper.bat. 
* metadata-corpus provides a simple overview of the corpus
* metadata-letters-year shows the distribution of letters per year in the whole corpus
* metadata-persons-reach includes all letters per sender as well as contacts with different receivers
* metadata-topics-years gives an overview of the distribution of topics (as tagged by the editors) per year

Files starting with 'sentiment-' were downloaded from [SentText](https://thomasschmidtur.pythonanywhere.com/) (input data see ../data-analysis/sentiment).
* sentiment-f_a_brockhaus shows the sentiment score of the single letters by Friedrich Arnold Brockhaus in chronological order
* sentiment-sender-min20 provides a list of all senders which have written at least 20 letters in the corpus and the overall sentiment score of their letters

For visualizations see ../result-viz.

# License

[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0)

# Contact

Frederike Neuber: neuber@bbaw.de
