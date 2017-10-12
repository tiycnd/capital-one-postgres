@Grab(group='org.apache.commons', module='commons-csv', version='1.5')
import org.apache.commons.csv.*

@GrabConfig(systemClassLoader=true)
@Grab(group='org.postgresql', module='postgresql', version='42.1.4')

def infile = new FileReader("fix_columns.csv")

def records = CSVFormat.RFC4180.withFirstRecordAsHeader().parse(infile);
for (record in records) {
    def id = record.get("isbn");
    println(id)
}

import groovy.sql.Sql

def dbUrl      = "jdbc:postgresql://localhost/library"
def dbUser     = "clinton"
def dbPassword = "bananas"
def dbDriver   = "org.postgresql.Driver"

def sql = Sql.newInstance(dbUrl, dbUser, dbPassword, dbDriver)

infile.close()