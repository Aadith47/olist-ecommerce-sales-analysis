import os
import sqlite3
import pandas as pd

data_folder = "data"
db_file = "olist.db"

# table name : csv file name
csv_files = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}

conn = sqlite3.connect(db_file)

for table_name, file_name in csv_files.items():
    path = os.path.join(data_folder, file_name)

    if not os.path.exists(path):
        print("missing file:", path)
        continue

    # utf-8-sig so a hidden character at the start of a file can't break the column names
    df = pd.read_csv(path, encoding="utf-8-sig")
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(table_name, "loaded,", len(df), "rows")

conn.close()
print("done. database file:", db_file)