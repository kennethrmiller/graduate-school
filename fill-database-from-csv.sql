# Creating a database from an unorganized CSV.
create database kemi1053records;
use kemi1053records;

# Creating an un-normalized (UNF) table first.
drop table recordsUNF;
create table recordsUNF
	(artistId int
    , name varchar(45)
    , albumid int
    , title varchar(100)
    , track1 varchar(200)
    , ms1	 bigint
    , bytes1 bigint
    , price1 int 
    , track2 varchar(200)
    , ms2 bigint
    , bytes2 int
    , price2 int
    , track3 varchar(200)
    , ms3 bigint
    , bytes3 int
    , price3 int
    );
 
# Filling UNF Table
load data infile 'c:\\TartarusData/songs.csv' 
	into table recordsUNF
charset Latin1
fields terminated by ','
optionally enclosed by '"'
ignore 1 lines
	(@artistID
    , name
    , albumid
    , title 
    , track1 
    , @ms1	 
    , bytes1 
    , price1  
    , @track2 
    , @ms2 
    , bytes2 
    , price2 
    , @track3 
    , @ms3 
    , bytes3 
    , price3 
    )
set artistId = nullif(@artistId, '')
	, ms1 = nullif(@ms1, '')
	, track2 = nullif(@track2, '')
    , ms2 = nullif(@ms2, '')
    , track3 = nullif(@track3, '')
    , ms3 = nullif(@ms3, '')
    ;
#---------------------------
# FORWARD ENGINEER HERE
#---------------------------
# Artist Table
insert into artists
	(artistID, name)
    select distinct UNF.artistID
		, UNF.name
	from kemi1053records.recordsUNF UNF;
    
select * from artists
limit 5;

# Album Table
insert into albums
	(albumID, title, artistID)
    select distinct UNF.albumID
		, UNF.title
        , UNF.artistID
	from kemi1053records.recordsUNF UNF;
    
select * from albums
limit 5;

# Song Table
insert into songs
	(songID, title, ms, bytes, price, artistID)
	select null as songID
		, UNF.track1 as title
        , UNF.ms1 as ms
        , UNF.bytes1 as bytes
        , UNF.price1 as price
        , UNF.artistID as artistID
	from kemi1053records.recordsUNF UNF
    where UNF.track1 is not null;

select * from songs
limit 5;

insert into songs
	(songID, title, ms, bytes, price, artistID)
	select null as songID
		, UNF.track2 as title
        , UNF.ms2 as ms
        , UNF.bytes2 as bytes
        , UNF.price2 as price
        , UNF.artistID
	from kemi1053records.recordsUNF UNF
    where UNF.track2 is not null;
    
insert into songs
	(songID, title, ms, bytes, price, artistID)
	select null as songID
		, UNF.track3 as title
        , UNF.ms3 as ms
        , UNF.bytes3 as bytes
        , UNF.price3 as price
        , UNF.artistID
	from kemi1053records.recordsUNF UNF
    where UNF.track3 is not null;
    
select * from songs
limit 5;    
    
# Track Table 
insert into tracks
	(trackID, albumID, songID, trackNo)
    select distinct null as trackID
		, albums.albumID
        , songs.songID
        , if(songs.songID < 258, 1, if(songs.songID > 515, 3, 2)) as trackNo
	from songs
    join artists on songs.artistID = artists.artistID
    join albums on artists.artistID = albums.artistID;
    
# Figuring out the number of copies needed to sell to make a profit. 
delimiter //

create function profitgetter(price dec(10, 2)) returns int
deterministic
begin
	declare copies int;
    set copies = 10000/price
    ;
return (copies);
end //
delimiter ;


select songID as 'Song ID'
	, title as 'Title'
    , concat('$', price) as 'Price'
    , profitgetter(price) as 'No. Copies to Make Profit'
from songs;

# Creating a procedure to "search" for certain titles, joining tables.
# Works with nulls in some categories
delimiter //
create procedure valuegetter2(inout pname varchar(45), inout pnumber int, out pprice int)
begin

    set pname = (select name from artists
		where pnumber = artistID);
        
    set pnumber = (select artistID from artists
		where pname = name);
        
    set pprice = (select sum(price) from songs
		join artists on artists.artistID = songs.artistID
        where pname = artists.name or pnumber = artists.artistID 
        group by artists.artistID);
	        
end //
delimiter ;

set @pname = 'AC/DC';
set @pnumber = null;
set @pprice = 0;
call kemi1053records.valuegetter(@pname, @pnumber, @pprice);
select @pname, @pnumber, @pprice;
    
set @pname = 'null';
set @pnumber = 10;
set @pprice = 0;
call kemi1053records.valuegetter2(@pname, @pnumber, @pprice);
select @pname, @pnumber, @pprice;
