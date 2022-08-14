/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

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
SELECT name
FROM Facilities
where membercost != 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(*) as number_of_facilities
FROM Facilities
where membercost = 0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
from Facilities
where membercost < (monthlymaintenance * 0.2)


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
from Facilities
where facid in (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
Case
	When monthlymaintenance > 100 then 'expensive'
	else 'cheap'
end as labeled
from Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname, joindate
FROM Members
ORDER BY joindate DESC
LIMIT 1

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT f.name, CONCAT_WS(firstname,' ',surname) as fullname
from Bookings as b
left join Facilities as f
on b.facid = f.facid
left join Members as m
on m.memid = b.memid
where f.name like 'Tennis Court%'
group by fullname
order by fullname


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select concat_ws(m.firstname, ' ' , m.surname) as fullName, (f.membercost * b.slots) as Cost
from Members as m 
inner join Bookings as b
on b.memid = m.memid
inner join Facilities as f
on f.facid = b.facid
where b.starttime like '2012-09-14%'
and (memberCost > 30 or guestCost > 30)

union

select concat_ws(m.firstname, ' ' , m.surname) as fullName, (f.guestcost * b.slots) as Cost
from Members as m 
inner join Bookings as b
on b.memid = m.memid
inner join Facilities as f
on f.facid = b.facid
where b.starttime like '2012-09-14%'
and (memberCost > 30 or guestCost > 30)
order by cost desc;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select me.name, concat_ws(m.surname, ' ' , m.firstname) as fullname, me.cost
from Members as m
inner join
	(select f.name, b.memid, (f.membercost * b.slots) as cost
 	from Bookings as b
 	inner join Facilities as f
	on b.facid = f.facid
	where b.starttime like '2012-09-14%') as me
on m.memid = me.memid
where me.cost > 30

union 

select me.name, concat_ws(m.surname, ' ' , m.firstname) as fullname, me.cost
from Members as m
inner join
	(select f.name, b.memid, (f.guestcost * b.slots) as cost
 	from Bookings as b
 	inner join Facilities as f
	on b.facid = f.facid
	where b.starttime like '2012-09-14%') as me
on m.memid = me.memid
where me.cost > 30
order by cost desc

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
q10 = 	'''SELECT f.name, SUM( 
				CASE WHEN b.memid =0
				THEN f.guestcost * b.slots
				ELSE f.membercost * b.slots
				END ) AS revenue
				FROM country_club.Facilities f
				JOIN country_club.Bookings b ON f.facid = b.facid
				GROUP BY f.name
				HAVING revenue <1000
				ORDER BY revenue DESC'''


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
q11 = '''
select m.memid, m.surname, m.firstname, concat_ws(me.firstname, ' ', me.surname) as recommender
from Members as m
inner join Members as me
on m.recommendedby = me.memid
where m.memid != 0
order by m.surname, m.firstname
'''

/* Q12: Find the facilities with their usage by member, but not guests */
q12 = '''
SELECT b.facid, f.name, SUM( b.slots ) AS usage_by_member
FROM Bookings AS b
INNER JOIN `Facilities` AS f ON b.facid = f.facid
WHERE b.memid !=0
GROUP BY b.facid
'''

/* Q13: Find the facilities usage by month, but not guests */
q13 = '''SELECT b.facid, f.name, EXTRACT(MONTH FROM b.starttime) as month, SUM(b.slots) AS usage_by_month
FROM `Bookings` AS b
INNER JOIN `Facilities` AS f 
ON b.facid = f.facid
WHERE b.memid !=0
GROUP BY b.facid, month'''
