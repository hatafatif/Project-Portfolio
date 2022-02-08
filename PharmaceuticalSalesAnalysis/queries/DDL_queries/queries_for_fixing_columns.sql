set SQL_SAFE_UPDATES = 0; -- Necessary to make changes in MySQL 

-- Adding ID Columns 
ALTER TABLE saleshourly ADD COLUMN `id` int UNSIGNED PRIMARY KEY AUTO_INCREMENT FIRST; 
ALTER TABLE salesdaily ADD COLUMN `id` int UNSIGNED PRIMARY KEY AUTO_INCREMENT FIRST;
ALTER TABLE salesweekly ADD COLUMN `id` int UNSIGNED PRIMARY KEY AUTO_INCREMENT FIRST;
ALTER TABLE salesmonthly ADD COLUMN `id` int UNSIGNED PRIMARY KEY AUTO_INCREMENT FIRST;


-- Adding a new date_time column after newly added ID column
ALTER TABLE salesdaily ADD COLUMN date_time datetime AFTER id;
ALTER TABLE saleshourly ADD COLUMN date_time datetime AFTER id; 
ALTER TABLE salesweekly ADD COLUMN date_time datetime AFTER id;
-- The table salesmonthly has the date parsed in correctly, we will just rename the "datum" columns.


-- Setting the new date_time column from previous datum column

UPDATE saleshourly
SET date_time = (
	SELECT str_to_date(datum, '%m/%d/%Y %H:%i')
);

UPDATE salesdaily
SET date_time = (
	SELECT str_to_date(datum, '%m/%d/%Y')
);

UPDATE salesweekly
SET date_time = (
	SELECT str_to_date(datum, '%m/%d/%Y')
);

ALTER TABLE salesmonthly RENAME COLUMN datum TO date_time;


-- Dropping the previous datum column
ALTER TABLE saleshourly DROP datum;
ALTER TABLE salesdaily DROP datum;
ALTER TABLE salesweekly DROP datum;


-- Setting the changes back
set SQL_SAFE_UPDATES = 1;   

