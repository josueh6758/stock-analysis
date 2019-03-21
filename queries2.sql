\pset footer off
DROP TABLE IF EXISTS good_fundamentals;
DROP TABLE IF EXISTS refined_investment;

CREATE TABLE good_fundamentals AS (
		SELECT
		a.*,(a.total_asset-a.total_liabilites) AS networth,b.avg_return
		FROM fundamentals a
			INNER JOIN good_performers b
			ON a.symbol = b.symbol
	);

\echo '\nnetworth growth over the years'
--networth growth over the years
CREATE TEMP TABLE networth_pct AS(
SELECT 
symbol, year, networth,
	LEAD(networth) OVER (
		PARTITION BY symbol
		ORDER BY year DESC) as prv_yr_networth,
	TRUNC( (((networth::float/LEAD(networth) OVER (PARTITION BY symbol ORDER BY year DESC))-1.0)*100)::NUMERIC, 2) AS networth_growth
FROM good_fundamentals
ORDER BY symbol,year DESC
);
SELECT * FROM networth_pct LIMIT 10;
SELECT STDDEV(networth_growth) AS SD, AVG(networth_growth) FROM networth_pct;


\echo 'income growth over the years'
--net income growth over the years
CREATE TEMP TABLE income_pct AS(
SELECT
symbol, year, net_income,
        LEAD(net_income) OVER (
                PARTITION BY symbol
                ORDER BY year DESC) as prv_yr_income,
        TRUNC( (((net_income::float/LEAD(net_income) OVER (PARTITION BY symbol ORDER BY year DESC))-1.0)*100)::NUMERIC, 2) AS income_growth
FROM good_fundamentals
ORDER BY symbol,year DESC
);
SELECT * FROM income_pct LIMIT 10;
SELECT STDDEV(income_growth) AS SD, AVG(income_growth) FROM income_pct;


\echo 'revenue growth over the years'
--REVENUE GROWTH
CREATE TEMP TABLE revenue_pct AS(
SELECT
symbol, year, total_revenue,
        LEAD(total_revenue) OVER (
                PARTITION BY symbol
                ORDER BY year DESC) as prv_yr_revenue,
        TRUNC( (((total_revenue::float/LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC))-1.0)*100)::NUMERIC, 2) AS revenue_growth
FROM good_fundamentals
ORDER BY symbol,year DESC
);
SELECT * FROM revenue_pct LIMIT 10;
SELECT STDDEV(revenue_growth) AS SD, AVG(revenue_growth) FROM revenue_pct;



\echo 'earnings-per-share growth'
--EPS GROWTH
CREATE TEMP TABLE eps_pct AS(
SELECT
symbol, year, earnings_per_share,
        LEAD(earnings_per_share) OVER (
                PARTITION BY symbol
                ORDER BY year DESC) as prv_yr_EPS,
        TRUNC( (((earnings_per_share::float/LEAD(earnings_per_share) OVER (PARTITION BY symbol ORDER BY year DESC))-1.0)*100)::NUMERIC, 2) AS EPS_growth
FROM good_fundamentals
ORDER BY symbol,year DESC
);
SELECT * FROM eps_pct LIMIT 10;
SELECT STDDEV(EPS_growth) AS SD, AVG(EPS_growth) FROM eps_pct;



--add prices to my good fundamentals table
CREATE TEMP TABLE pe AS(
SELECT
	a.symbol,a.year,b.close AS price, a.earnings_per_share,(b.close/a.earnings_per_share) AS pe_ratio
	from good_fundamentals a
	INNER JOIN prices b
		ON a.symbol = b.symbol AND a.year_ending = b.date
	ORDER BY symbol,a.year DESC
);

\echo 'price earning growth %'
--pe_growth
CREATE TEMP TABLE pe_pct AS(
SELECT
symbol, year, pe_ratio,
        LEAD(pe_ratio) OVER (
                PARTITION BY symbol
                ORDER BY year DESC) as prv_yr_pe_ratio,
        TRUNC( (((pe_ratio::float/LEAD(pe_ratio) OVER (PARTITION BY symbol ORDER BY year DESC))-1.0)*100)::NUMERIC, 2) AS pe_growth
FROM pe
ORDER BY symbol,year DESC
);
SELECT * FROM pe_pct LIMIT 10;
SELECT STDDEV(pe_growth) AS SD, AVG(pe_growth) FROM pe_pct;


\echo 'liquid cash / liabilities'
--cash equivalent
CREATE TEMP TABLE cash_n_liabilities AS(
SELECT 
symbol, year, cash_equivalent, total_liabilites, (cash_equivalent::FLOAT/total_liabilites)*100 AS cash_to_liability_ratio
FROM good_fundamentals
ORDER BY symbol,year DESC
);
SELECT * FROM cash_n_liabilities LIMIT 10;
SELECT STDDEV(cash_to_liability_ratio) AS SD, AVG(cash_to_liability_ratio) FROM cash_n_liabilities;

/*
 i've chosen revenue growth as the way i will further filter my results as the best stocks since the standard deviation and the mean value are not drastically different 
 which i see as something that the succesfull companies have in common. One thing i think may affect my results in a negative way is that perhaps i should've averaged the 
 percentages of each symbol and then run the aggregate functions. 
 */

CREATE TEMP TABLE refined_setup  AS(
SELECT
symbol, year, total_revenue,
        LEAD(total_revenue) OVER (
                PARTITION BY symbol
                ORDER BY year DESC) as prv_yr_revenue,
        TRUNC( (((total_revenue::float/LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC))-1.0)*100)::NUMERIC, 2) AS revenue_growth
FROM fundamentals
WHERE year='2016' OR year='2015'
ORDER BY symbol,year DESC
);

CREATE TABLE refined_investment AS(
SELECT symbol, revenue_growth FROM refined_setup
WHERE revenue_growth BETWEEN 5.00 AND 30.00

LIMIT 30
);


SELECT
	a.symbol, b.sector,b.sub_industry, a.revenue_growth
FROM refined_investment a
	INNER JOIN securities b
	ON a.symbol = b.symbol
ORDER BY  b.sector,b.sub_industry DESC
;


/*
 top 10
SBUX
NKE
STZ
BDX
CAH
CTAS
FDX
INTU
AMAT
WRK
 
 */

-----------HW 6 IS BELOW-----------------------------------------------


CREATE TEMP VIEW view_investment AS(

SELECT 
	symbol, date, close
FROM prices
WHERE symbol IN ('SBUX','NKE','STZ','BDX','CAH','CTAS','FDX','INTU','AMAT','WRK') AND date=(
	SELECT date 
	FROM prices 
	WHERE symbol = 'SBUX'
	ORDER BY DATE DESC
	LIMIT 1)

);

SELECT 
	symbol, date, close
FROM prices
WHERE symbol IN ('SBUX','NKE','STZ','BDX','CAH','CTAS','FDX','INTU','AMAT','WRK') AND date=(
	SELECT date 
	FROM prices 
	WHERE symbol = 'SBUX'
	ORDER BY DATE DESC
	LIMIT 1)
