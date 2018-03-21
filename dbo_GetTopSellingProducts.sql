create or alter procedure dbo.GetTopSellingProducts
	@categoryId int
as
begin
	set nocount on;

	declare @DB_CACHE_STATUS bit = 0
			,@CACHE_DURATION_MINUTES int = 5;

	select	@DB_CACHE_STATUS = mc.IsEnabled
	from	DBCache.MasterControl as mc
	where	mc.CachedEntity = 'dbo.GetTopSellingProducts';

	declare @cacheControlId int;

	if @DB_CACHE_STATUS = 1
	begin
		select top(1) @cacheControlId = c.Id
		from DBCache.dbo_GetTopSellingProducts_Control as c
		where	c.ExpiryDateTime >= getutcdate()
		and		c.Param_CategoryId = @categoryId;

		update DBCache.dbo_GetTopSellingProducts_Control  
			set UseCount = UseCount + 1  
		where Id = @cacheControlId;
	end

	if @cacheControlId is not null
	begin
		select r.ProductId
			  ,r.TotalSalePrice
		from DBCache.dbo_GetTopSellingProducts_Results as r
		where	r.ControlId = @cacheControlId
		order by r.TotalSalePrice desc;

		return;
	end

	/* No cached valued available or DBCache disabled, we are going to need to generate the results */

	select	top(20)
			p.ProductId
			,sum(s.TotalSalePrice) as TotalSalePrice
	into	#results
	from	dbo.Sales as s
	join	dbo.Product as p
	on 		p.ProductId = s.ProductId
	where	p.CategoryId = @categoryId
	and		s.SaleDateTime > getutcdate() - 1
	and		p.AvailableStock > 0
	group by p.ProductId
	order by sum(s.TotalSalePrice) desc;

	/* If this is a cache miss and DBCache is enabled, populate the cache */
	if @cacheControlId is null and @DB_CACHE_STATUS = 1
	begin
	begin try
		set @cacheControlId = next value for DBCache.SEQ_Control;
		
		insert into DBCache.dbo_GetTopSellingProducts_Results 
		(
			ControlId
			,ProductId
			,TotalSalePrice
		)
		select	@cacheControlId
			   ,r.ProductId
			   ,r.TotalSalePrice
		from	#results as r;

		insert into DBCache.dbo_GetTopSellingProducts_Control
		(
			Id
			,CacheDateTime
			,ExpiryDateTime
			,Param_CategoryId
			,UseCount
		)
		values
		(
			@cacheControlId
			,getutcdate()
			,dateadd(minute,@CACHE_DURATION_MINUTES,getutcdate())
			,@categoryId
			,1
		)
	end try
	begin catch
		/* Regardless of the error we've hit, set @cacheControlId to NULL to force results to be served from #results rather than cache */
		set @cacheControlId = null;
	end catch
	end

	if @cacheControlId is not null
	begin
		select r.ProductId
			  ,r.TotalSalePrice
		from DBCache.dbo_GetTopSellingProducts_Results as r
		where	r.ControlId = @cacheControlId
		order by r.TotalSalePrice desc;
	end
	else
	begin
		select r.ProductId
			  ,r.TotalSalePrice
		from #results as r
		order by r.TotalSalePrice desc;
	end

	/* END: DBCache */
end