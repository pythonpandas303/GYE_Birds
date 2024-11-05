# -*- coding: utf-8 -*-
"""
Created on Thu Oct 10 09:40:29 2024

@author: megal
"""

import pandas as pd
import matplotlib.pyplot as plt
import os

os.chdir('C:\\Users\\megal\\Desktop\\Data')

abun_df = pd.read_csv('GYE_Songbird_Abundance_80.csv')
trend_df = pd.read_csv('GYE_Songbird_Trends_80.csv')


output_dir = "species_plots_4"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)


species_list = abun_df['species'].unique()


for species in species_list:
    species_abun_df = abun_df[(abun_df['species'] == species) & (abun_df['region'] == 'continent')]
    species_trend_df = trend_df[(trend_df['species'] == species) & (trend_df['region'] == 'continent')]

    
    if species_abun_df.empty or species_trend_df.empty:
        continue

    
    years = species_abun_df['year']
    index = species_abun_df['index']  
    index_q_0_05 = species_abun_df['index_q_0.05']
    index_q_0_95 = species_abun_df['index_q_0.95']
    obs_mean = species_abun_df['obs_mean']  

    #Here a mean calculation is performed to determine mean routes over temporal scale
    mean_n_routes = species_abun_df['n_routes'].mean()

    
    trend_value = species_trend_df['trend'].values[0]
    trend_q_0_05 = species_trend_df['trend_q_0.05'].values[0]
    trend_q_0_95 = species_trend_df['trend_q_0.95'].values[0]

    #Here a logical statement is included to determine significance
    if trend_q_0_05 > 0 or trend_q_0_95 < 0:
        significance = "Significant at 90% CI"
    else:
        significance = "Not significant at 90% CI"

    
    plt.figure(figsize=(10, 6))

    
    plt.plot(years, index, label="Index of Relative Abundance", color="blue", linewidth=2)

    
    plt.scatter(years, obs_mean, color="slategrey", label="Observed Mean", zorder=5)

    
    plt.fill_between(years, index_q_0_05, index_q_0_95, color='lightgrey', alpha=0.5, label="90% Confidence Interval")

    
    plt.grid(True, which='both', linestyle='--', linewidth=0.7, color='gray', alpha=0.7)

    
    plt.xlabel("Year")
    plt.ylabel("Relative Abundance")
    plt.title(f"{species} in the GYE, 1980-2022")

    
    textstr = f"Trend : {trend_value:.2f}\nMean Routes: {mean_n_routes:.1f}\n{significance}"

    
    plt.subplots_adjust(right=0.75) 

    
    plt.text(1.07, 0.75, textstr, transform=plt.gca().transAxes, fontsize=12,
             verticalalignment='center', bbox=dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="white"))

    
    plt.legend(loc='upper left', bbox_to_anchor=(1.05, 1))

    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f"{species}_abundance_plot.png"))

    
    plt.close()

print(f"Plots executed and saved in the directory: {output_dir}")