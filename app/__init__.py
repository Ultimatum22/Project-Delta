# Import flask and template operators
from flask import Flask, render_template

# Define the WSGI application object
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Configurations
app.config.from_object('config')

# Define the database object which is imported
# by modules and controllers
db = SQLAlchemy(app)

# Import a module / component using its blueprint handler variable (mod_auth)
from app.mod_index.controllers import mod_index as index_module
from app.mod_background.controllers import mod_background as background_module
from app.mod_weather.controllers import mod_weather as weather_module

# Register blueprint(s)
app.register_blueprint(index_module)
app.register_blueprint(background_module)
app.register_blueprint(weather_module)

@app.after_request
def add_cors_headers(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Methods', 'PUT, POST, GET')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    return response


# Sample HTTP error handling
@app.errorhandler(404)
def not_found(error):
    return app.send_static_file('404.html')

# Build the database:
# This will create the database file using SQLAlchemy
db.create_all()