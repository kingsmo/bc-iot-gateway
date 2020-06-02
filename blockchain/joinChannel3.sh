
# Join peer0.org1.example.com to the channel.
docker exec peer0.org2.gateway.com peer channel fetch config -o orderer.gateway.com:7050 -c getoway --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/gateway.com/msp/tlscacerts/tlsca.gateway.com-cert.pem
docker exec peer0.org2.gateway.com peer channel join -b getoway_config.block

# Join peer1.org1.example.com to the channel.
docker exec peer1.org2.gateway.com peer channel fetch config -o orderer.gateway.com:7050 -c getoway --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/gateway.com/msp/tlscacerts/tlsca.gateway.com-cert.pem
docker exec peer1.org2.gateway.com peer channel join -b getoway_config.block
