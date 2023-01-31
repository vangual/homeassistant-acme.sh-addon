# Home Assistant Add-on: acme.sh

This Home Assistant addon uses `acme.sh` to obtain SSL/TLS certificates from ZeroSSL or Let's Encrypt.

## Configuration

Tested with the *dns_oci* configuration but It should work, the `dnsEnvVariables` can be configured with any environment required for `acme.sh` to work.

```yaml
accountemail: mail@example.com
domain: home.example.com
dnsprovider: dns_cf
dnsenvvars:
  - name: OCI_CLI_USER
    value: xxxx
  - name: OCI_CLI_TENANCY
    value: xxxx
  - name: OCI_CLI_REGION
    value: xxxx
  - name: OCI_CLI_KEY
    value: |-
      -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7JXeeUQ5G3DhB
    ...
    ...
    nmdtoD48M6MSrVAptxAeEbCPHeWrOyYWTG1O5+tl6nsFE3vT/K1oQsEjvgrpkt0c
    oxA0gRoymxuHyBBS4Wl+NFg=
    -----END PRIVATE KEY-----

keylength: 4096
fullchainfile: fullchain.pem
keyfile: privkey.pem
```

## Configure Home Assistant

Add `ssl_certificate` and `ssl_key` to  `/config/configuration.yaml`:

```yaml
http:
  ...
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
  ...
```

## About

This version of the addon is based on:
 - [Initial version by Anggol](https://github.com/Angoll/acme.sh-homeassistant-addon)
 - [Enhanced fork by Djelibeybi](https://github.com/Djelibeybi/homeassistant-acme.sh-addon)
 
[acme.sh](https://github.com/acmesh-official/acme.sh) is an ACME protocol client written purely in Shell (Unix shell) language.
