import random
import string
def get_password(a):
	collection = string.digits +  string.ascii_letters 
	password = ''.join(random.sample(collection, a))
	print(password)
def get_password_stronger(a):
	collection = string.digits + string.punctuation + string.ascii_letters 
	password = ''.join(random.sample(collection, a))
	print(password)

user_prompt = (input('Please enter if you want your password weaker or stronger: '))

def final_password(a):
	if a.lower() == 'stronger':
		get_password_stronger(15)
	elif a.lower() == 'weaker':
		get_password(10)

	else: 
		pass
final_password(user_prompt)	


