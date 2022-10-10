use mdm
go

insert into mdm.dbo.mdm_retailerpartner(
    name_id
,   value_id
,   start_date
,   end_date
,   created_at
,   updated_at
)
select
    name_id    = RT.id
  , value_id   = P.id
  , start_date = '20140101'
  , end_date   = '29991231'
  , getdate()
  , getdate()
from
    integrationDB.dbo.spot2d_bi_ttoptions TT
    inner join mdm.dbo.mdm_retailer RT
        on TT.id_client_tt = RT.ext_id and is_fake is null
    inner join mdm.dbo.mdm_partner P
        on TT.id_group = P.ext_id
union all
select
    name_id    = RT.id
  , value_id   = RT.ext_id
  , start_date = '20140101'
  , end_date   = '29991231'
  , getdate()
  , getdate()
from
    mdm.dbo.mdm_retailer RT
where
    is_fake is not null;
