from imessage_reader import fetch_data
import subprocess

# if the file database_message/message_to_treat.txt doesn't exist, create it
try:
    open('database_message/message_to_treat.txt', 'r')
except FileNotFoundError:
    open('database_message/message_to_treat.txt', 'w')

# if the file database_message/messages.txt doesn't exist, create it
try:
    open('database_message/messages.txt', 'r')
except FileNotFoundError:
    open('database_message/messages.txt', 'w')

# if the file database_message/new_messages.txt doesn't exist, create it
try:
    open('database_message/new_messages.txt', 'r')
except FileNotFoundError:
    open('database_message/new_messages.txt', 'w')

# This Python program, read all messages, stock it into a file called new_messages.txt
# Then, it compares the new_messages.txt file with the messages.txt file
# If there is a difference, it means that there is a new message
# So, it writes the new message in a file called message_to_treat.txt
# Then it's copy the new_messages.txt file into the messages.txt file
# Then, it prints the first line of message_to_treat.txt and erase it from the file (to treat message by message)

fd = fetch_data.FetchData()

my_data = fd.get_messages()

# save all elements in a file called new_messages.txt
with open('database_message/new_messages.txt', 'w') as f:
    for element in my_data:
        f.write(str(element) + '\n')

proc = subprocess.Popen(['diff', 'database_message/messages.txt', 'database_message/new_messages.txt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = proc.communicate()

# decode bytes to string
out = out.decode('utf-8')
err = err.decode('utf-8')

# check if there is any difference
if out:
    out = out.split(' ', 1)[1]
    out = '\n'.join([line for line in out.splitlines() if line.strip()])
    with open('database_message/message_to_treat.txt', 'a') as f:
        f.write(out + '\n')
    subprocess.call(['cp', 'database_message/new_messages.txt', 'database_message/messages.txt'])

# check if there was an error
if err:
    print("Error:")
    print(err)

if len(open('database_message/message_to_treat.txt').readlines()) > 0:
    with open('database_message/message_to_treat.txt', 'r') as f:
        first_line = f.readline()
    # print without the \n at the end
    print(first_line[:-1])
    # erase the first line of file message_to_treat.txt without using sed
    with open('database_message/message_to_treat.txt', 'r') as f:
        lines = f.readlines()
    with open('database_message/message_to_treat.txt', 'w') as f:
        f.writelines(lines[1:])

# if treat_message.txt have more than 50 lines, erase it
if len(open('database_message/message_to_treat.txt').readlines()) > 50:
    open('database_message/message_to_treat.txt', 'w').close()