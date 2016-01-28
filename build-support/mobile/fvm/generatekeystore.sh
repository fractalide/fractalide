#!/bin/sh -e

( echo "Noware Ltd"
  echo "Noware Ltd"
  echo "Noware Ltd"
  echo "Hong Kong"
  echo "Hong Kong"
  echo "China"
  echo "yes"
) | keytool --genkeypair --alias fractalide --keystore ./keystore --keypass fractalide --storepass mykeystore
