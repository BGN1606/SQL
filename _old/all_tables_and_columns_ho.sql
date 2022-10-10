select

  tbl.name					as [table_name],
  clmn.name					as [column_name],
  tp.name					as [column_type],
  case tp.system_type_id
    when 106 then concat(clmn.precision,',',clmn.scale)
	else convert(nvarchar,clmn.max_length)
  end						as [column_max_length]

from sys.tables tbl

join sys.columns clmn on tbl.object_id = clmn.object_id
join sys.types tp on clmn.system_type_id = tp.system_type_id

where type_desc = 'USER_TABLE'
  and left(tbl.name,3) = 'DS_'

order by tbl.name