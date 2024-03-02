set @rank = 1;
set @co = '';
set @pop = 0;

select countrycode as 'Code'
	, Name 
    , Population
    , corank as 'Rank'
 from (select countrycode
			, name
			, population
			, @rank := if(@co = countrycode
							, if(@pop = population
								, @rank
								, @rank+1)
							, 1) as corank
			, @co := countrycode
		from city
		order by countrycode,
		population desc) sq
where corank <= 3
order by countrycode
	, corank;
