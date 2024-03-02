create view NALangView as 
	select code as 'Country Code'
		, name as 'Country Name'
		, localName as 'Local Name'
		, cl.language as 'Language'
		, max(cl.percentage) as 'Percentage Spoken'
	from country2
	join countrylanguage2 cl on cl.countrycode = country2.code
	where continent = 'North America'
	group by countrycode
	order by max(cl.percentage) desc;
