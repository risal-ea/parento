from flask import *
from database import *


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

@parent.route('/and_manage_babie',methods=['POST'])
def manage_babies():
    data={}
    lid=request.form['lid']

    z="select * from parent where login_id='%s'"%(lid)
    xx=select(z)
    pid=xx[0]['parent_id']
    print(pid)
    baby_name = request.form['baby_name']
    dob = request.form['baby_dob']
    gender = request.form['baby_gender']
    health = request.form['health_issues']
    medical_condition = request.form['medical_condition']

    print(lid,"/////")


    x="insert into babies values(null,'%s','%s','%s','%s','null','%s','%s')"%(pid, baby_name, dob, gender, health, medical_condition)
    b=insert(x)

    print(data)
    return data