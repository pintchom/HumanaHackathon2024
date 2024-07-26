import os
from click.types import STRING
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
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

def update_provider_entry(userId: str, field: str, newVal: str) -> bool:
    try:
        data = get_user_data(userId)
        data1 = data['provider']
        data1[field] = newVal

        db.collection('users').document(userId).update({'provider': data1})
        return True
    except:
        return False

def addMedication(userId: str, name: str, daily_schedule, dosage: str, instructions: str):
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
    curDic = get_user_data(userId)
    curDic = curDic["Medication"]

    if name in curDic.keys(): return "Medication already in database"

    drugDic = {}
    drugDic['completed'] = False
    drugDic['daily_schedule'] = daily_schedule
    drugDic['dosage'] = dosage
    drugDic['empty'] = False
    drugDic['instructions'] = instructions
    curDic[name] = drugDic

    # concerned with atomicity?
    if update_entry(userId, 'Medication', curDic):
        return "success"
    return "failure"

def take_med(userId: str, index: int):

    dailySchedule = get_user_data(userId)['daily_schedule']
    if not (index < 0 or index >= len(dailySchedule)):
        del dailySchedule[index]
        update_entry(userId, "daily_schedule", dailySchedule)
        return "success" 
    else:
        return "Bad index"
    
def addToStaticSchedule(userId: str, medicDic):
    data = get_user_data(userId)
    statSchedule = data['static_schedule']
    statSchedule.append(medicDic)
    statSchedule.sort(key=lambda x: x['time'], reverse=True)
    
    date_format = '%H:%M'
    res = sorted(statSchedule, key=lambda x: datetime.strptime(x['time'], date_format))
    update_entry(userId, 'static_schedule', res)
    
def requestRefill(userId: str, name: str, daily_schedule, dosage: str, instructions: str):
    data = get_user_data(userId)
    data1 = data['provider']
    refills = data1['refill_requests']

    drugDic = {}
    drugDic['completed'] = False
    drugDic['daily_schedule'] = daily_schedule
    drugDic['dosage'] = dosage
    drugDic['empty'] = False
    drugDic['instructions'] = instructions
    
    refills.append(drugDic)

    if update_provider_entry(userId, 'refill_requests', refills): return "success"
    else: return "fail"

def repopulateDailySchedule(userId: str):
    data = get_user_data(userId)
    statSchedule = data['static_schedule']
    update_entry(userId, 'daily_schedule', statSchedule)

#requestRefill('1', 'test', ['7:00'], '10mg', 'eat fast')
