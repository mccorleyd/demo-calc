import json
import pytest
from app import app
from app.views import round_to_nearest_hundred

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_round_to_nearest_hundred():
    """Test the rounding function."""
    assert round_to_nearest_hundred(150) == 200
    assert round_to_nearest_hundred(149) == 100
    assert round_to_nearest_hundred(250000.49) == 250000
    assert round_to_nearest_hundred(250050.51) == 250100

def test_mortgage_affordability_calculation(client):
    """Test the mortgage affordability calculation with valid inputs."""
    test_data = {
        "annualIncome": 60000,
        "monthlyExpenses": 1800,
        "depositAmount": 25000,
        "mortgageTermYears": 20
    }
    response = client.post('/mortgage/affordability', 
                          data=json.dumps(test_data),
                          content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert "maxAffordableMortgage" in data
    assert "recommendedMonthlyPayment" in data
    assert "interestRate" in data
    assert data["interestRate"] == 3.5
    assert isinstance(data["maxAffordableMortgage"], float)
    assert isinstance(data["recommendedMonthlyPayment"], float)
    # Verify the mortgage amount is a multiple of 100
    assert data["maxAffordableMortgage"] % 100 == 0

def test_missing_required_fields(client):
    """Test error handling when required fields are missing."""
    # Missing annualIncome
    test_data = {
        "monthlyExpenses": 1800,
        "depositAmount": 25000,
        "mortgageTermYears": 20
    }
    response = client.post('/mortgage/affordability', 
                          data=json.dumps(test_data),
                          content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert "error" in data
    assert "Missing required field" in data["error"]

def test_invalid_input_values(client):
    """Test error handling when input values are invalid."""
    # Negative annual income
    test_data = {
        "annualIncome": -60000,
        "monthlyExpenses": 1800,
        "depositAmount": 25000,
        "mortgageTermYears": 20
    }
    response = client.post('/mortgage/affordability', 
                          data=json.dumps(test_data),
                          content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert "error" in data
    assert "All financial values must be positive" in data["error"] 