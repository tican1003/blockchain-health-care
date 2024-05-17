#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $6)
    local CP=$(one_line_pem $7)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${PEER}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${P1PORT}/$4/" \
        -e "s/\${CAPORT}/$5/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $6)
    local CP=$(one_line_pem $7)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${PEER}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${P1PORT}/$4/" \
        -e "s/\${CAPORT}/$5/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

## prepare connection profile for orghospital
ORG=Hospital
PEER=hospital
P0PORT=4444
P1PORT=4454
CAPORT=4400
PEERPEM=organizations/peerOrganizations/hospital/tlsca/tlsca.hospital-cert.pem
CAPEM=organizations/peerOrganizations/hospital/ca/ca.hospital-cert.pem

echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/hospital/connection-hospital.json
echo "$(yaml_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/hospital/connection-hospital.yaml
# save another copy of json connection profile in a different directory
echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > network-config/network-config-hospital.json

## prepare connection profile for orgpatient
ORG=Patient
PEER=patient
P0PORT=5555
P1PORT=5565
CAPORT=5500
PEERPEM=organizations/peerOrganizations/patient/tlsca/tlsca.patient-cert.pem
CAPEM=organizations/peerOrganizations/patient/ca/ca.patient-cert.pem

echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/patient/connection-patient.json
echo "$(yaml_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/patient/connection-patient.yaml
# save another copy of json connection profile in a different directory
echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > network-config/network-config-patient.json

## prepare connection profile for orgpharmacy
ORG=Pharmacy
PEER=pharmacy
P0PORT=6666
P1PORT=6676
CAPORT=6600
PEERPEM=organizations/peerOrganizations/pharmacy/tlsca/tlsca.pharmacy-cert.pem
CAPEM=organizations/peerOrganizations/pharmacy/ca/ca.pharmacy-cert.pem

echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/pharmacy/connection-pharmacy.json
echo "$(yaml_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/pharmacy/connection-pharmacy.yaml
# save another copy of json connection profile in a different directory
echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > network-config/network-config-pharmacy.json

## prepare connection profile for orginsurance
ORG=Insurance
PEER=insurance
P0PORT=7777
P1PORT=7787
CAPORT=7700
PEERPEM=organizations/peerOrganizations/insurance/tlsca/tlsca.insurance-cert.pem
CAPEM=organizations/peerOrganizations/insurance/ca/ca.insurance-cert.pem

echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/insurance/connection-insurance.json
echo "$(yaml_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/insurance/connection-insurance.yaml
# save another copy of json connection profile in a different directory
echo "$(json_ccp $ORG $PEER $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > network-config/network-config-insurance.json




