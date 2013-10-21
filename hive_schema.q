-- Creates customer table and loads data into it
DROP TABLE IF EXISTS customer;
CREATE TABLE customer
(
 cid int,
 name string,
 gender string,
 age int,
 rdate timestamp,
 country string,
 friend_count int,
 lifetime int
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/tmp/analytics_customer0.data' INTO TABLE customer;

-- Creates revenue table and loads data into it
DROP TABLE IF EXISTS revenue;
CREATE TABLE revenue
(
 cid int,
 pdate timestamp,
 usd float
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/tmp/analytics_revenue0.data' INTO TABLE revenue;

-- Creates gaming_fact table and loads data into it
DROP TABLE IF EXISTS gaming_fact;
CREATE TABLE gaming_fact
(
 cid int,
 game_name string,
 gdate timestamp
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/tmp/analytics_facts0.data' INTO TABLE gaming_fact;
