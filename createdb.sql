DROP TABLE game_sales;
select * from game_sales
CREATE TABLE game_sales (
  game VARCHAR(100) PRIMARY KEY,
  platform VARCHAR(64),
  publisher VARCHAR(64),
  developer VARCHAR(64),
  games_sold NUMERIC(5, 2),
  year INT
);

DROP TABLE reviews;

CREATE TABLE reviews (
    game VARCHAR(100) PRIMARY KEY,
    critic_score NUMERIC(4, 2),   
    user_score NUMERIC(4, 2)
);
select * from reviews
DROP TABLE top_critic_years;

CREATE TABLE top_critic_years (
    year INT PRIMARY KEY,
    avg_critic_score NUMERIC(4, 2)  
);

DROP TABLE top_critic_years_more_than_four_games;

CREATE TABLE top_critic_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_critic_score NUMERIC(4, 2)  
);

DROP TABLE top_user_years_more_than_four_games;

CREATE TABLE top_user_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_user_score NUMERIC(4, 2)  
);

\copy game_sales FROM 'game_sales.csv' DELIMITER ',' CSV HEADER;
\copy reviews FROM 'game_reviews.csv' DELIMITER ',' CSV HEADER;
\copy top_critic_years FROM 'top_critic_scores.csv' DELIMITER ',' CSV HEADER;
\copy top_critic_years_more_than_four_games FROM 'top_critic_scores_more_than_four_games.csv' DELIMITER ',' CSV HEADER;
\copy top_user_years_more_than_four_games FROM 'top_user_scores_more_than_four_games.csv' DELIMITER ',' CSV HEADER;


-- Select all information for the top ten best-selling games
-- Order the results from best-selling game down to tenth best-sellin
select *
from game_sales
order by games_sold desc
limit 10

/*Wow, the best-selling video games were released between 1985 to 2017! That's quite a range;
we'll have to use data from the reviews table to gain more insight on the best years for video games.

First, it's important to explore the limitations of our database. One big shortcoming is that
there is not any reviews data for some of the games on the game_sales table. */

-- Join games_sales and reviews
-- Select a count of the number of games where both critic_score and user_score are null
select count(g.game)
from game_sales g
left join reviews r
ON g.game = r.game
where critic_score is null and user_score is null

/*It looks like a little less than ten percent of the games on the game_sales table 
don't have any reviews data. That's a small enough percentage that we can continue our 
exploration, but the missing reviews data is a good thing to keep in mind as we move on to
evaluating results from more sophisticated queries.

There are lots of ways to measure the best years for video games! Let's start with what the 
critics think. */

-- Select release year and average critic score for each year, rounded and aliased
-- Join the game_sales and reviews tables
-- Group by release year
-- Order the data from highest to lowest avg_critic_score and limit to 10 results
select year, round(avg(critic_score),2) avg_critic_score
from game_sales as g
left join reviews as r
on g.game = r.game
group by year
order by avg_critic_score desc
limit 10

/* The range of great years according to critic reviews goes from 1982 until 2020: we are no closer to
finding the golden age of video games!
Hang on, though. Some of those avg_critic_score values look like suspiciously round numbers for averages.
The value for 1982 looks especially fishy. Maybe there weren't a lot of video games in our dataset that 
were released in certain years.

Let's update our query and find out whether 1982 really was such a great year for video games. */

-- Paste your query from the previous task; update it to add a count of games released in each year called num_games
-- Update the query so that it only returns years that have more than four reviewed games
select year, round(avg(critic_score),2) avg_critic_score, count(r.game) num_games
from game_sales as g
left join reviews as r
on g.game = r.game
group by year
having count(r.game) > 4
order by avg_critic_score desc
limit 10

/* That looks better! The num_games column convinces us that our new list of the critics' top games 
reflects years that had quite a few well-reviewed games rather than just one or two hits. But which years
dropped off the list due to having four or fewer reviewed games? Let's identify them so that someday we
can track down more game reviews for those years and determine whether they might rightfully be considered 
as excellent years for video game releases!

It's time to brush off your set theory skills. To get started, we've created tables with the results of our
previous two queries: */

-- Select the year and avg_critic_score for those years that dropped off the list of critic favorites 
-- Order the results from highest to lowest avg_critic_score
select year, avg_critic_score
from top_critic_years
except
select year, avg_critic_score
from top_critic_years_more_than_four_games
order by 2 desc
 
 
/* Based on our work in the task above, it looks like the early 1990s might merit consideration as the 
golden age of video games based on critic_score alone, but we'd need to gather more games and reviews 
data to do further analysis.

Let's move on to looking at the opinions of another important group of people: players! To begin,
let's create a query very similar to the one we used in Task Four, except this one will look at
user_score averages by year rather than critic_score averages. */

-- Select year, an average of user_score, and a count of games released in a given year, aliased and rounded
-- Include only years with more than four reviewed games; group data by year
-- Order data by avg_user_score, and limit to ten results
select year, round(avg(user_score),2) avg_user_score, count(r.game) num_games
from game_sales as g
left join reviews as r
on g.game = r.game
group by year
having count(r.game) > 4
order by avg_user_score desc
limit 10

/* Alright, we've got a list of the top ten years according to both critic reviews and user reviews. 
Are there any years that showed up on both tables? If so, those years would certainly be excellent ones!

Recall that we have access to the top_critic_years_more_than_four_games table, which stores the results 
of our top critic years query from Task 4: */

-- Select the year results that appear on both tables
select year
from top_critic_years_more_than_four_games
intersect
select year
from top_user_years_more_than_four_games

/* Looks like we've got three years that both users and critics agreed were in the top ten! There are 
many other ways of measuring what the best years for video games are, but let's stick with these years 
for now. We know that critics and players liked these years, but what about video game makers? Were 
sales good? Let's find out.

This time, we haven't saved the results from the previous task in a table for you. Instead, we'll use 
the query from the previous task as a subquery in this one! This is a great skill to have, as we don't
always have write permissions on the database we are querying. */

-- Select year and sum of games_sold, aliased as total_games_sold; order results by total_games_sold descending
-- Filter game_sales based on whether each year is in the list returned in the previous task
select year, sum(games_sold) total_games_sold
from game_sales
where year in (select year
from top_critic_years_more_than_four_games
intersect
select year
from top_user_years_more_than_four_games)
group by year
order by total_games_sold desc

select * from game_sales
select * from reviews
select distinct game from game_sales

select count(critic_score) as num_review, year
from game_sales
left join reviews 
using(game)
group by 2
order by 1 desc

select count(user_score) as num_users, year
from game_sales
left join reviews 
using(game)
group by 2
order by 1 desc