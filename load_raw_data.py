import pandas as pd
from sqlalchemy import create_engine, text

DB_PASSWORD = "12345"

DB_URL = f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/noora_health"


def main():
    excel_path = "data/noora_whatsapp_data.xlsx"

    # 1. Read Excel sheets
    messages_df = pd.read_excel(excel_path, sheet_name="Messages")
    statuses_df = pd.read_excel(excel_path, sheet_name="Statuses")

    # 2. Create DB engine
    engine = create_engine(DB_URL, echo=False)

    # 3. Drop old tables (if exist)
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS raw_messages"))
        conn.execute(text("DROP TABLE IF EXISTS raw_statuses"))

    # 4. Write new tables
    messages_df.to_sql("raw_messages", engine, if_exists="replace", index=False)
    statuses_df.to_sql("raw_statuses", engine, if_exists="replace", index=False)

    print("Loaded raw_messages and raw_statuses into Postgres")


if __name__ == "__main__":
    main()
