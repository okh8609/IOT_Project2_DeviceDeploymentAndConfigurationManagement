#!/bin/bash

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
        kill $(ps -C 'python3 ./rpi.py' | grep 'py' | awk '{print $1}') # kill all previous process
        cp ./rpi_.py ./rpi.py
        python3 ./rpi.py &
    fi  

done
