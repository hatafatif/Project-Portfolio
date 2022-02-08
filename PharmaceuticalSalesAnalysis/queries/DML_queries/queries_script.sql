/*

This is a dataset of transactional data of a Pharmacy, shared on Kaggle by the user: Milan Zdravković
Link >> https://www.kaggle.com/milanzdravkovic/pharma-sales-data

In this Dataset, we have records available from 2 Jan 2014 to 8 Oct 2019. We are going to perform basic analysis about this Sales data to gather useful insights. We are going to perform some basic filtering with the data. 
We will then connect this MySQL Database with PowerBI to visualize the data. That PowerBI file is also present inside the main project directory. 

NOTE: Some DDL adjustments were made to this table, queries for which are present in "DDL_queries" folder. Make sure to run that script before running this one. 
*/

/*

We have 4 tables: hourly, daily, weekly and monthly data. We can obtain the following information from these data:
    
    1. Hourly Data:
    -	Closing and Opening hours
	-	Trends in Hours to differentiate rush hours.
    -	Data of the previous day, split by Hours (for dashboarding purposes)
	
	2. Daily Data:
    -	Average Daily Sales Volume
    -	Weekdays vs Weekends
	-	Identifying Trends on Holidays (or pre-holiday)
    -	Data for the previous week, split by Days (for dashboarding purposes)
	
    3. Weekly Data:
    -	Checking to see if there is a trend in different weeks of a month.
    -	Data for the previous month, split by Weeks (for dashboarding purposes)
    
    4. Monthly Data:
    -	Monthly Comparison
	-	Access Growth
    -	Data of the previous 3 months, split by Months (for dashboarding purposes)
    
	NOTE: I am assuming the pharmacy is a retailer, and so the sales volume is directly proportional to the number of customers. 
    If there is a single customer placing huge orders, the results of this analysis might be a little inaccurate.
    
*/




/*
	1:  Hourly Data
*/
SELECT *
FROM saleshourly
LIMIT 5;


-- Closing and Opening hours of Pharmacy:
SELECT Hour, AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sale
FROM saleshourly
GROUP BY Hour
HAVING Avg_Total_Sale <> 0 
ORDER BY Hour;
-- Result: Pharmacy starts getting customers from 7 AM till 12 AM.


-- Busiest Hours vs Non-busiest hours.
SELECT Hour, AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sale
FROM saleshourly
GROUP BY Hour
HAVING Avg_Total_Sale <> 0
ORDER BY Avg_Total_Sale DESC;
-- Result: The busiest hour is 7 PM to 9 PM window is the busiest for the pharmacy. 


-- Dashboard data for the previous 24 hours
CREATE VIEW Past_Day AS 
SELECT Hour, M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06 as Total_Sales
FROM saleshourly
WHERE date(date_time) = "2018-04-01" 
-- For real-time updating Database, we would use the line below. For demostration purposes, the line used has a fixed date.
-- WHERE day(date_time) = CURDATE() 
ORDER BY date_time DESC
LIMIT 24;
-- This data can be used by PowerBI to quickly look at the sales volume in the current day.




/* 
	2: Daily Data
*/
SELECT *, date(date_time)
FROM salesdaily;



-- Average Daily Sales Volume
SELECT AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sales
FROM salesdaily;
-- GROUP BY year(date_time);
-- Result: In total, we can expect to have a Sale Volume of 60.53 per day. Uncommenting the last line shows that the results are fairly consistent every year.


-- Weekdays vs Weekends
SELECT `Weekday Name`, AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sales
FROM salesdaily
GROUP BY `Weekday Name`
ORDER BY Avg_Total_Sales DESC;
-- Result: Weekends are 6.64% busier than average in terms of sales volume, with saturday in particular being the busiest by a siginificant margin.


-- Identifying Trends on Holidays
SET @new_year = "01/01";
SET @christmas ="25/12";
SET @halloween = "31/10";
SET @independence = "04/07";
SET @valentines = "14/02";
SET @other = "00/00";


SELECT year(date_time), @new_year, AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sales
FROM salesdaily
WHERE date_format(date_time, '%d/%m') = @new_year
GROUP BY year(date_time);
-- Result: We saw previously that the average per day is 60.35. Now, we can safely assume that some holidays contribute more to the Sales Volume.


-- Data for the previous 7 days (for dashboarding purposes)
CREATE VIEW `Past_Week` AS 
SELECT date(date_time), weekday(date_time) as `Week Day`, M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06 as Total_Sales
FROM salesdaily
WHERE date(date_time) BETWEEN date_sub('2018-04-01', INTERVAL 6 DAY) AND '2018-04-01'
-- For real-time updating Database, we would use the function "CURDATE()" instead of a fixed date in the above line.
ORDER BY date_time DESC;
-- This data can be used by PowerBI to quickly look at the sales volume in the past 7 days.

-- DROP VIEW Past_Week;  


/* 
	3: Weekly Data
*/
SELECT *
FROM salesweekly
LIMIT 5;


-- Checking to see if there is a trend in different weeks of a month.
SELECT date(date_time) as 'Week_Date', weekofyear(date_time) as WeekOfYear,  AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sales
FROM salesweekly
GROUP BY weekofyear(date_time);


-- Data for the previous month, split by Weeks (for dashboarding purposes)
CREATE VIEW `Past_Month` AS 
SELECT date(date_time) as Sunday, M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06 as Total_Sales
FROM salesweekly
WHERE date(date_time) BETWEEN date_sub('2018-04-01', INTERVAL 4 WEEK) AND '2018-04-01'
-- For real-time updating Database, we would use the function "CURDATE()" instead of a fixed date in the above line.
ORDER BY date_time DESC;




/* 
	3: Monthly Data
*/
SELECT *
FROM salesweekly
LIMIT 5;


-- Monthly Comparison
SELECT month(date_time) as Month, AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sales
FROM salesmonthly
GROUP BY month(date_time)
ORDER BY Avg_Total_Sales DESC;
-- Result: The last quarter of the year is the busiest quarter by far.


-- Access Growth
SELECT year(date_time) as Year, month(date_time) as Month, AVG(M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06) as Avg_Total_Sales
FROM salesmonthly
GROUP BY year(date_time);
-- Result:  The year 2019 is only recorded till October, so the results for 2019 are not complete. The rest, we can see that the Sales 
-- 			Volumns is fairly constant. The year 2017 however has unusually low sales, which can be dived into deeper for analysis.


-- Data of the previous 3 months, split by Months (for dashboarding purposes)
CREATE VIEW `Past_Quarter` AS 
SELECT month(date_time) as Month, M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06 as Total_Sales
FROM salesmonthly
WHERE date(date_time) BETWEEN date_sub('2018-04-01', INTERVAL 3 MONTH) AND '2018-04-01'
-- For real-time updating Database, we would use the function "CURDATE()" instead of a fixed date in the above line.
ORDER BY date_time DESC;




















