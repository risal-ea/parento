from flask import *
from database import *

public=Blueprint('public',__name__)

@public.route("/")
def index():
    return render_template("index.html")

@public.route("/login",methods=['post','get'])
def log():
    if 'login' in request.form:
        uname=request.form['username']
        password=request.form['psw']

        getData="SELECT * FROM login WHERE username='%s' AND PASSWORD='%s'"%(uname,password)
        res = select(getData)

        if res:
            if res[0]['usertype']=='admin':
                return redirect(url_for('admin.adm'))
        
    return render_template("login.html")


@public.route("/dayCareReg",methods=['post','get'])
def dayCareReg():
    if 'register' in request.form:
        name = request.form['name']
        owner_name = request.form['ownerName']
        phone_no = request.form['phoneNo']
        adress = request.form['address']
        license_number = request.form['licenseNumber']
        capacity = request.form['capacity']
        opTime = request.form['opTime']
        dcDescription = request.form['dcDescription']
        username = request.form['username']       
        password = request.form['password']

        z="insert into login values(null,'%s','%s','dayCare')"%(username,password)
        id=insert(z)

        x="insert into day_care values(null,'%s','%s','%s','%s','%s','%s','%s','%s','%s')"%(id, name, owner_name,phone_no,adress,license_number,capacity,opTime,dcDescription)
        insert(x)


    return render_template("dayCareRegistration.html")

@public.route("/parentReg",methods=['post','get'])
def parentReg():
    if 'register' in request.form:
        name = request.form['name']
        phone_no = request.form['phone']
        adress = request.form['adress']
        gender = request.form['gender']
        dob = request.form['dob']
        email = request.form['email']
        username = request.form['username']
        password = request.form['password']

        z="insert into login values(null,'%s','%s','parent')"%(username,password)
        id=insert(z)

        x="insert into parent values(null,'%s','%s','%s','%s','%s','%s','%s')"%(id, name, email,phone_no,adress,dob,gender)
        insert(x)

    return render_template("parentRegistration.html")

    