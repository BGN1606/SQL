USE [Distr_Plus]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

declare
	@cntry nvarchar (3) = 'RUS',
	@PlaceId int = 64,
	@PlaceName nvarchar (100) = '��, �������',
	@dbname nvarchar (100) = 'Mobile_Schwarzkopf_ArhipovArh',
	@mindate date='20180701',
	@maxdate date = '20180731'
begin

execute('

declare
    @ErrCode int,
	@ErrText nvarchar (100),
	@Details nvarchar (255)

/*�������� �� ������� ������ � ������� � ������� �� ����������*/
if (select count(*) from [' + @dbname + '].[dbo].[ds_salesverificationreport] svf where svf.datecreated=cast(getdate() as date)) = 0
	begin
	  if object_id(''[distr_plus].[dbo].[svf_' + @dbname + ']'',''u'') is not null drop table [distr_plus].[dbo].[svf_' + @dbname + ']
	  
	  set @ErrCode = 1001
	  set @ErrText = ''��� ������ ��� ���������� ������''
	  set @Details = ''�� ������ ���������� ������, ����� Report.txt �� ��� ��������, ������� ��������� ������������ ���������� �� �� � ������� ������ �������� �� ftp''

	  select 
	    cast(getdate() as date) AS Month,
        ''' + @cntry + '''      AS Country,
        ''' + @PlaceId + '''    AS PlaceId,
        ''' + @PlaceName + '''  AS PlaceName,
	    @ErrCode                AS ErrCode,
	    @ErrText                AS ErrText,
	    null                    AS UfaceExId,
	    null                    AS UfaceName,
	    null                    AS DocType,
	    null                    AS DocDate,
	    null                    AS DocId,
	    null                    AS DocNumber,
	    null                    AS ProductName,
	    null                    AS EAN,
	    null                    AS IDH,
	    null                    AS Amount,
	    null                    AS SUMM,
	    @Details                AS Details
        into [distr_plus].[dbo].[svf_' + @dbname + ']
	end
else 
    /*��������� ��������� ������� ������� �� report.txt*/
	begin
	  if object_id(''tempdb..#kisdata'') is not null drop table #kisdata
	  select 
	    isnull(distribid,-1)		 distribid,
	    i.iid						 iid,
	    isnull(idh,-1)			     idh,
	    isnull(ean,-1)			     ean,
	    isnull(docdate,''19000101'') docdate,
	    isnull(docid,-1)			 docid,
	    isnull(docnumber,''ns'')	 docnumber,
	    isnull(doctype,-1)		     doctype,
	    isnull(ufaceid,-1)		     ufaceid,
	    isnull(ufacename,''noface'') ufacename,
	    isnull(itemsname,''noname'') itemsname,
	    isnull(avg([sum]),0)		 ''sum'',
	    isnull(sum(amount),0)		 amount, 
	    datecreated,
	    errorfields
	  into #kisdata
	  from [' + @dbname + '].[dbo].[ds_salesverificationreport] svf
	  left join [' + @dbname + '].[dbo].[ds_items] i
	    on svf.ean=i.iidtext
	   and isnumeric(i.iidtext)=1
      where isnumeric(svf.ean)=1
	    and svf.docdate is not null
	    and svf.datecreated=cast(getdate() as date)
	    and svf.docdate >= ''' + @mindate + '''
	    and svf.docdate <= ''' + @maxdate + '''
	  group by 
	    isnull(distribid,-1),
	    i.iid,
	    isnull(idh,-1),
	    isnull(ean,-1),
	    isnull(docdate,''19000101''),
	    isnull(docid,-1),
	    isnull(docnumber,''ns''),
	    isnull(doctype,-1),
	    isnull(ufaceid,-1),
	    isnull(ufacename,''noface''),
	    isnull(itemsname,''noname''),
	    datecreated,
	    errorfields

if (select count(*) from #kisdata)>0
	begin
	  if object_id(''[distr_plus].[dbo].[svf_' + @dbname + ']'',''u'') is not null drop table [distr_plus].[dbo].[svf_' + @dbname + ']
	  select * 
	  into [distr_plus].[dbo].[svf_' + @dbname + ']
	  from (			
			--select distinct
			--101 sort,
			--case 
			--  when (select min(docdate) from #kisdata)<> ''' + @mindate + '''
			--	or (select max(docdate) from #kisdata)<> ''' + @maxdate + ''' then concat(''����� report.txt ��� ������������ ������������, �� ������ ����������� ������ � ������ report.txt (� '',(select min(docdate) from #kisdata),'' �� '',(select max(docdate) from #kisdata),'') �� ������������� ����������� �� (� '',''' + @mindate + ''','' �� '',''' + @maxdate + ''','')'')
			--  else concat(''����� report.txt ��� ������������ ������������ � �������� ������ � '',(select min(docdate) from #kisdata),'' �� '',(select max(docdate) from #kisdata))
			--end error

            --union all

			/*�������� ���������������� ���������*/
						  
			set @ErrCode = 1002
	        set @ErrText = ''���������������� ���������''
	        
			select distinct	        
	          Month(getdate())        AS Month,
              ''' + @cntry + '''      AS Country,
              ''' + @PlaceId + '''    AS PlaceId,
              ''' + @PlaceName + '''  AS PlaceName,
	          @ErrCode                AS ErrCode,
	          @ErrText                AS ErrText,
	          null                    AS UfaceExId,
	          null                    AS UfaceName,
	          dtname                  AS DocType,
	          cast(ordate as date)    AS DocDate,
	          ordrs.docid             AS DocId,
	          ordrs.docnumber         AS DocNumber,
	          null                    AS ProductName,
	          null                    AS EAN,
	          null                    AS IDH,
	          null                    AS Amount,
	          null                    AS SUMM,
	          null                    AS Details
			--concat(count(docnumber),'' ���������� "'',dtname,''" �� ������������ � warm'') as error 
			from ' + @dbname + '.[dbo].[ds_orders] ordrs with (nolock)
			join ' + @dbname + '.[dbo].[ds_faces] fcs with (nolock)
			  on fid = ufid
			join ' + @dbname + '.[dbo].[ds_doctypes] dtype with (nolock)
			  on dtid=ortype
			where condition=1
			  and exid = ''tt_unknown''
			  and ortype in (2,9)
			
			


/*			union all

			/*�������� ������ idh ean*/
			select distinct
			  202 sort, 
			  concat(''������������ ������ idh-ean: � ��� �������������, ����� '',kis.itemsname,'' � idh(�������) '',kis.idh,'' ����������� �����-���� '',kis.ean,'', ������ ������������ �����-���� '',i.iidtext) error
			from #kisdata kis
			join [' + @dbname + '].[dbo].[ds_parts] p
			  on kis.idh=p.exid
			join [' + @dbname + '].[dbo].[ds_items] i 
			  on p.iid=i.iid
			where kis.ean<>cast(i.iidtext as bigint)
			  and isnumeric(i.iidtext)=1
			  and isnumeric(kis.ean)=1

			union all

			select distinct
			  201 sort, 
			  concat(''������ '',itemsname,'' ������ �������� �����-��� '',ean,'', ������� ������� ���������� sku � ������-�������'') error
			from #kisdata k
			left join [' + @dbname + '].[dbo].[ds_items] i
			  on k.ean=cast(i.iidtext as bigint)
			 and isnumeric(i.iidtext)=1
			where i.iid is null
			  and isnumeric(k.ean)=1

			union all

			/*�������� ������� ��. ���� */
			select distinct
			  301 sort, 
			  concat(''��.���� '',kis.ufacename,'' � ����� '',kis.ufaceid,'' �� ������� � warm'') error
			from #kisdata kis
			left join [' + @dbname + '].[dbo].[ds_faces] f
			  on kis.ufaceid=f.exid 
			 and kis.distribid=f.distid
			 and f.ftype=8
			where f.exid is null
			  and kis.doctype not in (628,682,683,652,629)

			union all

			/*�������� ������������ ���� ����������*/
			select distinct 
			401 sort, 
			case
				when k.docid is null then concat (ort2.dtname,'' �� '',cast(ordrs.ordate as date),'' � ����� '',ordrs.docid,'' � ������� '', ordrs.docnumber, '' ����������� � ������ report.txt (���), �� ������������ � warm'')
				when ordrs.docid is null then concat (ort1.dtname,'' �� '',k.docdate,'' � ����� '',k.docid,'' � ������� '', k.docnumber, '' ����������� � warm, �� ������������ � ������ report.txt (���)'')
				else null
			end error
			from #kisdata k
			full join (
					   select 
					     docid,
						 ortype,
						 ownerdistid
					   from [' + @dbname + '].[dbo].[ds_orders]
					   where cast(ordate as date) between '''+@mindate+''' and '''+@maxdate+'''
				       and ortype in (2,9,629,628,652,682,683)
				       and condition=1
				      ) ordrs
			  on k.docid = ordrs.docid
			 and k.distribid = o rdrs.ownerdistid
			
			left join [' + @dbname + '].[dbo].[ds_doctypes] ort1
			  on k.doctype=ort1.dtid
			
			left join [' + @dbname + '].[dbo].[ds_doctypes] ort2
			  on ordrs.ortype=ort2.dtid	
			
			where k.docid is null 
			   or ordrs.docid is null

			union all

			/*�������� ������������ ��� ����������*/
			select distinct 
			  402 sort, 
			  concat(''���� ��������� '',ort1.dtname,'' � ����� '',k.docid,'' � ������� '',k.docnumber,'', � ������ report.txt (���) �� ��������� � ����� ��������� � warm'') as error
			from #kisdata k
			join [' + @dbname + '].[dbo].[ds_orders] ordrs
			  on k.docid=ordrs.docid
			 and k.distribid = ordrs.ownerdistid
			 and k.doctype = ordrs.ortype
			 and ordrs.condition = 1
			left join [' + @dbname + '].[dbo].[ds_doctypes] ort1
			  on k.doctype=ort1.dtid
			where k.docdate<>cast(ordrs.ordate as date)

			union all

			/*�������� ������������ ����� ����������*/
			select distinct
			  403 sort, 
			  concat(''��� ��������� '',ort1.dtname,'' � ����� '',k.docid,'' � ������� '',k.docnumber,'', � ������ report.txt (���) �� ��������� � ����� ��������� � warm '',ort2.dtname) as error
			from #kisdata k
			join [' + @dbname + '].[dbo].[ds_orders] ordrs
			  on k.docid=ordrs.docid
			 and k.distribid=ordrs.ownerdistid
			 and k.docdate=cast(ordrs.ordate as date)
			 and ordrs.condition = 1
			left join [' + @dbname + '].[dbo].[ds_doctypes] ort1
			  on k.doctype=ort1.dtid
			left join [' + @dbname + '].[dbo].[ds_doctypes] ort2
			  on ordrs.ortype=ort2.dtid
			where k.doctype<>ordrs.ortype

			union all

			/*�������� ������������ ��. ��� � ����������*/
			select distinct
			  404 sort, 
			  concat(''��.���� � ��������� '',ort1.dtname,'' � ����� '',k.docid,'' � ������� '',k.docnumber,'', � ������ report.txt (���) �� ��������� � ��.����� ��������� � warm '',f.exid) as error
			from #kisdata k
			join [' + @dbname + '].[dbo].[ds_orders] ordrs
			  on k.docid=ordrs.docid
			 and k.distribid=ordrs.ownerdistid
			 and k.docdate=cast(ordrs.ordate as date)
			 and ordrs.condition=1
			 and k.doctype=ordrs.ortype
			join [' + @dbname + '].[dbo].[ds_faces] f
			  on ordrs.ufid=f.fid
			left join [' + @dbname + '].[dbo].[ds_doctypes] ort1
			  on k.doctype = ort1.dtid
			where k.ufaceid<>f.exid and k.errorfields not like ''%ufaceid%''*/
			) svf
	  end
	else
	  begin
	  if object_id(''[distr_plus].[dbo].[svf_' + @dbname + ']'',''u'') is not null drop table [distr_plus].[dbo].[svf_' + @dbname + ']
	
	set @ErrCode = 1001
	set @ErrText = ''��� ������ ��� ���������� ������''
	set @Details = ''�� ������ ���������� ������, �������� Report.txt �� �������� ������ �� ������ c ' + @mindate + ' �� ' + @maxdate + ', ������� ��������� ������������ ����������''


	select 
	Month(getdate())        AS Month,
    '''+@cntry+'''          AS Country,
    '''+@PlaceId+'''        AS PlaceId,
    '''+@PlaceName+'''      AS PlaceName,
	@ErrCode                AS ErrCode,
	@ErrText                AS ErrText,
	null                    AS UfaceExId,
	null                    AS UfaceName,
	null                    AS DocType,
	null                    AS DocDate,
	null                    AS DocId,
	null                    AS DocNumber,
	null                    AS ProductName,
	null                    AS EAN,
	null                    AS IDH,
	null                    AS Amount,
	null                    AS SUMM,
	@Details                AS Details
	into [distr_plus].[dbo].[svf_' + @dbname + ']
	  end
	end')
end



/*������ ��������� �������*/
--set ' + @mindate + '=case
--		when (select val from [' + @dbname + '].[dbo].[d_options] where optionid=955)>day(getdate()) 
--			then cast(dateadd(day,1-day((select dateadd(month,((select cast(attrvaluename as int) 
--				from [' + @dbname + '].[dbo].[d_options] op
--				join [' + @dbname + '].[dbo].[ds_attributesvalues] av
--					on op.val=av.attrvalueid
--				where optionid=954)),getdate()))),(select dateadd(month,((select cast(attrvaluename as int) 
--				from [' + @dbname + '].[dbo].[d_options] op
--				join [' + @dbname + '].[dbo].[ds_attributesvalues] av
--					on op.val=av.attrvalueid
--				where optionid in (954))),getdate()))) as date)
--		else  cast(dateadd(day,1-day((select dateadd(month,((select cast(attrvaluename as int)-1 
--				from [' + @dbname + '].[dbo].[d_options] op
--				join [' + @dbname + '].[dbo].[ds_attributesvalues] av
--					on op.val=av.attrvalueid
--				where optionid=954)),getdate()))),(select dateadd(month,((select cast(attrvaluename as int)-1 
--				from [' + @dbname + '].[dbo].[d_options] op
--				join [' + @dbname + '].[dbo].[ds_attributesvalues] av
--					on op.val=av.attrvalueid
--				where optionid in (954))),getdate()))) as date)
--		end