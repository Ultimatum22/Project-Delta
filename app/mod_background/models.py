from app import db


class Base(db.Model):
    __abstract__ = True

    id = db.Column(db.Integer, primary_key=True)
    date_created = db.Column(db.DateTime, default=db.func.current_timestamp())
    date_modified = db.Column(db.DateTime, default=db.func.current_timestamp(),
                              onupdate=db.func.current_timestamp())


class Background(Base):
    __tablename__ = 'auth_background'

    url = db.Column(db.String(256), nullable=False)
    album = db.Column(db.String(256), nullable=False)
    taken_by = db.Column(db.String(256), nullable=False)
    date_taken = db.Column(db.String(256), nullable=False)

    def __init__(self, url, album, taken_by, date_taken):
        self.url = url
        self.album = album
        self.taken_by = taken_by
        self.date_taken = date_taken

    def __repr__(self):
        return '<Album %r>' % self.album