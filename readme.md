Noora Health – WhatsApp Message Analysis

This project loads raw WhatsApp message data into PostgreSQL, transforms it into a clean message-level table, validates the data, and visualizes key metrics using Streamlit and Plotly.

PROJECT STRUCTURE:

noora_health_assessment/
├── load_raw_data.py
├── streamlit_app.py
├── sql/
│   ├── transformed_messages.sql
│   ├── data_quality_checks.sql
│   └── final_views.sql
├── requirements.txt
└── README.md


1. Setup Instructions
Install dependencies
pip install pandas SQLAlchemy psycopg2-binary streamlit plotly openpyxl

Create PostgreSQL Database

Create a database named: noora_health

2. Load Raw Data into Postgres
Place the Excel file inside a /data folder:
This script:

Reads the Messages and Statuses sheets
Loads them as tables: raw_messages, raw_statuses

3. Build Transformed Table & Views
Run the SQL files in the /sql folder:
transformed_messages.sql → Creates the main cleaned table
data_quality_checks.sql → Duplicate & consistency checks
final_views.sql → Creates 4 gold-level views for the dashboard

4. Launch the Streamlit Dashboard
Start the app:
streamlit run streamlit_app.py


This dashboard visualizes:
Weekly total & active users
Fraction of read non-failed outbound messages
Time to read outbound messages
Outbound message status in the last 7 days

~ Summary ~

This project demonstrates:

Data ingestion (Excel → PostgreSQL)

Data transformation with SQL

Data validation & quality checks

Metrics visualization in Streamlit

Clean, modular project structure