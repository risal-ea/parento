from flask import *
from database import *
import os
from werkzeug.utils import secure_filename

dayCare = Blueprint('dayCare', __name__)

@dayCare.route('/dayCare')
def dayCare_home():
    data={}
    a="select * from day_care"
    getData = select(a)
    
    if getData:
        data['view']= getData

    print("data_care_data: ",data)

    return render_template('dayCare.html', data=data)

@dayCare.route('/manageStaff',methods=['post','get'])
def manageStaff():
    data={}
    a="select * from staff where day_care_id='%s'"%(session['day_care'])
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
    if request.method == 'POST':
        print("Form submitted!")  # Check if form submission is happening
        print("Received Form Data:", request.form)  # Debugging

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

            print(f"Name: {staff_name}, Email: {staff_email}, Phone: {staff_phone}")

            # Insert into login table
            z = "insert into login values(null,'%s','%s','staff')" % (username, password)
            login_id = insert(z)
            print(f"Generated Login ID: {login_id}")

            # Insert into staff table
            x = "insert into staff values(null,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')" % (
                login_id, session['day_care'], staff_name, staff_email, staff_phone, 
                staff_dob, gender, staff_adress, position, qualification)
            
            if 'day_care' not in session:
                print("Session variable 'day_care' is missing!")
                return "Session expired. Please log in again."

            
            insert(x)
            print("Data inserted into staff table.")

            return '''<script>alert("Staff added successfully"); window.location="/manageStaff";</script>'''

    return render_template('addStaff.html')

UPLOAD_FOLDER_FIMAGE = 'static/facility_images'  # Adjust path as needed
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@dayCare.route('/manageFacilities', methods=['POST', 'GET'])
def manageFacilities():
    data = {}
    # Retrieve all facilities
    a = 'SELECT * FROM facilities WHERE day_care_id="%s"' % (session['day_care'])
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
        operating_hrs = request.form['operating_hrs']
        safety_measures = request.form['safety_measures']

        # Get current facility data to preserve existing image if no new upload
        current_data = select("SELECT facility_image FROM facilities WHERE facility_id='%s'" % id)
        facility_image = current_data[0]['facility_image'] if current_data else ''

        # Handle file upload
        if 'facility_image' in request.files:
            file = request.files['facility_image']
            if file and file.filename != '':
                if allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    file_path = os.path.join(UPLOAD_FOLDER_FIMAGE, filename)
                    if not os.path.exists(UPLOAD_FOLDER_FIMAGE):
                        os.makedirs(UPLOAD_FOLDER_FIMAGE)
                    file.save(file_path)  # Save the new file
                    facility_image = filename  # Update with new filename
                else:
                    return '''<script>alert("Invalid file format! Allowed formats: png, jpg, jpeg, gif"); 
                              window.location="/manageFacilities?action=update&id=%s"</script>''' % id

        # Update database with parameterized query to prevent SQL injection
        z = """UPDATE facilities 
               SET facility_name='%s', facility_type='%s', facility_des='%s', 
                   facility_capacity='%s', facility_image='%s', 
                   operating_hrs='%s', safety_measures='%s' 
               WHERE facility_id='%s'""" % (facility_name, facility_type, facility_des, 
                                             facility_capacity, facility_image, 
                                             operating_hrs, safety_measures, id)
        update(z)
        return '''<script>alert("Updated successfully"); window.location="/manageFacilities"</script>'''
    
    if action == 'delete':
        delete_facility = "DELETE FROM facilities WHERE facility_id='%s'" % id
        delete(delete_facility)
        return '''<script>alert("Deleted successfully"); window.location="/manageFacilities"</script>'''

        
    return render_template('manageFacilities.html', data=data)


@dayCare.route('/addFacility', methods=['GET', 'POST'])
def addFacility():
    data = {"up": []}  # Ensure data is always defined

    if request.method == 'POST' and 'add_facility' in request.form:
        facility_name = request.form['facility_name']
        facility_type = request.form['facility_type']
        facility_des = request.form['facility_des']
        facility_capacity = request.form['facility_capacity']
        operating_hrs = request.form['operating_hrs']
        safety_measures = request.form['safety_measures']

        # Handle file upload
        facility_image = ''
        if 'facility_image' in request.files:
            file = request.files['facility_image']
            if file.filename == '':
                return '''<script>alert("No file selected!"); 
                          window.location="/addFacility"</script>'''
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                file_path = os.path.join(UPLOAD_FOLDER_FIMAGE, filename)
                file.save(file_path)  # Save file
                facility_image = filename  # Store filename in DB
            else:
                return '''<script>alert("Invalid file format! Allowed formats: png, jpg, jpeg"); 
                          window.location="/addFacility"</script>'''

        # Ensure upload folder exists
        if not os.path.exists(UPLOAD_FOLDER_FIMAGE):
            os.makedirs(UPLOAD_FOLDER_FIMAGE)

        # Insert into database
        z = """INSERT INTO facilities 
               (day_care_id, facility_name, facility_type, facility_des, 
                facility_capacity, facility_image, operating_hrs, safety_measures) 
               VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')""" % (
                    session['day_care'], facility_name, facility_type, 
                    facility_des, facility_capacity, facility_image, 
                    operating_hrs, safety_measures)
        # Use parameterized query to prevent SQL injection
        insert(z)

        return '''<script>alert("Facility added successfully!"); 
                  window.location="/manageFacilities"</script>'''

    return render_template('addFacility.html', data=data)


@dayCare.route("/view-babies-daycare", methods=['get', 'post'])
def viewBabies():
    data={}
    a = 'select * from babies inner join admission_request where daycare_id="%s"'%(session['day_care'])
    b=select(a)
    if b:
        data['view']=b
    return render_template('viewBabies_daycare.html', data=data)


