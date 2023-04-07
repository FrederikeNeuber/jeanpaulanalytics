# jeanpaulanalytics

Analyses of letters from Jean Paul's surroundings ([jeanpaul-edition.de/](jeanpaul-edition.de/)) experimenting with metrics and methods from social media analytics. The analyses were conducted as part of a presentation at the conference 'Soziales Medium Brief. Sharen, Liken, Retweeten im 18. und 19. Jahrhundert. Neue Perspektiven auf die Briefkultur' (Berlin-Brandenburg Academy of Sciences and Humanities, June 24-26, 2021) and for the article 'Historische Korrespondenzen und Social Media Analytics. Eine experimentelle Analyse der Briefe aus Jean Pauls Umfeld'  comference proceedings (edited by Markus Bernauer, Selma Jahnke, Frederike Neuber, and Michael Rölcke; Summer 2023). 

The repository is primarily intended to supplement the above mentioned article in the conference proceedings.

# Contents

## data-source

Contains TEI files of the letters ([v.5.0](https://github.com/telota/jean_paul_briefe/releases/tag/v.5.0)) as well as normalized TEI versions (created with [CAB](https://kaskade.dwds.de/~moocow/software/DTA-CAB/). 

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
