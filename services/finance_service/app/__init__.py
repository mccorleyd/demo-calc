from flask import Flask

def create_app(configName='config'):
    app = Flask(__name__)
    app.config.from_object(configName)
    return app

app = create_app()

from app import views 