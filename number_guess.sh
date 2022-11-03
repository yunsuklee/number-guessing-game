#!/bin/bash
# pg_dump -cC --inserts -U freecodecamp number_guess > number_guess.sql

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Guessing ~~~~~\n"

NUMBER=$(( RANDOM % 1000 + 1))
TEXT="The next number is,"

echo -e "$TEXT $NUMBER\n"

# ask for username
echo -e "Enter your username:"
read USERNAME

# get username
USERNAME_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE name='$USERNAME'")

# if username is not found
if [[ -z $USERNAME_RESULT ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # insert new user into the db
  NEW_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
else
  echo "$USERNAME_RESULT" | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# ask user to play
echo -e "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1
# until he guesses the number
while [[ $GUESS != $NUMBER ]]
do
  # if input is a number
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    #increase a try
    (( TRIES++ ))
    # if user's guess is lower than the actual number
    if [[ $GUESS -gt $NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
    # if user's guess is higher than the actual number
    else
      echo -e "It's higher than that, guess again:"
    fi
  # if input is not a number
  else
    echo -e "That is not an integer, guess again:"
  fi
  # read next guess
  read GUESS
done
# when the number is guessed
if [[ -z $USERNAME_RESULT ]]
then
  USER_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=1, best_game=$TRIES WHERE name='$USERNAME'")
else
  echo "$USERNAME_RESULT" | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    (( GAMES_PLAYED++ ))
    if [[ $BEST_GAME -gt $TRIES ]]
    then
      USER_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$TRIES WHERE name='$USERNAME'")
    else
      USER_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE name='$USERNAME'")
    fi
  done
fi

echo -e "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"












