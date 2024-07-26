import os
from click.types import STRING
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
from flask.scaffold import T_route

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

def addMedication(userId: str, name: str, daily_schedule, dosage: str, instructions: str):
    print(daily_schedule)
    curDic = get_user_data(userId)
    curDic = curDic["Medication"]
    if name in curDic.keys(): return "Medication already in database"
    drugDic = {}
    drugDic['completed'] = False
    drugDic['daily-schedule'] = daily_schedule
    drugDic['dosage'] = dosage
    drugDic['empty'] = False
    drugDic['instructions'] = instructions
    curDic[name] = drugDic
    print(curDic)

    # concerned with atomicity?
    if update_entry(userId, 'Medication', curDic):
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

def take_med(userId: str, index: int):

    dailySchedule = get_user_data(userId)['daily_schedule']
    print(dailySchedule)
    if not (index < 0 or index >= len(dailySchedule)):
        del dailySchedule[index]
        update_entry(userId, "daily_schedule", dailySchedule)
        return "success" 
    else:
        return "Bad index"
