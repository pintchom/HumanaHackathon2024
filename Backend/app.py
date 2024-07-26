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


@app.route('/reset-schedule', methods=['POST'])
def reset_schedule():
    data = request.get_json()
    userId = data.get('userId')
    returnMessage = fb.repopulateDailySchedule(userId)
    return jsonify(returnMessage)

@app.route('/request-refill', methods=['POST'])
def request_refill():
    data = request.get_json()
    userId = data.get('userId')
    name = data.get('name')
    daily_schedule = data.get('daily-schedule')
    dosage = data.get('dosage')
    instructions = data.get('instructions')
    returnMessage = fb.requestRefill(userId, name, daily_schedule, dosage, instructions)
    return jsonify(returnMessage)

@app.route('/take-med', methods=['POST'])
def take_med():
    data = request.get_json()
    userId = data.get('userId')
    med_name = data.get('medName')
    time = data.get('time')

    result = fb.take_med(userId, med_name, time)
    
    return jsonify(result)
