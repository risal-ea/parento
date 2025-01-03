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
        session['log']= res[0]['login_id']
        print(session['log'])

        if res:
            if res[0]['usertype']=='admin':
                return redirect(url_for('admin.adm'))
            elif res[0]['usertype']=='dayCare':
                qry="select * from day_care where login_id='%s'"%(session['log'])
                res1=select(qry)
                session['day_care']=res1[0]['day_care_id']
                return redirect(url_for('dayCare.dayCare_home'))
            elif res[0]['usertype']=='staff':
                qry="select * from staff where login_id='%s'"%(session['log'])
                res1=select(qry)
                session['staff']=res1[0]['staff_id']
                return redirect(url_for('staff.staffHome'))

        
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

        z="insert into login values(null,'%s','%s','pending')"%(username,password)
        id=insert(z)

        x="insert into day_care values(null,'%s','%s','%s','%s','%s','%s','%s','%s','%s')"%(id, name, owner_name,phone_no,adress,license_number,capacity,opTime,dcDescription)
        insert(x)


    return render_template("dayCareRegistration.html")

@public.route("/parentReg",methods=['post','get'])
def parentReg():
    if 'register' in request.form:
        name = request.form['name']
        phone_no = request.form['phone']
        adress = request.form['address']
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

    