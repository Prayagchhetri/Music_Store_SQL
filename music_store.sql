Create database Music_Store


-- Q1: Who is the senior most employee based on job title?

Select 
top(1) CONCAT(first_name,' ',last_name) As Senior_Most_Employee, title  
from employee
Order by levels Desc


-- Q2: Which countries have the most Invoices?

Select top(1) billing_country AS Country_with_Max_Invoices , 
count(billing_country) as c
from invoice 
group by billing_country 
order by c desc


--Q3: What are top 3 values of total invoice?
 
 Select top(3) total as total_value_invoices
 From invoice 
 order by total Desc


--Q4: Which city has the best customers? 
-- We would like to throw a promotional Music Festival in the city we made the most money. 
 --Write a query that returns one city that has the highest sum of invoice totals. 
 --Return both the city name & sum of all invoice totals 

 Select top(1) Billing_city as City, sum(total) as Billing_Total
 from invoice 
 group by Billing_city 
 order by Billing_Total Desc


 --Who is the best customer? 
 --The customer who has spent the most money will be declared the best customer. 
 --Write a query that returns the person who has spent the most money.

 Select top(1) c.first_name , i.total as total1
 from customer as c
 join invoice as i
 on c.customer_id = i.customer_id
 group by c.customer_id, c.first_name, i.total
 order by total1 desc


 --Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
 --Return your list ordered alphabetically by email starting with A.

 Select c.email as Email_, c.First_name, c.last_name 
 from customer as c
 join invoice as i on c.customer_id = i.customer_id
 join invoice_line as il on i.invoice_id = il.invoice_id
 where track_id in 
 ( select track_id from track as t
	Join genre as g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
 ) 
 order by Email_ 



 --Q7: Let's invite the artists who have written the most rock music in our dataset. 
 --Write a query that returns the Artist name and total track count of the top 10 rock bands.

 Select a.name as Name_
 from artist as a
 join album as al on a.artist_id = al.artist_id
 where album_id in 
 ( select album_id from track as t
	Join genre as g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
 ) 
Group by a.name
 order by Name_ 



 --Q8: Return all the track names that have a song length longer than the average song length.
 --Return the Name and Milliseconds for each track. 
 --Order by the song length with the longest songs listed first.

 Select name, milliseconds 
 from track
 having milliseconds > avg(milliseconds)
 order by milliseconds desc



 -- Q9: Find how much amount spent by each customer on artists? 
 --Write a query to return customer name, artist name and total spent

With best_selling_artist as
(Select 
a.name as Name_ , a.artist_id as ID, sum(il.unit_price*il.quantity) as total_
from artist as a
join album as al on a.artist_id = al.album_id
join track as t  on al.album_id = t.album_id
join invoice_line as il on t.track_id = il.track_id
Group by a.name
order by total_ Desc
)
Select c.customer_id, c.First_name as cus_name, 
bsa.Name_ as Artist_ , sum(ili.unit_price*ili.quantity) as Total_ 
FROM invoice as i
join customer as c ON c.customer_id = i.customer_id
join invoice_line as ili ON ili.invoice_id = i.invoice_id
join track as tr ON tr.track_id = ili.track_id
join album as alb ON alb.album_id = tr.album_id
join best_selling_artist as bsa ON bsa.ID = alb.artist_id
group by 1,2,3
order by 4 desc



--Q10: We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres.

with popular_genre AS 
(
    select count(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
	row_number() over(Partition by c.country order by count(il.quantity) desc) as RowNo 
    from invoice_line as il 
	join invoice as i on i.invoice_id = il.invoice_id
	join customer as c on c.customer_id = i.customer_id
	join track as t on t.track_id = il.track_id
	join genre as g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 ASC, 1 DESC
)
select * from popular_genre where RowNo <= 1



--Q11: Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.

with Customter_with_country as (
		select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as RowNo 
		from invoice as i 
		join customer as c on c.customer_id = i.customer_id
		group by  1,2,3,4
		order by  4 asc ,5 desc )
SELECT * FROM Customter_with_country WHERE RowNo <= 1