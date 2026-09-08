-- =========================================================
-- Q-1: What are the total number of orders, customers,
-- products, and order items in the dataset?
-- =========================================================

select
	count(distinct Order_Id) as total_orders,
	count(distinct Customer_Id) as total_customers,
	count(distinct Product_Card_Id) as total_products,
	count(*) as total_order_items
from supply_chain_cleaned;

------------------------------------------------------------
-- Answer: 65,752 orders, 20,652 customers, 
-- 118 products, and 180,519 order items.
------------------------------------------------------------

-- =========================================================
-- Q-2: What are the total sales, total profit, average sales
-- per order item, and average profit per order item?
-- =========================================================

select
	sum(Sales) as total_sales,
	sum(Order_Profit_Per_Order) as total_profit,
	avg(Sales) as average_sales_per_order_item,
    avg(Order_Profit_Per_Order) as average_profit_per_order_item    
from Supply_Chain_Cleaned;

------------------------------------------------------------
-- Answer: Total sales = 36,784,735.01; 
-- total profit = 3,966,902.97; 
-- average sales per order item = 203.77; 
-- average profit per order item = 21.97. 
------------------------------------------------------------

-- =========================================================
-- Q-3: How have total sales changed from year to year?
-- =========================================================

select
	year(Order_Date_DateOrders) as order_year,
	sum(Sales) as total_sales
from Supply_Chain_Cleaned
group by year(Order_Date_DateOrders)
order by order_year;

------------------------------------------------------------
-- Answer: Sales declined from 12.34M (2015) to 12.30M (2016),
-- 11.81M (2017), and 0.33M (2018).
------------------------------------------------------------

-- =========================================================
-- Q-4: How has total profit changed from year to year?
-- =========================================================

select
	year(Order_Date_DateOrders) as order_year,
	sum(Order_Profit_Per_Order) as total_profit
from Supply_Chain_Cleaned
group by year(Order_Date_DateOrders)
order by order_year;

------------------------------------------------------------
-- Answer: Profit declined from 1.32M (2015) to 1.31M (2016),
-- 1.30M (2017), and 33,841.89 (2018).
------------------------------------------------------------

-- =========================================================
-- Q-5: Which markets generate the highest sales and profit?
-- =========================================================

select
	Market,
	sum(Sales) as total_sales,
	sum(Order_Profit_Per_Order) as total_profit
from Supply_Chain_Cleaned
group by Market
order by total_sales desc;

------------------------------------------------------------
-- Answer: Europe has the highest sales and profit; 
-- Africa has the lowest.
------------------------------------------------------------

-- =========================================================
-- Q-6: Which countries generate the highest sales?
-- =========================================================

select
	Order_Country,
	sum(Sales) as total_sales
from Supply_Chain_Cleaned
group by Order_Country
order by total_sales desc;

------------------------------------------------------------
-- Answer: The United States has the highest sales 
-- at 4,879,667.67, followed by France and Mexico.
------------------------------------------------------------

-- =========================================================
-- Q-7: Which 10 products generate the highest total sales?
-- =========================================================

select top 10
	Product_Name,
	sum(Sales) as total_sales
from Supply_Chain_Cleaned
group by Product_Name
order by total_sales desc;

------------------------------------------------------------
-- Answer: Field & Stream Sportsman 16 Gun Fire Safe has 
-- the highest sales at 6,929,653.69.
------------------------------------------------------------

-- =========================================================
-- Q-8: Which 10 products generate the highest total profit?
-- =========================================================

select top 10
	Product_Name,
	sum(Order_Profit_Per_Order) as total_profit
from Supply_Chain_Cleaned
group by Product_Name
order by total_profit desc;

------------------------------------------------------------
-- Answer: Field & Stream Sportsman 16 Gun Fire Safe has
-- the highest profit at 756,220.77.
------------------------------------------------------------

-- =========================================================
-- Q-9: Which product categories generate
-- the highest sales and profit?
-- =========================================================

select
	Category_Name,
	sum(Sales) as total_sales,
	sum(Order_Profit_Per_Order) as total_profit
from Supply_Chain_Cleaned
group by Category_Name
order by total_sales desc;

------------------------------------------------------------
-- Answer: Fishing has the highest sales and profit, 
-- followed by Cleats and Camping & Hiking.
------------------------------------------------------------

-- =========================================================
-- Q-10: Which customer segment generates
-- the highest sales and profit?
-- =========================================================

select
	customer_segment,
	sum(Sales) as total_sales,
	sum(Order_Profit_Per_Order) as total_profit
from Supply_Chain_Cleaned
group by Customer_Segment
order by total_sales desc;

------------------------------------------------------------
-- Answer: Consumer has the highest sales (19,095,790.16) 
-- and profit (2,073,487.67).
------------------------------------------------------------

-- =========================================================
-- Q-11: Who are the top 10 customers based on total sales?
-- =========================================================

select top 10
	Customer_Id,
	sum(Sales) as total_sales
from Supply_Chain_Cleaned
group by Customer_Id
order by total_sales desc;

------------------------------------------------------------
-- Answer: Customer 791 is the top customer with total sales 
-- of 10,524.17.
------------------------------------------------------------

