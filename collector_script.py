import sys
import json
import influxdb
from pysnmp.hlapi import *

# إعداد InfluxDB
influx_client = influxdb.InfluxDBClient(host='localhost', port=8086, database='tempmon_data')

# وظيفة لمحاكاة الحصول على بيانات درجة الحرارة من ملف (لأغراض التوضيح)
def get_temperature_from_file(switch_id):
    file_path = f"/home/abu-taha/Desktop/temp/{switch_id}.snmprec"
    temperatures = []
    try:
        with open(file_path, 'r') as file:
            for line in file:
                parts = line.strip().split('|')
                if len(parts) >= 2:
                    oid, temperature = parts[0], parts[1]
                    temperatures.append(float(temperature))
                else:
                    raise ValueError("Invalid SNMP record format")
        return temperatures
    except Exception as e:
        print(f"Error reading SNMP record file: {e}")
        return None

# وظيفة لمعالجة المهمة
def process_task(task):
    switch_id = task['switch_id']
    ip_address = task['ip_address']
    
    # استرجاع درجة الحرارة من ملف سجل SNMP (للتوضيح)
    temperatures = get_temperature_from_file(switch_id)
    
    if temperatures:
        # كتابة البيانات إلى InfluxDB
        for temperature in temperatures:
            json_body = [
                {
                    "measurement": "temperature",
                    "tags": {
                        "switch_id": switch_id
                    },
                    "fields": {
                        "value": temperature
                    }
                }
            ]
            influx_client.write_points(json_body)

if __name__ == "__main__":
    task = json.loads(sys.argv[1])
    process_task(task)
