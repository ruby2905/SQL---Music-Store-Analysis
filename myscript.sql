create database music_database;
select * from album2;

-- Question Set 1 - Easy

-- Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

-- Which countries have the most Invoices?
select count(invoice_id), billing_country from invoice
group by billing_country
order by count(invoice_id) desc
limit 1;

-- What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3;

-- Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals
select billing_city, sum(total) as t from invoice
group by billing_city
order by t desc
limit 1;

-- Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money
select invoice.customer_id,customer.first_name, customer.last_name, sum(total) as t 
from invoice join customer
on invoice.customer_id=customer.customer_id
group by invoice.customer_id,customer.first_name, customer.last_name
order by t desc
limit 1;

-- Question Set 2 – Moderate

-- Write a query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A
select distinct email, first_name, last_name from customer join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
where genre.name='Rock'
order by email;

-- Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands
select artist.name, count(track_Id)
from artist join album2 on artist.artist_id=album2.artist_id
join track on album2.album_id=track.album_id
where track.genre_id in (select track.genre_id from track join genre on track.genre_id=genre.genre_id
where genre.name='Rock')
group by artist.name
order by count(track_Id) desc
limit 10;

-- Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first
SELECT name
FROM track
WHERE LENGTH(name) > (SELECT AVG(LENGTH(name)) FROM track);

-- Question Set 3 – Advance

-- Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent
select customer.first_name, customer.last_name, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as total from customer join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_line_id
join track on invoice_line.track_id=track.track_id
join album2 on track.album_id=album2.album_id
join artist on album2.artist_id=artist.artist_id
group by customer.first_name, customer.last_name, artist.name
order by 4 desc;

-- We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres....partition by country then genre then ranking based on amt
with cte as (
select count(invoice_line.quantity), customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as ronum
from genre join track on genre.genre_id=track.genre_id join invoice_line on track.track_id=invoice_line.track_id
join invoice on invoice.invoice_id=invoice_line.invoice_id join customer on customer.customer_id=invoice.customer_id
group by 2,3,4
order by 2 asc, 1 desc

)
select * from cte where ronum<=1;

-- Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount
with cte1 as (
select customer.customer_id, customer.first_name, customer.last_name, customer.country, sum(invoice.total),
rank() over(partition by customer.country order by sum(invoice.total) desc) as ro
from customer join invoice on customer.customer_id=invoice.customer_id
group by 1,2,3,4
order by 4 asc, 5 desc
)
select * from cte1 where ro<=1
