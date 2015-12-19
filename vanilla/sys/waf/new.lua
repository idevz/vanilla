local NewTest = {}
function NewTest:new()
	ngx.exit(404)
end
return NewTest