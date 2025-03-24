FROM python:3.9-slim

WORKDIR /finance_service

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

ENV PYTHONPATH=/finance_service

CMD ["python", "run.py"] 