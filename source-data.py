import requests
import pandas as pd
import duckdb
import json


con = duckdb.connect('f1.db')
endpoints = ["car_data", "drivers", "laps", "location", "meetings", "pit", "position", "race_control", "session", "stints", "team_radio", "weather"]

for ep in endpoints[4:5]:
  # Define the API endpoint and parameters
  url = f"https://api.openf1.org/v1/{ep}"
  headers = {
      "Content-Type": "application/json"
  }

  # Make the GET request
  response = requests.get(url, headers=headers)

  # Check the response status and handle the data
  if response.status_code == 200:
      data = response.json()  # Parse JSON response
      print(f"Data retrieved successfully for `{ep}`")
  else:
      print(f"Error: {response.status_code}, {response.text}")

  # Convert the JSON data to a DataFrame
  df = pd.DataFrame(data)

  # Save data to temporary database
  con.execute(f"CREATE TABLE {ep} AS SELECT * FROM df")



con.sql("DESCRIBE meetings")

con.sql("SELECT * FROM meetings WHERE year = 2025")


con.sql("""
SELECT
m.date_start
,circuit_short_name
,meeting_name
,w.session_key
,d.driver_number
,d.full_name
,d.name_acronym
,d.team_name
,d.team_colour
,d.headshot_url
,MAX(w.track_temperature) AS max_temp
,MIN(w.track_temperature) AS min_temp
,MAX(w.humidity) AS max_hum
,MIN(w.humidity) AS min_hum
,MAX(w.wind_speed) AS max_wind
,MIN(w.wind_speed) AS min_wind
,MAX(w.rainfall) AS max_rain
,MIN(w.rainfall) AS min_rain
,MAX(w.pressure) AS max_pressure
,MIN(w.pressure) AS min_pressure
,MAX(w.air_temperature) AS max_air_temp
,MIN(w.air_temperature) AS min_air_temp

FROM weather w
INNER JOIN meetings m ON m.meeting_key = w.meeting_key
INNER JOIN drivers d ON d.session_key = w.session_key
    AND d.meeting_key = m.meeting_key
WHERE year = 2025

GROUP BY
m.date_start
,circuit_short_name
,meeting_name
,w.session_key
,d.driver_number
,d.full_name
,d.name_acronym
,d.team_name
,d.team_colour
,d.headshot_url
""")




