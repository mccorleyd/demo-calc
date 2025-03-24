# Finance Service - Mortgage Affordability Calculator

This microservice provides a simple mortgage affordability calculator API.

## API Endpoints

### 1. Calculate Mortgage Affordability

**Endpoint:** `/mortgage/affordability`

**Method:** POST

**Description:** Calculates the maximum affordable mortgage based on income, expenses, deposit and term.

**Request Body:**

```json
{
  "annualIncome": float,
  "monthlyExpenses": float,
  "depositAmount": float,
  "mortgageTermYears": int
}
```

**Response:**

```json
{
  "maxAffordableMortgage": float,
  "recommendedMonthlyPayment": float,
  "interestRate": float
}
```

**Example Usage:**

```bash
curl -X POST http://localhost:8003/mortgage/affordability \
-H "Content-Type: application/json" \
-d '{
  "annualIncome": 60000,
  "monthlyExpenses": 1800,
  "depositAmount": 25000,
  "mortgageTermYears": 20
}'
```

## Error Handling

The service validates all inputs and returns appropriate error messages with the following status codes:

- `400 Bad Request`: Missing or invalid parameters
- `500 Internal Server Error`: Unexpected server errors

## Calculation Logic

The affordability calculation uses the following logic:

1. Calculate monthly income from annual income
2. Calculate disposable income (monthly income - monthly expenses)
3. Assume 40% of disposable income can be used for mortgage payments
4. Using a fixed interest rate (3.5%), calculate the maximum affordable loan using standard mortgage formula
5. Add the deposit amount to get the total affordable mortgage amount 