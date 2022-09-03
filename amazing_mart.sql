#1 Which order was the most profitable in Italy, January 2012? Who made the purchase?
SELECT
l.order_id,
customer_name,
country,
sum(profit) profit
FROM am.listoforders l
  JOIN am.orderbreakdwon o ON l.order_id = o.order_id
WHERE order_date BETWEEN '2012-01-01' AND '2012-01-28'
AND country = 'Italy'
GROUP BY customer_name, country, l.order_id
ORDER BY profit DESC


#2 Of the products sold, which category is the most profitable? Which subcategory within this category is the most profitable?
SELECT
  category,
  sub_category, 
  sum(profit) as profit
FROM `coursera-project-358501.am.orderbreakdwon`
GROUP BY ROLLUP (category, sub_category)
ORDER BY category, profit DESC

#3 Which product generated the most total sales in 2014, and what was the average profit on this product?
SELECT 
  product_name,
  sum(quantity) total_quantity,
  sales*sum(quantity) as total_sales,
  avg(profit) profit
FROM
  am.orderbreakdwon o
  JOIN am.listoforders l on l.order_id = o.order_id
WHERE order_date BETWEEN '2014-01-01' and '2014-12-31'
GROUP BY product_name, sales
ORDER BY total_sales DESC

#4 In which country are the highest sales, and what is the average discount on products there?
SELECT
  category,
  sub_category, 
  sum(profit) as profit
FROM `coursera-project-358501.am.orderbreakdwon`
GROUP BY ROLLUP (category, sub_category)
ORDER BY category, profit DESC

#5 How do sales of products compare to target sales?
SELECT
  order_date,
  sum(sales) sales,
  sum(s.target) target
FROM am.listoforders l
  JOIN am.orderbreakdwon o ON l.order_id = o.order_id
  LEFT JOIN am.salestargets2 s ON l.order_date = s.Month_of_Order_Date
GROUP BY ROLLUP (order_date)
ORDER BY order_date

#6 Which ship mode was the most profitable in 2011?
SELECT 
  l.ship_mode,
  sum(o.profit) profit
FROM am.listoforders l
  JOIN am.orderbreakdwon o ON o.order_id = l.order_id
WHERE order_date BETWEEN '2011-01-01' and '2011-12-31'
GROUP BY l.Ship_Mode
ORDER BY profit

#7 Which product is has the highest discount and what is the profit on this product?
 In which city is this product sold?
 SELECT 
  product_name,
  discount,
  profit,
  city
FROM
  am.orderbreakdwon o
  JOIN am.listoforders l on l.order_id = o.order_id
ORDER BY discount DESC

#8 Which customers have ordered the most product and where did they purchase? 
How much in sales can be attributed to these customers?
SELECT 
  customer_name,
  city,
  COUNT(l.order_id) orders,
  sum(sales) sales,
FROM
  am.orderbreakdwon o
  JOIN am.listoforders l on l.order_id = o.order_id
GROUP BY customer_name, city
ORDER BY orders DESC

#9 Which month and year did the customer have to wait the longest for their order to arrive?
SELECT 
  EXTRACT(month from ship_date) month,
  EXTRACT (year from ship_date) year,
  ROUND(AVG(DATE_DIFF(ship_date, order_date, day)),1) as days_to_ship
FROM am.listoforders
GROUP BY month, year
ORDER BY days_to_ship DESC

#10 How were regions performing compared to each other in 2014?
WITH sales_cte AS (SELECT SUM(sales) sales_by_region,
region
FROM am.orderbreakdwon o
JOIN am.listoforders l on o.order_id = l.Order_ID
WHERE order_date BETWEEN '2014-01-01' AND '2014-12-31'                   
GROUP BY region
)
SELECT
AVG(sales_by_region) avage_total_sales,
region
FROM sales_cte
GROUP BY ROLLUP(region)
