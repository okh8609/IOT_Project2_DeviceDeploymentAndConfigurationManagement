from flask import Flask, jsonify
from flask import request
import json
import sqlite3


app = Flask(__name__)


@app.route('/', methods=['GET', 'POST'])
def index():
    print(request.data)
    return "Hello World10!"


@app.route('/reg', methods=['POST'])
def reg():
    data = json.loads(request.data)
    print("--------------------###--------------------")
    print(data['uuid'])
    print(data['public_url'])
    print(data['new'])
    print("--------------------###--------------------")

    conn = sqlite3.connect('iot2.db')
    cur = conn.cursor()
    if data['new']:
        cur.execute("select * from USER where UUID = ?", (data['uuid'],))
        entry = cur.fetchone()
        if entry is None:  # No entry found
            cur.execute("insert into USER (UUID, URL) values (?, ?)",(data['uuid'], data['public_url']))   
            conn.commit()
            conn.close()         
            return jsonify(0) # new uuid reg
        else:
            return jsonify(-1) # uuid duplicate (please re-reg)
    else:
        cur.execute("update USER set URL = ? where UUID = ?", (data['public_url'], data['uuid']) )  # 門是開的
        conn.commit()
        conn.close()    
        return jsonify(1) # update url


@app.route('/uuid/<uuid>', methods=['GET'])
def check_uuid(uuid):
    conn = sqlite3.connect('iot2.db')
    cur = conn.cursor()
    cur.execute("select * from USER where UUID = ?", (uuid,))
    entry = cur.fetchone()
    if entry is None:  # No entry found
        return jsonify(True) # uuid not exist - 可以使用
    else:
        return jsonify(False) # uuid exist - 不能使用

@app.route('/user')
def print_user_table():
    conn = sqlite3.connect('iot2.db')
    cur = conn.cursor()
    with conn:
        cur.execute("SELECT * FROM USER")
        return jsonify(cur.fetchall())


# 初始化資料庫
@app.route('/sql')
def sql_init():
    conn = sqlite3.connect('iot2.db')
    c = conn.cursor()
    # 建立表格
    c.execute('''create table if not exists USER
        (UUID    TEXT    NOT NULL,
         URL     TEXT    NOT NULL,
         PRIMARY KEY (UUID));
        ''')
    conn.commit()
    conn.close()
    return jsonify("OK")


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8888)
