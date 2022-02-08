/*

This is a dataset of transactional data, shared on Kaggle by the user: Milan Zdravković
Link >> https://www.kaggle.com/milanzdravkovic/pharma-sales-data

In this Dataset, we have data available from Feb 2014 to Aug 2019. We are going to perform basic analysis about the Sales data to gather useful insights.

*/

/*
	Some adjustments were made to this table, queries of which are present in a seperate file.
*/

-- 1: Trend in Sales in the Weekdays
SELECT *, `Weekday Name`, AVG(ROUND((M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06))) as Total_Sale
FROM salesdaily
GROUP BY `Weekday Name`
ORDER BY Total_Sale DESC;
-- Since the dataset is huge, we can safely assume that Saturdays are the most active days, followed by Sundays. Also to note that Thursdays are lower than average for some reason.

-- 2: Looking at Sale Volume for every year. Keep in mind that 2019 is not yet complete. 
SELECT year(datum), AVG(ROUND((M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06))) as Total_Sale
FROM salesmonthly
GROUP BY year(datum);
-- There are abnormally less sales in the year 2017. We will do a deeper dive into the 2017 year in a visualization software to figure out the reason why.

-- 3: Most Popular and Least Popular category for Drugs
SELECT year(datum), SUM(M01AB), SUM(M01AE), SUM(N02BA), SUM(N02BE), SUM(N05B), SUM(N05C), SUM(R03), SUM(R06)
FROM salesmonthly
GROUP BY year(datum);
-- N02BE is contributing by far the most to our sales volume.

-- 4: Checking Active Hours and their patterns
SELECT year(date_time), Hour, AVG(M01AB), AVG(M01AE), AVG(N02BA), AVG(N02BE), AVG(N05B), AVG(N05C), AVG(R03), AVG(R06), AVG((M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06)) as Total_Sale
FROM saleshourly
GROUP BY Hour, year(date_time)
ORDER BY year, hour;
-- This information is all over the place, and it needs to be visualized to be properly understood.

-- 5: Trend in Months
SELECT year(datum), month(datum), AVG((M01AB + M01AE + N02BA + N02BE + N05B + N05C + R03 + R06)) as Total_Sale
FROM salesmonthly
GROUP BY year(datum), month(datum);
-- As seen in the second query, the sales in January of 2017 are abnormally low. 




























