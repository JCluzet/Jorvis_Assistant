echo "using npm install..."
npm install
echo "using npm install chatgpt..."
npm install chatgpt
echo "using pip3 install imessage_reader"

# if the file config/key_openai.txt is not created, ask to enter the api key of OpenAI
# if the file config/key_openai.txt is not present

clear
if [ ! -f config/key_openai.txt ]; then
    echo -ne "Enter your OpenAI API key then type enter: "
    read -r -s key
    echo $key > config/key_openai.txt
fi

# sleep 10

echo "Testing your OpenAI API key..."
api_key=$(cat config/key_openai.txt)
res=$(node api_OpenAI.js "Tell me that I managed to configure Jorvis perfectly and that the key is good, I can start using Jorvis using the bash command jorvis_launcher.sh" "undefined" "$api_key" 2>error.txt)
first_line=$(echo $res | cut -d'|' -f1)
message=$(echo $res | cut -d'|' -f2)
# if the message contain "'content-length' => { name: 'Content-Length', value:" it means that the key is not good

# if the error.txt file is empty, delete it
if [ -s error.txt ]; then
    # if the error.txt contain Incorrect API key provided, delete the key_openai.txt file and ask to enter a new key
    if [[ $(cat error.txt) == *"Incorrect API key provided"* ]]; then
        echo "❌ Your OpenAI API key is not good. Please launch the script again and enter a good key."
        rm config/key_openai.txt
        echo "You can find your key here: https://platform.openai.com/account/api-keys"
        exit 1
    fi
    echo "❌ There is an error trying to contact ChatGPT server."
    echo "Check this Issue:"
    cat error.txt
    rm config/key_openai.txt
    exit 1
else
    rm error.txt
fi
    echo "✅ $message"
