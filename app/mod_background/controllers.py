import json
import os
import random

import exifread
import time

import flask
from flask import url_for
from werkzeug.utils import redirect

from app import db, app

from flask import Blueprint, request, render_template

DT_TAGS = ["Image DateTime", "EXIF DateTimeOriginal", "DateTime"]

mod_background = Blueprint('background', __name__, url_prefix='/background')


@mod_background.route('/get/', methods=['GET'])
def background_get():
    script_dir = os.path.dirname(os.path.abspath('run.py'))
    # photo_albums_dir = os.sep.join([script_dir, 'static', 'photo_albums'])
    photo_albums_dir = os.sep.join(['app', 'static', 'photo_albums'])

    print '[[photo_albums_dir]]', photo_albums_dir

    files = [os.path.join(path, filename)
             for path, dirs, files in os.walk(photo_albums_dir)
             for filename in files]
    random_background = random.choice(files)

    album = ""
    taken_by = ""
    date_taken = ""

    try:
        date_taken = get_exif_date_exif(random_background)
    except:
        print('Something is terribly wrong! Both PIL and exifread raises exception')

    image_data = random_background.split(os.path.sep)[2:]
    image_data_length = len(image_data)

    if image_data_length == 3:
        album = image_data[1]
    elif image_data_length == 4:
        taken_by = image_data[2]
        album = image_data[1]
    elif image_data_length == 5:
        taken_by = image_data[3]
        album = image_data[1] + ' / ' + image_data[2]
    return flask.jsonify(
        # url='/'.join(random_background.split(os.path.sep)),
        url='/' + '/'.join(random_background.split(os.path.sep)[1:]),
        album=album,
        taken_by=taken_by,
        date_taken=date_taken)


@mod_background.route('/upload/', methods=['GET'])
def background_upload():
    return app.send_static_file('upload.html')


@mod_background.route('/upload/do/', methods=['POST', 'GET'])
def background_upload_do():
    """Handle the upload of a file."""
    form = request.form

    # Is the upload using Ajax, or a direct POST by the form?
    is_ajax = False
    if form.get("__ajax", None) == "true":
        is_ajax = True

    print form.items()

    # Target folder for these uploads.
    # target = os.sep.join(['app', 'static', 'photo_albums', 'Test', 'Dave'])
    script_dir = os.path.dirname(os.path.abspath(__file__))
    target = os.sep.join([script_dir, 'static', 'photo_albums', form.items()[0][1], form.items()[1][1]])

    for upload in request.files.getlist("file"):
        filename = upload.filename.rsplit(os.sep)[0]
        if not os.path.exists(target):
            print "Creating directory:", target
            os.makedirs(target)

        destination = os.sep.join([target, filename])

        print "Accept incoming file:", filename
        print "Save it to:", destination
        upload.save(destination)

    # if is_ajax:
    return ajax_response(True, msg="DONE!")
    # else:
    #     return redirect(url_for('upload'))


def ajax_response(status, msg):
    status_code = "ok" if status else "error"
    return json.dumps(dict(
        status=status_code,
        msg=msg,
    ))


def exif_info2time(ts):
    """changes EXIF date ('2005:10:20 23:22:28') to number of seconds since 1970-01-01"""
    return time.mktime(time.strptime(ts + 'UTC', '%Y:%m:%d %H:%M:%S%Z'))


def get_exif_date_exif(jpegfn):
    dt_value = None
    f = open(jpegfn, 'rb')
    try:
        tags = exifread.process_file(f)
        # print('tags cnt: %d' % len(tags))
        # print('\n'.join(tags))
        for dt_tag in DT_TAGS:
            try:
                dt_value = '%s' % tags[dt_tag]
                break
            except:
                continue
        if dt_value:
            exif_time = exif_info2time(dt_value)
            return exif_time
    finally:
        f.close()
    return None