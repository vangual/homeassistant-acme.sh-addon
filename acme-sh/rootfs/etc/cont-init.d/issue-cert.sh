#!/usr/bin/env bashio
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
DNS_ENV_VARS=$(jq -r '.dnsenvvars |map("export \(.name)=\(.value|tojson)")|.[]' $CONFIG_PATH)
KEY_LENGTH=$(bashio::config 'keylength')
FULLCHAIN_FILE=$(bashio::config 'fullchainfile')
KEY_FILE=$(bashio::config 'keyfile')

# shellcheck source=/dev/null
source <(echo "$DNS_ENV_VARS");

bashio::log.info "Registering account"
acme.sh --register-account -m "$ACCOUNT_EMAIL"

bashio::log.info "Issuing certificate for domain: $DOMAIN"

function issue {
    # Issue the certificate exit corretly if is not time to renew
    local RENEW_SKIP=2
    acme.sh --issue --domain "$DOMAIN" \
        --keylength "$KEY_LENGTH" \
        --dns "$DNS_PROVIDER" \
        --debug 2 \
        || { ret=$?; [ $ret -eq ${RENEW_SKIP} ] && return 0 || return $ret ;}
}

issue

bashio::log.info "Installing private key to /ssl/$KEY_FILE and certificate to /ssl/$FULLCHAIN_FILE"
ECC_ARG=$( [[ ${KEY_LENGTH} == ec-* ]] && echo '--ecc' || echo '' )
[ ! -d "/ssl/${DOMAIN}/" ] && mkdir -p "/ssl/${DOMAIN}/"
acme.sh --install-cert --domain "$DOMAIN" "$ECC_ARG" \
        --key-file       "/ssl/$KEY_FILE" \
        --fullchain-file "/ssl/$FULLCHAIN_FILE" \
        --debug 2

bashio::log.info "Configuration complete."
crontab -l
