select * from syscomments 
join sysobjects on syscomments.id=sysobjects.id 
where sysobjects.xtype='TR'