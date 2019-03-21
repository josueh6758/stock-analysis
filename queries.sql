-- SELECT * FROM fundamentals LIMIT 10;
-- SELECT * FROM securities LIMIT 5;
-- SELECT * FROM prices LIMIT 5;
DROP TABLE IF EXISTS good_performers CASCADE;
DROP TABLE IF EXISTS yearly_return CASCADE;


--assign a temp table to just filter out and add row_num
CREATE TEMP TABLE year_row AS(
	SELECT 
		EXTRACT(year FROM date) AS year,date,
	       	ROW_NUMBER() OVER (
			PARTITION BY EXTRACT(year FROM date)
			ORDER BY date DESC 
		) AS row_num
	       	
	FROM prices
);

--DEBUG THE TABLE ABOVE
--SELECT * FROM year_row LIMIT 10;

CREATE TEMP TABLE year_ends AS(
	SELECT 
	year, date
	FROM year_row 
	WHERE row_num = 1
);
--DEBUG ABOVE TABLE 
--SELECT * FROM year_ends LIMIT 10;

--create a new price table i-joined w/ yr,end and produce pct_return
/*
the following mess is the result of getting the last years closing price 
but partition is key or else lead/lag will get anthr symbols price ruining the data
price innerjoined to yr_end to filter data. Other opt is use IN subquery 
*/
CREATE TABLE yearly_return AS(
SELECT 
	symbol, EXTRACT(year FROM a.date) AS year, TRUNC(close::NUMERIC,2) AS close, 
	TRUNC(  (LEAD(close) OVER (
		PARTITION BY symbol
       		ORDER BY a.date DESC))::NUMERIC,2) AS prv_year_close,
	TRUNC( (((close/LEAD(close) OVER (PARTITION BY symbol ORDER BY a.date DESC))-1.0)*100)::NUMERIC ,2) AS return_pct

	FROM prices a 
		INNER JOIN year_ends b
			ON a.date = b.date
	ORDER BY symbol, year DESC
);
--DISPLAY THE TABLE ABOVE 
SELECT * FROM yearly_return LIMIT 100;



--MY TOP 30 will be companies whose average return pct is btw 10-30 & more than 5 years trading

CREATE TABLE good_performers AS(
	SELECT 
	symbol, TRUNC( (AVG(return_pct))::NUMERIC, 2) as avg_return
	FROM yearly_return 
	GROUP BY symbol 
	HAVING count(*)>5 AND AVG(return_pct) BETWEEN 10.00 AND 30.00
	ORDER BY avg_return DESC
	LIMIT 60
	OFFSET 5
);
--DISPLAY THE TABLE ABOVE;
SELECT * FROM good_performers ORDER BY symbol;



\echo 'hello world
world'
