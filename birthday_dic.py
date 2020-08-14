import json
from collections import Counter	
with open('info.json','r') as reading_file:
	dictionary = json.load(reading_file)
def print_dictionary():
	keys = '\n'.join(list(dictionary.keys()))
	print(f'we know birthdays of: \n{keys}.')
	
def add_item():
	take = input('Would you like to save an entry on the dictionary?: ')
	if take in ['yes','y']:
		person = input('Please enter the name of the person you would like to add: ')
		day = input('Please enter the birthday of the person in format like 14 July: ')
		dictionary.update({str(person):str(day)})
		with open('info.json','w') as file:
			json.dump(dictionary,file)
		print(f'{person} has been added to the dictionary')
	else:
		print('thank you for using this app!')
def lookup():
	prompt= input('Whoes birthday do you want to lookup? ')
	print(f'{prompt}\'s birthday is on: {dictionary[prompt]}')
#permission = ''
while True:
	print('===Welcome to birthday dictionary===' )
	permission = input('type check to check someone\'s birthday and add to add an entry or exit to exit: ')

	if permission == 'add':
		add_item()
	elif permission == 'check':

		lookup()
	elif permission == 'exit':
		break
	else:
		print(f'{permission} is not a valid keyword, try again!')
		pass
with open('info.json','r') as file:
	mydict = json.load(file)
#print(mydict)
new_list = list(mydict.values())
#print(new_list)
sample_list = []
for items in new_list:
	sample_list.append(items.split()[1])
c = Counter(sample_list)
print(c)
