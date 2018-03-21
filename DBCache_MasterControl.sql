create table DBCache.MasterControl
(
	CachedEntity varchar(255) not null
	,IsEnabled bit not null
	,constraint PK_MasterControl primary key clustered (CachedEntity)
);