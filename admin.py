from flask import *
from database import *


admin=Blueprint('admin',__name__)


@admin.route('/adm')
def adm():
    return render_template('admin.html')
