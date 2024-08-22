USE  pizzahut;
select * from pizzahut.pizzas;
select * from pizzahut.orders;
select * from pizzahut.pizza_type;
select * from pizzahut.order_details;

CREATE TABLE order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)
);

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_order
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales. 
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            02) AS total_sales
FROM
    order_details
        JOIN
    pizzas
WHERE
    order_details.pizza_id = pizzas.pizza_id;
-- Identify the highest-priced pizza.
SELECT 
    pizza_type.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_type
WHERE
    pizza_type.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 5;
-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details_id)
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size;
-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_type.name, sum(order_details.quantity) as quantity
FROM
    pizza_type
        JOIN
    pizzas ON pizza_type.pizza_type_id=pizzas.pizza_type_id 
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type.name
ORDER BY quantity DESC
LIMIT 5; 


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_type.category, sum(order_details.quantity) as quantity
FROM
    pizza_type
        JOIN
    pizzas ON pizza_type.pizza_type_id=pizzas.pizza_type_id 
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type.category
ORDER BY quantity DESC;
-- LIMIT 5; 

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(orders.order_id)
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_type group by category;

-- Group the orders by date and calculate the total  number of pizzas ordered per day.
SELECT 
    SUM(order_details.quantity), WEEKDAY(orders.order_date)
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY WEEKDAY(order_date)
ORDER BY WEEKDAY(order_date) ASC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        SUM(order_details.quantity) as quantity, orders.order_date
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date)as order_quantity;
    

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_type.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_type
        JOIN
    pizzas ON pizza_type.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_type.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                02) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas
                WHERE
                    order_details.pizza_id = pizzas.pizza_id)*100,
            2) AS revenue
FROM
    pizza_type
        JOIN
    pizzas ON pizza_type.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type.category
ORDER BY revenue DESC;
-- LIMIT 5;


-- Analyze the cumulative revenue generated over time.
-- e.g  normal revenueperday  cummilative revenue
--  					200  200
-- 						300  500
--  					400  900
--  					700  1600
select order_date,sum(revenue) over (order by order_date) as cum_revenue from 
(SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category , name, revenue from (select category,name,revenue,
rank() over (partition by category order by revenue desc) as rn from(SELECT 
    pizza_type.category,
    pizza_type.name,
    SUM(order_details.quantity * pizzas.price) as revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_type ON pizza_type.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_type.category , pizza_type.name) as basic) as final                              -- as we cannot use where rn <=3 in basic table , hence created another subquerry
where rn<=3;
