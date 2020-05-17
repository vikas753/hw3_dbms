USE `lotrfinal_1`;

/* 1 Number of occurences of each character */
SELECT character_name,COUNT(*) AS num_encounters FROM lotr_character INNER JOIN lotr_first_encounter ON lotr_character.character_name = lotr_first_encounter.character1_name OR lotr_character.character_name = lotr_first_encounter.character2_name GROUP BY character_name;

/* 2 Number of regions visited by a character . Union of regions visited and encountered by characters as homeland 
     with a count of distinct regions */
SELECT character_name,COUNT(*) AS num_regions_visited FROM (SELECT character_name,region_name as region_name_table FROM lotr_character 
  LEFT OUTER JOIN lotr_first_encounter ON lotr_character.character_name = lotr_first_encounter.character1_name 
  OR lotr_character.character_name = lotr_first_encounter.character2_name 
UNION
SELECT character_name,homeland as region_name_table FROM lotr_character) AS CHAR_REGION_TABLE GROUP BY character_name ORDER BY COUNT(*) DESC;

/* 3 Charachters having hobbit as major species */
SELECT COUNT(*) AS num_regions_hobbit_major_species from lotr_region WHERE major_species = 'hobbit';

/* 4 , Region which was visited the most */
SELECT region_name , MAX(regions_visited) FROM (SELECT region_name , COUNT(*) 
  AS regions_visited FROM lotr_first_encounter GROUP BY region_name ORDER BY COUNT(*) DESC) AS REGIONS_TABLE;

/* 5 Region visited by all characters , group by regions visited by all characters and then 
     perform a sql division with character_name column.
*/
SELECT region_name FROM
(SELECT region_name , character_name FROM 
  (SELECT region_name , character_name FROM lotr_first_encounter LEFT OUTER JOIN lotr_character 
   ON lotr_character.character_name = lotr_first_encounter.character1_name 
   OR lotr_character.character_name = lotr_first_encounter.character2_name 
   GROUP BY region_name,character_name ORDER BY region_name) 
   AS REGION_CHAR_TABLE WHERE character_name IN ( SELECT character_name FROM lotr_character)) AS region_char_table GROUP BY region_name
   HAVING COUNT(*) = (SELECT COUNT(*) FROM lotr_character); 

/* 6  Create table book1encounters with first encounters and book title */
DROP TABLE IF EXISTS `book1encounters`;
CREATE TABLE book1encounters AS 
  SELECT character1_name,character2_name,lotr_first_encounter.book_id,title as title 
  FROM lotr_first_encounter INNER JOIN lotr_book WHERE lotr_first_encounter.book_id = lotr_book.book_id; 

/* 7 We would using already made table book1encounters as above to select book and title */
SELECT book_id,title FROM book1encounters 
WHERE (character1_name = 'faramir' AND character2_name = 'frodo') 
OR (character2_name = 'faramir' AND character1_name = 'frodo');

/* 8 We dont have LISTAGG not STRINGAGG support for which I would eventually use 
     region_name to order and group the records which does similar job as required */
SELECT DISTINCT middle_earth_location , character_name  
  as charachter_middle_earth_location FROM lotr_character 
  INNER JOIN lotr_region WHERE homeland = region_name ORDER BY middle_earth_location;  

/* 9 Species with maximum size */
SELECT species_name,`description`,MAX(size) FROM lotr_species;

/* 10 Number of characters that are human */
SELECT COUNT(*) as num_charachters_human FROM lotr_character WHERE species = 'human';

/* 11 Records that have human and hobbit as first encounters */
DROP TABLE IF EXISTS  `HumanHobbitFirstEncounters`;
CREATE TABLE HumanHobbitFirstEncounters AS 
SELECT character1_name,character2_name,book_id,region_name FROM 
  (SELECT character_name FROM lotr_character WHERE species = 'human') AS HUMAN_TABLE 
  INNER JOIN lotr_first_encounter 
  INNER JOIN (SELECT character_name FROM lotr_character WHERE species = 'hobbit') AS HOBBIT_TABLE 
  WHERE (character1_name = HUMAN_TABLE.character_name AND character2_name = HOBBIT_TABLE.character_name) 
  OR (character1_name = HOBBIT_TABLE.character_name AND character2_name = HUMAN_TABLE.character_name);

/* 12 Characters where homeland is gondor */
SELECT character_name FROM lotr_character WHERE homeland = 'gondor';

/* 13 Number of characters whose species is hobbit */
SELECT COUNT(*) as num_hobbit_species FROM lotr_character WHERE species = 'hobbit';

/* 14 Middle earth location that as number characters having it as a homeland */
SELECT DISTINCT middle_earth_location , COUNT(*) 
  as number_characters_each_middle_earth_location FROM lotr_character 
  INNER JOIN lotr_region WHERE homeland = region_name GROUP BY middle_earth_location 
  ORDER BY COUNT(*) DESC;  