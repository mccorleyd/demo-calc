from flask import request, jsonify
from app import app
import math

def round_to_nearest_hundred(value):
    """Round a number to the nearest hundred."""
    return float(round(value / 100) * 100)

@app.route('/mortgage/affordability', methods=['POST'])
def calculate_affordability():
    """
    Calculate mortgage affordability based on income, expenses, deposit and term.
    
    Expected JSON input:
    {
      "annualIncome": float,
      "monthlyExpenses": float,
      "depositAmount": float,
      "mortgageTermYears": int
    }
    
    Returns JSON with:
    {
      "maxAffordableMortgage": float (rounded to nearest £100),
      "recommendedMonthlyPayment": float,
      "interestRate": float
    }
    """
    # Get data from request
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No input data provided"}), 400
            
        # Validate required fields
        required_fields = ["annualIncome", "monthlyExpenses", "depositAmount", "mortgageTermYears"]
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
                
        # Extract and validate input values
        annual_income = float(data.get("annualIncome"))
        monthly_expenses = float(data.get("monthlyExpenses"))
        deposit_amount = float(data.get("depositAmount"))
        mortgage_term_years = int(data.get("mortgageTermYears"))
        
        # Validate input values are positive
        if annual_income <= 0 or monthly_expenses < 0 or deposit_amount < 0 or mortgage_term_years <= 0:
            return jsonify({"error": "All financial values must be positive and term must be greater than 0"}), 400
            
        # Fix interest rate (could be configurable in a more complex implementation)
        interest_rate = 3.5  # 3.5%
        
        # Calculate monthly income
        monthly_income = annual_income / 12
        
        # Calculate disposable income
        disposable_income = monthly_income - monthly_expenses
        
        # Calculate affordable mortgage payment (40% of disposable income)
        affordable_payment = 0.4 * disposable_income
        
        # Calculate maximum affordable mortgage using standard mortgage formula
        # M = P * (r * (1 + r)^n) / ((1 + r)^n - 1)
        # where:
        # M = monthly payment
        # P = principal (loan amount)
        # r = monthly interest rate (annual rate / 12 / 100)
        # n = number of payments (term in years * 12)
        
        r = interest_rate / 12 / 100  # Monthly interest rate
        n = mortgage_term_years * 12  # Total number of payments
        
        # Solve for P (principal)
        # P = M * ((1 + r)^n - 1) / (r * (1 + r)^n)
        numerator = (1 + r)**n - 1
        denominator = r * (1 + r)**n
        max_loan_amount = affordable_payment * (numerator / denominator)
        
        # Add deposit to get total mortgage affordability and round to nearest £100
        max_affordable_mortgage = round_to_nearest_hundred(max_loan_amount + deposit_amount)
        
        # Round monthly payment to 2 decimal places
        affordable_payment = round(affordable_payment, 2)
        
        # Return results
        response_data = {
            "maxAffordableMortgage": max_affordable_mortgage,
            "recommendedMonthlyPayment": affordable_payment,
            "interestRate": interest_rate
        }
        
        return jsonify(response_data)
        
    except ValueError as e:
        return jsonify({"error": f"Invalid input values: {str(e)}"}), 400
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500 