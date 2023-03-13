#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#echo "$($PSQL "SELECT * FROM services")"
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU(){
	echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR NAME
	do
		echo "$SERVICE_ID) $NAME"
	done

	read SERVICE_ID_SELECTED
	
	NUMBER_OF_SERVICES=$($PSQL "SELECT COUNT(*) FROM services")

	if (( $SERVICE_ID_SELECTED > 0 && $SERVICE_ID_SELECTED <= $NUMBER_OF_SERVICES ))
	then
		NUMBER=$SERVICE_ID_SELECTED
		SERVICE_SECTION
	else
		WRONG_ENTRY
	fi
}

WRONG_ENTRY(){
	echo -e "\nI could not find that service. What would you like today?"
	MAIN_MENU
}

SERVICE_SECTION(){
	#Get service with id of $NUMBER
	GET_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$NUMBER")

	#ask for phone number
	echo -e "\nWhat's your phone number?"
	read CUSTOMER_PHONE

	#GET NAME with phone number PHONE
	GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

	if [[ -z $GET_CUSTOMER_NAME ]]
	then
		echo -e "\nI don't have a record for that phone number, what's your name?"
		read CUSTOMER_NAME

		#Save phone number and name to database
		SAVE_CUSTOMER_PHONE_AND_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
	else
		CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
	fi

	echo -e "\nWhat time would you like your$GET_SERVICE,$CUSTOMER_NAME?"
	read SERVICE_TIME

	#GET CUSTOMER_ID
	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

	SERVICE_ID=$NUMBER

	INSERT_AN_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

	echo -e "\nI have put you down for a $GET_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU