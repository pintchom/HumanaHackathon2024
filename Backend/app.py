from flask import Flask, jsonify, request
import firebase as fb

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({"message": "Hello, World!"})
