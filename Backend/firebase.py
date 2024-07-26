import os
from click.types import STRING
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore

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
        return None
