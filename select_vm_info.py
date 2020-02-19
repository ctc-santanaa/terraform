import sys
import json

vm_info = json.load(sys.stdin)

vms = {} 
for vm in vm_info:
    vms[vm['virtualMachine']['name']] = vm['virtualMachine']['network']['publicIpAddresses'][0]['ipAddress']

print(json.dumps(vms))