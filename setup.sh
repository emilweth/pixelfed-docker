#!/bin/bash

confirm_overwrite() {
    if [ -f .env ]; then
        read -p ".env file already exists. Do you want to overwrite? (y/n): " choice
        case "$choice" in
            y|Y ) echo "Overwriting .env..."; > .env;;
            n|N ) echo "Exiting without overwriting."; exit 1;;
            * ) echo "Invalid choice"; exit 1;;
        esac
    else
        > .env
    fi
}

ask_for_input() {
    local env_var_name=$1
    local description=$2
    local default_value=$3

    echo "$description"

    # Use the default value if provided and if the user simply hits enter
    read -p "$env_var_name [$default_value]=" input_value
    if [ -z "$input_value" ]; then
        input_value="$default_value"
    fi

    # Append to .env file
    echo "$env_var_name=$input_value" >> .env
}

# Confirmation before overwriting
confirm_overwrite

touch .env.extra

# Sample usage with the default value
ask_for_input "APP_NAME" "Name of your application" "Pixelfed"
ask_for_input "APP_URL" "Application URL" "https://localhost"
ask_for_input "APP_DOMAIN" "Application domain" "localhost"
ask_for_input "ADMIN_DOMAIN" "Admin domain" "localhost"
ask_for_input "SESSION_DOMAIN" "Session domain" "localhost"

ask_for_input "APP_KEY" "App encryption key" "$(docker compose run --rm --entrypoint="" pixelfed php artisan key:generate --show)"

echo "All values have been written to .env"
