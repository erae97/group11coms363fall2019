USE cs363teamproject;

-- Q1

-- List k most retweeted tweets in a given month and a given year;
-- show the retweet count, the tweet text, the posting user’s screen name, the posting user’s category, the posting user’s sub-category
-- in descending order of the retweet count values 
-- Input: Value of k (e.g., 10), month (e.g., 1), and year (e.g., 2016)
-- Rationale: This query finds k most influential tweets in a given time frame and the users who posted them

PREPARE q1prep FROM
	'SELECT t.retweet_count, t.tweet_text, u.screen_name, u.category, u.sub_category
	FROM tweets t 
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE YEAR(t.created_at) = ?
		AND MONTH(t.created_at) = ?
	ORDER BY t.retweet_count DESC
	LIMIT ?;';

SET @q1year = 2016;
SET @q1month = 1;
SET @q1k = 5;

EXECUTE q1prep USING @q1year,@q1month,@q1k;


-- Q3

-- Find k hashtags that appeared in the most number of states in a given year;
-- list the total number of states the hashtag appeared,
-- the list of the distinct states it appeared (FL is the same as Florida*),
-- and the hashtag itself in descending order of the number of states the hashtag appeared.
-- Input:  Value of k and year (e.g., 2016)
-- Rationale: This query finds k hashtags that are used across the most number of states,
-- which could indicate a certain agenda (e.g., education, healthcare) that is widely discussed.

PREPARE q3prep FROM
	'SELECT COUNT(DISTINCT u.state), GROUP_CONCAT(DISTINCT u.state), hh.name
	FROM hashashtag hh
		INNER JOIN tweets t ON hh.id = t.id
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE YEAR(t.created_at) = ?
		AND u.state != "na"
	GROUP BY hh.name
	ORDER BY COUNT(DISTINCT u.state) DESC
	LIMIT ?;';

SET @q3year = 2016;
SET @q3k = 5;

EXECUTE q3prep USING @q3year,@q3k;


-- Q6

-- Find k users who used at least one of the hashtags in a given list of hashtags in their tweets.
-- Show the user’s screen name and the state the user lives in descending order of the number of this user’s followers.
-- Input: Value of k and list of hashtags (e.g., [GOPDebate, DemDebate]) 
-- Rationale: This is to find k users with similar interests.

PREPARE q6prep FROM
	'SELECT DISTINCT u.screen_name, u.state
	FROM hashashtag hh
		INNER JOIN tweets t ON hh.id = t.id
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE FIND_IN_SET(hh.name, ?)
	ORDER BY u.followers DESC
	LIMIT ?;';

SET @q6list = 'GOPDebate,DemDebate';
SET @q6k = 5;

EXECUTE q6prep USING @q6list,@q6k;


-- Q9

-- Find top kmost followed users in a given party.
-- Show the user’s screen name, the user’s party, and the number of followers in descending order of the number of followers.
-- Input:  Value of category (e.g., 'GOP', 'Democrat') 
-- Rationale: This query finds the most influential users measured by the number of followers.

PREPARE q9prep FROM
	'SELECT DISTINCT u.screen_name, u.sub_category, u.followers
	FROM hashashtag hh
		INNER JOIN tweets t ON hh.id = t.id
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE u.sub_category = ?
	ORDER BY u.followers DESC
	LIMIT ?;';

SET @q9party = 'GOP';
SET @q9k = 5;

EXECUTE q9prep USING @q9party,@q9k;


-- Q10

-- Find the list of distinct hashtags that appeared in one of the states in a given list in a given month of a given year;
-- show the list of the hashtags and the names of the states in which they appeared.
-- Input: list of states, (e.g., [Ohio, Alaska, Alabama]), month, year
-- Rationale: This is to find common interests among the users in the states of interest.

PREPARE q10prep FROM
	'SELECT DISTINCT hh.name, u.state
	FROM hashashtag hh
		INNER JOIN tweets t ON hh.id = t.id
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE FIND_IN_SET(u.state, ?)
		AND YEAR(t.created_at) = ?
		AND MONTH(t.created_at) = ?;';

SET @q10list = 'Colorado,FL';
SET @q10year = 2016;
SET @q10month = 1;

