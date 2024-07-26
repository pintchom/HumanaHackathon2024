import os
from click.types import STRING
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
from flask.scaffold import T_route
from datetime import datetime


load_dotenv()

cred = credentials.Certificate("humanahackathon-24-firebase-adminsdk-hqhjz-4d0d73b64b.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def get_user_data(userId: str):
    user_ref = db.collection('users').document(userId)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        print(user_data)
        return user_data
    else:
        print(f"No user found with id: {userId}")
        return {}

def update_entry(userId: str, field: str, newVal) -> bool:
    try:
        userRef = db.collection('users').document(userId)
        userRef.update({field: newVal})  
        return True
    except Exception as e:
        print(f"Error updating entry: {e}")  
        return False

def addMedication(userId: str, name: str, daily_schedule, dosage: str, instructions: str):
    print(daily_schedule)
    userData = get_user_data(userId)
    curDic = userData.get("Medication", {})
    if name in curDic.keys(): 
        return "Medication already in database"
    
    drugDic = {
        'completed': False,
        'daily-schedule': daily_schedule,
        'dosage': dosage,
        'empty': False,
        'instructions': instructions
    }
    curDic[name] = drugDic
    print(curDic)

    # Get the static_schedule from the root of userData, not from curDic
    static_schedule = userData.get("static_schedule", [])
    print("Current static schedule:", static_schedule)
    
    for time in daily_schedule:
        tempDict = {
            'time': time,
            'dosage': dosage,
            'instructions': instructions,
            'medication': name
        }
        static_schedule.append(tempDict)
    
    static_schedule.sort(key=lambda x: datetime.strptime(x['time'], '%H:%M'))
    print("Updated static schedule:", static_schedule)

    # Update both Medication and static_schedule
    if update_entry(userId, 'Medication', curDic) and update_entry(userId, "static_schedule", static_schedule):
        return "success"
    else:
        return "failure"
    
def requestRefill(userId: str, name: str, daily_schedule, dosage: str, instructions: str):
    data = get_user_data(userId)
    refills = data['provider']['refill-requests']

    drugDic = {}
    drugDic['completed'] = False
    drugDic['daily_schedule'] = daily_schedule
    drugDic['dosage'] = dosage
    drugDic['empty'] = False
    drugDic['instructions'] = instructions
    
    refills.append(drugDic)

    if update_entry(userId, 'refill-requests', refills): return "success"
    else: return "fail"

def repopulateDailySchedule(userId):
    data = get_user_data(userId)
    statSchedule = data['static_schedule']
    print(statSchedule)
    if update_entry(userId, 'daily_schedule', statSchedule):
        return "success"
    return "failure"
