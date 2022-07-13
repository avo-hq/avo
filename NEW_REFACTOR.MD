- removed `params[:related_name]` in favor of `params[:resource_class]`
- all associations going through a `resource` route with `constraints` attached that check for `params[:resource_class]`

