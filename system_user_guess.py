import random

system_guess = 0
count = 0
user_guess = int(input('Please enter your guess: '))
while system_guess != user_guess:
	system_guess = random.randint(0,5000)
	count +=1
	#print(f'The system guess  was {system_guess} and the count was {count}')
	if system_guess == user_guess:
		print(f'The system has guessed your number which is {user_guess}, and  it made {count} attempts to guess it')
		break
	elif user_guess > 5000:
		print('Please enter a number less than 5000')
		break


