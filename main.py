from flask import *

from dayCare import *
from public import *
from admin import *
from staff import *

app=Flask(__name__)

app.register_blueprint(public)
app.register_blueprint(admin)
app.register_blueprint(dayCare)
app.register_blueprint(staff)

app.secret_key="aaaaaaaaaaaaaaaa"

app.run(debug=True)
