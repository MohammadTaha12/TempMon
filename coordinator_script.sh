#!/bin/bash

# Add environment variables
export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin

echo "$(date): Running coordinator_script.sh" >> /home/abu-taha/Desktop/temp/coordinator_script.log 2>> /home/abu-taha/Desktop/temp/coordinator_script_error.log

# Fetch list of switches from MariaDB
switches=$(/usr/bin/mysql -u root -p123456mm -e "USE tempmon; SELECT switch_id, ip_address FROM switches LIMIT 5;" -B -N)

# Loop through each switch and create collection tasks
while read -r switch; do
    switch_id=$(echo $switch | awk '{print $1}')
    ip_address=$(echo $switch | awk '{print $2}')
    
    # Create a task for the switch
    task="{\"switch_id\": \"$switch_id\", \"ip_address\": \"$ip_address\"}"
    
    # Start a collector for the task
    /usr/bin/python3 /home/abu-taha/Desktop/temp/collector_script.py "$task" &
done <<< "$switches"

# Start Grafana server if not running
if ! /usr/bin/pgrep -x "grafana-server" > /dev/null
then
    sudo /usr/bin/systemctl start grafana-server
fi

echo "$(date): Finished running coordinator_script.sh" >> /home/abu-taha/Desktop/temp/coordinator_script.log 2>> /home/abu-taha/Desktop/temp/coordinator_script_error.log
