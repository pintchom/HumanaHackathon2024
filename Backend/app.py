from flask import Flask, jsonify, request
from firebase import get_user_data, update_entry
import firebase as fb
import json

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
