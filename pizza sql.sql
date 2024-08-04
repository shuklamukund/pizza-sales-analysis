CREATE DATABASE pizzahut
use pizzahut
CREATE TABLE orders (
order_id int not null,
order_date int not null,
order_time time not null,
primary key(order_id)
);
select COUNT(*) from order_details
-- SELECT SUM(quantity*price) FROM pizzas
-- JOIN order_details ON order_details.pizza_id=pizzas.pizza_id

-- select d.piz,sum(order_details.quantity) as sum from (
-- select pizza_types.name as piz,pizzas.pizza_id as id from pizza_types
-- join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id) as d
-- join order_details on d.id=order_details.pizza_id
-- group by d.piz order by sum desc limit 5;

-- select * from orders

-- Basic:
-- Retrieve the total number of orders placed.
-- Calculate the total revenue generated from pizza sales.
-- Identify the highest-priced pizza.
-- Identify the most common pizza size ordered.
-- List the top 5 most ordered pizza types along with their quantities.

-- 1.
SELECT COUNT(*) FROM orders;

-- 2.
SELECT sum(quantity*price) FROM order_details
JOIN pizzas ON order_details.pizza_id=pizzas.pizza_id;
-- 3.
SELECT pizza_types.name FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id
ORDER BY pizzas.price DESC LIMIT 1;

-- 4.

SELECT pizzas.size,COUNT(order_details.order_details_id)
FROM pizzas JOIN order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY pizzas.size ORDER BY COUNT(order_details.order_details_id) DESC LIMIT 1;


-- 5.

SELECT pizza_types.name,SUM(order_details.quantity) 
FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id 
JOIN order_details ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.name ORDER BY SUM(order_details.quantity) DESC LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
-- Determine the distribution of orders by hour of the day.
-- Join relevant tables to find the category-wise distribution of pizzas.
-- Group the orders by date and calculate the average number of pizzas ordered per day.
-- Determine the top 3 most ordered pizza types based on revenue.

-- 1.

SELECT SUM(order_details.quantity), pizza_types.category
FROM order_details JOIN pizzas ON order_details.pizza_id=pizzas.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id
GROUP BY pizza_types.category ORDER BY SUM(order_details.quantity) DESC

-- 2.

SELECT count(order_id),hour(time) FROM orders
GROUP BY hour(time)
category
-- 3.

SELECT DISTINCT(category) FROM pizza_types

-- 4.

SELECT AVG(qnt) FROM
(SELECT orders.date,SUM(order_details.quantity) AS qnt
FROM orders JOIN order_details
ON orders.order_id=order_details.order_id
GROUP BY orders.date) AS order_quantity

-- 5.

SELECT SUM(pizzas.price*order_details.quantity),pizza_types.name FROM pizzas
JOIN order_details ON pizzas.pizza_id=order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id
GROUP BY pizza_types.name ORDER BY SUM(pizzas.price*order_details.quantity) DESC LIMIT 3


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
-- Analyze the cumulative revenue generated over time.
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

-- 1.

SELECT ROUND((SUM(pizzas.price*order_details.quantity)/(SELECT SUM(price*quantity) FROM pizzas JOIN order_details ON pizzas.pizza_id=order_details.pizza_id)),2)*100,pizza_types.category FROM pizzas
JOIN order_details ON pizzas.pizza_id=order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id
GROUP BY pizza_types.category ORDER BY SUM(pizzas.price*order_details.quantity) DESC

-- 2.

SELECT date,SUM(revenue) OVER(ORDER BY date) AS cum_revenue
FROM
(SELECT orders.date,SUM(order_details.quantity*pizzas.price) AS revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id=pizzas.pizza_id
JOIN  orders
ON orders.order_id=order_details.order_id
GROUP BY orders.date) AS sales

-- 3.
SELECT name,revenue FROM
(SELECT category,name,revenue,RANK() OVER(PARTITION BY category order by revenue DESC) AS rn
FROM
(SELECT pizza_types.category,pizza_types.name,
SUM((order_details.quantity)*pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS a) AS b
WHERE rn<=3;
