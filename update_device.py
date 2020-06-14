# Copyright (C) 2020 nysascape
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.

import json
import os
import sys
import glob

# Call device codename
DEVICE = sys.argv[1] # second call to the script
HOME = os.getenv("HOME")
OUTDIR = "{a}/evo/target/product/{}/".format(a=HOME, b=DEVICE) # hardcoded :(
LIST_JSON = glob.glob(OUTDIR + '*.json')

# This assumes official_devices is at ~/official_devices
DEVICE_JSON_FILE = "{b}/official_devices/builds/{a}.json".format(a=DEVICE, b=HOME)

# Load ~/official_devices/builds/device.json into dict
with open(DEVICE_JSON_FILE, 'r') as file:
    DEVICE_DICTIONARY = json.load(file)

LATEST_BUILD_JSON = max(LIST_JSON, key = os.path.getctime)
BUILD_JSON_FILE = (LATEST_BUILD_JSON)

with open(BUILD_JSON_FILE, 'r') as file2:
    BUILD_DICTIONARY = json.load(file2)

# Grab info
DATETIME = BUILD_DICTIONARY['datetime']
FILEHASH = BUILD_DICTIONARY['filehash']
FILENAME = BUILD_DICTIONARY['filename']
ID = BUILD_DICTIONARY['id']
SIZE = BUILD_DICTIONARY['size']
# Construct URL
URL = "https://sourceforge.net/projects/evolution-x/files/{a}/{b}/download".format(a=DEVICE, b=FILENAME)

# Set new info
DEVICE_DICTIONARY['datetime'] = DATETIME
DEVICE_DICTIONARY['filehash'] = FILEHASH
DEVICE_DICTIONARY['filename'] = FILENAME
DEVICE_DICTIONARY['id'] = ID
DEVICE_DICTIONARY['size'] = SIZE
DEVICE_DICTIONARY['url'] = URL

with open(DEVICE_JSON_FILE, 'w', encoding='utf8') as outfile:
    json.dump(DEVICE_DICTIONARY, outfile, indent=4, ensure_ascii=False)

print("Updated info in official_devices repo!")
