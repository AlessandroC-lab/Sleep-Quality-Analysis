# Sleep-Quality-Analysis

Analysis of sleep wellness as the exam session approaches, using data from the Empatica EmbracePlus wearable device.

## Project Overview
This project estimates key sleep parameters (sleep efficiency, HRV metrics, EDA events) across 9 nights to investigate how approaching exam stress impacts sleep quality. A key focus is the electrodermal activity (EDA) signal that correlates with sleep disturbances such as EDA storms.

The analysis pipeline covers:
- Data acquisition and conversion (from .avro to .mat via Python Colab script)
- Raw data management and night assembly
- Feature extraction from acceleration (sleep/wake detection via van Heels algorithm), PPG (HRV: IBI, RMSSD, SDNN, mean HR), and EDA (epochs, storms, average size, std, largest storm, event count)
- Statistical analysis with PCA (3 principal components explain 99.65% variance; PC1 dominated by EDA storm size and HR)


## How to Run
1. Place your processed .mat data files in a `data/` folder (or adjust paths in scripts).
2. Open MATLAB and run `Progetto_main.m`.
3. Outputs include sleep metrics, PCA results, and visualizations.


## Results Highlights
- PCA shows a strong correlation between EDA storm size, largest storm, and exam proximity ("countdown" variable).
- Sleep efficiency and HRV metrics degrade as exams approach. See PDF for plots and tables.
