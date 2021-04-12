sudo apt update
sudo apt install python3
sudo apt install python3-pip
pip3 install flask

sudo apt install nginx
sudo mkdir -p /etc/letsencrypt/nginx
sudo cp ./nginx/letsencrypt/cert.pem /etc/letsencrypt/nginx/
sudo cp ./nginx/letsencrypt/key.pem /etc/letsencrypt/nginx/
sudo cp ./nginx/etc/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp ./nginx/nginx_conf/default /etc/nginx/sites-available/default
sudo systemctl stop nginx
sudo systemctl start nginx
sudo systemctl restart nginx
sudo systemctl reload nginx
sudo systemctl status nginx.service

sudo ufw allow in 80
sudo ufw allow in 443

sudo apt install uwsgi-core
sudo apt install uwsgi-plugin-python
cd flask
pip3 install -r requirements.txt
uwsgi --socket :8888 --plugin python --wsgi-file app.py \
        --callable app --processes 4 --threads 2 \
        --py-autoreload=1 
        \ #???
        --home /usr/lib
        --home ~/.local

pip3 freeze > requirements.txt

# 查看LOG
cat /var/log/nginx/access.log
cat /var/log/nginx/error.log 
