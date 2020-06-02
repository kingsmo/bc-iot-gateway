#!/usr/bin/python3

#sensor 1
import json
import time
import datetime
import paho.mqtt.client as mqtt_client
from collections import OrderedDict
import os

pub = mqtt_client.Client()
pub.connect("192.168.56.7", port=1883)

with open('datasensor.json', 'r') as f:
        data = f.read().split('\n')

data.remove('')

os.system('clear')
print("\033[1;37;44m\n Publishing..\n\033[1;37;40m")
a = 1
try:
        # Publish
        data2 = {}
        for i in data:
                time.sleep(1)
                temp = i.strip('{|}').split(', ')
                for i in temp:
                        key, value = i.split(": ")
                        key = key.strip("'")
                        data2[key] = value

                timestamp = str(datetime.datetime.now())
                data3 = OrderedDict([
                        ("ID", "1"),
                        ("BRIGHTNESS", data2['BRIGHTNESS']),
                        ("TEMPERATURE",  data2['TEMPERATURE']),
                        ("HUMIDITY",  data2['HUMIDITY']),
                        ("TIMESTAMP", timestamp)
                ]);
                data_up=json.dumps(data3)
                pub.publish("/sensor/1", data_up)
                print("%d. "%(a), end='')
                print(data_up)
                print(datetime.datetime.now())
                a+=1

except KeyboardInterrupt:
    pub.disconnect()
    exit(0)
