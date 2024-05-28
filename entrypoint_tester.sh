#!/bin/bash

username=$TEST_USERNAME
password=$TEST_PASSWORD
nasid=statustesting
host1=127.0.0.1
host2=server
secret=secret
retries=1
timeout=3
frOut=$1
epoch=$(date +%s)
#authStr="User-Name=$username, User-Password=$password, Acct-Session-Id=$epoch, NAS-Identifier=$nasid"
#acctStr="User-Name=$username, Acct-Session-Id=$epoch, NAS-Identifier=$nasid"
baseStr="User-Name=$username, Acct-Session-Id=$epoch, Calling-Station-Id=00:11:22:AA:BB:CC, Called-Station-Id=00-11-22-AA-BB-CC:SOME_SSID"
authStr="$baseStr, User-Password=$password"
acctStr="$baseStr"

#Define ping test parameters
authStrPing="User-Name=ping"
acctStrPing=$authStrPing
authStrRPMPing="User-Name=rpmping"
acctStrRPMPing=$authStrPing
pingReplyText="pong"

sh /entrypoint_common.sh

echo "$TESTER_VALID_KEY" | base64 -d > "$TESTER_VALID_KEY_LOCATION"
echo "$TESTER_VALID_CRT" | base64 -d > "$TESTER_VALID_CRT_LOCATION"
echo "$TESTER_INVALID_KEY" | base64 -d > "$TESTER_INVALID_KEY_LOCATION"
echo "$TESTER_INVALID_CRT" | base64 -d > "$TESTER_INVALID_CRT_LOCATION"

interpretResponse() {

    #Test failed?
    if [ $? != "$1" ]
    then
        echo "result: fail"
        [ -n "$resp" ] && echo "outcome: $resp"
        exit 1

    #Test passed?
    else
        echo "result: pass"
    fi
}

lookForPingResponse() {
    echo "$resp" | grep -q $pingReplyText
    interpretResponse 0
}

lookForResponse() {
    echo "$resp" | grep -q "$1"
    interpretResponse 0
}

setUntrustedPKI() {
    export KEY_FILENAME=$TESTER_INVALID_KEY_LOCATION
    export CRT_FILENAME=$TESTER_INVALID_CRT_LOCATION
}

setTrustedPKI() {
    export KEY_FILENAME=$TESTER_VALID_KEY_LOCATION
    export CRT_FILENAME=$TESTER_VALID_CRT_LOCATION
}

startFreeRADIUS() {
    #Start FreeRADIUS.
    echo -n "Starting FreeRADIUS for RADIUS to RadSec converting....."
    export SUT_RADSEC_PORT=$1
    if [ -z "$(pgrep freeradius)" ]
    then
        /usr/sbin/freeradius -n radiusd_tester -l "$frOut" 
        interpretResponse 0
    else
        echo "FreeRADIUS already running"
    fi
}

for port in 2083 2183 2283; do

    pkill freeradius
    sleep 1
    setTrustedPKI
    echo "Sending to port ${port}"
    startFreeRADIUS $port
    
    hosts=( $host1 $host2 )
    host_labels=(RadSec UDP)
    
    for i in 0 1; do
    	#Attempt authentication test.
    	echo -n "Starting ${host_labels[$i]} authentication test with user \"$username\"....."
    	resp=$(echo "$authStr" | radclient -t $timeout -r $retries ${hosts[$i]} auth $secret 2>&1 > /dev/null)
    	interpretResponse 0
    done
    
    for i in 0 1; do
    	#Attempt accounting start test.
    	echo -n "Starting ${host_labels[$i]} accounting start test with user \"$username\"....."
    	resp=$(echo "$acctStr, Acct-Status-Type=1" | radclient -t $timeout -r $retries ${hosts[$i]} acct $secret 2>&1 > /dev/null)
    	interpretResponse 0
    done
    
    #Attempt accounting stop test.
    echo -n "Starting accounting stop test with user \"$username\"....."
    resp=$(echo "$acctStr, Acct-Status-Type=2" | radclient -t $timeout -r $retries $host1 acct $secret 2>&1 > /dev/null)
    interpretResponse 0
    
    #Attempt ping authentication test.
    echo -n "Starting ping authentication test....."
    resp=$(echo "$authStrPing" | radclient -x -t $timeout -r $retries $host1 auth $secret 2> /dev/null)
    lookForPingResponse $pingReplyText
    
    #Attempt ping accounting test.
    echo -n "Starting ping accounting test....."
    resp=$(echo "$acctStrPing" | radclient -x -t $timeout -r $retries $host1 acct $secret 2> /dev/null)
    lookForResponse $pingReplyText
    
    #Attempt rpmping authentication test.
    echo -n "Starting rpmping authentication test....."
    resp=$(echo "$authStrRPMPing" | radclient -x -t $timeout -r $retries $host1 auth $secret 2> /dev/null)
    lookForPingResponse $pingReplyText
    
    #Attempt rpmping accounting test.
    echo -n "Starting rpmping accounting test....."
    resp=$(echo "$acctStrRPMPing" | radclient -x -t $timeout -r $retries $host1 auth $secret 2> /dev/null)
    lookForPingResponse $pingReplyText
    
    #Attempt hub az1 authentication test
    echo -n "Starting authentication test to hub az1 with user \"$username\" and expecting Reply-Message of \"$EXPECTED_REPLY_ENDPOINT1\"....."
    resp=$(echo "$authStr, NAS-Identifier=az1" | radclient -x -t $timeout -r $retries $host1 auth $secret 2> /dev/null)
    lookForResponse "$EXPECTED_REPLY_ENDPOINT1"
    
    #Attempt hub az1 accounting test
    echo -n "Starting accounting test to hub az1 with user \"$username\" and expecting Reply-Message of \"$EXPECTED_REPLY_ENDPOINT1\"....."
    resp=$(echo "$acctStr, Acct-Status-Type=1, NAS-Identifier=az1" | radclient -x -t $timeout -r $retries $host1 acct $secret 2> /dev/null)
    lookForResponse "$EXPECTED_REPLY_ENDPOINT1"
    
    #Attempt hub az2 authentication test
    echo -n "Starting authentication test to hub az2 with user \"$username\" and expecting Reply-Message of \"$EXPECTED_REPLY_ENDPOINT2\"....."
    resp=$(echo "$authStr, NAS-Identifier=az2" | radclient -x -t $timeout -r $retries $host1 auth $secret 2> /dev/null)
    lookForResponse "$EXPECTED_REPLY_ENDPOINT2"
    
    #Attempt hub az2 accounting test
    echo -n "Starting accounting test to hub az2 with user \"$username\" and expecting Reply-Message of \"$EXPECTED_REPLY_ENDPOINT2\"....."
    resp=$(echo "$acctStr, Acct-Status-Type=1, NAS-Identifier=az2" | radclient -x -t $timeout -r $retries $host1 acct $secret 2> /dev/null)
    lookForResponse "$EXPECTED_REPLY_ENDPOINT2"
    
    
    setUntrustedPKI
    pkill freeradius
    sleep 1
    startFreeRADIUS $port
    
    #Attempt authentication test with invalid cert.
    echo -n "Starting negative test with user \"$username\" and invalid cert....."
    resp=$(echo "$authStr" | radclient -t $timeout -r $retries $host1 auth $secret 2>&1 > /dev/null)
    interpretResponse 1


done

#All tests passed, return 0.
exit 0


