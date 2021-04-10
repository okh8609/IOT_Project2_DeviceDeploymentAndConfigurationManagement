from flask import Flask
from flask import request

app = Flask(__name__)


# @app.route('/')
# def hello():
#     return "Hello World10!"

@app.route('/', methods=['GET', 'POST'])
def parse_request():
    print(request.data)
    return "Hello World10!"

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8888)
