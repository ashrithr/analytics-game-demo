-- group the revenue table by cid

-- DROP TABLE IF EXISTS grp_revenue;
-- CREATE TABLE grp_revenue
-- (
-- 	cid int,
-- 	min_rev_date timestamp,
-- 	max_rev_date timestamp,
-- 	usd float
-- );

-- INSERT OVERWRITE TABLE 	grp_revenue
-- SELECT cid, min(pdate) as min_rev_date,
-- max(pdate) as max_rev_date,
-- sum(usd) as usd
-- FROM revenue r
-- WHERE usd > 0
-- GROUP BY cid;

-- group the gaming table by cid

DROP TABLE IF EXISTS grp_gaming;
CREATE TABLE grp_gaming
(
	cid int,
	min_played_date timestamp,
	max_played_date timestamp,
	city_played int,
	pictionary_played int,
	scramble_played int,
	sniper_played int,
	num_played int
);

INSERT OVERWRITE TABLE 	grp_gaming
SELECT cid,
min(gdate) as min_played_date,
max(gdate) as max_played_date,
SUM(if(game_name = 'city',1,0)) as city_played,
SUM(if(game_name = 'pictionary',1,0)) as pictionary_played,
SUM(if(game_name = 'scramble',1,0)) as scramble_played,
SUM(if(game_name = 'sniper',1,0)) as sniper_played,
count(1) as num_played
FROM gaming_fact g
GROUP BY cid;


--generate final table
DROP TABLE IF EXISTS datafile_table;
CREATE TABLE datafile_table
(
	gender string,
	age int,
	country string,
	friend_count int,
	lifetime int,
	city_played int,
	pictionary_played int,
	scramble_played int,
	sniper_played int,
	paid string
);

INSERT OVERWRITE TABLE 	datafile_table
SELECT c.gender, c.age, c.country, c.friend_count,
-- DATEDIFF(max_played_date,min_played_date) as lifetime, --  '99999' as lifetime,
  c.lifetime,
	if(city_played is null, 0, city_played) as city_played,
	if(pictionary_played is null, 0, pictionary_played) as pictionary_played,
	if(scramble_played is null, 0, scramble_played) as scramble_played,
	if(sniper_played is null, 0, sniper_played) as sniper_played,
	if(r.cid is null, 'non_payer','payer') as paid

FROM customer c
LEFT OUTER JOIN revenue r on (r.cid=c.cid)
LEFT OUTER JOIN grp_gaming g on (g.cid=c.cid)
;
