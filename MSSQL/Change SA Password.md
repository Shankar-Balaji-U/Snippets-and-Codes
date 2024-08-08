# To access to the SQL server, if you lost or forget the SA password.

Open you Command Prompt with **Run As Administrator**.

Then execute `net stop MSSQL$SQL2019` to stop the ms sql instance service. 
You can do it from the **Services** application in your PC.

Now we need to start this service as Single User. 
Execute this command to start as Single User `net start MSSQL$SQL2019 /m"SQLCMD"`

To run the sql commands through the command prompt `sqlcmd -S CIT277\SQL2019`
```
1> CREATE LOGIN shankar WITH password = 'testing@321'
2> GO
1> sp_addsrvrolemember shankar, 'SYSADMIN'
2> GO
1> EXIT
```
Now stop and start the SQL Server once.
```
net stop MSSQL$SQL2019
net start MSSQL$SQL2019
```

Now, you have a new Login and Password. With this you can login and modify the SA login password.