EXECUTE q10prep USING @q10list,@q10year,@q10month;


-- Q11

-- Find k tweets (with the given hashtag)
-- posted by republican (GOP) or democrat members of a given state in a given month of a given year.
-- Show the tweet text, the hashtag, the screen name of the posting user, and the users’ party
-- Input:  Values of k, state (e.g., Ohio), month, year, hashtag
-- Rationale: This query explores the context in which the hashtag was used

PREPARE q11prep FROM
	'SELECT t.tweet_text, hh.name, u.screen_name, u.sub_category
	FROM hashashtag hh
		INNER JOIN tweets t ON hh.id = t.id
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE hh.name = ?
		AND u.state = ?
        AND (u.sub_category = "GOP" OR u.sub_category = "democrat")
		AND YEAR(t.created_at) = ?
		AND MONTH(t.created_at) = ?
	ORDER BY t.retweet_count DESC
	LIMIT ?;';

SET @q11hashtag = 'Ohio';
SET @q11state = 'Ohio';
SET @q11year = 2016;
SET @q11month = 1;
SET @q11k = 5;

EXECUTE q11prep USING @q11hashtag,@q11state,@q11year,@q11month,@q11k;


-- Q15

-- Find users in a given sub-category along with the list of URLs used in the user’s tweets in a given month of a given year.
-- Show the user’s screen name, the state the user lives, and the list of URLs
-- Input: Values of a sub-category (e.g.,  ' GOP'), month, year
-- Rationale: This  query finds  URLs shared by a party.

PREPARE q15prep FROM
	'SELECT u.screen_name, u.state, GROUP_CONCAT(DISTINCT hu.address)
	FROM HasURLs hu
		INNER JOIN tweets t ON hu.id = t.id
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE u.sub_category = ?
		AND YEAR(t.created_at) = ?
		AND MONTH(t.created_at) = ?
	GROUP BY u.screen_name;';
	
SET @q15list = 'GOP';
SET @q15year = 2016;
SET @q15month = 1;

EXECUTE q15prep USING @q15list,@q15year,@q15month;


-- Q18

-- Find k users who were mentioned the most in tweets of users of a given party in a given month of a given year.
-- Show the user’s screen name, user’s state, and the list of the screen name of the user(s) who mentioned this user
-- in descending order of the number of tweets mentioning this user.
-- Input: Values of k, sub-category (e.g., 'GOP'), month, year.

PREPARE q18prep FROM
	'SELECT u.screen_name, u.state, GROUP_CONCAT(DISTINCT op.screen_name)
	FROM Mention m
		INNER JOIN useraccounts u ON m.screen_name = u.screen_name
		INNER JOIN tweets t ON m.id = t.id
        INNER JOIN useraccounts op ON t.tweeted_by = op.screen_name
	WHERE op.sub_category = ?
		AND YEAR(t.created_at) = ?
		AND MONTH(t.created_at) = ?
	GROUP BY m.screen_name
    ORDER BY COUNT(m.id) DESC
    LIMIT ?;';

SET @q18party = 'GOP';
SET @q18year = 2016;
SET @q18month = 1;
SET @q18k = 5;

EXECUTE q18prep USING @q18party,@q18year,@q18month,@q18k;


-- Q23

-- Find k most used hashtags with the count of tweets it appeared posted by a given sub-category of users in a list of months.
-- Show the hashtag name and the count in descending order of the count.
-- Input:Values of k, sub-category (e.g.,  'GOP'), a list of months (e.g., [1, 2, 3]), year=2016 

PREPARE q23prep FROM
	'SELECT hh.name, COUNT(DISTINCT t.id)
	FROM HasHashtag hh
		INNER JOIN tweets t ON hh.id = t.id
		INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name
	WHERE u.sub_category = ?
		AND YEAR(t.created_at) = ?
        AND FIND_IN_SET(MONTH(t.created_at), ?)
	GROUP BY hh.name
    ORDER BY COUNT(t.id) DESC
    LIMIT ?;';
	
SET @q23party = 'GOP';
SET @q23year = 2016;
SET @q23list = '1,2,3';
SET @q23k = 5;

EXECUTE q23prep USING @q23party,@q23year,@q23list,@q23k;