import sys
import os
import duckdb

con = duckdb.connect()
con.execute("CREATE TABLE raw_retail AS SELECT * FROM read_csv_auto('data/raw/online_retail.csv.gz')")

# if the cleaning file exists, run it first (we'll create it in Step 2)
if os.path.exists("sql/00_build_clean_tables.sql"):
    con.execute(open("sql/00_build_clean_tables.sql").read())

query = open(sys.argv[1]).read()
result = con.sql(query)
if result is not None:
    result.show(max_width=300, max_rows=100)
else:
    print("Done (no table to show)")