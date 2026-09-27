import gzip
import shutil
import urllib.request

URL = ("https://raw.githubusercontent.com/databricks/Spark-The-Definitive-Guide/"
       "master/data/retail-data/all/online-retail-dataset.csv")
OUT = "data/raw/online_retail.csv.gz"

print("Downloading... (45 MB, may take a minute)")
with urllib.request.urlopen(URL) as src, gzip.open(OUT, "wb") as dst:
    shutil.copyfileobj(src, dst)          # download + compress at the same time
print(f"Saved -> {OUT}")