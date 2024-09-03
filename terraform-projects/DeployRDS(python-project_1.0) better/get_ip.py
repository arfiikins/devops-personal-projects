#!/usr/bin/env python3
import json
import requests

# using requests to get my public ip from ifconfig.me... requires to pip install requests
response = requests.get('https://ifconfig.me')
public_ip = response.text.strip()

# outputs it to a json format
print(json.dumps({"public_ip": public_ip}))
