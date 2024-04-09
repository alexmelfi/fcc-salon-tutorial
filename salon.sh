#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\nWelcome to the Salon!\n"

DISPLAY_SERVICES() {
  if [[ $1 ]]
  then
    echo -e $1
  fi

  echo "$($PSQL "select * from services")" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  CREATE_APPOINTMENT
}

CREATE_APPOINTMENT() {
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]*$ ]]
  then
    SERVICE_TYPE=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_TYPE ]]
    then
      DISPLAY_SERVICES "\nI could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_ID ]]
      then
        echo "Name not found. What is your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
      fi

      echo "What time?"
      read SERVICE_TIME

      INSERT_APPOINTMENT=$($PSQL "insert into appointments (time, customer_id, service_id) values ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

      SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")

      SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//')
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//')

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  else
    DISPLAY_SERVICES "Please choose a number."
  fi
}

DISPLAY_SERVICES