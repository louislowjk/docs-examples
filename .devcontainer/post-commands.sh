#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKSPACE_DIR="$( cd "$SCRIPT_DIR/.." &> /dev/null && pwd )"


VISIBLE_FOLDER_SERVER="$VISIBLE_FOLDER_SERVER"
VISIBLE_FOLDER_CLIENT="$VISIBLE_FOLDER_CLIENT"
VISIBLE_FOLDER_PROJECT="$VISIBLE_FOLDER_PROJECT"
VISIBLE_FOLDER_VERSION="$VISIBLE_FOLDER_VERSION"

if [ -z "$VISIBLE_FOLDER_VERSION" ]; then
    SERVER_DIR=$WORKSPACE_DIR/$VISIBLE_FOLDER_PROJECT/backend
    CLIENT_DIR=$WORKSPACE_DIR/$VISIBLE_FOLDER_PROJECT/frontend/$VISIBLE_FOLDER_CLIENT
else
    SERVER_DIR=$WORKSPACE_DIR/$VISIBLE_FOLDER_PROJECT/$VISIBLE_FOLDER_VERSION/backend
    CLIENT_DIR=$WORKSPACE_DIR/$VISIBLE_FOLDER_PROJECT/$VISIBLE_FOLDER_VERSION/frontend/$VISIBLE_FOLDER_CLIENT/client

fi

# Backend setup functions
setup_backend_node() {
    cd $SERVER_DIR/node && npm install
}

setup_backend_java() {
    cd $SERVER_DIR && touch java/.env && cd java && mvn clean install
}

setup_backend_dotnet() {
    cd $SERVER_DIR/dotnet && dotnet restore
}

setup_backend_php() {
    cd $SERVER_DIR && touch php/.env && cd php && composer install
}

# Frontend setup functions
setup_frontend_react() {
    cd $CLIENT_DIR && npm install
}

setup_frontend_html() {
    cd $CLIENT_DIR && npm install
}

# Backend start functions
start_backend_node() {
    cd $SERVER_DIR/node && npm start
}

start_backend_java() {
    cd $SERVER_DIR/java && mvn spring-boot:run
}

start_backend_dotnet() {
    cd $SERVER_DIR/dotnet && dotnet run
}

start_backend_php() {
    cd $SERVER_DIR/php && php -S localhost:8080 -t public/
}

# Frontend start functions
start_frontend_react() {
    cd $CLIENT_DIR && npm run start --no-analytics
}

start_frontend_html() {
    cd $CLIENT_DIR && npm run start --no-analytics
}

# Post-create commands
post_create() {
    echo "Running post-create commands..."

    # Backend setup
    case "$VISIBLE_FOLDER_SERVER" in
        node) setup_backend_node ;;
        java) setup_backend_java ;;
        dotnet) setup_backend_dotnet ;;
        php) setup_backend_php ;;
        *) echo "Unknown backend technology: $VISIBLE_FOLDER_SERVER"; exit 1 ;;
    esac

    # Frontend setup
    case "$VISIBLE_FOLDER_CLIENT" in
        react) setup_frontend_react ;;
        html) setup_frontend_html ;;
        *) echo "Unknown frontend technology: $VISIBLE_FOLDER_CLIENT"; exit 1 ;;
    esac

    echo "Post-create commands completed."
}

# Post-attach commands
post_attach() {
    echo "Running post-attach commands..."

    local backend_command
    case "$VISIBLE_FOLDER_SERVER" in
        node) backend_command="npm start" ;;
        java) backend_command="mvn spring-boot:run" ;;
        dotnet) backend_command="dotnet run" ;;
        php) backend_command="php -S localhost:8080 -t public/" ;;
        *) echo "Unknown backend technology: $VISIBLE_FOLDER_SERVER"; exit 1 ;;
    esac

    local frontend_command
    case "$VISIBLE_FOLDER_CLIENT" in
        react|html) frontend_command="npm run start --no-analytics" ;;
        *) echo "Unknown frontend technology: $VISIBLE_FOLDER_CLIENT"; exit 1 ;;
    esac

    # Run backend and frontend in parallel
    (cd $SERVER_DIR && $backend_command) & \
    (cd $CLIENT_DIR && $frontend_command)

    echo "Post-attach commands completed."
}

# Main execution
case "$1" in
    post-create)
        post_create
        ;;
    post-attach)
        post_attach
        ;;
    *)
        echo "Usage: $0 {post-create|post-attach}"
        exit 1
        ;;
esac

exit 0