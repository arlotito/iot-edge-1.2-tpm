
Can't provision x509 with EST and TPM
from here: https://github.com/Azure/iotedge/issues/5306


ISSUE:
self signed certificate in certificate chain

WORKAROUND:
You can add the CA to the OS's cert store (/etc/ssl or whatever it is on your distro) instead of using a cert_issuance.est.trusted_certs file.

sudo -i
echo | openssl s_client -showcerts -servername testrfc7030.com -connect testrfc7030.com:8443 2>/dev/null | awk '{print > "/usr/local/share/ca-certificates/testrfc." (1+n) ".crt"} /-----END CERTIFICATE-----/ {n++}'
update-ca-certificates

TOOL INFO:
sudo -u aziotks pkcs11-tool --module "$PKCS11_LIB_PATH" -IOT

CONFIG TOML:
# ==============================================================================
## DPS provisioning with X.509 certificate
# ==============================================================================
[provisioning]
source = "dps"
global_endpoint = "https://global.azure-devices-provisioning.net"
id_scope = "__redacted__"

[provisioning.authentication]
 method = "x509"

[provisioning.attestation]
method = "x509"
registration_id = "__redacted__"


# dynamically issued via EST, or...
identity_cert = { method = "est", common_name = "__redacted__" }
# PKCS#11 URI
identity_pk = "pkcs11:token=__redacted__?pin-value=__redacted__"


# ==============================================================================
# Cert issuance via EST
# ==============================================================================
[cert_issuance]
  device-id = { method = "est" }

[cert_issuance.est]
  trusted_certs = [ "file:///var/secrets/cacerts.pem" ]

[cert_issuance.est.auth]
username = "estuser"
password = "estpwd"

[cert_issuance.est.urls]
default = "https://testrfc7030.com:8443/.well-known/est"
device-id = "https://testrfc7030.com:8443/.well-known/est"

# ==============================================================================
# PKCS#11
# ==============================================================================

[aziot_keys]
pkcs11_lib_path = "/usr/local/lib/libtpm2_pkcs11.so"
pkcs11_base_slot = "pkcs11:token=__redacted__?pin-value=__redacted__"