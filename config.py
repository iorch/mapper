import os


class Config(object):
    DEBUG = os.getenv('DEBUG_MODE')
    ADDR = os.getenv('POSTGRES_PORT_5432_TCP_ADDR')
    PORT = os.getenv('POSTGRES_PORT_5432_TCP_PORT')
    PASSWORD = os.getenv('POSTGRES_ENV_POSTGRES_PASSWORD')
