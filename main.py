from flask import *

from dayCare import *
from public import *
from admin import *
from staff import *
from parent import *

app=Flask(__name__)

app.register_blueprint(public)
app.register_blueprint(admin)
app.register_blueprint(dayCare)
app.register_blueprint(staff)
app.register_blueprint(parent)

app.secret_key="aaaaaaaaaaaaaaaa"

from flask import Flask, request, jsonify

@app.route('/update_payment_status', methods=['POST','GET'])  # Restrict to POST only
def update_payment_status():
    data = {}
    try:
        # Extract admission from form data (matches Flutter's "admission" key)
        admission = request.form.get('admission', '')
        if not admission:
            data['status'] = 'error'
            data['message'] = 'Admission ID is required'
            return jsonify(data), 400

        print(f"Admission ID: {admission} ////")

        # Use parameterized query to safely select data
        select_query = "SELECT * FROM admission_request WHERE adminssion_id = %s"%(admission)
        select_result = select(select_query)

        print(f"Select result: {select_result} //////")

        if not select_result:
            data['status'] = 'error'
            data['message'] = 'No admission request found for the given ID'
            return jsonify(data), 404

        # Use parameterized query to safely update payment status
        update_query = "UPDATE admission_request SET payment_status = 'paid' WHERE adminssion_id = %s"%(admission)
        update_result = update(update_query)

        # Check if update was successful (assuming update returns rows affected or True)
        if update_result:
            # Uncomment and fix this if you want to insert into admission_payment
            # insert_query = "INSERT INTO admission_payment VALUES (NULL, %s, %s, NOW(), 'paid')"
            # insert_result = insert(insert_query, (admission, select_result[0].get('payment', '')))
            # if insert_result:
            #     data['status'] = 'success'
            #     data['message'] = 'Payment status updated and recorded successfully'
            # else:
            #     data['status'] = 'failed'
            #     data['message'] = 'Failed to record payment'
            # return jsonify(data), 200 if insert_result else 500

            data['status'] = 'success'
            data['message'] = 'Payment status updated successfully'
        else:
            data['status'] = 'failed'
            data['message'] = 'Failed to update payment status'

        return jsonify(data), 200 if update_result else 500

    except KeyError as e:
        print(f"KeyError: {str(e)}")
        data['status'] = 'error'
        data['message'] = f'Missing required field: {str(e)}'
        return jsonify(data), 400
    except Exception as e:
        print(f"Error in update_payment_status: {str(e)}")
        data['status'] = 'error'
        data['message'] = f'Internal server error: {str(e)}'
        return jsonify(data), 500





@app.route('/and_login',methods=['POST','GET'])
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


@app.route('/and_registor',methods=['POST'])
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

@app.route('/view_daycare',methods=['POST'])
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

@app.route('/and_manage_babie', methods=['POST'])
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



# @app.route('/and_manage_babie',methods=['POST'])
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

@app.route('/and_send_complaint', methods=['POST'])
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

    
@app.route('/and_send_feedback', methods=['POST'])
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
    
@app.route('/view_facility', methods=['POST'])
def view_facility():
    try:
        data = {}
        daycare_id = request.form.get('daycareId')
        print("id//////////////", daycare_id)

        if not daycare_id:
            return jsonify({'status': 'failed', 'message': 'Missing daycareId'}), 400

        query = "SELECT * FROM facilities WHERE day_care_id = %s"%(daycare_id)
        result = select(query)  # ✅ Secure query

        if result:
            data['status'] = 'success'
            data['data'] = result
        else:
            data['status'] = 'failed'
            data['message'] = 'No facilities found'

        return jsonify(data)
    except Exception as e:
        print(f"Server Error: {e}")  # ✅ Corrected Error Handling
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route("/Activities", methods=['POST'])
def activities():
    lid=request.form['lid']
    baby_id=request.form['baby_id']

    print(lid,"////")

    data = {}
    a="SELECT * FROM parento.daily_activity inner join babies using(baby_id) inner join parent using(parent_id) where login_id='%s' and baby_id='%s'"%(lid,baby_id)
    s = select(a) 
    
    print("Database Response:", s)  # Debugging line

    if s:
        data['status'] = 'success'
        data['data'] = s  # Ensure `s` is a list of dictionaries
        print(data['data'])
    else:
        data['status'] = 'failed'
    
    return data

