import sys
import json

vm_info = json.load(sys.stdin)

for (vm,ip) in vm_info.items():
    print(F"Host {vm}")
    print(F"  HostName {ip}")
    print("  User azureuser")
    print("  IdentityFile ~/.ssh/azureuser_id_rsa")
    print("")