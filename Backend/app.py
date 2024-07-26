from flask import Flask, jsonify, request
import firebase as fb

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({"message": "Hello, World!"})

@app.route('/get-data', methods=['POST'])
def get_data():
    data = request.get_json()
    userId = data.get('userId')
    userData = fb.get_user_data(userId)
    return jsonify(userData)