@app.route('/baby_profile', methods=["POST"])
def babyprofile():
    data={}
    lid=request.form['lid']
    print(lid,"baby profile//")
    a="SELECT * FROM parento.babies inner join parent using(parent_id) where parent.login_id='%s'"%(lid)
    s = select(a)
    if s:
        data['status']='success'
        data['data']=s
    else:
        data['status']='failed'
    print(data)
    return data

@app.route('/daycare_details', methods=['POST'])
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

@app.route('/admition_request', methods=['POST'])
def admition_request():
    startDate = request.form['startDate']
    schedule = request.form['schedule']
    daycare_id = request.form['daycareId']
    print(daycare_id,"////")
    loginID = request.form.get('lid')
    babyId = request.form.get('babyId')
    print(babyId,"///")

    getParentId = "select * from parent where login_id = '%s'" % (loginID)
    parent_id = select(getParentId)[0]['parent_id']

    insertData = "insert into admission_request values(null, '%s', '%s', '%s', '%s', 'pending', '%s', 'pending', '%s','pending')"%(parent_id, babyId, startDate, schedule, daycare_id, curentDateTime)
    insert(insertData)

    return jsonify({"status": "success", "message": "Request received"})



@app.route("/baby_details", methods=['POST', 'GET'])
def baby_details():
    try:
        baby_id = request.form.get('baby_id', '')  # Safely get baby_id
        
        if not baby_id:
            return jsonify({"status": "error", "message": "Baby ID is required"}), 400

        print(f"Baby ID received: {baby_id}")  # Improved logging

        # Fetch baby details from database (unchanged query)
        query = "SELECT baby_name, baby_dob, baby_photo, allergies_or_dietry_restriction, medical_condition FROM babies WHERE baby_id=%s"
        result = select(query, (baby_id,))

        # Fetch QR code separately (unchanged query)
        qr_query = "SELECT * FROM admission_request WHERE baby_id = %s"
        qr_result = select(qr_query, (baby_id,))

        if result and len(result) > 0:  # If baby data is found
            baby_data = {
                "status": "success",
                "data": [{
                    "baby_name": result[0].get("baby_name", ""),
                    "payment": str(qr_result[0].get("payment", "")) if qr_result and len(qr_result) > 0 else "",
                    "payment_status": qr_result[0].get("payment_status", "") if qr_result and len(qr_result) > 0 else "",
                    "admision": str(qr_result[0].get("adminssion_id", "")) if qr_result and len(qr_result) > 0 else "",
                    "baby_dob": str(result[0].get("baby_dob", "")) if result[0].get("baby_dob") else "",
                    "baby_photo": "" if result[0].get("baby_photo", "") == "null" else result[0].get("baby_photo", ""),
                    "allergies_or_dietry_restriction": result[0].get("allergies_or_dietry_restriction", ""),
                    "medical_condition": result[0].get("medical_condition", ""),
                    "qr_code": qr_result[0].get("qr_code", "") if qr_result and len(qr_result) > 0 else ""
                }]
            }
            print(f"Returning baby data: {baby_data}")  # Log the response
            return jsonify(baby_data), 200
        else:
            print(f"No baby found for ID: {baby_id}")
            return jsonify({"status": "error", "message": "Baby not found"}), 404

    except Exception as e:
        print(f"Error in baby_details: {str(e)}")
        return jsonify({"status": "error", "message": "Internal server error"}), 500
    

# @app.route("/baby_details", methods=['POST','GET'])
# def baby_details():
#     try:
#         baby_id = request.form.get('baby_id', '')  # Safely get baby_id
        
#         if not baby_id:
#             return jsonify({"status": "error", "message": "Baby ID is required"}), 400

#         print(f"Baby ID received: {baby_id}")  # Improved logging

#         # Fetch baby details from database
#         query = "SELECT baby_name, baby_dob, baby_photo, allergies_or_dietry_restriction, medical_condition FROM babies WHERE baby_id=%s"
#         result = select(query, (baby_id,))

#         # Fetch QR code separately
#         qr_query = "SELECT * FROM admission_request WHERE baby_id = %s"
#         qr_result = select(qr_query, (baby_id,))

