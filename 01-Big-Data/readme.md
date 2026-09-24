# 01 – Big Data

Rattrapage sur le cours de Big data.
Analyse du dataset de Cartofriches / Open Data.
Scénario : je suis investisseur et je souhaite trouver une grande friche à réhabiliter en espace culturel.

## Contenu

- `friches-standard-2026-06-15.csv` : dataset
- `analyse-friches.ipynb` : notebook avec nettoyage, analyse et visualisation des données
- `viz_histogramme_surfaces.png` : distribution des surfaces (parmis les friches "candidats")
- `viz_histogramme_surfaces_risque.png` : même distribution, sites pollués ou occupés en évidence

## Setup

```powershell
cd 01-Big-Data
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install pandas matplotlib jupyter
jupyter notebook analyse-friches.ipynb
```

Puis exécuter les cellules dans l’ordre.

## Dataset

Source Open Data : Cartofriches (friches en France).  
Fichier utilisé : `friches-standard-2026-06-15.csv` (~36k lignes).

## Vidéo

Lien YouTube (non répertorié) : https://www.youtube.com/watch?v=xuA8v_kWVwI

## Recherches web

- Rédaction du cours personnelles / projets fait en cours