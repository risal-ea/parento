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