/* The version of the procedure before caching is applied */
create or alter procedure dbo.GetTopSellingProducts_NoCache
	@categoryId int
as
begin
	select	top(20)
			p.ProductId
			,sum(s.TotalSalePrice) as TotalSalePrice
	from	dbo.Sales as s
	join	dbo.Product as p
	on 		p.ProductId = s.ProductId
	where	p.CategoryId = @categoryId
	and		s.SaleDateTime > getutcdate() - 1
	and		p.AvailableStock > 0
	group by p.ProductId
	order by sum(s.TotalSalePrice) desc;
end