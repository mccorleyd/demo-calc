import json

def test_example(client):
    data = {
        "annualIncome": 60000,
        "monthlyExpenses": 1800,
        "depositAmount": 25000,
        "mortgageTermYears": 20
    }
    response = client.post('/calculate_mortgage_affordability', 
                          data=json.dumps(data),
                          content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert "maxAffordableMortgage" in data
    assert "recommendedMonthlyPayment" in data
    assert "interestRate" in data
    assert data["maxAffordableMortgage"] % 100 == 0  # Check rounding to nearest £100