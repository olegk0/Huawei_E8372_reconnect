#!/bin/bash
on=$1

USER="login" # admin
PASSWORD="password"
MODEM_IP="192.168.8.1"

curl -i -s -X GET "http://$MODEM_IP/html/home.html" > /tmp/ses_tok.txt
COOKIE=`grep "SessionID=" /tmp/ses_tok.txt | cut -d ':' -f2 | cut -d ';' -f1`
TOKEN=`grep -m2 "csrf_token" /tmp/ses_tok.txt | tail -n1 | cut -d '"' -f4`

#grep -m2 "csrf_token" /tmp/ses_tok.txt | tail -n1 | cut -d '"' -f4  > SecondToken.txt
#nodejs cli.js

#USER=`cat User.txt`
#PASSWORD=`cat Password.txt`

#base64encode(SHA256(user + base64encode(SHA256(pass)) + token));
psd=`printf "$PASSWORD" | sha256sum | cut -d " " -f1`
#echo "bash0:$psd|"
psd=`printf "${psd}" | base64 -w0`
#psd="${psd:0:-2}=="
#echo "bash1:$psd|"
psd="${USER}${psd}${TOKEN}"
#echo "bash2:$psd|"
psd=`printf "$psd" | sha256sum | cut -d " " -f1`
#echo "bash3:$psd|"
psd=`printf "$psd" | base64 -w0`

#echo "bash:${psd}|"
#PASSWORD=`cat encPassword.txt`
#echo "js:${PASSWORD}|"
PASSWORD=$psd


LOGIN_REQ="<?xml version "1.0" encoding="UTF-8"?><request><Username>$USER</Username><Password>$PASSWORD</Password><password_type>4</password_type></request>"
#echo "$LOGIN_REQ" > Request.xml
#curl -X POST -# -v -d @Request.xml "http://$MODEM_IP/api/user/login" \
echo "##############################################################################################################"
curl -X POST -# -v -d "$LOGIN_REQ" "http://$MODEM_IP/api/user/login" \
-H "__RequestVerificationToken: $TOKEN" \
-H "Content-Type: application/x-www-form-urlencoded" \
-H "Cookie: $COOKIE" \
-H "X-Requested-With: XMLHttpRequest" \
-H "Accept-Encoding: gzip, deflate" \
-H "Pragma: no-cache" \
-H "Connection: keep-alive" \
-H "Accept-Language: en-us" \
--dump-header /tmp/login_resp_hdr.txt
# > /dev/null
echo
echo "##############################################################################################################"
SESSION_ID=`grep "SessionID=" /tmp/login_resp_hdr.txt | cut -d ':' -f2 | cut -d ';' -f1`
TOKEN=`grep "__RequestVerificationTokenone" /tmp/login_resp_hdr.txt | cut -d ':' -f2`

echo "admin session_id"
echo "$SESSION_ID"
TOKEN="${TOKEN:0:-1}"
echo "$TOKEN"
echo
echo "##############################################################################################################"

curl -v -X POST -d "<?xml version='1.0' encoding='UTF-8'?><request><dataswitch>$on</dataswitch></request>" \
"http://$MODEM_IP/api/dialup/mobile-dataswitch" \
-H "Cookie: $SESSION_ID" \
-H "__RequestVerificationToken: $TOKEN" \
-H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"

echo
