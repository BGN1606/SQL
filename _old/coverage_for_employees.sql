/*КОЛ-ВО ТОРГОВЫХ ТОЧЕК С ПРОДАЖАМИ БОЛЬШЕ 0*/
SELECT  '-1' as ObjectID, 
	   COUNT(ordrs.[mfID]) as Value 
FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders] ordrs

/*ОТФИЛЬТРОВЫВАЕМ ДОКУМЕНТЫ РЦ*/
LEFT JOIN  [Mobile_Schwarzkopf_HO].[dbo].[DS_DocAttributes] DCOrdrs ON ordrs.orid = DCOrdrs.DocID 
																	and ordrs.MasterFID = DCOrdrs.MasterfID 
																	and DCOrdrs.attrid = 685 
																	and DCOrdrs.AttrValueID = 685000001 
																	and DCOrdrs.OwnerDistID <> 1 
																	and DCOrdrs.ActiveFlag = 1

/*ПОДТЯГИВАЕМ ТАБЛИЦУ СО СВЯЗКОЙ ТОЧКА-СОТРУДНИК*/
JOIN [Mobile_Schwarzkopf_HO].[dbo].[MobFaces] Mfcs ON mfcs.mFid = ordrs.mfID

WHERE	orDate between '2017-06-01' /*%BeginDate%*/ and '2017-06-30'  /*%EndDate%*/
		and Mfcs.MasterFID = 36000001 /*%Masterfid%*/
		and Condition = 1 
		and ortype = 2 
		and orSum >0  
		and DCOrdrs.MasterfID is null
GROUP BY mfcs.MasterFID
