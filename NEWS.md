# inser 0.3.0

* `create_selectivity_sheet()` generate html files. #24

# inser 0.2.0

* The `zones` parameter of `create_selectivity_sheet()` does not have a default value anymore. #7
* Arrows are now visible on the map. #6
* Zone geometries are made valid before being plotted in `create_maps()` #5
* Tests of `create_selectivity_sheet()` don't rely on `testthat::expect_snapshot_file()` anymore and thus 
should work on every platform. #2
* Package source code is now hosted on github.
* Selectivity sheets can be generated in both French and English.
* The parameter `ices_data` of the `create_maps()` is renamed to `data_zones_sf`
* Zone label positions on maps are automatically calculated.
* ICES data are included with the package.
* Mapping function does not depend on {sp} anymore.


# inser 0.1.0

* All provided examples run successfully.
* The package has its own `pkgdown` website.
