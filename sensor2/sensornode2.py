#!/usr/bin/python3

#sensor 2
import json
import time
import paho.mqtt.client as mqtt_client
from collections import OrderedDict
import os

pub = mqtt_client.Client()
pub.connect("18.216.78.136", port=1883)

with open('datasensor.json', 'r') as f:
    data = f.read().split('\n')

data.remove('')

os.system('clear')
print("\033[1;37;44m\n Publishing.. \033[0;37;0m")
print("\033[0;30m")
a = 1
try:
    # Publish
    data2 = {}
    for i in data:
        time.sleep(2)
        temp = i.strip('{|}').split(', ')
        for i in temp:
            key, value = i.split(": ")
            key = key.strip("'")
            data2[key] = value

        timestamp = str(time.time())
        data3 = OrderedDict([
            ("ID", "2"),
            ("BRIGHTNESS", data2['BRIGHTNESS']),
            ("TEMPERATURE",  data2['TEMPERATURE']),
            ("HUMIDITY",  data2['HUMIDITY']),
            ("TIMESTAMP", timestamp)
        ]);
        data_up=json.dumps(data3)
        pub.publish("/sensor/2", data_up)
        print("%2d. "%(a), end='')
        print(data_up)
        a+=1

except KeyboardInterrupt:
    pub.disconnect()
    exit(0)
