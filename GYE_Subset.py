import pandas as pd

Mt = pd.read_csv('Montana.csv')
Wy = pd.read_csv('Wyoming.csv')
Id = pd.read_csv('Idaho.csv')
splist = pd.read_csv('spList.csv')

GreaterYellowstone = pd.concat([Mt, Wy, Id], ignore_index=True, axis=0)
GreaterYellowstone = pd.merge(GreaterYellowstone, splist, on='AOU', how='left')  

locs = pd.read_csv('routes.csv', encoding='latin-1')
locs = locs[(locs["StateNum"] == 53) | (locs["StateNum"] == 92) | (locs["StateNum"] == 33)]
locs = locs.drop('CountryNum', axis=1)

GreaterYellowstone = pd.merge(GreaterYellowstone, locs, on=['StateNum','Route'])

GreaterYellowstone.to_csv('GYE.csv')
