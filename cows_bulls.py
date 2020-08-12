import string
import random
print('--------***Welcome to the cows and bulls game***----------')

while True:
	user_input = list(input('Please guess a 4 digit number: '))
	collection = random.sample(string.digits,4)
	print(collection)
	count_bull = 0
	count_cow = 0
	for item in user_input:
		if item in collection:
			if user_input.index(item) == collection.index(item):
				count_cow+=1

				
			else:
				count_bull+=1
				
		else:
			pass
	print(f'{count_cow} Cows, {count_bull} Bulls')

	if user_input == collection:
		break
	else:
		pass


