import mysql.connector
user="root"
password="12345678"
# password=""
database="parento"

# def select(q):
# 	con=mysql.connector.connect(user=user,password=password,host="localhost",database=database,port=3306)
# 	cur=con.cursor(dictionary=True)
# 	cur.execute(q)
# 	result=cur.fetchall()
# 	cur.close()
# 	con.close()
# 	return result

def select(q, params=None):
    try:
        con = mysql.connector.connect(user=user, password=password, host="localhost", database=database, port=3306)
        cur = con.cursor(dictionary=True)
        cur.execute(q, params or ())
        result = cur.fetchall()
        cur.close()
        con.close()
        return result
    except Error as e:
        print(f"Error: {e}")
        return None

def insert(q):
	con=mysql.connector.connect(user=user,password=password,host="localhost",database=database,port=3306)
	cur=con.cursor(dictionary=True)
	cur.execute(q)
	con.commit()
	result=cur.lastrowid
	cur.close()
	con.close()
	return result

def update(q):
	con=mysql.connector.connect(user=user,password=password,host="localhost",database=database,port=3306)
	cur=con.cursor(dictionary=True)
	cur.execute(q)
	con.commit()
	res=cur.rowcount
	cur.close()
	con.close()
	return res

def delete(q):
	con=mysql.connector.connect(user=user,password=password,host="localhost",database=database,port=3306)
	cur=con.cursor(dictionary=True)
	cur.execute(q)
	con.commit()
	result=cur.rowcount
	cur.close()
	con.close()
	return result