from flask import *
from database import *

staff = Blueprint('staff', __name__)

@staff.route('/staff')
def staffHome():
    return render_template('staff.html')

@staff.route('/view-complaint-staff', methods=['get', 'post'])
def viewComplaint():
    data={}
    a="select * from complaint inner join parent where complaint.login_id = parent.login_id and complaint.status='pending'"
    b = select(a)

    if b:
        data['view']=b
    print("view complaint: ", data)

    if 'action' in request.args:
        action = request.args['action']
        id=request.args['id'] 
    else:
        action=None

    if action == 'update':
        q="update complaint set status='forwarded' where complaint_id='%s'"%(id)
        r=update(q)
        return """<script>alert('forwarded');window.location='/view-complaint-staff'</script>"""

    return render_template('viewComplaint_staff.html', data=data)

@staff.route('/view-profile-staff')
def viewProfile():
    data = {}
    q = "SELECT * FROM staff WHERE staff_id='%s'" % (session['staff'])
    b = select(q)

    if b:
        data['view'] = b[0]  # Pass only the first record
    else:
        data['view'] = None

    # print("Staff ID:", session['staff'])
    # print("Query Result:", b)

    return render_template('viewProfile_staff.html', data=data)

@staff.route("/view-babies-staff")
def viewBabies():
    data={}
    a = 'select * from babies'
    b=select(a)
    if b:
        data['view']=b
    return render_template('viewBabies_daycare_staff.html', data=data)

@staff.route('/addActivity', methods=['GET', 'POST'])
def addActivity():
    id = request.args.get('id')  # Use .get() to avoid errors if 'id' is missing
    data = {}
    
    # Fetch activities from database
    z = "SELECT * FROM daily_activity WHERE baby_id='%s'" % (id)
    b = select(z)
    data['view'] = b
    
    if 'addActivity' in request.form:
        date = request.form['date']
        activity_type = request.form['activity_type']
        description = request.form['description']
        start_time = request.form['start_time']
        end_time = request.form['end_time']

        query = """INSERT INTO daily_activity 
                   VALUES (NULL, '%s', '%s', '%s', '%s', '%s', '%s')""" % (
                    id, date, activity_type, description, start_time, end_time)
        
        print("Executing SQL Query:", query)  # Debugging Step
        
        try:
            insert(query)
            print("✅ Data Inserted Successfully!")
            return redirect(url_for('staff.addActivity', id=id))
        except Exception as e:
            print("❌ Database Error:", e)

    return render_template('addActivity_staff.html', data=data)

