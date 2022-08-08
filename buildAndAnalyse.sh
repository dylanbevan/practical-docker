#!/usr/bin/env bash

sonarqube_generate_token() {
    curl --silent \
         --location \
         --request POST "${SONARQUBE_URL}/api/user_tokens/generate?name=build" \
         --header "Authorization: Basic ${SONARQUBE_TOKEN}" | jq -r .token
}

sonarqube_revoke_token() {
    curl --silent \
         --location \
         --request POST "${SONARQUBE_URL}/api/user_tokens/revoke?name=build" \
         --header "Authorization: Basic ${SONARQUBE_TOKEN}"
}

main() {
    sonarqube_revoke_token
    BUILD_TOKEN=$(sonarqube_generate_token)
    dotnet sonarscanner begin \
        /k:$SONARQUBE_PROJECT_KEY \
        /d:sonar.host.url=$SONARQUBE_URL \
        /d:sonar.login=$BUILD_TOKEN \
        /d:sonar.exclusions=**/wwwroot/**/*

    dotnet build

    dotnet sonarscanner end \
        /d:sonar.login=$BUILD_TOKEN
    sonarqube_revoke_token
    exit 0
}
main $@