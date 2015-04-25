#!/bin/bash
 
# Mostly inherit from http://www.jamescoyle.net/how-to/1073-bash-script-to-create-an-ssl-certificate-key-and-request-csr
# Thanks to JAMES.COYLE very much

#Required
domain=$1
commonname=$domain
 
#Change to your company details
country=
state=
locality=
organization=
organizationalunit=
email=
 
#Optional
password=
 
if [ -z "$domain" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"
 
    exit 99
fi
 
echo "Generating key request for $domain"
 
#Generate a key
openssl genrsa -des3 -passout pass:$password -out $domain.key 2048 -sha256 -noout
 
#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in $domain.key -passin pass:$password -out $domain.key
 
#Create the request
echo "Creating CSR"
openssl req -new -key $domain.key -out $domain.csr -sha256 -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
 
#Sign the crt with ca.key
echo "Signing the cert"
#openssl ca -policy policy_anything -days 1460 -cert ca/ca.crt -keyfile ca/ca.key -sha256 -in $domain.csr -out $domain.crt -passin pass:$password
openssl x509 -req -days 1460 -in $domain.csr -CA ca/ca.crt -CAkey ca/ca.key -sha256 -out $domain.crt -passin pass:$password

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
cat $domain.csr
 
echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat $domain.key

echo
echo "---------------------------"
echo "-----Below is your Cert----"
echo "---------------------------"
echo
openssl x509 -in $domain.crt -text
