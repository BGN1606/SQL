USE [Schwarzkopf]
GO

/****** Object:  StoredProcedure [dbo].[getkey]    Script Date: 01.11.2018 17:21:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Boris Gevorkyan>
-- Create date: <20180920>
-- Description:	<Процедура для получения кодов доступа>
-- =============================================

CREATE PROCEDURE [dbo].[getkey] 
	@dval nvarchar(max),
	@rval nvarchar(max),
	@dkey nvarchar(max) OUTPUT,
	@rkey nvarchar(max) OUTPUT
AS
BEGIN
     SET @dkey = (SELECT d.[key]
                  FROM [Authentication].[dbo].[Division] d
                  JOIN [Authentication].[dbo].[Report] r
                    ON d.ReportID=r.ReportID
                  WHERE r.Value=@rval
                    AND d.Value=@dval)
     
     SET @rkey = (SELECT r.[key]
                  FROM [Authentication].[dbo].[Division] d
                  JOIN [Authentication].[dbo].[Report] r
                    ON d.ReportID=r.ReportID
                  WHERE r.Value=@rval
                    AND d.Value=@dval)
END
GO


