create procedure dbo.GetPostCount
	@userId int
as
begin
	select	count(*) as PostCount
	from	dbo.Posts as p
	where	p.OwnerUserId = @userId;
end