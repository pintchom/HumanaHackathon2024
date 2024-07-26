import os
from click.types import STRING
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

cred = credentials.Certificate("/Users/alexanderding/Desktop/HumanaHackathon2024/Backend/humanahackathon-24-firebase-adminsdk-hqhjz-4d0d73b64b.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

<<<<<<< Updated upstream
=======
def getAllInfo(self):
    return get_user_data()

>>>>>>> Stashed changes
def get_user_data(userId: str):
    user_ref = db.collection('users').document(userId)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        return user_data
    else:
        print(f"No user found with id: {userId}")
        return None
<<<<<<< Updated upstream
=======

def update_entry(userId: str, field: str, newVal: str):
    db.collection('users').document(userId).update({field: newVal})

def addMedication(userId: str, name: str, daily_schedule, dosage: str, instructions: str):
    curDic = get_user_data(userId)['Medication']
    if name in curDic.keys(): return "Medication already in database"
    drugDic = {}
    drugDic['completed'] = False
    drugDic['daily_schedule'] = daily_schedule
    drugDic['dosage'] = dosage
    drugDic['empty'] = False
    drugDic['instructions'] = instructions
    curDic[name] = drugDic
    print(curDic)
    update_entry(userId, 'Medication', curDic)
    return "success"
    


def test_app(self):
    with app.app_context():
        print(addMedication('1', 'test', ["7:00"], "10mg", "Eat"))
        print('\n')
        userData = get_user_data('1')
        print(userData['Medication'])
>>>>>>> Stashed changes
