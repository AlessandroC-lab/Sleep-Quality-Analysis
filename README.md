# Sleep-Quality-Analysis

Analysis of sleep wellness as the exam session approaches, using data from the Empatica EmbracePlus wearable device. [file:29]

## Project Overview
This project estimates key sleep parameters (sleep efficiency, HRV metrics, EDA events) across 9 nights to investigate how approaching exam stress impacts sleep quality. A key focus is the electrodermal activity (EDA) signal, which correlates with sleep disturbances like EDA storms.

The analysis pipeline covers:
- Data acquisition and conversion (from .avro to .mat via Python Colab script)
- Raw data management and night assembly
- Feature extraction from acceleration (sleep/wake detection via van Heels algorithm), PPG (HRV: IBI, RMSSD, SDNN, mean HR), and EDA (epochs, storms, average size, std, largest storm, event count)
- Statistical analysis with PCA (3 principal components explain 99.65% variance; PC1 dominated by EDA storm size and HR) [file:29]

## Files
| File | Description |
|------|-------------|
| `Progetto_main.m` | Main script to run the full pipeline |
| `AccProcessing.m` | Sleep/wake detection and acceleration processing |
| `PPGProcessing.m` | HRV extraction (IBI, RMSSD, SDNN, mean HR) |
| `EDAProcessing.m` | EDA filtering, event/storm detection |
| `NightsAssembling.m` | Combines data across nights|
| `PCA_analysis.m` | Principal component analysis|
| `DataSave.m` | Data storage and management|
| `ProgettoEmpatica_Cardia.pdf` | Full project report with results and figures |

## How to Run
1. Place your processed .mat data files in a `data/` folder (or adjust paths in scripts).
2. Open MATLAB and run `Progetto_main.m`.
3. Outputs include sleep metrics, PCA results, and visualizations.

**Dependencies**: MATLAB with Signal Processing Toolbox recommended.

## Results Highlights
- PCA shows strong correlation between EDA storm size, largest storm, and exam proximity ("countdown" variable).
- Sleep efficiency and HRV metrics degrade as exams approach. See PDF for plots and tables. 
