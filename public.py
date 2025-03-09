from flask import *
from database import *

public=Blueprint('public',__name__)

@public.route("/")
def index():
    return render_template("index.html")


@public.route("/scanner")
def scanner():
    return render_template("scanner.html")

@public.route("/process-qr", methods=["POST"])
def process_qr():
    qr_data = request.json.get("qr_data")
    
    if not qr_data:
        return jsonify({"status": "error", "message": "No QR data provided"}), 400

    print(f"QR Code Scanned - ID: {qr_data}")

    # Check if already checked in and out today
    cc = "select * from checking_history where admission_id='%s' and check_in_date=curdate() and check_out_date=curdate()"%(qr_data)
    vv = select(cc)

    if not vv:
        # Check if there's a pending check-out
        c = "select * from checking_history where admission_id='%s' and check_out_date='pending'"%(qr_data)
        ed = select(c)

        if not ed:
            # Insert new check-in record
            z = "insert into checking_history values(null,'%s',curdate(),curtime(),'pending','pending')"%(qr_data)
            insert(z)
            print("Added Check in data")
            return jsonify({"status": "success", "message": "Successfully checked in"})
        else:
            # Update check-out data
            z = "update checking_history set check_out_date=curdate(),check_out_time=curtime()"
            update(z)
            print("Updated Check out data")
            return jsonify({"status": "success", "message": "Successfully checked out"})
    else:
        print("Already marked check-in and check-out date")
        return jsonify({"status": "success", "message": "Already checked in and out today"})

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

    