#!/usr/bin/env python3
import re
import json
import subprocess

pattern = r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"

master_public_ip = re.findall(pattern, subprocess.run(["make", "aws_output"], stdout=subprocess.PIPE).stdout.decode("utf-8"))

inventory_pattern = { "hosts": master_public_ip }

print(json.dumps(inventory_pattern))
