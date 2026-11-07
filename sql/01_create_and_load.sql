-- 01_create_and_load.sql
-- Loads Online Retail II (UCI) CSVs into MySQL

SET GLOBAL local_infile = 1;

CREATE DATABASE IF NOT EXISTS retail_db;

DROP TABLE IF EXISTS retail_db.retail_raw;
CREATE TABLE retail_db.retail_raw (
    invoice      VARCHAR(20),
    stock_code   VARCHAR(20),
    description  VARCHAR(255),
    quantity     INT,
    invoice_date DATETIME,
    price        DECIMAL(10,3),
    customer_id  VARCHAR(20),
    country      VARCHAR(50)
);

-- Sheet 1: 2009-2010 (525,461 rows)
LOAD DATA LOCAL INFILE 'E:/projects/retail_2009.csv'
INTO TABLE retail_db.retail_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(invoice, stock_code, @descr, quantity, @inv_date, price, @cust, country)
SET description  = TRIM(@descr),
    invoice_date = STR_TO_DATE(@inv_date, '%d-%m-%Y %H:%i'),
    customer_id  = NULLIF(TRIM(@cust), '');

-- Sheet 2: 2010-2011
LOAD DATA LOCAL INFILE 'E:/projects/retail_2010.csv'
INTO TABLE retail_db.retail_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(invoice, stock_code, @descr, quantity, @inv_date, price, @cust, country)
SET description  = TRIM(@descr),
    invoice_date = STR_TO_DATE(@inv_date, '%d-%m-%Y %H:%i'),
    customer_id  = NULLIF(TRIM(@cust), '');