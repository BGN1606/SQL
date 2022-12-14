use mobile_schwarzkopf_ho

select p.iid,p.PartID,p.Exid,i.iidText,i.iName,pp.Price PartyPrice,ip.CostRoubles ItemsPrice from ds_parts p
left join ds_items i
 on i.iid=p.iid
left join DS_Party_Prices pp
  on p.PartID=pp.PartId
  and getdate() between pp.StartDate and pp.EndDate
left join ds_items_prices ip
  on p.iID=ip.iID
 and ip.OwnerDistID=1
where exid in ('2324155','2324154','2374283','2374282')
