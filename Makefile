STATE_FIPS = \
	01|al|alabama \
	02|ak|alaska \
	04|az|arizona \
	05|ar|arkansas \
	06|ca|california \
	08|co|colorado \
	09|ct|connecticut \
	10|de|delaware \
	11|dc|district_of_columbia \
	12|fl|florida \
	13|ga|georgia \
	15|hi|hawaii \
	16|id|idaho \
	17|il|illinois \
	18|in|indiana \
	19|ia|iowa \
	20|ks|kansas \
	21|ky|kentucky \
	22|la|louisiana \
	23|me|maine \
	24|md|maryland \
	25|ma|massachusetts \
	26|mi|michigan \
	27|mn|minnesota \
	28|ms|mississippi \
	29|mo|missouri \
	30|mt|montana \
	31|ne|nebraska \
	32|nv|nevada \
	33|nh|new_hampshire \
	34|nj|new_jersey \
	35|nm|new_mexico \
	36|ny|new_york \
	37|nc|north_carolina \
	38|nd|north_dakota \
	39|oh|ohio \
	40|ok|oklahoma \
	41|or|oregon \
	42|pa|pennsylvania \
	44|ri|rhode_island \
	45|sc|south_carolina \
	46|sd|south_dakota \
	47|tn|tennessee \
	48|tx|texas \
	49|ut|utah \
	50|vt|vermont \
	51|va|virginia \
	53|wa|washington \
	54|wv|west_virginia \
	55|wi|wisconsin \
	56|wy|wyoming \

all: all_house all_senate
################################################################################
# GENERATE STATE TARGETS
################################################################################
define CHAMBER_TARGETS_TEMPLATE
data/shp/$(word 3,$(subst |, ,$(state)))_house.shp: data/gz/house/tl_2015_$(word 1,$(subst |, ,$(state)))_sldl.zip
data/shp/$(word 3,$(subst |, ,$(state)))_senate.shp: data/gz/senate/tl_2015_$(word 1,$(subst |, ,$(state)))_sldu.zip
endef

$(foreach state,$(STATE_FIPS),$(eval $(CHAMBER_TARGETS_TEMPLATE)))

all_house: $(foreach T,$(STATE_FIPS),data/shp/$(word 3,$(subst |, ,$(T)))_house.shp)
all_senate: $(foreach T,$(STATE_FIPS),data/shp/$(word 3,$(subst |, ,$(T)))_senate.shp)

################################################################################
# SHAPEFILES: META
################################################################################
data/shp/%.shp:
	 rm -rf $(basename $@)
	 mkdir -p $(basename $@)
	 tar --exclude="._*" -xzm -C $(basename $@) -f $<

	 for file in `find $(basename $@) -name '*.shp'`; do \
		 ogr2ogr -dim 2 -f 'ESRI Shapefile' -t_srs 'EPSG:4326' $(basename $@).$${file##*.} $$file; \
		 chmod 644 $(basename $@).$${file##*.}; \
	 done
	 rm -rf $(basename $@)

data/gz/house/%.zip:
	 mkdir -p $(dir $@)
	 curl 'ftp://ftp2.census.gov/geo/tiger/TIGER2015/SLDL/$(notdir $@)' -o $@.download
	 mv $@.download $@

data/gz/senate/%.zip:
	 mkdir -p $(dir $@)
	 curl 'ftp://ftp2.census.gov/geo/tiger/TIGER2015/SLDU/$(notdir $@)' -o $@.download
	 mv $@.download $@
