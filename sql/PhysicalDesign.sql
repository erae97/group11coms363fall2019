-- Q1
ALTER TABLE `cs363teamproject`.`tweets` 
ADD INDEX `q1_index` (`retweet_count` ASC, `tweet_text` ASC, `tweeted_by` ASC) VISIBLE;
;

-- Q3 & Q15 & Q18 & Q23
ALTER TABLE `cs363teamproject`.`tweets` 
ADD INDEX `q3_q15_q18_q23_id_screen` (`id` ASC, `created_at` ASC, `tweeted_by` ASC) VISIBLE;
;

-- Q6 & Q11
ALTER TABLE `cs363teamproject`.`hashtags` 
ADD INDEX `q6_q11_hash_index` (`name` ASC) VISIBLE;
;

-- Q9
ALTER TABLE `cs363teamproject`.`useraccounts` 
ADD INDEX `q9_index_users` (`sub_category` ASC) VISIBLE;
;

-- Q10
ALTER TABLE `cs363teamproject`.`useraccounts` 
ADD INDEX `q10_user_state` (`state` ASC) VISIBLE;