- removed `params[:related_name]` in favor of `params[:for_resource_class]`
- all associations going through a `resource` route with `constraints` attached that check for `params[:for_resource_class]`