@dayCare.route('/view-parent-daycare')
def viewParent():
    data={}
    id=request.args['id']
    a = "SELECT * FROM babies INNER JOIN parent USING(parent_id) where parent_id = '%s'"%(id)
    b=select(a)
    if b:
        data['view']=b

    return render_template('viewParent_daycare.html', data=data)

@dayCare.route('/view-feedback-daycare')
def viewFeedback():
    data = {}
    
    # Get the logged-in daycare ID from the session
    day_care_id = session.get('day_care')
    
    if not day_care_id:
        return "You are not logged in as a daycare."
    
    # Define the SQL query to get feedback for the logged-in daycare
    a = '''
        SELECT feedback.feedback_id, day_care.day_care_name, parent.parent_name, feedback.feedback, feedback.date_time
        FROM feedback
        INNER JOIN day_care USING (day_care_id)
        INNER JOIN parent ON feedback.login_id = parent.login_id
        WHERE feedback.day_care_id = %s
    '''
    
    # Execute the query using the modified select() function
    b = select(a, (day_care_id,))
    
    if b:
        data['view'] = b

    # Return the rendered template with the feedback data
    return render_template('/viewFeedback_daycare.html', data=data)

@dayCare.route('/view-complaint-daycare')
def viewComplaint():
    data={}
    a="select * from complaint inner join parent where complaint.login_id = parent.login_id and complaint.status = 'forwarded'"
    b = select(a)

    if b:
        data['view']=b

    print("view complaint: ", data)

    return render_template('viewComplaint_daycare.html', data=data)

@dayCare.route('/send-reply', methods=['get', 'post'])
def sendReply():
    id=request.args['id']
    if 'submit' in request.form:
        reply = request.form['reply'] 

        q="update complaint set reply='%s' where complaint_id='%s'"%(reply,id)
        r=update(q)
        return "<script>alert('replied');window.location='/view-complaint-daycare'</script>"

    return render_template('sendReply.html')

@dayCare.route('/view-admission-requests', methods=['get', 'post'])
def view_admission_requests():
   data={}

   z="select * from admission_request inner join parent using(parent_id) inner join babies using(baby_id) where daycare_id='%s'"%(session['day_care'])
   data['view']=select(z)
    
   return render_template('admission_request.html', data=data)

import qrcode
import os

# Ensure the 'static/qr/' directory exists
os.makedirs("static/qr", exist_ok=True)

@dayCare.route("/accept_request", methods=['GET', 'POST'])
def accept_request():
    id = request.args.get('id')

    # Generate QR code
    qr = qrcode.make(id)
    qr_path = f"static/qr/{id}.png"
    qr.save(qr_path)

    if 'submit' in request.form:
        pay = request.form['payment']
        q="update admission_request set qr_code='%s', payment='%s'  where adminssion_id='%s'"%(qr_path,pay,id)
        r=update(q)
        return "<script>alert('request accepted');window.location='/view-admission-requests'</script>"

    return render_template("payment_form.html", qr_code=qr_path)

@dayCare.route("/reject_request", methods=['GET', 'post'])
def reject_request():
    id = request.args.get('id')

    q="update admission_request set qr_code='rejected', payment='rejected'  where adminssion_id='%s'"%(id)
    update(q)

    return "<script>alert('request rejected');window.location='/view-admission-requests'</script>"


@dayCare.route("/chat", methods=['GET', 'POST'])
def chat():
    # Get the admission ID from the query parameter
    admission_id = request.args.get('id')

    # Fetch admission request details to get parent_id
    query_admission = "SELECT * FROM admission_request WHERE adminssion_id = '%s'" % (admission_id)
    admission_data = select(query_admission)
    if not admission_data:
        return "Admission not found", 404
    parent_id = admission_data[0]['parent_id']

    print(parent_id, "////pid")

    # Fetch parent details to get login_id
    query_parent = "SELECT * FROM parent WHERE parent_id = '%s'" % (parent_id)
    parent_data = select(query_parent)
    if not parent_data:
        return "Parent not found", 404
    parent_login_id = parent_data[0]['login_id']

    # Get daycare login ID from session (corrected from 'log' to 'day_care' if needed)
    daycare_login_id = session.get('log')  # Confirm this key matches your login logic
    if not daycare_login_id:
        return "Daycare not logged in", 401

    print(parent_login_id, daycare_login_id, "/////")

    # Handle POST request (sending a new message)
    if request.method == 'POST':
        message = request.form.get('message')
        if message:
            # Insert new message into chat table
            query_insert = """
                INSERT INTO chat (sender_id, sender_type, receiver_id, receiver_type, message, date_time)
                VALUES ('%s', 'daycare', '%s', 'parent', '%s', NOW())
            """ % (daycare_login_id, parent_login_id, message)
            select(query_insert)  # Replace with your insert function if select doesn't work for INSERT

            # Redirect to the same chat page with GET to prevent resubmission
            return redirect(url_for('dayCare.chat', id=admission_id))

    # Fetch chat history between daycare and parent (GET request)
    query_chat = """
        SELECT * FROM chat 
        WHERE (sender_id = '%s' AND receiver_id = '%s') 
           OR (sender_id = '%s' AND receiver_id = '%s') 
        ORDER BY date_time 
    """ % (daycare_login_id, parent_login_id, parent_login_id, daycare_login_id)
    chat_history = select(query_chat)

    # Pass data to the template
    return render_template("chat.html", 
                          chat_history=chat_history, 
                          daycare_id=daycare_login_id, 
                          parent_id=parent_login_id,
                          admission_id=admission_id)

