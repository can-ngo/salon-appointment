#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ c4nng0 Salon ~~~\n"
echo -e "Welcome to c4nng0 Salon, how can I help you?\n"

MAIN_MENU() {
if [[ $1 ]]
then
  echo -e "\n$1"
fi

echo "1) cut"
echo "2) nail"
echo "3) massage"

read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  # send to main menu
  MAIN_MENU "Please input number."
else
  # SERVICE_ID_SELECTION is number
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # if SERVICE_ID_SELECTED <> SERVICE_ID
  if [[ -z $SERVICE_ID ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # ask phone number
    echo "What's your phone number?"
    read CUSTOMER_PHONE
    # look for customer_id by phone
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if a phone number doesn't exist (customer_id doesn't exist)
    if [[ -z $CUSTOMER_ID ]]
    then
      # prompt user to enter their name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert new customer to db
      NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      # get new customer_id and service_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # ask customer to time
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
      echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # insert new record to appointment db
      APPOINTMENT_ADDED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
      if [[ $APPOINTMENT_ADDED == "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi    
    else  # phone number exist
      # ask customer to time
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
      echo -e "\nWhat time would you like your$SERVICE_NAME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME
      # insert new record to appointment db
      APPOINTMENT_ADDED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
      if [[ $APPOINTMENT_ADDED == "INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
      fi    
    fi
  fi
  
  
  
fi

}

MAIN_MENU