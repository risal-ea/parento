from flask import *
from database import *

dayCare = Blueprint('dayCare', __name__)

@dayCare.route('/dayCare')
def dayCare_home():
    return render_template('dayCare.html')

@dayCare.route('/manageStaff')
def manageStaff():
    return render_template('manageStaff.html')

from flask import Blueprint, request, render_template

dayCare = Blueprint('dayCare', __name__)

@dayCare.route('/addStaff', methods=['GET', 'POST'])
def addstaff():
    if 'add_staff' in request.form:
        staff_name = request.form['staff_name']
        staff_email = request.form['staff_email']
        staff_phone = request.form['staff_phone']
        staff_dob = request.form['staff_dob']
        gender = request.form['gender']
        staff_adress = request.form['staff_adress']
        position = request.form['position']
        qualification = request.form['qualification']
        username = request.form['username']
        password = request.form['password']

        z="insert into login values(null,'%s','%s','staff')"%(username,password)
        login_id=insert(z)

        x="insert into staff values(null,'%s','%s','%s','%s','%s','%s','%s','%s','%s', '%s')"%(login_id, dayCare_id, staff_name,staff_email,staff_phone,staff_dob,gender,staff_adress,position, qualification)
        insert(x)

    return render_template('addStaff.html')


