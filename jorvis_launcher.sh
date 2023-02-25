spinner[0]="-"
spinner[1]="\\"
spinner[2]="|"
spinner[3]="/"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

must_type_jorvis=1
take_all_people=1

# if the directory conv doesn't exist, create it
if [ ! -d conv ]; then
    mkdir conv
fi

# if the directory database_message doesn't exist, create it
if [ ! -d database_message ]; then
    mkdir database_message
fi

# if the file config/contact.txt doesn't exist, create it
if [ ! -f config/contact.txt ]; then
    touch config/contact.txt
fi

echo "Jorvis is running..."

function is_registered() {
    name=$(grep -w $1 config/contact.txt)
    if [ "$name" != "" ]; then
        # cut the text after the first ,
        request=${name#*|}
        name=${name%%,*}
        echo "$name"
    else
        echo "$1"
    fi
}

function handle_message() {
    number=${1#*\'}
    number=${number%%\'*}
    message=$2
    last_digit=$3

    # if the message is from ME, last digits is 1
    if [ "$last_digit" == "1" ]; then
        # if the message contain jorvis and reset
        if [[ $message == *"jorvis"* ]] && [[ $message == *"reset"* ]]; then
            # echo -e "\r\n\n${GREEN}NEW ${NC}message found !           "
            echo -e "\n${GREEN}Message reset received from you ! ${NC}Reset $number..."
            rm -rf conv/$number
            imessage --text "C'est noté Jo! J'ai reset ma conversation avec le $number 🤖 --Jorvis" --contacts "$number"
            return
        fi
        return
    fi

    echo -e "\r\n"
    # SKIP if its a message from a number not in contact.txt
    name=$(is_registered $number)
    if [ "$name" == "$number" ] && [ "$take_all_people" == "0" ]; then
        echo -e "${RED}$name${NC}"
        echo -e "${RED}SKIPPING ${NC}because not register to Jorvis\n${NC}"
        return
    fi

    # SKIP if the message is longuer than 3000 characters
    if [ ${#message} -gt 3000 ]; then
        echo -e "${RED}SKIPPING ${NC}because message is too long\n${NC}"
        return
    fi

    # skip if the message is empty or None
    if [ "$message" == "" ] || [ "$message" == "None" ]; then
        echo -e "${RED}SKIPPING ${NC}because message is empty\n${NC}"
        return
    fi

    echo -ne " 📨 ${GREEN}$name${NC}: "

    if [ -f conv/$number/conv.txt ]; then
        date=$(stat -f "%Sm" -t "%d %b %H:%M" conv/$number/conv.txt)
        # echo "date: $date"
        timestamp=$(date -j -f "%d %b %H:%M" "$date" "+%s")
        current_timestamp=$(date "+%s")
        if [ $((current_timestamp - timestamp)) -gt 3600 ]; then
            echo -e "${RED}SKIPPING ${NC}because conversation is too old\n${NC}"
            rm -rf conv/$number
            return
        fi
    fi 

    # if the message contain +33684298861, return 
    if [[ $message == *"+33684298861"* ]]; then
        echo -e "${RED}SKIPPING ${NC}because message contain my number\n${NC}"
        return
    fi

    # if must_type_jorvis is 1 AND the conv/$number/conv.txt file don't exist
    if [ "$must_type_jorvis" == "1" ] && [ ! -f conv/$number/conv.txt ]; then
        if [[ $message != *"jorvis"* ]] && [[ $message != *"Jorvis"* ]]; then
            echo -e "$message\n ❌ ${RED}SKIPPING ${NC}> don't contain the word 'jorvis'\n${NC}"
            return
        fi
    fi

    if [[ $message == *"STOP"* ]]; then
        echo -e "\n${RED}User asking to stop conversation ${NC}Reset $number..."
        rm -rf conv/$number
        imessage --text "C'est noté $name! Pour me reactiver tu peux simplement m'appeler dans ton message 🤖 --Jorvis" --contacts "$number"
        return
    fi

    echo -e "${GREEN}${NC}$message"

    # remove all ' from the findmessage
    message=$(echo $message | sed "s/'//g")

    # create date with date and hour
    date=$(date +"%Y-%m-%d %H:%M:%S")

    echo " 🤖 Jorvis is thinking..."
    response=$(bash handle_message.sh "$name" "$message" "$date" "$number")
    echo -e " 🦾 ${GREEN}Jorvis${NC}:$response"

    # send the response to the number
    imessage --text "$response" --contacts "$number"

    echo -e "${GREEN} ✅ Message sent to $name${NC}\n\n"
}

while true; do
    number_lines=$(wc -l < database_message/message_to_treat.txt)
    echo -ne "\r${spinner[i]} Searching for new message..."
    number_lines=$(echo $number_lines | xargs)
    if [ "$number_lines" != "0" ]; then
        echo -e " > $number_lines in waiting list..."
    fi
    new_message=$(python3 get_message.py)

    if [ "$new_message" != "" ]; then
        message=$new_message
        message=${message:18}
        message=${message%,*}
        message=${message%,*}
        message=${message%,*}
        message=${message%,*}
        last_digit=${new_message: -2}
        last_digit=${last_digit:0:1}
        message=$(echo $message | cut -c 1-$((${#message} - 1)))
        handle_message "$new_message" "$message" "$last_digit"
    fi
    i=$(((i + 1) % 4))
done
