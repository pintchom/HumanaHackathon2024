import os
from click.types import STRING
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

load_dotenv()

cred = credentials.Certificate("/Users/alexanderding/Desktop/HumanaHackathon2024/Backend/humanahackathon-24-firebase-adminsdk-hqhjz-4d0d73b64b.json")
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

def update_entry(userId: str, field: str, newVal: str) -> bool:
    try:
        db.collection('users').document(userId).update({field: newVal})
        return True
    except:
        return False

def addMedication(userId: str, name: str, daily_schedule, dosage: str, instructions: str):
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
    if update_entry(userId, 'Medication', curDic) and addToStaticSchedule(userId, curDic):
        return "success"
    else:
        return "failure"
    
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
    refills = data['refill_requests']

    drugDic = {}
    drugDic['completed'] = False
    drugDic['daily_schedule'] = daily_schedule
    drugDic['dosage'] = dosage
    drugDic['empty'] = False
    drugDic['instructions'] = instructions
    
    refills.append(drugDic)

    if update_entry(userId, 'refill-requests', refills): return "success"
    else: return "fail"

def repopulateDailySchedule(userId: str):
    data = get_user_data(userId)
    statSchedule = data['static_schedule']
    update_entry(userId, 'daily_schedule', statSchedule)
