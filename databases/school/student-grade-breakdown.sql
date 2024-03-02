#-----------------------------------------------------

# What are the highest scorers for each assignment?
select distinct firstName as 'First Name'
	, lastName as 'Last Name'
    , assignment.assignmentID as 'Assignment ID'
    , Description 
    , concat(max(round(score/grade.maxScore*100, 2)), '%') as 'Score'
from student
join grade on grade.studentID = student.studentID
join assignment on assignment.assignmentID = grade.assignmentID
where score/grade.maxScore > 0.9
group by description
order by firstName;

#---------------------------------------------------------------

# Using a function to grab the overall letter grade of each student
delimiter //
create function letterGetter(ppercent int) returns varchar(2)
deterministic
begin
	declare grade varchar(2);
	if ppercent >= 90.0 then set grade = 'A';
    elseif ppercent >= 80.0 and ppercent < 90.0 then set grade = 'B';
    elseif ppercent >= 70.0 and ppercent < 80.0 then set grade = 'C';
    elseif ppercent >= 60.0 and ppercent < 70.0 then set grade = 'D';
    elseif ppercent < 60.0 then set grade = 'F';
    else set grade = 'unknown';
    end if;
return(grade);
end //
delimiter ;

#---------------------------------------------------------------

# What students are not passing and what are their parent's emails? Send them an email. Using a function.
select grade.studentID as 'Student ID'
	, student.firstName as 'Student First Name'
	, round(avg(score/maxScore * 100), 2) as Grade
    , letterGetter(avg(round(score/maxScore * 100 , 2))) as 'Letter Grade'
    , parent.parentID as 'Parent ID'
    , concat(parent.lastName, ', ', parent.firstName) as 'Parent Name'
    , parent.email as 'Parent Email'
from grade
join student on student.studentID = grade.studentID
join parent on parent.parentID = student.parentID
group by grade.studentID having Grade < 70
order by parent.lastName
    , student.firstName;
    
#---------------------------------------------------------------
