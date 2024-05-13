-- --DBMS First Question all queries.

--Structuring the databases adn tables and inserting the data into it.




-- 1. Retrieve names of students enrolled in any society.
    select distinct(Student_Name) as Student_Name_enrolled_in_society from student
    join enrollment as e on e.ROLLNO = student.RollNo
    join society as sc on sc.socID = e.SID;

-- 2. Retrieve all society names.
    select socName from society;

-- 3. Retrieve students' names starting with letter ‘A’.
    select  Student_Name from student 
    where Student_Name like 'A%' ;

-- 4. Retrieve students' details studying in courses ‘computer science’ or ‘chemistry’.
    select * from student
    where course = 'CS' or course = 'Chemistry';

-- 5. Retrieve students’ names whose roll no either starts with ‘X’ or ‘Z’ and ends with ‘9’
    --not used in our dataset as our roll number is like this '100001'
    select  Student_Name from student
    where RollNo like  'X%' or RollNo like 'Z%' and RollNo like '%9';

-- 6. Find society details with more than N TotalSeats where N is to be input by the user
    SET  @num=5; --run this first then run next line
    Select * from society where Total_seats >@num;

-- 7. Update society table for mentor name of a specific society
    update  society 
    set mentorName='Mr.Nitish' 
    where socName='NSS';

-- 8. Find society names in which more than five students have enrolled
    select socName from society
    join enrollment as e on e.SID = society.socID
    group by socName
    having count(socName)>3; --having more than 3 students. i have less data therefore i used 3 instead of 5.

-- 9. Find the name of youngest student enrolled in society ‘NSS’
    select Student_Name from student
    join enrollment as e on e.ROLLNO = student.RollNo
    join society as s on s.socID = e.SID
    where socName = 'NSS'
    order by (DOB) DESC
    limit 1;

-- 10. Find the name of most popular society (on the basis of enrolled students)
    select socName from society
    join enrollment as e on e.SID = society.socID
    join student as st on st.RollNo = e.ROLLNO
    group by socName
    order by COUNT(socName) desc
    limit 1;

-- 11. Find the name of two least popular societies (on the basis of enrolled students)
    select socName from society
    join enrollment as e on e.SID = society.socID
    join student as st on st.RollNo = e.ROLLNO
    group by socName
    order by COUNT(socName) asc
    limit 2;

-- 12. Find the student names who are not enrolled in any society
SELECT Student_Name
FROM student
LEFT JOIN enrollment ON student.RollNo = enrollment.ROLLNO
WHERE enrollment.SID IS NULL;

-- 13. Find the student names enrolled in at least two societies
SELECT Student_Name
FROM student
JOIN enrollment ON student.RollNo = enrollment.ROLLNO
GROUP BY Student_Name
HAVING COUNT(DISTINCT enrollment.SID) >= 2;

-- 14. Find society names in which maximum students are enrolled
SELECT socName
FROM society
JOIN enrollment ON society.socID = enrollment.SID
GROUP BY socName
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 15. Find names of all students who have enrolled in any society and society names in which at
-- least one student has enrolled
SELECT Student_Name
FROM student
JOIN enrollment ON student.RollNo = enrollment.ROLLNO
UNION
SELECT socName
FROM society
JOIN enrollment ON society.socID = enrollment.SID;

-- 16. Find names of students who are enrolled in any of the three societies ‘Debating’, ‘Dancing’
-- and ‘Sashakt’.
SELECT Student_Name
FROM student
JOIN enrollment ON student.RollNo = enrollment.ROLLNO
JOIN society ON society.socID = enrollment.SID
WHERE socName IN ('Debating', 'Dancing', 'Sashakt');

-- 17. Find society names such that its mentor has a name with ‘Gupta’ in it.
SELECT socName
FROM society
WHERE mentorName LIKE '%Gupta%';

-- 18. Find the society names in which the number of enrolled students is only 10% of its
-- capacity.
SELECT socName
FROM (
    SELECT society.socID, socName, Total_seats, COUNT(enrollment.ROLLNO) AS enrolled_count,
           Total_seats * 0.1 AS ten_percent_capacity
    FROM society
    JOIN enrollment ON society.socID = enrollment.SID
    GROUP BY society.socID
) AS subquery
WHERE enrolled_count <= ten_percent_capacity;

-- 19. Display the vacant seats for each society.
SELECT socName, Total_seats - COUNT(enrollment.ROLLNO) AS vacant_seats
FROM society
LEFT JOIN enrollment ON society.socID = enrollment.SID
GROUP BY socName;

-- 20. Increment Total Seats of each society by 10%
UPDATE society
SET Total_seats = Total_seats * 1.1;

-- 21. Add the enrollment fees paid (‘yes’/’No’) field in the enrollment table.
ALTER TABLE enrollment
ADD enrollment_fees_paid ENUM('Yes', 'No') DEFAULT 'No';

-- 22. Update date of enrollment of society id ‘s1’ to ‘2018-01-15’, ‘s2’ to current date and ‘s3’
-- to ‘2018-01-02’.
UPDATE enrollment
SET date_of_enrollment = 
    CASE 
        WHEN SID = 's1' THEN '2018-01-15'
        WHEN SID = 's2' THEN CURDATE()
        WHEN SID = 's3' THEN '2018-01-02'
    END;

-- 23. Create a view to keep track of society names with the total number of students enrolled in
-- it.
CREATE VIEW Society_Enrollment_Count AS
SELECT socName, COUNT(enrollment.ROLLNO) AS total_students_enrolled
FROM society
LEFT JOIN enrollment ON society.socID = enrollment.SID
GROUP BY socName;

-- 24. Find student names enrolled in all the societies.
SELECT Student_Name
FROM student
WHERE NOT EXISTS (
    SELECT socID
    FROM society
    WHERE NOT EXISTS (
        SELECT *
        FROM enrollment
        WHERE enrollment.SID = society.socID
        AND enrollment.ROLLNO = student.RollNo
    )
);

-- 25. Count the number of societies with more than 5 students enrolled in it
SELECT COUNT(socID)
FROM (
    SELECT socID
    FROM enrollment
    GROUP BY socID
    HAVING COUNT(ROLLNO) > 5
) AS subquery;

-- 26. Add column Mobile number in student table with default value ‘9999999999’
ALTER TABLE student
ADD Mobile_number VARCHAR(15) DEFAULT '9999999999';

-- 27. Find the total number of students whose age is > 20 years.
SELECT COUNT(*)
FROM student
WHERE TIMESTAMPDIFF(YEAR, DOB, CURDATE()) > 20;

-- 28. Find names of students who are born in 2001 and are enrolled in at least one society.
SELECT Student_Name
FROM student
JOIN enrollment ON student.RollNo = enrollment.ROLLNO
WHERE YEAR(DOB) = 2001;

-- 29. Count all societies whose name starts with ‘S’ and ends with ‘t’ and at least 5 students are
-- enrolled in the society.
SELECT COUNT(*)
FROM (
    SELECT socID
    FROM society
    WHERE socName LIKE 'S%t'
    GROUP BY socID
    HAVING COUNT(ROLLNO) >= 5
) AS subquery;

-- 30. Display the following information:
-- Society name Mentor name Total Capacity Total Enrolled Unfilled Seats
SELECT socName, mentorName, Total_seats, COUNT(enrollment.ROLLNO) AS Total_Enrolled,
       (Total_seats - COUNT(enrollment.ROLLNO)) AS Unfilled_Seats
FROM society
LEFT JOIN enrollment ON society.socID = enrollment.SID
GROUP BY socName;



