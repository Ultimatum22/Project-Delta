from flask import Blueprint, render_template
from app import app

mod_index = Blueprint('index', __name__, url_prefix='/')


@mod_index.route('/')
def index():
    return app.send_static_file('index.html')


@mod_index.route('/<path:path>')
def static_proxy(path):
    return app.send_static_file(path)
