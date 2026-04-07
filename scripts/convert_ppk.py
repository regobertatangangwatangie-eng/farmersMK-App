import paramiko, os, sys

ppk = "/keys/farmersmk.com.ppk"
pem = "/keys/farmersmk.com.pem"

for cls in [paramiko.RSAKey, paramiko.Ed25519Key, paramiko.ECDSAKey]:
    try:
        k = cls.from_private_key_file(ppk)
        k.write_private_key_file(pem)
        os.chmod(pem, 0o600)
        print(f"OK: converted {ppk} using {cls.__name__}")
        sys.exit(0)
    except Exception as e:
        print(f"Tried {cls.__name__}: {e}")

print("ERROR: Could not convert PPK with any key type")
sys.exit(1)
