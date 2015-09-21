#!/usr/bin/env python
# coding=utf-8

from flask import Flask,request
import psycopg2
import json

app = Flask(__name__)
app.config.from_object('config.Config')
connection = psycopg2.connect("dbname='tomala' \
                user=postgres \
                host=192.168.99.100 \
                port=5432 \
                password=helloNSA")
cursor = connection.cursor()

@app.route('/store', methods = ['POST'])
def store():
    print("test")
    print(request.get_json())
    print("test")
    return("success\n",200)

@app.route('/create_table', methods = ['POST'])
def create_table():
    cursor.execute("DROP TABLE IF EXISTS reportes")
    mydictionary = request.get_json()
    types = map(lambda x: x.__class__.__name__,mydictionary.values())
    fields_types = dict(zip(mydictionary.keys(), types))
    py_to_pg = {
    'unicode': "VARCHAR",
    'bool': "BOOLEAN",
    'int': "BIGINT",
    'float': "DOUBLE PRECISION",
    'list': "VARCHAR",
    'NoneType': "VARCHAR"
    }
    definitions = ""
    separator = ""
    for field,ftype in fields_types.items():
        definitions += separator + "    " + field + " " + py_to_pg[ftype]
        separator=",\n"
    psql_instruction = "CREATE TABLE reportes (\n" + definitions + "); " + \
    "SELECT AddGeometryColumn ('public','reportes','geom',4326,'POINT',2);" + \
    "\n COMMIT;"
    cursor.execute( psql_instruction)
    return("Table created.\n",200)

@app.route('/report', methods = ['POST'])
def report():
    report = request.get_json()
    variables = ',\n'.join(report.keys())
    vals = []
    for key,val in report.items():
        mytype = val.__class__.__name__
        if (mytype == 'int' or mytype == 'bool' or mytype == 'float'):
            val = u''+str(val)
        elif (mytype == 'NoneType'):
            val = u"NULL"
        elif (mytype == 'list'):
            val = u"'[" + ",".join(str(v) for v in val).replace("'",'"') +"]'"
        else:
            val = u"'" + val + "'"
        print(key + " => " +mytype+ " => " + val)
        vals.append(val)
    values = ',\n'.join(vals)
    geom = "(SELECT ST_SetSRID(ST_MakePoint(" + str(report["coordinates"][1]) + "," + \
        str(report["coordinates"][0]) + "),4326))"
    print("INSERT INTO reportes ("+ variables + ") VALUES (" + \
        values + ");\n COMMIT;")
    cursor.execute("INSERT INTO reportes ("+ variables + ",geom) VALUES (" + \
        values + "," + geom + ");\n COMMIT;")
    return("OK", 200)





if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000,debug=True)
