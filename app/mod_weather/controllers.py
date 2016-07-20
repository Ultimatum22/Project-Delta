import os
import random

import datetime
import exifread
import time

import flask
import forecastio

from app import db

from flask import Blueprint, request, render_template

mod_weather = Blueprint('weather', __name__, url_prefix='/weather')

wind_directions = ['N', 'NNO', 'NO', 'ONO', 'O', 'OZO', 'ZO', 'ZZO', 'Z', 'ZZW', 'ZW', 'WZW', 'W', 'WNW', 'NW', 'NNW']

location = [51.8804, 4.5588]  # Rotterdam, Vegelinsoord
api_key = '5d4bd7c46be7491259968fb2727a43d8'


@mod_weather.route('/get/', methods=['GET'])
def weather_index():

    now = datetime.datetime.now()

    forecast = forecastio.load_forecast(api_key, location[0], location[1])

    forecast.json['daily']['data'] = forecast.json['daily']['data'][:5]
    forecast.json['last_update'] = str(now.hour) + ':' + str(now.minute)
    forecast.json['currently']['windDirection'] = bearing_to_direction(forecast.json['currently']['windBearing'])

    sunrise_time = datetime.datetime.fromtimestamp(int(forecast.json['daily']['data'][0]['sunriseTime']))
    sunset_time = datetime.datetime.fromtimestamp(int(forecast.json['daily']['data'][0]['sunsetTime']))

    if now >= sunrise_time <= sunset_time:
        forecast.json['currently']['sunset_or_sunrise'] = 'sunset'
        forecast.json['currently']['sunset_or_sunrise_time'] = sunset_time.strftime('%H:%M')
    else:
        forecast.json['currently']['sunset_or_sunrise'] = 'sunrise'
        forecast.json['currently']['sunset_or_sunrise_time'] = sunrise_time.strftime('%H:%M')

    return flask.jsonify(forecast.json)


def bearing_to_direction(bearing):
    return wind_directions[(int((bearing / 22.5) + .5) % 16)]
