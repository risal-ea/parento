from flask import *
from database import *
from datetime import datetime

import os

curentDateTime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')


parent=Blueprint('parent',__name__)

@parent.route('/and_login',methods=['POST'])
def login():
    data={}

    uname=request.form['username']
    password= request.form['password']
    
    a="select * from login where username = '%s' and password = '%s' and usertype='parent'" %(uname, password)
    s = select(a)
    if s:
        data['status']='success'
        data['login_id']=s[0]['login_id']
    else:
        data['status']='failed'
    return data

@parent.route('/and_registor',methods=['POST'])
def registor():
    data={}

    name= request.form['name']
    phn_num = request.form['phone_number']
    email = request.form['email']
    addres = request.form['addres']
    dob = request.form['dob']
    gender = request.form['gender']
    uname=request.form['username']
    password= request.form['password']

    z="insert into login values(null,'%s','%s','parent')"%(uname,password)
    id=insert(z)

    x="insert into parent values(null,'%s','%s','%s','%s','%s','%s','%s')"%(id, name, email, phn_num, addres, dob, gender)
    b=insert(x)

    if b:
        data['status']='success'
    else:
        data['status']='failed'

    print("Name:", name)
    print("Phone Number:", phn_num)
    print("Email:", email)
    print("Address:", addres)
    print("Date of Birth:",dob)
    print("Gender:", gender)
    print("Username:", uname)
    print("Password:", password)
    
    return data

@parent.route('/view_daycare',methods=['POST'])
def daycare():
    data={}
    a="select * from day_care"
    s = select(a)
    if s:
        data['status']='success'
        data['data']=s
    else:
        data['status']='failed'
    print(data)
    return data


import os
from flask import request, jsonify
from werkzeug.utils import secure_filename
from database import insert, select

UPLOAD_FOLDER = 'static/baby_photos'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@parent.route('/and_manage_babie', methods=['POST'])
def manage_babies():
    data = {}
    lid = request.form['lid']

    query = "SELECT * FROM parent WHERE login_id='%s'" % (lid)
    parent_data = select(query)

    if not parent_data:
        return jsonify({"status": "failed", "message": "Invalid parent ID"})

    pid = parent_data[0]['parent_id']
    baby_name = request.form['baby_name']
    dob = request.form['baby_dob']
    gender = request.form['baby_gender']
    health = request.form['health_issues']
    medical_condition = request.form['medical_condition']

    baby_photo = "null"

    if 'baby_photo' in request.files:
        file = request.files['baby_photo']
        if file.filename != '':
            filename = secure_filename(file.filename)
            file_path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(file_path)
            baby_photo = file_path

    insert_query = """
        INSERT INTO babies VALUES 
        (NULL, '%s', '%s', '%s', '%s', '%s', '%s', '%s')
    """ % (pid, baby_name, dob, gender, baby_photo, health, medical_condition)
    
    insert(insert_query)

    return jsonify({"status": "success", "message": "Baby details saved successfully"})



# @parent.route('/and_manage_babie',methods=['POST'])
# def manage_babies():
#     data={}
#     lid=request.form['lid']

#     z="select * from parent where login_id='%s'"%(lid)
#     xx=select(z)
#     pid=xx[0]['parent_id']
#     print(pid)
#     baby_name = request.form['baby_name']
#     dob = request.form['baby_dob']
#     gender = request.form['baby_gender']
#     health = request.form['health_issues']
#     medical_condition = request.form['medical_condition']

#     print(lid,"/////")


#     x="insert into babies values(null,'%s','%s','%s','%s','null','%s','%s')"%(pid, baby_name, dob, gender, health, medical_condition)
#     b=insert(x)

#     print(data)
#     return data

@parent.route('/and_send_complaint', methods=['POST'])
def sendComplaint():
    data={}
    lid=request.form['lid']
    complaint=request.form['complaint']

    query = "INSERT INTO complaint VALUES (NULL, '%s', '%s', NULL, '%s', 'Pending')" % (lid, complaint, curentDateTime)
    insertData = insert(query)

    if insertData:
        data['status'] = 'success'
    else:
        data['status'] = 'failed'
    return data

    
@parent.route('/and_send_feedback', methods=['POST'])
def sendFeedback():
    data={}
    lid=request.form['lid']
    feedback=request.form['feedback']
    daycareId=request.form['daycareId']

    # Daycare id isnot set in the below query
    query = "INSERT INTO feedback VALUES (NULL, '%s', '%s', '%s', '%s')" % (daycareId, lid, feedback, curentDateTime)
    insertData = insert(query)

    if insertData:
        data['status'] = 'success'
    else:
        data['status'] = 'failed'
    return data
    
@parent.route('/view_facility',methods=['POST'])
def view_facility():
    data={}
    a="select * from facilities"
    s = select(a)
    if s:
        data['status']='success'
        data['data']=s
    else:
        data['status']='failed'
    print(data)
    return data

@parent.route("/Activities", methods=['POST'])
def activities():
    lid=request.form['lid']
    baby_id=request.form['baby_id']

    print(lid,"////")

    data = {}
    # a = "SELECT * FROM daily_activity"
    a="SELECT * FROM parento.daily_activity inner join babies using(baby_id) inner join parent using(parent_id) where login_id='%s' and baby_id='%s'"%(lid,baby_id)
    s = select(a) 
    
    print("Database Response:", s)  # Debugging line

    if s:
        data['status'] = 'success'
        data['data'] = s  # Ensure `s` is a list of dictionaries
    else:
        data['status'] = 'failed'
    
    return data

@parent.route('/baby_profile', methods=["POST"])
def babyprofile():
    data={}
    lid=request.form['lid']
    print(lid,"//")
    a="SELECT * FROM parento.babies inner join parent using(parent_id) where parent.login_id='%s'"%(lid)
    s = select(a)
    if s:
        data['status']='success'
        data['data']=s
    else:
        data['status']='failed'
    print(data)
    return data

@parent.route('/daycare_details', methods=['POST'])
def daycare_details():
    data = {}
    daycare_id = request.form['day_care_id']

    query = f"SELECT * FROM day_care WHERE day_care_id = '{daycare_id}'"
    result = select(query)

    if result:
        data['status'] = 'success'
        data['details'] = result[0]  # Assuming one record per daycare_id
    else:
        data['status'] = 'failed'

    print(data)
    return jsonify(data)

@parent.route('/admition_request', methods=['POST'])
def admition_request():
    startDate = request.form['startDate']
    schedule = request.form['schedule']
    daycare_id = request.form['daycareId']
    print(daycare_id,"////")
    loginID = request.form.get('lid')

    getParentId = "select * from parent where login_id = '%s'" % (loginID)
    parent_id = select(getParentId)[0]['parent_id']

    insertData = "insert into admission_request values(null, '%s', 1, '%s', '%s', 'pending', '%s', 'pending', '%s','pending')"%(parent_id, startDate, schedule, daycare_id, curentDateTime)
    insert(insertData)


    return jsonify({"status": "success", "message": "Request received"})
