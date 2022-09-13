CREATE TABLE IF NOT EXISTS second_period
(
    id integer PRIMARY KEY,
    first_name varchar(15),
    last_name varchar(15) NOT NULL,
    grade integer,
    activity varchar(10) CHECK (activity IN('sport', 'band', 'work', 'theater', 'other')),
    feeling_scale integer CHECK (feeling_scale <=5),
    intro_math integer,
    measurement integer,
    exam_1 integer)
INSERT INTO second_period
(id, first_name, last_name, grade, activity, feeling_scale, intro_math, measurement, exam_1)
VALUES
(001, 'Mariela', 'Fisher', 11, 'sport', 5, 100, 100, 95),
(002, 'Max', 'Harden', 11, 'sport', 3, 90, 78, 75),
(003, 'Amy', 'Wydeven', 10, 'theater', 5, 100, 100, 100),
(004, 'Luke', 'Beringer', 12, 'sport', 5, 55, 90, 70),
(005, 'Mark', 'Fisher', 11, 'other', 2, NULL, 70, 60),
(006, 'Tennesse', 'Smith', 10, 'theater', 4, 90, 100, 90),
(007, 'Robert', 'Crenshaw', 11, 'work', 2, 100, 100, 95),
(008, 'Jameson', 'Townsend', 10, 'band', 4, 100, 70, 75),
(009, 'Robert', 'Collins', 11, 'sport', 2, 65, 50, 50),
(010, 'John', 'Gendelman', 12, 'work', 4, 80, 70, 70),
(011, 'Patricia', 'Knix', 10, 'band', 5, 90, 90, 70),
(012, 'Parker', 'Casteldini', 12, 'other', 4, 100, 70, 85),
(013, 'Julia', 'Nichols', 11, 'work', 3, 40, 55, 60),
(014, 'TeAsia', 'Jackson', 10, 'band', 5, 90, 95, 90),
(015, 'Tucker', 'Johnson', 10, 'band', 5, 80, 80, 65),
(016, 'Sarah', 'Carlson', 11, 'theater', 4, 100, 90, 95),
(017, 'Townes', 'OReilly', 11, 'other', 4, 95, 80, 95),
(018, 'Tasha', 'Dawson', 11, 'band', 4, 70, 90, 90),
(019, 'Adam', 'Peters', 10, 'theater', 2, 50, 90, 65),
(020, 'Abigail', 'Foster', 11, 'band', 5, 100, 100, 100)

edited the table due to some name preferences:
UPDATE second_period 
SET first_name = 'Mary'
WHERE first_name = 'Mariela' and last_name = 'Fisher';
UPDATE second_period
SET first_name = 'Bobby'
WHERE first_name = 'Robert' and last_name = 'Collins';
UPDATE second_period
SET first_name = 'Beth'
WHERE first_name = 'Townes'

#1 Which students self-report an emotional state of 2 or lower?
SELECT first_name, last_name, feeling_scale FROM second_period
WHERE feeling_scale <3

#2 What percentage of students are in a sport?
SELECT ROUND((COUNT (*)/20.0)*100) as sport_percentage
FROM second_period
WHERE activity = 'sport'

#3 Which students scored below average on exam 1?
SELECT first_name, last_name, exam_1 
FROM second_period WHERE exam_1 < 
((SELECT ROUND(AVG(exam_1),2)
FROM second_period))

#4 How did students do on the intro assignemnt? How can we group those who are in need of remediation?
SELECT 
    first_name, 
    substr(last_name, 1,1) as last_initial, 
    intro_math,
    CASE WHEN intro_math <= 70 THEN 'needs_remediation'
        WHEN intro_math BETWEEN 71 AND 85 THEN 'monitor'
        WHEN intro_math >85 THEN 'mastered'
        ELSE 'not_administered'
    END AS intro_grouping
FROM second_period

#5 Are there any athletes who are currently failing? 
SELECT  
    first_name, 
    last_name,
    (intro_math*.2) + (measurement*.3) + (exam_1*.5) AS average
FROM second_period
WHERE activity = 'sport'
ORDER BY average


# Here, teachers are assigned to low-performing students for tutoring:
DROP TABLE IF EXISTS teachers;
CREATE TABLE teachers
(teacher_id SERIAL, teacher_name varchar(15), department varchar(10), student_id integer,
 FOREIGN KEY (student_id) REFERENCES second_period (id));
 INSERT INTO teachers
 (teacher_name, department, student_id)
 VALUES
 ('Noack', 'Science', 009),
 ('Graham', 'Science', 013),
 ('Ely', 'Science', 019),
 ('Koslan', 'Science', 010),
 ('Sorto', 'Science', 015),
 ('Cerame', 'Science', 004)


#6 Who are the students who need remediation and who are their tutors? Do any low-performing students 
need a tutor to be assigned?
WITH groups AS (SELECT 
    id,
    first_name, 
    last_name, 
    intro_math,
    CASE WHEN intro_math <= 70 THEN 'needs_remediation'
        WHEN intro_math BETWEEN 71 AND 85 THEN 'monitor'
        WHEN intro_math >85 THEN 'mastered'
        ELSE 'not_administered'
    END AS intro_grouping
    FROM second_period)
SELECT *, teacher_name from groups
    LEFT JOIN teachers t on t.student_id = groups.id
WHERE intro_grouping = 'needs_remediation'

 #7 What activities are low-performing students involved in and who are their tutors?
 SELECT 
    s.first_name,
    s.last_name,
    activity, 
    teacher_name
FROM
    second_period s
    JOIN teachers t ON s.id = t.student_id
ORDER BY activity

#8 Are there any students involved in sports who could serve as peer tutors?
SELECT
  *
FROM second_period s1
WHERE intro_math = (SELECT MAX(Intro_math) FROM second_period s2  
                    WHERE s1.activity = s2.activity AND activity = 'sport')
