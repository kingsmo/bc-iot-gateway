if [ -z ${1} ]; then
	ls | grep iot-network
	exit
fi

VERSION=$1
ORDERER_HOST=18.223.18.123
ORG1_HOST=3.133.216.254
ORG2_HOST=3.136.166.21

composer card delete -c PeerAdmin@byfn-network-org2
composer card delete -c PeerAdmin@byfn-network-org1
composer card delete -c bob@iot-network
composer card delete -c alice@iot-network

rm -rv alice
rm -rv bob


echo "INSERT_ORG1_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.gateway.com/peers/peer0.org1.gateway.com/tls/ca.crt > ./tmp/INSERT_ORG1_CA_CERT

echo "INSERT_ORG2_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org2.gateway.com/peers/peer0.org2.gateway.com/tls/ca.crt > ./tmp/INSERT_ORG2_CA_CERT

echo "INSERT_ORDERER_CA_CERT: "
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/gateway.com/orderers/orderer.gateway.com/tls/ca.crt > ./tmp/INSERT_ORDERER_CA_CERT


cat << EOF > ./byfn-network-org1.json
{
    "name": "byfn-network",
    "x-type": "hlfv1",
    "version": "1.0.0",
	"client": {
		"organization": "org1",
		"connection": {
			"timeout": {
				"peer": {
					"endorser": "2100",
					"eventHub": "2100",
					"eventReg": "2100"
				},
				"orderer": "2100"
			}
		}
	},
    "channels": {
        "getoway": {
            "orderers": [
                "orderer.gateway.com"
            ],
            "peers": {
                "peer0.org1.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.gateway.com",
                "peer1.org1.gateway.com"
            ],
            "certificateAuthorities": [
                "ca.org1.gateway.com"
            ]
        },
        "org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.gateway.com",
                "peer1.org2.gateway.com"
            ],
            "certificateAuthorities": [
                "ca.org2.gateway.com"
            ]
        }
    },
    "orderers": {
        "orderer.gateway.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.org1.gateway.com": {
            "url": "grpcs://${ORG1_HOST}:7051",
						"eventUrl": "grpc://${ORG1_HOST}:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.org1.gateway.com": {
            "url": "grpcs://${ORG1_HOST}:8051",
						"eventUrl": "grpc://${ORG1_HOST}:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.org2.gateway.com": {
            "url": "grpcs://${ORG2_HOST}:9051",
						"eventUrl": "grpc://${ORG2_HOST}:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.org2.gateway.com": {
            "url": "grpcs://${ORG2_HOST}:10051",
						"eventUrl": "grpc://${ORG2_HOST}:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.gateway.com": {
            "url": "https://${ORG1_HOST}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.gateway.com": {
            "url": "https://${ORG2_HOST}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF


cat << EOF > ./byfn-network-org2.json
{
    "name": "byfn-network",
    "x-type": "hlfv1",
    "version": "1.0.0",
	"client": {
		"organization": "org2",
		"connection": {
			"timeout": {
				"peer": {
					"endorser": "2100",
					"eventHub": "2100",
					"eventReg": "2100"
				},
				"orderer": "2100"
			}
		}
	},
    "channels": {
        "getoway": {
            "orderers": [
                "orderer.gateway.com"
            ],
            "peers": {
                "peer0.org1.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.gateway.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.gateway.com",
                "peer1.org1.gateway.com"
            ],
            "certificateAuthorities": [
                "ca.org1.gateway.com"
            ]
        },
        "org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.gateway.com",
                "peer1.org2.gateway.com"
            ],
            "certificateAuthorities": [
                "ca.org2.gateway.com"
            ]
        }
    },
    "orderers": {
        "orderer.gateway.com": {
            "url": "grpcs://${ORDERER_HOST}:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORDERER_CA_CERT`"
            }
        }
    },
    "peers": {
        "peer0.org1.gateway.com": {
            "url": "grpcs://${ORG1_HOST}:7051",
						"eventUrl": "grpc://${ORG1_HOST}:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer1.org1.gateway.com": {
            "url": "grpcs://${ORG1_HOST}:8051",
						"eventUrl": "grpc://${ORG1_HOST}:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG1_CA_CERT`"
            }
        },
        "peer0.org2.gateway.com": {
            "url": "grpcs://${ORG2_HOST}:9051",
						"eventUrl": "grpc://${ORG2_HOST}:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        },
        "peer1.org2.gateway.com": {
            "url": "grpcs://${ORG2_HOST}:10051",
						"eventUrl": "grpc://${ORG2_HOST}:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.gateway.com"
            },
            "tlsCACerts": {
                "pem": "`cat ./tmp/INSERT_ORG2_CA_CERT`"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.gateway.com": {
            "url": "https://${ORG1_HOST}:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.gateway.com": {
            "url": "https://${ORG2_HOST}:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

ORG1ADMIN="./crypto-config/peerOrganizations/org1.gateway.com/users/Admin@org1.gateway.com/msp"
ORG2ADMIN="./crypto-config/peerOrganizations/org2.gateway.com/users/Admin@org2.gateway.com/msp"

composer card create -p ./byfn-network-org1.json -u PeerAdmin -c $ORG1ADMIN/signcerts/A*.pem -k $ORG1ADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-org1.card
composer card create -p ./byfn-network-org2.json -u PeerAdmin -c $ORG2ADMIN/signcerts/A*.pem -k $ORG2ADMIN/keystore/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@byfn-network-org2.card

composer card import -f PeerAdmin@byfn-network-org1.card --card PeerAdmin@byfn-network-org1
composer card import -f PeerAdmin@byfn-network-org2.card --card PeerAdmin@byfn-network-org2

composer network install --card PeerAdmin@byfn-network-org1 --archiveFile iot-network@$VERSION.bna
composer network install --card PeerAdmin@byfn-network-org2 --archiveFile iot-network@$VERSION.bna

composer identity request -c PeerAdmin@byfn-network-org1 -u admin -s adminpw -d alice
composer identity request -c PeerAdmin@byfn-network-org2 -u admin -s adminpw -d bob

composer network start -c PeerAdmin@byfn-network-org1 -n iot-network -V $VERSION -o endorsementPolicyFile=./endorsement-policy.json -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem

# create card for alice, as business network admin
composer card create -p ./byfn-network-org1.json -u alice -n iot-network -c alice/admin-pub.pem -k alice/admin-priv.pem
composer card import -f alice@iot-network.card

# create card for bob, as business network admin
composer card create -p ./byfn-network-org2.json -u bob -n iot-network -c bob/admin-pub.pem -k bob/admin-priv.pem
composer card import -f bob@iot-network.card
