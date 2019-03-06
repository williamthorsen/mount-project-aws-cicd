#!/usr/bin/env bash

# This file contains functions unrelated to AWS

# Constants for formatting console output
FONT_WEIGHT_BOLD=$(tput bold)
FONT_WEIGHT_NORMAL=$(tput sgr0)


# Given an argument, exit with status code
#   0 if the argument isn't empty
#   1 if the argument is empty
assertNotEmpty () {
  if [[ $# -eq 0 || -z "$1" ]]
  then
    echo "Assertion failed" 1>&2
    false
  fi
  true
}

echoRandomId () {
  local LENGTH=$1
  LENGTH=${LENGTH:='13'}
  echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${LENGTH} | head -n 1)
}

echoRandomLowercaseId () {
  local LENGTH=$1
  LENGTH=${LENGTH:='13'}
  echo $(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w ${LENGTH} | head -n 1)
}

# Given 2 values, echo the greater of them
echoMax () {
  echo $(( $1 > $2 ? $1 : $2 ))
}

# Given 2 values, echo the lesser of them
echoMin () {
  echo $(( $1 < $2 ? $1 : $2 ))
}

embold () {
  local bold=$(tput bold)
  local normal=$(tput sgr0)

  local TEXT_TO_EMBOLD=$1
  echo "${bold}${TEXT_TO_EMBOLD}${normal}"
}

