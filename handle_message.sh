name=$1
message=$2
date=$3
number=$4

first_message_to_jorvis="Je m'appelle $name et tu dois repondre a ce message : $message, presente toi comme l'assistant de Joseph, créé par Joseph et basé sur un modele de Machine Learning, dis que tu est ravi de me rencontrer, que tu repondras a toutes mes demandes pendant 1h. Au bout d'une heure pour me reactiver il suffit d'ecrire Jorvis dans mon message. Rappelle moi que si je ne veux plus te parler il faut que j'ecrive STOP en majuscule dans mon message. "
first_message_from_jorvis="jorvis: Salut je suis Jorvis, l'assistant de Jo. -Jorvis"

# if the file conv/$number/ is not created, it's the first message of the conversation
# So we create the file conv/$number/conv.txt and conv/$number/res.txt, and we present Jorvis to the user with rules
if [ ! -d conv/$number ]; then
    mkdir conv/$number/
    touch conv/$number/conv.txt
    touch conv/$number/res.txt
    cat config/rules.txt >conv/$number/conv.txt
    # echo "Les regles : Tu est jorvis, l'assistant de Jo. Tu dois repondre au dernier message.">conv/$number/conv.txt
    echo "$name: $message" >>conv/$number/conv.txt
    message=first_message_to_jorvis
    echo "$first_message_from_jorvis" >>conv/$number/conv.txt
    # echo "jorvis: Salut je suis Jorvis, l'assistant de Jo. -Jorvis" >>conv/$number/conv.txt
    api_key=$(cat config/key_openai.txt)
    res=$(node api_OpenAI.js "$message" "undefined" "$api_key")
    first_line=$(echo $res | cut -d'|' -f1)
    message=$(echo $res | cut -d'|' -f2)
    echo $first_line > conv/$number/res.txt
    echo "$message"
else
    # else we just add the message to the conversation
    echo "$name: $message" >>conv/$number/conv.txt
    res=$(cat conv/$number/res.txt)
    message="$name: $message"
    bam=$(cat conv/$number/conv.txt)
    new_message="$bam"
    echo -ne "jorvis: " >>conv/$number/conv.txt
    api_key=$(cat config/key_openai.txt)
    response=$(node api_OpenAI.js "$new_message" "$res" "$api_key")
    first_line=$(echo $response | cut -d'|' -f1)
    message=$(echo $response | cut -d'|' -f2)
    echo $first_line > conv/$number/res.txt
    echo "$message" >>conv/$number/conv.txt
    echo $message
fi

