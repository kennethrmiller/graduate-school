select nc.continent as 'Continent'
	, numreg as 'Number of Regions'
    , Region
    , numcountry as 'Number of Countries'
from
	(select count(distinct region) as numreg
			, Continent 
		from country
		group by continent) nr
	join
    (select continent 
		, count(distinct name) as numcountry
		, Region
	from country
	group by region) nc 
    on nr.continent = nc.continent
order by nc.continent
	, Region;
