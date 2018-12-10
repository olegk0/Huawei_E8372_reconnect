#!/bin/bash
on=$1

USER="login" # admin
PASSWORD="password"
MODEM_IP="192.168.8.1"

ses_tok=`curl -s -i -X GET "http://$MODEM_IP/html/home.html"`
ses_tok=`echo "$ses_tok" | tr '\r' '\n'`
COOKIE=`echo "$ses_tok" | grep "SessionID=" | cut -d ':' -f2 | cut -d ';' -f1`
TOKEN=`echo "$ses_tok" | grep -m2 "csrf_token" | tail -n1 | cut -d '"' -f4`

#base64encode(SHA256(user + base64encode(SHA256(pass)) + token));
PASSWORD=`printf "$PASSWORD" | sha256sum | cut -d " " -f1`
PASSWORD=`printf "${PASSWORD}" | base64 -w0`
PASSWORD="${USER}${PASSWORD}${TOKEN}"
PASSWORD=`printf "$PASSWORD" | sha256sum | cut -d " " -f1`
PASSWORD=`printf "$PASSWORD" | base64 -w0`

LOGIN_REQ="<?xml version "1.0" encoding="UTF-8"?><request><Username>$USER</Username><Password>$PASSWORD</Password><password_type>4</password_type></request>"

echo "##############################################################################################################"
login_resp_hdr=`curl -s -i -X POST -d "$LOGIN_REQ" "http://$MODEM_IP/api/user/login" \
-H "__RequestVerificationToken: $TOKEN" \
-H "Content-Type: application/x-www-form-urlencoded" \
-H "Cookie: $COOKIE" \
-H "X-Requested-With: XMLHttpRequest" \
-H "Accept-Encoding: gzip, deflate" \
-H "Pragma: no-cache" \
-H "Connection: keep-alive" \
-H "Accept-Language: en-us"`

#--dump-header /tmp/login_resp_hdr.txt  > /dev/null
echo "##############################################################################################################"
login_resp_hdr=`echo "$login_resp_hdr" | tr '\r' '\n'`
echo "##############################################################################################################"
SESSION_ID=`echo "$login_resp_hdr" | grep "SessionID=" | cut -d ':' -f2 | cut -d ';' -f1`
TOKEN=`echo "$login_resp_hdr" | grep "__RequestVerificationTokenone" | cut -d ':' -f2`

echo "admin session_id"
echo "$SESSION_ID"
#TOKEN="${TOKEN:0:-1}"
echo "Token"
echo "$TOKEN"
echo
echo "##############################################################################################################"

curl -s -X GET "http://$MODEM_IP/api/monitoring/traffic-statistics" \
-H "Cookie: $SESSION_ID" \
-H "__RequestVerificationToken: $TOKEN" \
-H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"  > /tmp/4g_stat.txt

echo
echo "##############################################################################################################"

curl -s -X POST -d "<?xml version='1.0' encoding='UTF-8'?><request><dataswitch>$on</dataswitch></request>" \
"http://$MODEM_IP/api/dialup/mobile-dataswitch" \
-H "Cookie: $SESSION_ID" \
-H "__RequestVerificationToken: $TOKEN" \
-H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"

echo
