from flask import *
from database import *

dayCare = Blueprint('dayCare', __name__)

@dayCare.route('/dayCare')
def dayCare_home():
    return render_template('dayCare.html')

@dayCare.route('/manageStaff',methods=['post','get'])
def manageStaff():

    print("//////////////////////")
    data={}
    a='select * from staff'
    getData=select(a)
    if getData:
        data['view']=getData

    if 'action' in request.args:
        action=request.args['action']
        id=request.args['id']

    else:
        action=None

    if action=='update':
        qry="select * from staff where login_id='%s'"%(id)  
        res=select(qry)
        if res:
            data['up']=res
            print(res,"////////")
    
    if 'update_staff' in request.form:
        staff_name = request.form['staff_name']
        staff_email = request.form['staff_email']
        staff_phone = request.form['staff_phone']
        staff_dob = request.form['staff_dob']
        gender = request.form['gender']
        staff_adress = request.form['staff_adress']
        position = request.form['position']
        qualification = request.form['qualification']


        z="update staff set staff_name='%s',staff_email='%s',staff_phone='%s', staff_dob='%s', gender='%s', staff_adress='%s', position='%s', qualification='%s' where login_id='%s'"%(staff_name,staff_email,staff_phone,staff_dob,gender,staff_adress,position,qualification,id)
        update(z)
        return '''<script>alert("updated successfully");window.location="/manageStaff"</script>'''
    

    if action=='delete':
        delete_staff = "delete from staff where login_id='%s'"%(id)
        delete_staff_login = "delete from login where login_id='%s'"%(id)

        delete(delete_staff)
        delete(delete_staff_login)
        return '''<script>alert("delete successfully");window.location="/manageStaff"</script>'''

    return render_template('manageStaff.html', data=data)



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

       
        x="insert into staff values(null,'%s','%s','%s','%s','%s','%s','%s','%s','%s', '%s')"%(login_id, session['day_care'], staff_name,staff_email,staff_phone,staff_dob,gender,staff_adress,position, qualification)
        insert(x)

    return render_template('addStaff.html')

@dayCare.route('/manageFacilities', methods=['POST', 'GET'])
def manageFacilities():
    data = {}
    # Retrieve all facilities
    a = 'SELECT * FROM facilities'
    getData = select(a)
    if getData:
        data['view'] = getData

    action = request.args.get('action')
    id = request.args.get('id')

    # Handle update action
    if action == 'update':
        qry = "SELECT * FROM facilities WHERE facility_id='%s'" % id
        res = select(qry)
        if res:
            data['up'] = res

    # Handle form submission for updating facility details
    if 'update_facility' in request.form:
        facility_name = request.form['facility_name']
        facility_type = request.form['facility_type']
        facility_des = request.form['facility_des']
        facility_capacity = request.form['facility_capacity']
        facility_image = request.form['facility_image']
        operating_hrs = request.form['operating_hrs']
        safety_measures = request.form['safety_measures']

        z = """UPDATE facilities 
               SET facility_name='%s', facility_type='%s', facility_des='%s', 
                   facility_capacity='%s', facility_image='%s', 
                   operating_hrs='%s', safety_measures='%s' 
               WHERE facility_id='%s'""" % (facility_name, facility_type, facility_des, 
                                             facility_capacity, facility_image, 
                                             operating_hrs, safety_measures, id)
        update(z)
        return '''<script>alert("Updated successfully"); window.location="/manageFacilities"</script>'''

    # Handle delete action
    if action == 'delete':
        delete_facility = "DELETE FROM facilities WHERE facility_id='%s'" % id
        delete(delete_facility)
        return '''<script>alert("Deleted successfully"); window.location="/manageFacilities"</script>'''

    return render_template('manageFacilities.html', data=data)

@dayCare.route('/addFacility', methods=['GET', 'POST'])
def addFacility():
    if 'add_facility' in request.form:
        facility_name = request.form['facility_name']
        facility_type = request.form['facility_type']
        facility_des = request.form['facility_des']
        facility_capacity = request.form['facility_capacity']
        facility_image = request.form['facility_image']
        operating_hrs = request.form['operating_hrs']
        safety_measures = request.form['safety_measures']

        z = """INSERT INTO facilities 
               (day_care_id, facility_name, facility_type, facility_des, 
                facility_capacity, facility_image, operating_hrs, safety_measures) 
               VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')""" % (
                    session['day_care'], facility_name, facility_type, 
                    facility_des, facility_capacity, facility_image, 
                    operating_hrs, safety_measures)
        insert(z)

    return render_template('addFacility.html')




