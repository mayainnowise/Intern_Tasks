--Display the top 10 actors whose films were rented the most, sorted in descending order.

select a.first_name, a.last_name, count(rental_id) as count_rent
from rental 
left join inventory inv using (inventory_id)
left join film f on inv.film_id=f.film_id
left join film_actor fa on f.film_id=fa.film_id
left join actor a using (actor_id)
group by first_name, last_name
order by 3 desc
limit 10;

--Display the number of films in each category, sorted in descending order.

select name as category_name, count(*) as film_count
from film_category 
left join category using (category_id) 
group by name
order by 2 desc;

--Display the category of films that generated the highest revenue.

select name, sum(amount)
from payment 
left join rental using (customer_id)
left join inventory using (inventory_id)
left join film using (film_id)
left join film_category using (film_id)
left join category using (category_id)
group by name
order by 2 desc
limit 5;

--Display the titles of films not present in the inventory. Write the query without using the IN operator.

select title
from film 
left join inventory using (film_id)
where inventory_id IS NULL;

--Display the top 3 actors who appeared the most in films within the "Children" category. If multiple actors have the same count, include all.

select * 
from (
	select first_name, last_name, name as category, count(*) as count_film, dense_rank() over(order by count(*) desc) as rank_category
	from film_actor
	left join film_category using (film_id)
	left join actor using (actor_id) 
	left join category using (category_id)
	group by first_name, last_name, name
	having name='Children' 
	order by 4 desc) as ranked
where rank_category<=3;

--Display cities with the count of active and inactive customers (active = 1). Sort by the count of inactive customers in descending order.

select 
    city, 
    count(*) filter (where active = 1) as active_customers,
    count(*) filter (where active = 0) as inactive_customers
from customer
left join address using (address_id)
left join city using (city_id)
group by city
order by inactive_customers desc; 

--Display the film category with the highest total rental hours in cities where customer.address_id belongs to that city and starts with the letter "a". Do the same for cities containing the symbol "-". Write this in a single query.

(select name as category_name, sum(return_date-rental_date) as sum_rent_time
from rental r
left join inventory using (inventory_id)
left join film_category using (film_id)
left join category using (category_id)
left join customer using (customer_id)
left join store on customer.store_id=store.store_id
left join address on customer.address_id=address.address_id
where city_id in (select city_id from city where city like 'a%')
group by name
order by 2 desc
limit 1)
union 
(select name as category_name, sum(return_date-rental_date)
from rental r
left join inventory using (inventory_id)
left join film_category using (film_id)
left join category using (category_id)
left join customer using (customer_id)
left join store on customer.store_id=store.store_id
left join address on customer.address_id=address.address_id
where city_id in (select city_id from city where city like '%-%')
group by name
order by 2 desc
limit 1)