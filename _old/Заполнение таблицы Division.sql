use authentication

declare
  @pwd nvarchar (max),
  @ReportID int,
  @Value nvarchar(100)

exec pwdgen 256, @Value = @pwd output
set @ReportID = 1000029
set @Value = 'HO'


--insert into [Authentication].[dbo].[Division]
--select @pwd,@ReportID,@Value

select * from [Authentication].[dbo].[Division]
where [ReportID] = @ReportID
  --and [Value] = @Value

--delete [Authentication].[dbo].[Division]
--where [key] = '447Q8Gn5V0RbA25kpEUA865U4upLmy9VgIc6ZayNEbHjwKqGLxXf3U0FQWOhcMebAOVTIyurx/F5EqNA8je1d+abq9VVwtgyw36aSZaHdhagmOxXSYXmMrOLqyckQAk8Vu/mlhEc6PQpK+LyBGqcjIaHDEVtfzWZw9aRaEEcCppLO4VvHwHQWt+wLwNuBNrasxCjJwl6sbszQi7aceaAlTFHCzntFgqGvRA3HpBCmNPBxRKib/Pb78T1mqdVNcoAbtsZ3R9il/TrYmcIuyOkkwHcbQxTGotbOmF4l8aTsp4g+6tRytaDyOR1IQx44rNHkZP1inOmY8S47PixgD1Rew=='