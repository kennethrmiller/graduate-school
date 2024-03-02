#-------------------------------------------------------

# What parents currently do not have bills?
select parentID as 'Parent ID'
	, concat(lastName, ', ',firstName) as 'Name'
from parent
where parentID not in (select parentID from billing);

#-------------------------------------------------------

# What parents have multiple kids enrolled in school, and what do they currently owe?
select parent.parentID as 'Parent ID'
	, concat(parent.lastName, ', ', parent.firstName) as 'Parent Name'
    , count(student.studentID) as 'No. Students Enrolled'
    , if(parent.parentID not in 
			(select parentID from billing)
			, 'False'
			, 'True') as Bills
	, if(parent.parentID not in
			(select parentID from billing)
            , concat('$', 0)
            , concat('$', format(count(student.studentID)*400, '$'))) as 'Amount Due'
from parent
join student on student.parentID = parent.parentID
group by student.parentID 
	having count(student.studentID) > 1;
