#!/bin/bash

function createHospital() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/hospital/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/hospital/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:4400 --caname ca-hospital --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-4400-ca-hospital.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-4400-ca-hospital.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-4400-ca-hospital.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-4400-ca-hospital.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/hospital/msp/config.yaml

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy hospital's CA cert to hospital's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p ${PWD}/organizations/peerOrganizations/hospital/msp/tlscacerts
  cp ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem ${PWD}/organizations/peerOrganizations/hospital/msp/tlscacerts/ca.crt

  # Copy hospital's CA cert to hospital's /tlsca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/hospital/tlsca
  cp ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem ${PWD}/organizations/peerOrganizations/hospital/tlsca/tlsca.hospital-cert.pem

  # Copy hospital's CA cert to hospital's /ca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/hospital/ca
  cp ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem ${PWD}/organizations/peerOrganizations/hospital/ca/ca.hospital-cert.pem

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-hospital --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-hospital --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-hospital --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-hospital --id.name hospitaladmin --id.secret hospitaladminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:4400 --caname ca-hospital -M ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/msp --csr.hosts peer0.hospital --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:4400 --caname ca-hospital -M ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/msp --csr.hosts peer1.hospital --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/hospital/msp/config.yaml ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/msp/config.yaml
  cp ${PWD}/organizations/peerOrganizations/hospital/msp/config.yaml ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/msp/config.yaml

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:4400 --caname ca-hospital -M ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/tls --enrollment.profile tls --csr.hosts peer0.hospital --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null


  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:4400 --caname ca-hospital -M ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/tls --enrollment.profile tls --csr.hosts peer1.hospital --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

 # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/tls/signcerts/* ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/tls/keystore/* ${PWD}/organizations/peerOrganizations/hospital/peers/peer0.hospital/tls/server.key

  cp ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/tls/signcerts/* ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/tls/keystore/* ${PWD}/organizations/peerOrganizations/hospital/peers/peer1.hospital/tls/server.key

  infoln "Generating the user msp"

  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:4400 --caname ca-hospital -M ${PWD}/organizations/peerOrganizations/hospital/users/User1@hospital/msp --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/hospital/msp/config.yaml ${PWD}/organizations/peerOrganizations/hospital/users/User1@hospital/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://hospitaladmin:hospitaladminpw@localhost:4400 --caname ca-hospital -M ${PWD}/organizations/peerOrganizations/hospital/users/Admin@hospital/msp --tls.certfiles ${PWD}/organizations/fabric-ca/hospital/ca-cert.pem

  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/hospital/msp/config.yaml ${PWD}/organizations/peerOrganizations/hospital/users/Admin@hospital/msp/config.yaml
}
function createPatient() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/patient/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/patient/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:5500 --caname ca-patient --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-5500-ca-patient.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-5500-ca-patient.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-5500-ca-patient.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-5500-ca-patient.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/patient/msp/config.yaml

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy patient's CA cert to patient's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p ${PWD}/organizations/peerOrganizations/patient/msp/tlscacerts
  cp ${PWD}/organizations/fabric-ca/patient/ca-cert.pem ${PWD}/organizations/peerOrganizations/patient/msp/tlscacerts/ca.crt

  # Copy patient's CA cert to patient's /tlsca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/patient/tlsca
  cp ${PWD}/organizations/fabric-ca/patient/ca-cert.pem ${PWD}/organizations/peerOrganizations/patient/tlsca/tlsca.patient-cert.pem

  # Copy patient's CA cert to patient's /ca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/patient/ca
  cp ${PWD}/organizations/fabric-ca/patient/ca-cert.pem ${PWD}/organizations/peerOrganizations/patient/ca/ca.patient-cert.pem

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-patient --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-patient --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-patient --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-patient --id.name patientadmin --id.secret patientadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5500 --caname ca-patient -M ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/msp --csr.hosts peer0.patient --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:5500 --caname ca-patient -M ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/msp --csr.hosts peer1.patient --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/patient/msp/config.yaml ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/msp/config.yaml
  cp ${PWD}/organizations/peerOrganizations/patient/msp/config.yaml ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/msp/config.yaml

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5500 --caname ca-patient -M ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/tls --enrollment.profile tls --csr.hosts peer0.patient --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null


  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:5500 --caname ca-patient -M ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/tls --enrollment.profile tls --csr.hosts peer1.patient --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

 # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/tls/signcerts/* ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/tls/keystore/* ${PWD}/organizations/peerOrganizations/patient/peers/peer0.patient/tls/server.key

  cp ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/tls/signcerts/* ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/tls/keystore/* ${PWD}/organizations/peerOrganizations/patient/peers/peer1.patient/tls/server.key

  infoln "Generating the user msp"

  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:5500 --caname ca-patient -M ${PWD}/organizations/peerOrganizations/patient/users/User1@patient/msp --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/patient/msp/config.yaml ${PWD}/organizations/peerOrganizations/patient/users/User1@patient/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://patientadmin:patientadminpw@localhost:5500 --caname ca-patient -M ${PWD}/organizations/peerOrganizations/patient/users/Admin@patient/msp --tls.certfiles ${PWD}/organizations/fabric-ca/patient/ca-cert.pem

  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/patient/msp/config.yaml ${PWD}/organizations/peerOrganizations/patient/users/Admin@patient/msp/config.yaml
}
function createPharmacy() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/pharmacy/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/pharmacy/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:6600 --caname ca-pharmacy --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-6600-ca-pharmacy.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-6600-ca-pharmacy.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-6600-ca-pharmacy.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-6600-ca-pharmacy.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/pharmacy/msp/config.yaml

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy pharmacy's CA cert to pharmacy's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p ${PWD}/organizations/peerOrganizations/pharmacy/msp/tlscacerts
  cp ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem ${PWD}/organizations/peerOrganizations/pharmacy/msp/tlscacerts/ca.crt

  # Copy pharmacy's CA cert to pharmacy's /tlsca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/pharmacy/tlsca
  cp ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem ${PWD}/organizations/peerOrganizations/pharmacy/tlsca/tlsca.pharmacy-cert.pem

  # Copy pharmacy's CA cert to pharmacy's /ca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/pharmacy/ca
  cp ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem ${PWD}/organizations/peerOrganizations/pharmacy/ca/ca.pharmacy-cert.pem

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-pharmacy --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-pharmacy --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-pharmacy --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-pharmacy --id.name pharmacyadmin --id.secret pharmacyadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6600 --caname ca-pharmacy -M ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp --csr.hosts peer0.pharmacy --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:6600 --caname ca-pharmacy -M ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/msp --csr.hosts peer1.pharmacy --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/msp/config.yaml
  cp ${PWD}/organizations/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/msp/config.yaml

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6600 --caname ca-pharmacy -M ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls --enrollment.profile tls --csr.hosts peer0.pharmacy --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null


  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:6600 --caname ca-pharmacy -M ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls --enrollment.profile tls --csr.hosts peer1.pharmacy --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

 # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/signcerts/* ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/keystore/* ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer0.pharmacy/tls/server.key

  cp ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/signcerts/* ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/keystore/* ${PWD}/organizations/peerOrganizations/pharmacy/peers/peer1.pharmacy/tls/server.key

  infoln "Generating the user msp"

  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:6600 --caname ca-pharmacy -M ${PWD}/organizations/peerOrganizations/pharmacy/users/User1@pharmacy/msp --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/organizations/peerOrganizations/pharmacy/users/User1@pharmacy/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://pharmacyadmin:pharmacyadminpw@localhost:6600 --caname ca-pharmacy -M ${PWD}/organizations/peerOrganizations/pharmacy/users/Admin@pharmacy/msp --tls.certfiles ${PWD}/organizations/fabric-ca/pharmacy/ca-cert.pem

  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/pharmacy/msp/config.yaml ${PWD}/organizations/peerOrganizations/pharmacy/users/Admin@pharmacy/msp/config.yaml
}
function createInsurance() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/insurance/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/insurance/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7700 --caname ca-insurance --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7700-ca-insurance.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7700-ca-insurance.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7700-ca-insurance.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7700-ca-insurance.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/insurance/msp/config.yaml

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy insurance's CA cert to insurance's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p ${PWD}/organizations/peerOrganizations/insurance/msp/tlscacerts
  cp ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem ${PWD}/organizations/peerOrganizations/insurance/msp/tlscacerts/ca.crt

  # Copy insurance's CA cert to insurance's /tlsca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/insurance/tlsca
  cp ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem ${PWD}/organizations/peerOrganizations/insurance/tlsca/tlsca.insurance-cert.pem

  # Copy insurance's CA cert to insurance's /ca directory (for use by clients)
  mkdir -p ${PWD}/organizations/peerOrganizations/insurance/ca
  cp ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem ${PWD}/organizations/peerOrganizations/insurance/ca/ca.insurance-cert.pem

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-insurance --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-insurance --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-insurance --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-insurance --id.name insuranceadmin --id.secret insuranceadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7700 --caname ca-insurance -M ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/msp --csr.hosts peer0.insurance --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7700 --caname ca-insurance -M ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/msp --csr.hosts peer1.insurance --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/insurance/msp/config.yaml ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/msp/config.yaml
  cp ${PWD}/organizations/peerOrganizations/insurance/msp/config.yaml ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/msp/config.yaml

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7700 --caname ca-insurance -M ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/tls --enrollment.profile tls --csr.hosts peer0.insurance --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null


  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7700 --caname ca-insurance -M ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/tls --enrollment.profile tls --csr.hosts peer1.insurance --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

 # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/tls/signcerts/* ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/tls/keystore/* ${PWD}/organizations/peerOrganizations/insurance/peers/peer0.insurance/tls/server.key

  cp ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/tls/signcerts/* ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/tls/keystore/* ${PWD}/organizations/peerOrganizations/insurance/peers/peer1.insurance/tls/server.key

  infoln "Generating the user msp"

  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7700 --caname ca-insurance -M ${PWD}/organizations/peerOrganizations/insurance/users/User1@insurance/msp --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/insurance/msp/config.yaml ${PWD}/organizations/peerOrganizations/insurance/users/User1@insurance/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://insuranceadmin:insuranceadminpw@localhost:7700 --caname ca-insurance -M ${PWD}/organizations/peerOrganizations/insurance/users/Admin@insurance/msp --tls.certfiles ${PWD}/organizations/fabric-ca/insurance/ca-cert.pem

  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/insurance/msp/config.yaml ${PWD}/organizations/peerOrganizations/insurance/users/Admin@insurance/msp/config.yaml
}
function createOrderer1() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/itblanket.org/orderer1

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1


  fabric-ca-client enroll -u https://admin:adminpw@localhost:2200 --caname ca-orderer1 --tls.certfiles ${PWD}/organizations/fabric-ca/orderer1/ca-cert.pem


  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-2200-ca-orderer1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-2200-ca-orderer1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-2200-ca-orderer1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-2200-ca-orderer1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/config.yaml

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/orderer1/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/tlscacerts/tlsca-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tlsca"
  cp "${PWD}/organizations/fabric-ca/orderer1/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tlsca/tlsca-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer1 --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer1/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer1 --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/orderer1/ca-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:2200 --caname ca-orderer1 -M ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp --tls.certfiles ${PWD}/organizations/fabric-ca/orderer1/ca-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/config.yaml ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/config.yaml

  infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:2200 --caname ca-orderer1 -M ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls --enrollment.profile tls --csr.hosts orderer1 --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/orderer1/ca-cert.pem
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls/keystore/* ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls/server.key

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/tlscacerts/tlsca-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:2200 --caname ca-orderer1 -M ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/orderer1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/msp/config.yaml ${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/users/Admin@example.com/msp/config.yaml
}


