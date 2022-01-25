Create a primary key with hash algorithm sha256 and key algorithm rsa and store the object context in a file (po.ctx).

```bash
tpm2_createprimary -H o -g sha256 -G rsa -C po.ctx
```

Now create an object that can be loaded into the TPM with parent object from file (po.ctx) using hash algorithm SHA256 and key algorithm RSA output the public and private keys to key.pub|priv.
```bash
tpm2_create -c po.ctx -g sha256 -G rsa -u key.pub -r key.priv
```

Load the private and public keys into the TPM's transient memory.
```bash
tpm2_load -c po.ctx -u key.pub -r key.priv -C obj.ctx
```

Make the object persistent, specifying a valid handle.
```bash
tpm2_evictcontrol -A o -c obj.ctx -H 0x81010010
```

Now you can remove all temporarily files.
```bash
rm key.name *.ctx
```

source: https://security.stackexchange.com/questions/126715/tpm-2-0-pkcs11-on-windows-and-linux 