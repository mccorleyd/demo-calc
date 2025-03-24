import requests
from flask import request, jsonify
from app import app

@app.route('/')
def index():
    return "Mortgage Affordability Calculator Microservice <br> Based on Flask-Microservice-Template <br> By: Biebras and YuelinXin"

@app.route('/calculate_mortgage_affordability', methods=['POST'])
def calculate_mortgage_affordability():
    """
    Proxy endpoint that forwards the request to the finance service
    for mortgage affordability calculation.
    """
    try:
        # Get data from request
        data = request.get_json()
        if not data:
            return jsonify({"error": "No input data provided"}), 400
            
        # Forward request to finance service
        response = requests.post('http://finance-service:8003/mortgage/affordability', json=data)
        
        # Return the response from the finance service
        return response.json(), response.status_code
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500