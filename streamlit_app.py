import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
import plotly.express as px

# DATABASE CONNECTION
DB_PASSWORD = "12345"
engine = create_engine(
    f"postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/noora_health"
)

def run_query(sql):
    return pd.read_sql(sql, engine)

st.title("Noora Health  WhatsApp Message Analysis")
st.write("Using transformed data & gold-level SQL views")

# -----------------------------------------
# 1️⃣ Weekly Total & Active Users
# -----------------------------------------
st.header("1. Weekly Total & Active Users")

df_users = run_query("SELECT * FROM vw_weekly_total_active_users")

fig1 = px.line(
    df_users,
    x="week_start",
    y=["total_users", "active_users"],
    labels={"value": "Users", "week_start": "Week"},
    title="Weekly Total vs Active Users"
)
st.plotly_chart(fig1, use_container_width=True)

# -----------------------------------------
# 2️⃣ Fraction of Non-failed Outbound Read
# -----------------------------------------
st.header("2. Read Fraction of Non-Failed Outbound Messages")

df_fraction = run_query("SELECT * FROM vw_fraction_non_failed_msgs_outbound")

fraction = float(df_fraction['fraction_read'][0])
st.metric("Read Fraction", f"{fraction:.2%}")

# -----------------------------------------
# 3️⃣ Read Delay in Minutes
# -----------------------------------------
st.header("3. Time to Read (Minutes)")

df_delay = run_query("SELECT * FROM vw_sent_read_time")

fig2 = px.histogram(
    df_delay,
    x="minutes_to_read",
    nbins=40,
    title="Distribution of Time to Read Outbound Messages (Minutes)"
)
st.plotly_chart(fig2, use_container_width=True)

# -----------------------------------------
# 4️⃣ Outbound Status in Last Week
# -----------------------------------------
st.header("4. Outbound Message Status (Last 7 Days)")

df_status = run_query("SELECT * FROM vw_outbound_status_last_week")

fig3 = px.bar(
    df_status,
    x="last_status",
    y="message_count",
    title="Outbound Messages by Status (Last Week)"
)
st.plotly_chart(fig3, use_container_width=True)
