import re
import duckdb
from pathlib import Path

con = duckdb.connect()
con.execute("CREATE TABLE raw_retail AS SELECT * FROM read_csv_auto('data/raw/online_retail.csv.gz')")

for sql_file in sorted(Path("sql").glob("*.sql")):
    query = sql_file.read_text()

    if sql_file.stem.startswith("00"):            # the cleaning file: just run it
        con.execute(query)
        print("clean tables built")
        continue

    # save each result as a table, e.g. 04_rfm_segments -> table "rfm_segments",
    # so later queries (05, 06) can use it
    table_name = re.sub(r"^\d+_", "", sql_file.stem)
    con.execute(f"CREATE OR REPLACE TABLE {table_name} AS {query.strip().rstrip(';')}")
    result = con.table(table_name).df()
    result.to_csv(f"outputs/tables/{sql_file.stem}.csv", index=False)
    print(f"saved outputs/tables/{sql_file.stem}.csv  ({len(result)} rows)")