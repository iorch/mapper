import os


class Config(object):
    DEBUG = os.getenv('DEBUG_MODE')
    ADDR = 'localhost'
    PORT = 5432
    PASSWORD = os.getenv('POSTGRES_PASSWORD')
