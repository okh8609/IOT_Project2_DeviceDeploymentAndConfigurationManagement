#!/bin/bash

kill $(ps -C 'python3 ./rpi.py' | grep 'py' | awk '{print $1}')

# get UUID
UUID_FILE_PATH=./UUID.txt
if [ -f $UUID_FILE_PATH ]; then
    # 檔案 /path/to/dir/filename 存在
    echo "File $UUID_FILE_PATH exists."
    UUID=`cat $UUID_FILE_PATH`
    if curl -fs https://khaos.tw/uuid/$UUID | grep "true"
    then
        echo "error: The UUID.txt file has been tampered with."
        exit -1
    fi
    NEW_USR=false
else
    # 檔案 /path/to/dir/filename 不存在
    echo "File $UUID_FILE_PATH does not exists."
    # generate UUID
    UUID=$(uuidgen)
    until $(curl -sf https://khaos.tw/uuid/$UUID | grep -q "true"); do
        UUID=$(uuidgen)
        printf '.'
        sleep 1
    done
    echo $UUID > $UUID_FILE_PATH
    NEW_USR=true
fi
echo $UUID 

# get public domain
kill $(ps -C 'ngrok' | grep 'ngrok' | awk '{print $1}') 
ngrok tcp 22 > /dev/null &

url="http://localhost:4040/api/tunnels"
until $(curl -sf $url | grep -q "public_url"); do
    printf '.'
    sleep 1
done
PUB_URL="$(curl -sf $url | jq ".tunnels[0].public_url")"
echo $PUB_URL

# reg to backend
POST_DATA="{ \"uuid\": \"$UUID\", \"public_url\": $PUB_URL, \"new\": $NEW_USR }"
echo $POST_DATA

curl -i \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "$POST_DATA" "https://khaos.tw/reg"

# 可以用 python3 -m pyinotify -v /tmp 去看到底發生哪些mask
# 如：maskname=IN_MODIFY 或 maskname=IN_MOVED_TO|IN_ISDIR ...
# 然後到 fswatch 的 doc 取看看對應的 Event Flags
fswatch -0  --event Created --event MovedTo --event Updated --event Removed /home/kh/iot_project2_rpi | while read -d "" event; do
    echo "File [ ${event} ] has changed."
    
    cp /home/kh/iot_project2_rpi/ok.py ./rpi_.py
    # cp /home/kh/iot_project2_rpi/rpi.py ./rpi_.py
    pylint3 ./rpi_.py
    EXE_RESULT=$?
    #  1 fatal message issued
    #  2 error message issued
    # 32 usage error
    #  0 no error
    #  4 warning message issued
    #  8 refactor message issued
    # 16 convention message issued
    echo "### EXE_RESULT=$EXE_RESULT"
    if [ $EXE_RESULT -eq 1   -o   $EXE_RESULT -eq 2   -o   $EXE_RESULT -eq 32   -o   $EXE_RESULT -eq 22   -o   $EXE_RESULT -eq 18 ];
    then
        echo "### error.."
    else
        echo "### ok~"
        cp ./rpi_.py ./rpi.py
        kill $(ps -C 'python3 ./rpi.py' | grep 'py' | awk '{print $1}') # kill all previous process
        python3 ./rpi.py &
    fi
done
