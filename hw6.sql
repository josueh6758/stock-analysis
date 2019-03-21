DROP VIEW IF EXISTS view_investment;

CREATE VIEW view_investment AS(

SELECT
        symbol, date, close
FROM prices
WHERE symbol IN ('SBUX','NKE','STZ','BDX','CAH','CTAS','FDX','INTU','AMAT','WRK') AND date=(
        SELECT date
        FROM prices
        WHERE symbol = 'SBUX'
        ORDER BY DATE DESC
        LIMIT 1)
ORDER BY symbol

);

SELECT * FROM view_investment;


\echo SYMBOL,last close of 2017, net gain 
\echo AMAT, 51.12,  0.58
\echo BDX, 214.06,  0.29
\echo CAH, 61.27,  -0.14
\echo CTAS,155.83, 0.35
\echo FDX: 249.54,  0.34
\echo INTU,157.78, 0.38
\echo NKE:    62.55,  0.23
\echo SBUX: 57.43,  0.03
\echo STZ: 228.57,  0.49
\echo WRK:  63.21,   0.25
\echo ---------------------
\echo AVG RETURN:   28%
/*
Overall with the method i used to select my stocks from the beggining i 
chose my primary stocks with the intention of seeking conservative gains 
and it paid off in the end as i was able to limit losing money on only 1 stock

 */



/*
 COMMANDS USED:
DUMP:sudo -u postgres pg_dump -U postgres -d stocks > backup.sql
EXPORT VIEW: sudo -u postgres psql -U postgres -tAF, -f script.sql> output_file.csv
 */



