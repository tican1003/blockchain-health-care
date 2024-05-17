seq_no_file="seq_no.txt"

# Check if the file exists or create it if it doesn't
if [ -e "$seq_no_file" ]; then
    # If the file exists, read the value from the file
    SEQ_VAL=$(<"$seq_no_file")
else
    # If the file doesn't exist, initialize the variable to 0
    SEQ_VAL=1
    # Create the file and save the initial value
    echo "$SEQ_VAL" >"$seq_no_file"
fi

# Pull the images
./bootstrap.sh 2.5.4 1.5.7

# bring up the network
./network.sh up -ca -s couchdb

# create the hcchannel. Specify the channel name and the profile to be used.
./network.sh createChannel -c hcchannel

# deploy chaincode hcchaincode on hcchannel

# Uncomment if chaincode initialization required and add "Initialize" function to the chaincode.
# ./network.sh deployCC -c hcchannel -ccn hcchaincode -ccp ../../chaincode -ccl go -cci Initialize
./network.sh deployCC -c hcchannel -ccn hcchaincode -ccp ../../chaincode -ccl go -ccs $SEQ_VAL

((SEQ_VAL++))
echo "$SEQ_VAL" > "$seq_no_file"

