#!/usr/bin/env python3
import requests

public_ip = requests.get('https://ifconfig.me').text.strip()
print(f'{{"public_ip": "{public_ip}/32"}}')