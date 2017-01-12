#!/bin/bash -e

if [ "$(whoami)" != "testcloud" ]; then
  echo "Ops! You are not running this script with a dedicated testcloud user"
  echo "Please run this script as the correct user."
  echo "For mor informations check the project's documentation."
  echo "Have a swell day :)"
  exit 1
fi

figlet "SERV CHECK"

printf "Checking Environment Integrity.\n\n"
