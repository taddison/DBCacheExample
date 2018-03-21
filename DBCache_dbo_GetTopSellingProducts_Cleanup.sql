create or alter proc DBCache.dbo_GetTopSellingProducts_Cleanup
as
begin
	set nocount on;

	declare @CONTROL_NAME varchar(255) = 'dbo.GetTopSellingProducts'
			,@truncatedResultsTable bit = 0;

	update DBCache.MasterControl
		set IsEnabled = 0
	where	CachedEntity = @CONTROL_NAME;

	waitfor delay '00:00:45';

	set lock_timeout 1000;

	declare @retryCount int = 0
			,@MAX_RETRY_COUNT int = 5;

	while (@retryCount < @MAX_RETRY_COUNT and @truncatedResultsTable = 0)
	begin
		begin try
			truncate table DBCache.dbo_GetTopSellingProductsResults;
			set @truncatedResultsTable = 1;
		end try
		begin catch
			set @retryCount += 1;
		end catch
	end

	update DBCache.dbo_GetTopSellingProducts_Control
		set ExpiryDateTime = getutcdate()
	where	ExpiryDateTime > getutcdate();

	update DBCache.MasterControl
		set IsEnabled = 1
	where	CachedEntity = @CONTROL_NAME;

	if @truncatedResultsTable = 0
	begin
		;throw 50001, 'Failed to clean up results table for dbo.GetTopSellingProducts', 1;
	end
end