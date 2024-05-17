#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER1_CA=${PWD}/organizations/ordererOrganizations/itblanket.org/orderer1/tlsca/tlsca-cert.pem
export PEER0_HOSPITAL_CA=${PWD}/organizations/peerOrganizations/hospital/tlsca/tlsca.hospital-cert.pem
export PEER0_PATIENT_CA=${PWD}/organizations/peerOrganizations/patient/tlsca/tlsca.patient-cert.pem
export PEER0_PHARMACY_CA=${PWD}/organizations/peerOrganizations/pharmacy/tlsca/tlsca.pharmacy-cert.pem
export PEER0_INSURANCE_CA=${PWD}/organizations/peerOrganizations/insurance/tlsca/tlsca.insurance-cert.pem

# Set environment variables for the peer org
setGlobals() {
  PEER=$1
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$2
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ "$USING_ORG" == "hospital" ]; then
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HOSPITAL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/hospital/users/Admin@hospital/msp
    if [ $PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:4444
    elif [ $PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:4454
    elif [ $PEER -eq 2 ]; then
      export CORE_PEER_ADDRESS=localhost:4464
    elif [ $PEER -eq 3 ]; then
      export CORE_PEER_ADDRESS=localhost:4474
    fi
  elif [ "$USING_ORG" == "patient" ]; then
    export CORE_PEER_LOCALMSPID="PatientMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PATIENT_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/patient/users/Admin@patient/msp
    if [ $PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:5555
    elif [ $PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:5565
    elif [ $PEER -eq 2 ]; then
      export CORE_PEER_ADDRESS=localhost:5575
    elif [ $PEER -eq 3 ]; then
      export CORE_PEER_ADDRESS=localhost:5585
    fi
  elif [ "$USING_ORG" == "pharmacy" ]; then
    export CORE_PEER_LOCALMSPID="PharmacyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PHARMACY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/pharmacy/users/Admin@pharmacy/msp
    if [ $PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:6666
    elif [ $PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:6676
    elif [ $PEER -eq 2 ]; then
      export CORE_PEER_ADDRESS=localhost:6686
    elif [ $PEER -eq 3 ]; then
      export CORE_PEER_ADDRESS=localhost:6696
    fi
  elif [ "$USING_ORG" == "insurance" ]; then
    export CORE_PEER_LOCALMSPID="InsuranceMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INSURANCE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/insurance/users/Admin@insurance/msp
    if [ $PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:7777
    elif [ $PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:7787
    elif [ $PEER -eq 2 ]; then
      export CORE_PEER_ADDRESS=localhost:7797
    elif [ $PEER -eq 3 ]; then
      export CORE_PEER_ADDRESS=localhost:7807
    fi

  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals 0 $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ "$USING_ORG" == "hospital" ]; then
    export CORE_PEER_ADDRESS=peer0.hospital:4444
  elif [ "$USING_ORG" == "patient" ]; then
    export CORE_PEER_ADDRESS=peer0.patient:5555
  elif [ "$USING_ORG" == "pharmacy" ]; then
    export CORE_PEER_ADDRESS=peer0.pharmacy:6666
  elif [ "$USING_ORG" == "insurance" ]; then
    export CORE_PEER_ADDRESS=peer0.insurance:7777

  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""

  # Loop through the input parameters as an array of strings
  for PARAM in "$@"; do
    setGlobals 0 "$PARAM"
    PEER="peer0.$PARAM"
    ## Set peer addresses
    if [ -z "$PEERS" ]; then
      PEERS="$PEER"
    else
      PEERS="$PEERS $PEER"
    fi

    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)

    ## Set path to TLS certificate
    CA="PEER0_${PARAM^^}"_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
  done

  # Remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

