#!/usr/bin/env python3
import json
import requests

def get_public_ip():
    response = requests.get('https://api.ipify.org?format=json')
    response.raise_for_status()
    ip = response.json()['ip']
    return ip

if __name__ == "__main__":
    ip_address = get_public_ip()
    print(json.dumps({"ip": ip_address}))