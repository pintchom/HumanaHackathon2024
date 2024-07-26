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

@app.route('/add-medication', methods=['POST'])
def add_medication():
    data = request.get_json()
    userId = data.get('userId')
    name = data.get('name')
    daily_schedule = data.get('daily-schedule')
    dosage = data.get('dosage')
    instructions = data.get('instructions')
    returnMessage = fb.addMedication(userId, name, daily_schedule, dosage, instructions)
    return jsonify(returnMessage)

