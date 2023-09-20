from sys import argv
import yaml

if len(argv) < 2:
    print(f'Usage: python {argv[0]} FILINAME')
    exit(1)

FILINAME = argv[1]

with open(FILINAME, 'r') as file:
    doc = yaml.safe_load(file)
    if not 'layers' in doc:
        print('Invalid file')
        exit(2)
    for layer in doc['layers'].keys():
        print(layer)
