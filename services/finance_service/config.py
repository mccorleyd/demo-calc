import os

class Config(object):
    DEBUG = False
    TESTING = False
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    HOST = '0.0.0.0'
    PORT = 8003

class TestConfig(Config):
    TESTING = True 