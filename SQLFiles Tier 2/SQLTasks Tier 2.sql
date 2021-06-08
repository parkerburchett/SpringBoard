/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name FROM `Facilities` WHERE membercost > 0;



/* Q2: How many facilities do not charge a fee to members? */
SELECT count(*) FROM `Facilities` WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT `facid`,`name`,`membercost`,`monthlymaintenance` FROM Facilities 
WHERE (.2 * `monthlymaintenance`) > `membercost`;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
select * from Facilities 
WHERE `facid` in (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

select  `name`, 
		`monthlymaintenance`, 
		case when `monthlymaintenance`> 100 then 'expensive'
	    else 'cheap' end as price
from Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT `firstname`,`surname` FROM `Members`
WHERE `joindate` = (select max(`joindate`) from `Members`);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT distinct concat(m.firstname, ' ', m.surname) as member_name

FROM `Members` as m
join `Bookings` as b on b.memid = m.memid
join `Facilities` as f on b.facid = f.facid

where 
f.name like '%tennis court%'
and concat(m.firstname, ' ', m.surname) not like '%Guest'
order by member_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
    f.name as facility_name, 
    concat(m.firstname, ' ', m.surname) as member_name, 
    f.guestcost as cost -- I verified that thare are no membercosts that are greater than 30 on this day. 

FROM `Members` as m
join `Bookings` as b on b.memid = m.memid
join `Facilities` as f on b.facid = f.facid


WHERE DATE(b.starttime) = '2012-09-14'
and ( 
    (f.guestcost> 30 and m.memid = 0) or 
    (f.membercost > 30 and m.memid != 0) 
	)

order by f.guestcost desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */


-- Subquery
SELECT 
    f.name as facility_name, 
    concat(m.firstname, ' ', m.surname) as member_name, 
    f.guestcost as cost

FROM `Members` as m
join `Bookings` as b on b.memid = m.memid
join `Facilities` as f on b.facid = f.facid

AND b.bookid in 
	(SELECT
		b.bookid
	FROM `Members` as m
	join `Bookings` as b on b.memid = m.memid
	join `Facilities` as f on b.facid = f.facid

	WHERE
         DATE(b.starttime) = '2012-09-14' and
	     ((f.guestcost > 30 and m.memid = 0) or 
	     (f.membercost > 30 and m.memid != 0)));


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT f.name as Facility_name, 
                  ((count(m.memid = 0) * f.guestcost) + (count(m.memid != 0) * f.membercost)) as total_revenue

            FROM `Members` as m
            join `Bookings` as b on b.memid = m.memid
            join `Facilities` as f on b.facid = f.facid

            group by f.name
			      HAVING total_revenue < 10000 
            order by total_revenue desc;

-- I could not figure out this question. 

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
select 
                        concat(firstname, ' ', surname) as member_name,
                        group_concat(recommendedby, ',') as rec_ids
                        from Members 
                        group by member_name;

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT f.name as Facility_name, 
                count(b.bookid) as member_usage

            FROM `Members` as m
            join `Bookings` as b on b.memid = m.memid
            join `Facilities` as f on b.facid = f.facid
            where m.memid !=0
            Group by Facility_name;

/* Q13: Find the facilities usage by month, but not guests */

          SELECT strftime('%m', b.starttime) as Month, 
                 count(b.bookid) as member_usage 

            FROM `Members` as m
            join `Bookings` as b on b.memid = m.memid
            join `Facilities` as f on b.facid = f.facid

            where m.memid !=0
            Group by Month