Production - Fit Model
===============================

<img arc="/Zzz-images/model.PNG" style="display: block; margin: auto;" />

## Project

- The code for this project should follow more stringent patterns of development-testing-production 
- The idea is to take the insights form the Data Science project and implement a "pipeline" that fits the model for production
- In Production, the same script is re-run so as to use more recent data to update the coefficients of the model
- The model is refitted on a regular, but infrequent, intervals, such as monthly, quarterly, etc.
- The updated model is made available to downstream applications that score the data


