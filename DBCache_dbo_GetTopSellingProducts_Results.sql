create table DBCache.dbo_GetTopSellingProducts_Results
(
	ControlId int not null
	,ProductId int not null
	,TotalSalePrice money not null
	,index CIX_dbo_GetTopSellingProducts_Results clustered (ControlId)
);