-- =========================================================
-- Q-12: What is the distribution of orders across 
-- different order statuses?
-- =========================================================

select
	Order_Status,
	count(distinct Order_Id) as total_orders
from Supply_Chain_Cleaned
group by Order_Status
order by total_orders desc;

------------------------------------------------------------
-- Answer: COMPLETE has the most orders (21,716),
-- while PAYMENT_REVIEW has the fewest (704).
------------------------------------------------------------

-- =========================================================
-- Q-13: What percentage of orders are delivered on time, 
-- late, or in advance?
-- =========================================================

with DeliveryCounts as
(
    select
        Delivery_Status,
        count(distinct Order_Id) as Total_Orders
    from Supply_Chain_Cleaned
    group by Delivery_Status
)
select
    Delivery_Status,
    Total_Orders,
    round(
        Total_Orders * 100.0 /
        (select sum(Total_Orders) from DeliveryCounts),
        2
    ) as Percentage_of_Orders
from DeliveryCounts
order by Percentage_of_Orders desc;

------------------------------------------------------------
-- Answer: Late delivery = 54.82%, advance shipping = 23.01%,
-- on time = 17.83%, and canceled = 4.34%.
------------------------------------------------------------

-- =========================================================
-- Q-14: How many orders are at a risk of late delivery, 
-- and what percentage of total orders do they represent?
-- =========================================================

SELECT
    COUNT(DISTINCT CASE
        WHEN Late_delivery_risk = 1 THEN Order_Id
    END) AS Orders_At_Risk,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN Late_delivery_risk = 1 THEN Order_Id
        END) * 100.0 /
        COUNT(DISTINCT Order_Id),
        2
    ) AS Percentage_of_Total_Orders
FROM Supply_Chain_Cleaned;

------------------------------------------------------------
-- Answer: 36,048 orders are at risk of late delivery,
-- representing 54.82% of total orders.
------------------------------------------------------------

-- =========================================================
-- Q-15: Which shipping modes are most frequently used, and 
-- how do they compare in terms of sales and delivery performance?
-- =========================================================

with ShippingModeData as
(
    select
        Shipping_Mode,
        Order_Id,
        Sales,
        Days_for_shipping_real,
        Days_for_shipment_scheduled,
        Late_delivery_risk
    from Supply_Chain_Cleaned
)
select
    Shipping_Mode,
    count(distinct Order_Id) as Total_Orders,
    sum(Sales) as Total_Sales,
    round(avg(cast(Days_for_shipping_real as float)), 2) as Avg_Actual_Shipping_Days,
    round(avg(cast(Days_for_shipment_scheduled as float)), 2) as Avg_Scheduled_Shipping_Days,
    round(
        count(distinct case
            when Late_delivery_risk = 1 then Order_Id
        end) * 100.0 /
        count(distinct Order_Id),
        2
    ) as Late_Risk_Percentage
from ShippingModeData
group by Shipping_Mode
order by Total_Orders desc;

------------------------------------------------------------
-- Answer: Standard Class is most used and generates 
-- the highest sales. First Class has the highest late-risk (95.27%), while Standard Class
-- has the lowest late-risk (38.13%).
------------------------------------------------------------

-- =========================================================
-- Q-16: How does actual shipping time compare with 
-- scheduled shipping time across different shipping modes?
-- =========================================================

select
    Shipping_Mode,
    round(avg(cast(Days_for_shipping_real as float)), 2) as Avg_Actual_Shipping_Days,
    round(avg(cast(Days_for_shipment_scheduled as float)), 2) as Avg_Scheduled_Shipping_Days,
    round(
        avg(cast(Days_for_shipping_real as float)) -
        avg(cast(Days_for_shipment_scheduled as float)),
        2
    ) as Difference_in_Days
from Supply_Chain_Cleaned
group by Shipping_Mode
order by Difference_in_Days desc;

------------------------------------------------------------
-- Answer: Second Class has the largest gap (1.99 days); 
-- Standard Class matches its schedule.
------------------------------------------------------------

-- =========================================================
-- Q-17: Which payment types are most commonly used, and 
-- how much sales do they generate?
-- =========================================================

select
    type as Payment_Type,
    count(distinct Order_Id) as Total_Orders,
    sum(Sales) as Total_Sales
from Supply_Chain_Cleaned
group by type
order by Total_Orders desc;

------------------------------------------------------------
-- Answer: DEBIT is most commonly used (25,340 orders)
-- and generates the highest sales (14,076,857.66).
------------------------------------------------------------

-- =========================================================
-- Q-18: How does the discount rate affect sales and profit?
-- =========================================================

select
    round(Order_Item_Discount_Rate, 2) as Discount_Rate,
    sum(Sales) as Total_Sales,
    sum(Order_Profit_Per_Order) as Total_Profit
from Supply_Chain_Cleaned
group by round(Order_Item_Discount_Rate, 2)
order by Discount_Rate;

------------------------------------------------------------
-- Answer: Higher discount rates generally reduce profit,
-- while sales remain relatively stable.
------------------------------------------------------------