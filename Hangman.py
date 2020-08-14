import random
open_file = open('words.txt','r')
collection = open_file.readlines()
word = list(random.choice(collection).strip())
print(word)
print(set(word))
guessed = ['_']*len(word)
print(guessed)
user_letter = ''
wrong = 0
count = 0
while  wrong != 6 and user_letter != 'EXIT':
	if guessed == word:
		print('Congrats. you won!')
		break
	user_letter = input('Please enter a letter to guess: ').upper()
	if word[count] == user_letter:
		guessed[count] = user_letter		
		print(guessed)
		count+=1
	elif user_letter in set(guessed):
		pass
	elif user_letter == 'EXIT':
		print('Sorry to see you go!')
	else:
		if wrong < 5:
			print(f'Incorrect! {5-wrong} more attempts')
			wrong+=1
		else:
			print('That was incorrect too!, game over!')
			break