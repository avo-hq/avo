- removed `params[:related_name]` in favor of `params[:resource_class]`
- all associations going through a `resource` route with `constraints` attached that check for `params[:resource_class]`
- moved ordering into it's own controller. Root and association ordering hits the same endpoint.

- change the `resource_name` param to `associated_resource_class` and get the resource from there.

TODO:

- [x] make all associations work
- [x] file field
- [x] trix uploads
- [x] re-ordering
- [x] delete. from index, show, associations (show, index)
- [ ] attach
- [ ] detach
- [ ] edit
- [ ] view
- [ ] belongs to
- [ ] search


