from flask import *
from database import *


admin=Blueprint('admin',__name__)


@admin.route('/adm')
def adm():
    return render_template('admin.html')

@admin.route('/view-dayCare')
def viewDaycare():
    data={}
    a="SELECT * FROM day_care INNER JOIN login USING(login_id)"
    b=select(a)
    if b:
        data['view']=b

    if 'action' in request.args:
        action=request.args['action']
        id=request.args['id']

        if action=='accept':
            qry1="update login set usertype='dayCare' where login_id='%s'"%(id)
            update(qry1)
        else:
            qry1="update login set usertype='rejected' where login_id='%s'"%(id)
            update(qry1)

    return render_template('viewDayCare.html',data=data)

@admin.route('/view-staff')
def viewStaff():
    data={}
    a = 'select * from staff'
    b=select(a)
    if b:
        data['view']=b

    return render_template('viewStaff.html', data=data)

@admin.route('/view-parent')
def viewParent():
    data={}
    a = 'select * from parent'
    b=select(a)
    if b:
        data['view']=b

    return render_template('viewParent.html', data=data)

@admin.route('/view-feedback')
def viewFeedBack():
    data={}
    a = 'select * from feedback'
    b=select(a)
    if b:
        data['view']=b

    return render_template('viewFeedBack.html', data=data)

@admin.route('/view-babies')
def viewBabies():
    data={}
    id=request.args['id']
    a = "SELECT * FROM babies INNER JOIN parent USING(parent_id) where parent_id = '%s'"%(id)
    b=select(a)
    if b:
        data['view']=b

    return render_template('viewBabies.html', data=data)
