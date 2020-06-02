#!/usr/bin/python3

import os
import time
import json
import paho.mqtt.client as mqtt_client
import jwt
import requests
from threading import Timer

session = requests.Session()
sub = mqtt_client.Client()

class CountDelay:
    def __init__(self, start_time = 0, count= 0):
        self._count = count
        self._start_time = start_time

    # set amount of data
    def set_amount_data(self, x):
        self._count += x

    # get amount of data
    def get_amount_data(self):
        return self._count

    # set amount of data
    def set_start_time(self, x):
        self._start_time = x

    # get amount of data
    def get_start_time(self):
        return self._start_time 

count = CountDelay()

def start():
    if count.get_amount_data()==0:
        count.set_start_time(time.time())
        t = Timer(300.0, timeout)
        t.start()

def timeout():
    sub.loop_stop()
    sub.disconnect()
    elapsed_time = 0;
    throughput = 0;
    if count.get_start_time() != 0:
        elapsed_time = time.time() - count.get_start_time()
        throughput = count.get_amount_data()/elapsed_time
    print("\033[1;37;0m\n======================== THROUGHTPUT RESULT ========================")
    print("\tTotal %d data recieved in %d seconds" %(count.get_amount_data(), elapsed_time))
    print("\tTherefore, throughput is %.3f data/s" %(throughput))
    print("====================================================================")
    exit(0)

def authorization():
    auth_token = input ("\033[0;30;0m\nInsert JWT Token to connect : ")
    print("\nAuthorizing.. ", end='', flush="False")
    time.sleep(1)
    hed = {'Authorization': 'Bearer ' + auth_token}

    auth_url = 'http://3.133.216.254:3000/auth/jwt/callback'
    try:
        r = session.get(auth_url, headers=hed)
        cookies = session.cookies.get_dict()
    except Exception:
        print('\033[31m\nCan\'t connect\033[30m\n')
        exit(0)

    try:
        access_token = (cookies['access_token'])
    except Exception:
        access_token = ''

    if access_token == '':
        print('\033[31mFAIL.')
        time.sleep(0.5)
        print('Please try again.')
        return authorization()
    else:
        print('\033[32mSUCCESS.')
        time.sleep(0.5)
        print('Successfully authenticated.')
        time.sleep(1.2)
        return access_token

def clear_data():
    url_api_data = "http://3.133.216.254:3000/api/DataSensor"
    response = session.get(url_api_data)
    result = (response.text)
    result = result.replace('[', '').replace(']', '')

    if(result!=""):
        result = result.replace('"', '').replace('{','').split('},')

        dataSensorId = []
        data2 = {}
        for i in result:
            temp = i.split(',')
            for i in temp:
                key, value = i.split(":")
                data2[key] = value

            dataSensorId.append(data2['dataSensorId']);

        print("\nThere are", len(dataSensorId),"data on blockchain")
        confirm = input ("Are you sure want to delete them?(y/n)")
        if(confirm=="y" or confirm=="Y"):
            print("\nDeleting.. ", end='', flush="False")
            time.sleep(1)
            for i in dataSensorId:
                url_delete = url_api_data+"/"+i
                response = session.delete(url_delete)

            print("\033[32mCleared.")
        elif(confirm=="n" or confirm=="N"):
            print("OK.")
        else:
            clear_data()
    else:
        print("\nAlready cleared.")

    print("\033[32m\nStart subscribing..")
    time.sleep(1.5)

def handle_message(client, object, msg):
    url_api_data = "http://3.133.216.254:3000/api/DataSensor"
    millis = int(round(time.time() * 1000))
    delivered_time = time.time()

    #Penerimaan data
    data = msg.payload.decode()
    data_in = {}
    temp = data.strip('{|}').split(', ')
    for i in temp:
        key, value = i.split(": ")
        key = key.strip("'")
        data_in[key] = value

    print("\n======================================================")
    print("%-11s : %s " % ("ID DATA" , str(data_in["ID_DATA"])))
    print("%-11s : %s " % ("SENSOR ID" , str(data_in["ID"])))
    print("%-11s : %s " % ("BRIGHTNESS" , str(data_in["BRIGHTNESS"])))
    print("%-11s : %s " % ("TEMPERATURE" , str(data_in["TEMPERATURE"])))
    print("%-11s : %s " % ("HUMIDITY" , str(data_in["HUMIDITY"])))
    print("======================================================")

    #Pengolahan struktur data sensor
    data_sensor = {
                  "$class": "org.gateway.datasensor.DataSensor",
                  "dataSensorId" : str(data_in["ID_DATA"]),
                  "sensorId" : str(data_in["ID"]),
                  "brightness": str(data_in["BRIGHTNESS"]),
                  "temperature": str(data_in["TEMPERATURE"]),
                  "humidity": str(data_in["HUMIDITY"])
                  }

    #Pengiriman data sensor ke blockchain
    print("Sending to blockchain..", end='',flush="False")
    response = session.post(url_api_data, json=data_sensor)
    print("\033[32m",response.status_code,'\033[30m')

    count.set_amount_data(1)

def main():
    sub.connect("18.216.78.136", 1883)

    try:
        #Insert JWT Token
        os.system('clear')
        print("\033[1;37;44m\nStep 1: Insert JWT Token ")
        token = authorization()

        os.system('clear')
        print("\033[1;37;44m\nStep 2: Clear Data on Blockchain \033[1;37;0m")
        clear_data()

        os.system('clear')
        print("\033[1;37;44m\n Subscribing.. \n\033[1;37;0m")

        sub.on_message = handle_message

        sub.subscribe("/sensor/#", qos=2)
        sub.loop_forever()

    except (KeyboardInterrupt, Exception) as e:
        print(e)
        timeout();

if __name__== "__main__":
  main()
