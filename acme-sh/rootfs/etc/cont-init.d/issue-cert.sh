#!/usr/bin/with-contenv bashio
CONFIG_PATH=/data/options.json
LE_CONFIG_HOME="/data/acme.sh"

[ ! -d "$LE_CONFIG_HOME" ] && mkdir -p "$LE_CONFIG_HOME"

if [ ! -f "$LE_CONFIG_HOME/account.conf" ]; then
    bashio::log.info "Copying the default account.conf file"
    cp /default_account.conf "$LE_CONFIG_HOME/account.conf"
fi

ACCOUNT_EMAIL=$(bashio::config 'accountemail')
DOMAIN=$(bashio::config 'domain')
DNS_PROVIDER=$(bashio::config 'dnsprovider')
DNS_ENV_VARS=$(jq --raw-output '.dnsenvvars | map("export \(.name)='\''\(.value)'\''") | .[]' $CONFIG_PATH)
KEY_LENGTH=$(bashio::config 'keylength')
FULLCHAIN_FILE=$(bashio::config 'fullchainfile')
KEY_FILE=$(bashio::config 'keyfile')

# shellcheck source=/dev/null
source <(echo "$DNS_ENV_VARS");

bashio::log.info "Registering account"
acme.sh --register-account -m "$ACCOUNT_EMAIL"

bashio::log.info "Issuing certificate for domain: $DOMAIN"

function issue {
    # Issue the certificate, if necessary. Exit cleanly if it exists.
    local RENEW_SKIP=2
    acme.sh --issue --domain "$DOMAIN" \
        --keylength "$KEY_LENGTH" \
        --dns "$DNS_PROVIDER" \
        || { ret=$?; [ $ret -eq ${RENEW_SKIP} ] && return 0 || return $ret ;}
}

issue

bashio::log.info "Installing private key to /ssl/$KEY_FILE and certificate to /ssl/$FULLCHAIN_FILE"
ECC_ARG=$( [[ ${KEY_LENGTH} == ec-* ]] && echo '--ecc' || echo '' )

acme.sh --install-cert --domain "$DOMAIN" $ECC_ARG \
        --key-file       "/ssl/$KEY_FILE" \
        --fullchain-file "/ssl/$FULLCHAIN_FILE"

bashio::log.info "Inital configuration complete."