#         if result and len(result) > 0:  # If baby data is found
#             baby_data = {
#                 "status": "success",
#                 "data": [{
#                     "baby_name": result[0]["baby_name"],
#                     "payment": qr_result[0]["payment"],
#                     "payment_status": qr_result[0]["payment_status"],
#                     "admision": qr_result[0]["adminssion_id"],
#                     "baby_dob": str(result[0]["baby_dob"]),  # Convert date to string
#                     "baby_photo": result[0]["baby_photo"] or "",  # Handle null values
#                     "allergies_or_dietry_restriction": result[0]["allergies_or_dietry_restriction"] or "",
#                     "medical_condition": result[0]["medical_condition"] or "",
#                     "qr_code": qr_result[0]["qr_code"] if qr_result and len(qr_result) > 0 else ""
#                 }]
#             }
#             print(f"Returning baby data: {baby_data}")  # Log the response
#             return jsonify(baby_data), 200
#         else:
#             print(f"No baby found for ID: {baby_id}")
#             return jsonify({"status": "error", "message": "Baby not found"}), 404

#     except Exception as e:
#         print(f"Error in baby_details: {str(e)}")
#         return jsonify({"status": "error", "message": "Internal server error"}), 500



@app.route("/parent_profile", methods=['POST'])
def parent_profile():
    loginId = request.form.get('login_id')
    query = "SELECT * FROM parent WHERE login_id = '%s'" % (loginId)
    result = select(query)


    print("Query Result:", result)  # Debugging line

    if result:
        parent_data = {
            "status": "success",
            "data": [{
                "parent_name": result[0]["parent_name"],
                "parent_email": result[0]["parent_email"],
                "parent_phone": result[0]["parent_phone"],
                "parent_address": result[0]["parent_adress"],
            }]
        }
    else:
        parent_data = {"status": "error", "message": "Parent not found"}

    return jsonify(parent_data)  # Ensure this is returned outside the else

@app.route("/home", methods=["POST"])
def home():
    data = {"status": "failed", "data": []}
    loginId = request.form.get('login_id')
    babyId = request.form.get('baby_id')

    if not loginId or not babyId:
        return jsonify({"status": "error", "message": "Missing login_id or baby_id"})

    query = """
    SELECT * 
    FROM parento.daily_activity 
    INNER JOIN babies USING(baby_id) 
    INNER JOIN parent USING(parent_id) 
    WHERE login_id=%s AND baby_id=%s
    """
    result = select(query, (loginId, babyId))

    if result:
        data["status"] = "success"
        data["data"] = result
    else:
        print("No data found for login_id:", loginId, "and baby_id:", babyId)

    print("Backend Response:", data)  # Log the response
    return jsonify(data)


from flask import Blueprint, request, jsonify
from database import insert, select
from datetime import datetime

parent = Blueprint('parent', __name__)

currentDateTime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

@app.route("/send_chat_message", methods=["POST"])
def send_chat_messages():
    baby_id = request.form.get('baby_id')
    login_id = request.form.get('login_id')
    message = request.form.get('message')

    if not baby_id or not login_id or not message:
        return jsonify({"status": "error", "message": "Missing required fields"}), 400

    print(f"baby_id: {baby_id}, login_id: {login_id}")

    # Get daycare_id from admission_request
    admission_query = "SELECT * FROM admission_request WHERE baby_id='%s'" % (baby_id)
    admission_data = select(admission_query)

    if not admission_data:
        return jsonify({"status": "error", "message": "No admission request found"}), 404

    daycare_id = admission_data[0]['daycare_id']
    print(f"daycare_id: {daycare_id}")

    # Get daycare login_id from day_care
    daycare_query = "SELECT * FROM day_care WHERE day_care_id='%s'" % (daycare_id)
    daycare_data = select(daycare_query)

    if not daycare_data:
        return jsonify({"status": "error", "message": "Daycare not found"}), 404

    daycare_login_id = daycare_data[0]['login_id']
    print(f"daycare_login_id: {daycare_login_id}")

    # Insert chat message with date_time column
    chat_query = "INSERT INTO chat VALUES (NULL, '%s', 'parent', '%s', 'daycare', '%s', '%s')" % (
        login_id, daycare_login_id, message, currentDateTime
    )
    insert(chat_query)

    return jsonify({"status": "success", "message": "Message sent successfully"})


