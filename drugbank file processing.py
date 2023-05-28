import xml.etree.ElementTree as ET
import csv

# open the xml file
tree = ET.parse('full database.xml')
root = tree.getroot()

# open the csv file for writing
with open('drugbank.csv', 'w', newline='',encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)

    # write the header row
    writer.writerow(['drugbank-id', 'name', 'description', 'cas-number', 'groups'])

    # iterate over the drug elements
    for drug in root.findall('{http://www.drugbank.ca}drug'):

        # get the drugbank-id element
        drugbank_id = drug.find('{http://www.drugbank.ca}drugbank-id').text

        # get the name element
        name = drug.find('{http://www.drugbank.ca}name').text

        # get the description element
        description = drug.find('{http://www.drugbank.ca}description').text

        # get the cas-number element
        cas_number = drug.find('{http://www.drugbank.ca}cas-number').text


        # get the groups elements
        groups = ','.join([g.text for g in drug.findall('{http://www.drugbank.ca}groups/{http://www.drugbank.ca}group')])

        # write the row to the csv file
        writer.writerow([drugbank_id, name, description, cas_number, groups])