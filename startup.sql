BEGIN;

DROP TABLE IF EXISTS fundamentals CASCADE;

DROP TABLE IF EXISTS prices CASCADE;

DROP TABLE IF EXISTS securities CASCADE;


CREATE TABLE fundamentals (
	id integer,
	symbol text,
	year_ending date,
	cash_equivalent bigint,
	earnings_before_int_tax BIGINT,
	gross_margin BIGINT,
	net_income BIGINT,
	total_asset BIGINT,
	total_liabilites BIGINT,
	total_revenue BIGINT,
	year text,
	earnings_per_share FLOAT,
	shares_outstanding FLOAT
);

CREATE TABLE prices(
	date date,
	symbol text,
	open float,
	close float,
	low float,
	high float,
	volume integer
); 

CREATE TABLE securities(
	symbol text,
	company text,
	sector text,
	sub_industry text,
	initial_date date	
);

\COPY fundamentals FROM './data/fundamentals.csv' WITH(FORMAT csv);
\COPY prices FROM './data/prices.csv' WITH(FORMAT csv);
\COPY securities FROM './data/securities.csv' WITH(FORMAT csv);



ALTER TABLE ONLY fundamentals
	ADD CONSTRAINT fundamentals_pkey PRIMARY KEY(id);

ALTER TABLE ONLY prices 
	ADD CONSTRAINT prices_pkey PRIMARY KEY(date,symbol);

ALTER TABLE ONLY securities
	ADD CONSTRAINT securities_pkey PRIMARY KEY(symbol);

ALTER TABLE ONLY fundamentals 
	ADD CONSTRAINT fundamentals_symbol_fkey FOREIGN KEY(symbol)
       	REFERENCES securities(symbol);

ALTER TABLE ONLY prices
	ADD CONSTRAINT prices_symbol_fkey FOREIGN KEY(symbol)
	REFERENCES securities(symbol);

COMMIT;
ANALYZE fundamentals;
ANALYZE prices;
ANALYZE securities;

