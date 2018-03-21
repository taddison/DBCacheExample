create table DBCache.dbo_GetTopSellingProducts_Control
(
	CacheDateTime datetime2(3) not null
	,ExpiryDateTime datetime2(3) not null
	,Param_CategoryId int not null
	,UseCount int null
	,Id int not null
	,constraint PK_dbo_GetTopSellingProducts_Control primary key clustered (Id)
	,index IX_dbo_GetTopSellingProducts_Control_ExpiryParams nonclustered (Param_CategoryId, ExpiryDateTime)
);