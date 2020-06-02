#!/bin/sh -e

#Create new card
echo -n 'ID Gateway: '
read gatewayID
echo -n 'Username: '
read username
echo -n 'Password: '
read password

card='alice@iot-network'
JSON='{"$class": "org.gateway.datasensor.Gateway", "gatewayId": "'"$gatewayID"'", "username": "'"$username"'", "password": "'"$password"'"}'

echo 'Adding Participant...\b'
composer participant add -d "$JSON" -c ${card}
echo 'Issuing Identity...\b'
composer identity issue -u ${username} -a org.gateway.datasensor.Gateway#${gatewayID} -c ${card}
echo 'Importing Card...\b'
composer card import -f ${username}@iot-network.card
echo 'Done.'

#Copy to /card
cp $username@iot-network.card ~/card
