# Mortgage Affordability Calculator Microservice

A simple Flask microservice architecture that provides mortgage affordability calculations via a REST API.

## Architecture

This project uses a microservice architecture with two services:

1. **Main Service**: Acts as an API gateway and provides a simple user interface
2. **Finance Service**: Performs mortgage affordability calculations

## Getting Started

To use this application, you will need to have Docker and Docker Compose installed on your system.

### Running the Application

1. Clone this repository
2. Navigate to the project directory
3. Run the `run.sh` script:

```bash
sh run.sh
```

This will build and start all the services defined in the `docker-compose.yml` file.

### Using the API

Once the services are running, you can use the following endpoint to calculate mortgage affordability:

```bash
curl -X POST http://localhost:8000/calculate_mortgage_affordability \
-H "Content-Type: application/json" \
-d '{
  "annualIncome": 60000,
  "monthlyExpenses": 1800,
  "depositAmount": 25000,
  "mortgageTermYears": 20
}'
```

Example response:

```json
{
  "maxAffordableMortgage": 200000.0,
  "recommendedMonthlyPayment": 850.0,
  "interestRate": 3.5
}
```

## Service Details

### Main Service

The main service runs on port 8000 and provides a simple API gateway that forwards requests to the finance service.

### Finance Service

The finance service runs on port 8003 and provides the core mortgage affordability calculation logic. It has a single endpoint:

- `/mortgage/affordability` (POST): Calculates mortgage affordability based on income, expenses, deposit and term.

See the [Finance Service README](./services/finance_service/README.md) for more details.

## Testing

You can test each service by entering `pytest` in their environment. To test the main application, run the `test.sh` script in the root directory.

## Persistent Storage

Each service has a persistent folder where data is stored and remains even when Docker is restarted. This means that any changes made within Docker are also reflected on the local machine.

## Extending the Application

This template is designed to be easily extendable. You can add more services by following the same pattern:

1. Create a new directory in the `services` folder
2. Add the required files (app, config, Dockerfile, etc.)
3. Update the `docker-compose.yml` file to include the new service
4. Update the `run.sh` script to build the new service
