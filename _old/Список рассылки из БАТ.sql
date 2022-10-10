USE [BAT_Henkel_NEW_TEST]
GO
/****** Object:  StoredProcedure [dbo].[sprSchedules_SelectAll]    Script Date: 08.08.2017 12:55:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sprSchedules_SelectAll](
	@SchedulesSelectKind tinyint,
	@rverID int = NULL,
	@rusrID int = NULL,
	@TimeStart smallint = NULL,
	@TimeEnd smallint = NULL,
	@DateNow datetime = NULL,
	@Day smallint = NULL,
	@userID int = NULL,
	@FilterDateBegin datetime = NULL,
	@FilterDateEnd datetime = NULL,
	@FilterUserID int = NULL,
	@ShowAll bit = 0
)
AS
BEGIN
	IF OBJECT_ID('tempdb..#tempUserWindowsGroups', 'U') IS NULL 
		CREATE TABLE #tempUserWindowsGroups 
		( 
			tmpWindowsGroup nvarchar(50) COLLATE DATABASE_DEFAULT, 
			tmpWindowsDomain nvarchar(50) COLLATE DATABASE_DEFAULT 
		)

	IF @SchedulesSelectKind = 0	/*ScheduleService*/
	BEGIN
		SELECT 
			schID,
			schDays,
			schTime,
			schEndTime,
			schRepeatEvery,
			sch_rverID,
			schUseReportName,
			CASE
				WHEN schUseReportName = 1
				THEN
					rptName
				ELSE 
					schName
			END AS schName,
			schNotes,
			schIgnoreReportUserPermission,
			schUC,
			schUM,
			usrNameFirst + ' ' + usrNameLast + ' (' + usrLogin + ')' AS 'sch_usrFullName',
			CASE WHEN rusrID IS NULL THEN 1 ELSE 0 END AS 'sch_usrIsAdmin',
			lccConfig AS schLCConfig,
			schFormat,
			schSettings,
			schMode,
			schBeginDate,
			schEndDate,
			schModeRepeateEvery,
			schMonthlyMode,
			schMonth,
			schStatus,
			schAllPages,
			schOwnerTypes,
			schPageTypes,
			schConditionMode,
			schConditionExecutionMode,
			schConditionExecutionValue,
			schConditionCheckMode,
			schConditionExecutionContext,
			'' AS schFolder,
			rptName,
			rverNumber,
			1 AS schStatusInReport,
			1 AS CanAdminUserEdit
		FROM 
			tblSchedules
			INNER JOIN tblUsers ON schUM = usrID
			LEFT JOIN tblReportUsers ON usrID = rusr_usrID
			INNER JOIN tblReportVersions ON sch_rverID = rverID
			INNER JOIN tblReports ON rver_rptID = rptID
			INNER JOIN tblCubes ON rver_cubeID = cubeID
			LEFT JOIN tblLCConfigs ON sch_lccID = lccID
		WHERE
			(schStatus = 1) AND (cubeStatus = 0) AND (rverStatus = 0) 
			AND 
			(
				rptStatus = 0
				OR
				rptID IN (
							SELECT 
								rlk_rptLinkID
							FROM
								tblReportLinks
								INNER JOIN tblReports AS r ON r.rptID = rlk_rptID
							WHERE (rlkOverrideStatus = 0 AND r.rptStatus = 0)
						 )
			)
			AND (dbo.IsScheduleDateIn(schBeginDate, schEndDate, @DateNow) = 1)
			AND (dbo.IsScheduleMode(schMode, @DateNow, schBeginDate, schModeRepeateEvery, schDays, schMonthlyMode, schMonth, @Day) = 1)
			AND (dbo.IsScheduleTimeIn(@TimeStart, @TimeEnd, schTime, schEndTime, schRepeatEvery * 60) = 1)
	END
	ELSE IF @SchedulesSelectKind = 1	/*AdminModuleAll*/  
	BEGIN
		IF @ShowAll = 0 AND @FilterDateBegin IS NULL
		BEGIN
			SET @FilterDateBegin = (SELECT MIN(schBeginDate) FROM tblSchedules)
		END
		
		SELECT 
			schID,
			schDays,
			schTime,
			schEndTime,
			schRepeatEvery,
			sch_rverID,
			schUseReportName,
			CASE
				WHEN schUseReportName = 1
				THEN
					rptName
				ELSE 
					schName
			END AS schName,
			schNotes,
			schIgnoreReportUserPermission,
			schUC,
			schUM,
			usrNameFirst + ' ' + usrNameLast + '(' + usrLogin + ')' AS 'sch_usrFullName',
			CASE WHEN rusrID IS NULL THEN 1 ELSE 0 END AS 'sch_usrIsAdmin',
			lccConfig AS schLCConfig,
			schFormat,
			schSettings,
			schMode,
			schBeginDate,
			schEndDate,
			schModeRepeateEvery,
			schMonthlyMode,
			schMonth,
			schStatus,
			schAllPages,
			schOwnerTypes,
			schPageTypes,
			schConditionMode,
			schConditionExecutionMode,
			schConditionExecutionValue,
			schConditionCheckMode,
			schConditionExecutionContext,
			rpfName AS schFolder,
			rptName,
			rverNumber,
			CAST(CASE
					WHEN schStatus = 1 AND rverStatus = 1 AND rptStatus = 1 AND rpfStatus = 1  
					THEN 1
					ELSE 0
					END AS BIT) AS schStatusInReport,
			CASE
				WHEN rptAllowEdit = 1
				THEN 1
				WHEN @userID = rptOwnerID
				THEN 1
				WHEN @userID = -100
				THEN 1
				WHEN (rptID in (SELECT raup_rptID
								FROM tblReportAdminUserPermissions a
									 INNER JOIN tblAdminUsers b ON a.raup_ausrID = b.ausrID
								WHERE b.ausr_usrID = @userID))
				THEN 1 
				ELSE 0 
			END AS CanAdminUserEdit
		FROM 
			tblSchedules
			INNER JOIN tblUsers ON schUM = usrID
			LEFT JOIN tblReportUsers ON usrID = rusr_usrID
			INNER JOIN tblReportVersions ON sch_rverID = rverID
			INNER JOIN tblReports ON rver_rptID = rptID
			INNER JOIN tblReportFolders ON rpt_rpfID = rpfID
			LEFT JOIN tblLCConfigs ON sch_lccID = lccID
		WHERE
			@ShowAll = 1
			OR
			(
				(dbo.IsScheduleDateBetween(schBeginDate, schEndDate, @FilterDateBegin, @FilterDateEnd) = 1)
				AND	(dbo.IsScheduleModeBetween(schMode, schBeginDate, schEndDate, schModeRepeateEvery, schDays, schMonthlyMode, schMonth, @FilterDateBegin, @FilterDateEnd) = 1)
			)
	END
	ELSE IF @SchedulesSelectKind = 2	/*AdminModuleReportVersion*/ 
	BEGIN
		SELECT 
			schID,
			schDays,
			schTime,
			schEndTime,
			schRepeatEvery,
			sch_rverID,
			schUseReportName,
			CASE
				WHEN schUseReportName = 1
				THEN
					rptName
				ELSE 
					schName
			END AS schName,
			schNotes,
			schIgnoreReportUserPermission,
			schUC,
			schUM,
			usrNameFirst + ' ' + usrNameLast + '(' + usrLogin + ')' AS 'sch_usrFullName',
			CASE WHEN rusrID IS NULL THEN 1 ELSE 0 END AS 'sch_usrIsAdmin',
			lccConfig AS schLCConfig,
			schFormat,
			schSettings,
			schMode,
			schBeginDate,
			schEndDate,
			schModeRepeateEvery,
			schMonthlyMode,
			schMonth,
			schStatus,
			schAllPages,
			schOwnerTypes,
			schPageTypes,
			schConditionMode,
			schConditionExecutionMode,
			schConditionExecutionValue,
			schConditionCheckMode,
			schConditionExecutionContext,
			'' AS schFolder,
			rptName,
			rverNumber,
			1 AS schStatusInReport,
			CASE
				WHEN rptAllowEdit = 1
				THEN 1
				WHEN @userID = rptOwnerID
				THEN 1
				WHEN @userID = -100
				THEN 1
				WHEN (rptID in (SELECT raup_rptID
								FROM tblReportAdminUserPermissions a
									 INNER JOIN tblAdminUsers b ON a.raup_ausrID = b.ausrID
								WHERE b.ausr_usrID = @userID))
				THEN 1 
				ELSE 0 
			END AS CanAdminUserEdit
		FROM 
			tblSchedules
			INNER JOIN tblUsers ON schUM = usrID
			LEFT JOIN tblReportUsers ON usrID = rusr_usrID
			INNER JOIN tblReportVersions ON sch_rverID = rverID
			INNER JOIN tblReports ON rver_rptID = rptID
			LEFT JOIN tblLCConfigs ON sch_lccID = lccID
		WHERE
			@rverID IS NULL OR @rverID = sch_rverID
	END
	ELSE IF @SchedulesSelectKind = 3	/*ReportModuleReportVersion*/
	BEGIN
		SELECT 
			tblSchedules.schID,
			tblSchedules.schDays,
			tblSchedules.schTime,
			tblSchedules.schEndTime,
			tblSchedules.schRepeatEvery,
			tblSchedules.sch_rverID,
			tblSchedules.schUseReportName,
			CASE
				WHEN tblSchedules.schUseReportName = 1
				THEN
					rptName
				ELSE 
					tblSchedules.schName
			END AS schName,
			tblSchedules.schNotes,
			tblSchedules.schIgnoreReportUserPermission,
			tblSchedules.schUC,
			tblSchedules.schUM,
			usrNameFirst + ' ' + usrNameLast + '(' + usrLogin + ')' AS 'sch_usrFullName',
			CASE WHEN rusrID IS NULL THEN 1 ELSE 0 END AS 'sch_usrIsAdmin',
			lccConfig AS schLCConfig,
			tblSchedules.schFormat,
			tblSchedules.schSettings,
			tblSchedules.schMode,
			tblSchedules.schBeginDate,
			tblSchedules.schEndDate,
			tblSchedules.schModeRepeateEvery,
			tblSchedules.schMonthlyMode,
			tblSchedules.schMonth,
			tblSchedules.schStatus,
			tblSchedules.schAllPages,
			tblSchedules.schOwnerTypes,
			tblSchedules.schPageTypes,
			tblSchedules.schConditionMode,
			tblSchedules.schConditionExecutionMode,
			tblSchedules.schConditionExecutionValue,
			tblSchedules.schConditionCheckMode,
			tblSchedules.schConditionExecutionContext,
			'' AS schFolder,
			rptName,
			rverNumber,
			1 AS schStatusInReport,
			1 AS CanAdminUserEdit
		FROM 
			tblSchedules
			INNER JOIN tblUsers ON schUM = usrID
			LEFT JOIN tblReportUsers ON usrID = rusr_usrID
			INNER JOIN tblReportVersions ON sch_rverID = rverID
			INNER JOIN tblReports ON rver_rptID = rptID
			LEFT JOIN tblLCConfigs ON sch_lccID = lccID
			INNER JOIN
				(
					SELECT 
						schu_schID AS 'schID'
					FROM 
						tblScheduleUsers
					WHERE
						schu_rusrID = @rusrID
					UNION
					SELECT
						schr_schID AS 'schID'
					FROM
						tblScheduleRoles
						INNER JOIN 
							(
								SELECT 
									rurl_roleID
								FROM 
									tblReportUserRoleLinks
								WHERE
									 rurl_rusrID = @rusrID
								UNION
								SELECT
									roleID AS rurl_roleID
								FROM
									#tempUserWindowsGroups
									INNER JOIN tblRoles ON LOWER(tmpWindowsGroup) = LOWER(roleWindowsGroupName) AND LOWER(tmpWindowsDomain) = LOWER(roleWindowsDomain) AND roleIsBindedToWindowsGroup = 1
							) tblUserRoleLinks ON tblUserRoleLinks.rurl_roleID = schr_roleID
				) AS UserSchedules ON  tblSchedules.schID = UserSchedules.schID
		WHERE
			@rverID IS NULL OR @rverID = sch_rverID
	END
END
