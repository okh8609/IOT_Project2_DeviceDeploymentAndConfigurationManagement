# 開始監控（進入block堵塞模式，動態輸出變動）
# 假設監控/ tmp文件夾
fswatch -0 /tmp | while read -d "" event; do
    echo "This file ${event} has changed."
done



# # task 1
# fswatch $1 | while read -d "" event; do
#     rsync -rauv --delete --progress /path/to/source1/ /path/to/target1/
# done &
 
# # task 2
# fswatch $1 | while read -d "" event; do
#     rsync -rauv --delete --progress /path/to/source2/ /path/to/target2/
# done &
