--Set the remote login timeout to 30 seconds, by using this code:

sp_configure 'remote login timeout', 30
go 
reconfigure with override 
go 

--Set the remote query timeout to 0 (infinite wait), by using this code:

sp_configure 'remote query timeout', 0 
go 
reconfigure with override 
go 