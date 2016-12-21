import logging
logging.config.fileConfig('logging.ini')
logger = logging.getLogger('manage')

from flask import Flask, redirect, current_app
from flask_script import Manager, Shell, Command, Server, prompt_bool
from .dummy_data import get_dummy_data

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


def create_app(testing=False):
    app = Flask(__name__)
    app.config.from_pyfile('default.py')

    @app.route('/')
    def hello():
        return "hello"

    db.init_app(app)

    return app

manager = Manager(
    create_app,
    with_default_commands=False,
)


def _drop_all():
    """Will drop ALL tables in db, including alembic_version.
    """
    logger.critical('Using db: {0}'.format(db.engine))
    if prompt_bool(
            'Are you sure you want to delete all the data in the given database? [y/n]'):
        db.metadata.reflect(db.engine)
        db.drop_all()


class RunServer(Server):

    def handle(self, *args, **kwargs):
        Server.handle(self, *args, **kwargs)

manager.add_command(
    'run-server',
    RunServer(
        use_debugger=True,
        use_reloader=True,
        host='0.0.0.0',
    ),
)


class CreateAll(Command):

    def run(self):
        db.create_all()

manager.add_command('create-all', CreateAll())


class DropAll(Command):

    def run(self):
        _drop_all()

manager.add_command('drop-all', DropAll())


class Populate(Command):

    @staticmethod
    def populate_dummy_data(session):
        session.add_all(get_dummy_data())
        session.commit()

    def run(self):
        Populate.populate_dummy_data(db.session)


class InitDB(Command):

    def run(self):
        _drop_all()
        db.create_all()
        Populate.populate_dummy_data(db.session)

manager.add_command('init-db', InitDB())


def _make_context():
    context = dict(
        db=db,
        current_app=current_app,
    )
    from backend import models
    context.update(vars(models))
    return context

manager.add_command('shell', Shell(make_context=_make_context))

if __name__ == '__main__':
    manager.run()
