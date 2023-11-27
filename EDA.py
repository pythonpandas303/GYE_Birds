# -*- coding: utf-8 -*-
"""
Created on Sun Nov 26 18:41:05 2023

@author: megal
"""

import pandas as pd

gye = pd.read_csv('Clipped_GYE_Birds.csv')

# Dropping all years prior to 1990

gye = gye[gye["Year"] >= 1990]

gye.dtypes

# StateNum          int64
# Route             int64
# RPID              int64
# Year              int64
# AOU               int64
# StopTotal         int64
# SpeciesTotal      int64
# Common_Name      object
# Order            object
# Family           object
# Genus            object
# Species          object
# RouteName        object
# Latitude        float64
# Longitude       float64
# BCR               int64

gye.shape

# (42085, 16)

gye.isnull().sum()

# StateNum        0
# Route           0
# RPID            0
# Year            0
# AOU             0
# StopTotal       0
# SpeciesTotal    0
# Common_Name     0
# Order           0
# Family          0
# Genus           0
# Species         0
# RouteName       0
# Latitude        0
# Longitude       0
# BCR             0
# dtype: int64

# concat genus and species to 'SP'

gye['SP'] = gye['Genus'] + ' ' + gye['Species']

# Creating new data frame, grouping by SP, describing Species total

SpTotal = gye.groupby('SP')['SpeciesTotal'].describe()

SpTotal.to_csv('SpeciesTotals.csv')


# Same as above, but agg'd by year

YearSPTotal = gye.groupby(['SP', 'Year']).agg({'SpeciesTotal': ['sum','mean']}).reset_index()

YearSPTotal.to_csv('YearSpeciesTotal.csv')