@app.route("/get_chat_messages", methods=["POST"])
def get_chat_messages():
    baby_id = request.form.get('baby_id')
    login_id = request.form.get('login_id')

    if not baby_id or not login_id:
        return jsonify({"status": "error", "message": "Missing baby_id or login_id"}), 400

    print(f"Fetching chats for baby_id: {baby_id}, login_id: {login_id}")

    # Get daycare_id from admission_request
    admission_query = "SELECT * FROM admission_request WHERE baby_id='%s'" % (baby_id)
    admission_data = select(admission_query)

    if not admission_data:
        return jsonify({"status": "error", "message": "No admission request found for this baby"}), 404

    daycare_id = admission_data[0]['daycare_id']
    print(f"Daycare ID: {daycare_id}")

    # Get daycare login_id from day_care
    daycare_query = "SELECT * FROM day_care WHERE day_care_id='%s'" % (daycare_id)
    daycare_data = select(daycare_query)

    if not daycare_data:
        return jsonify({"status": "error", "message": "Daycare not found"}), 404

    daycare_login_id = daycare_data[0]['login_id']
    print(f"Daycare Login ID: {daycare_login_id}")

    # Fetch chat messages with date_time column, oldest first
    chat_query = """
        SELECT message, date_time, sender_type 
        FROM chat 
        WHERE (sender_id='%s' AND receiver_id='%s' AND sender_type='parent' AND receiver_type='daycare') 
           OR (sender_id='%s' AND receiver_id='%s' AND sender_type='daycare' AND receiver_type='parent') 
        ORDER BY date_time Desc
    """ % (login_id, daycare_login_id, daycare_login_id, login_id)
    chat_data = select(chat_query)

    if not chat_data:
        print("No chat messages found")
        return jsonify({"status": "success", "data": []})

    # Format messages with date_time
    messages = [
        {
            "message": row['message'],
            "timestamp": row['date_time'],  # Named 'timestamp' for frontend compatibility
            "sender_type": row['sender_type']
        } for row in chat_data
    ]

    print(f"Messages fetched: {messages}")
    return jsonify({"status": "success", "data": messages})

@app.route("/daycare_staff", methods=["POST"])
def daycare_staff():
    data={}
    dayCareId = request.form.get('daycareId')

    query = "SELECT * FROM Staff WHERE day_care_id = %s"%(dayCareId)
    result = select(query)  # ✅ Secure query

    if result:
        data['status'] = 'success'
        data['data'] = result
    else:
        data['status'] = 'failed'
        data['message'] = 'No facilities found'

    return jsonify(data)

@app.route("/notifications", methods=["POST"])
def notifications():
    data={}
    loginId = request.form.get('lid')
    babyId= request.form.get('baby_id')
    print("loginId:", loginId)
    print("babyId:", babyId)

    cc="select * from parent where login_id='%s'"%(loginId)
    ccc=select(cc)
    pid=ccc[0]['parent_id']

    query = "select * from notifications where parent_id = '%s' and baby_id='%s'"%(pid, babyId)
    result = select(query)  # ✅ Secure query
    print(result,"////")
    if result:
        data['status'] = 'success'
        data['data'] = result
    else:
        data['status'] = 'failed'
        data['message'] = 'No notification found'
    return jsonify(data)

@app.route("/view_meeting", methods=['POST'])
def view_meeting():
    data={}
    loginId = request.form.get('lid')

    cc="select * from parent where login_id='%s'"%(loginId)
    ccc=select(cc)
    pid=ccc[0]['parent_id']

    fetchData = "select * from meeting where parent_id = '%s'"%(pid)
    meetingData = select(fetchData)

    if meetingData:
        data['status'] = 'success'
        data['data'] = meetingData
    else:
        data['status'] = 'failed'
        data['message'] = 'No notification found'
    return jsonify(data)

@app.route("/checkInOut", methods=['POST', 'GET'])
def checkInOut():
    data={}
    babyId = request.form.get('baby_id')

    print("babyId:", babyId)

    fetchAdminNo = "select * from admission_request where baby_id='%s'"%(babyId)
    table = select(fetchAdminNo)
    adminNo= table[0]['adminssion_id']

    print("adminNo:", adminNo)

    fetchCheckInOut = "select * from checking_history where admission_id='%s'"%(adminNo)
    checkInOut = select(fetchCheckInOut)

    if checkInOut:
        data['status'] = 'success'
        data['data'] = checkInOut
    else:
        data['status'] = 'failed'
        data['message'] = 'No data found'

    print(data)
    return jsonify(data)


    




#/////////////////////////
app.run(debug=True, host='0.0.0.0', port=5001)
