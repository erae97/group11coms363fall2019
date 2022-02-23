//Emily Young

//Q1
MATCH (u:User)-[:POSTED]-(t:Tweet)-[:HAS_TWEET]-(:Day)-[:HAS_DAY]-(m:Month {month: '1'})-[:HAS_MONTH]-(:Year {year: '2016'})
WITH t, u, max(toInt(t.retweet_count)) as retweet_count 
RETURN retweet_count, t.text, u.screen_name, u.category, u.sub_category 
ORDER BY retweet_count DESC LIMIT 5

//Q3 not working
MATCH (u:User)-[:POSTED]-(t:Tweet)-[:HAS_TWEET]-(:Day)-[:HAS_DAY]-(m:Month)-[:HAS_MONTH]-(:Year {year: '2016'})
WITH COUNT(DISTINCT u.location) AS numStates, collect(DISTINCT u.location) as stateList
MATCH (h:Hashtag)-[:TAGGED]-(t:Tweet)-[:POSTED]-(u:User {sub_category: 'GOP'})
WHERE h.name <>""
WITH h,numStates, stateList, max(toInt(numStates)) as numstates
RETURN numstates, stateList, h.name as hashtag
ORDER BY numstates DESC LIMIT 5

//Q6
MATCH (u:User)-[:POSTED]-(t:Tweet)-[:TAGGED]-(h:Hashtag)
WHERE h.name = "GOPDebate" OR h.name = "DemDebate"
WITH u, max(toInt(u.followers)) as fol
RETURN u.screen_name, u.location as state
ORDER BY fol  DESC LIMIT 5

//Q9
MATCH (u:User {sub_category: "GOP"})-[:POSTED]-(t:Tweet)
WITH u, max(toInt(u.followers)) as fol
RETURN u.screen_name, u.sub_category, fol
ORDER BY fol  DESC LIMIT 5

MATCH (u:User {sub_category: "democrat"})-[:POSTED]-(t:Tweet)
WITH u, max(toInt(u.followers)) as fol
RETURN u.screen_name, fol
ORDER BY fol  DESC LIMIT 5

//Q10
MATCH (u:User)-[:POSTED]-(t:Tweet)-[:HAS_TWEET]-(:Day)-[:HAS_DAY]-(m:Month {month: '1'})-[:HAS_MONTH]-(:Year {year: '2016'})
WHERE u.location = "Ohio" OR u.location = "Alaska" OR u.location = "Alabama"
WITH u
MATCH (u:User)-[:POSTED]-(t:Tweet)-[:TAGGED]-(h:Hashtag)
WHERE h.name <> ""
WITH toUpper(h.name) as hashtag, u.location as state
RETURN DISTINCT hashtag, state
ORDER BY state DESC

//Q11
MATCH (u:User {location: "Ohio"})-[:POSTED]-(t:Tweet)-[:HAS_TWEET]-(:Day)-[:HAS_DAY]-(m:Month {month: '1'})-[:HAS_MONTH]-(:Year {year: '2016'})
WITH u, t
MATCH (u:User)-[:POSTED]-(t:Tweet)-[:TAGGED]-(h:Hashtag {name: "Ohio"})
RETURN t.text, h.name, u.screen_name, u.sub_category

//Q15
MATCH (u:User {sub_category: "GOP"})-[:POSTED]-(t:Tweet)-[:HAS_TWEET]-(:Day)-[:HAS_DAY]-(m:Month {month: '1'})-[:HAS_MONTH]-(:Year {year: '2016'}) 
WITH u, t
MATCH (t:Tweet)-[:URL_USED]-(r:Url)
WHERE r.url <> ""
RETURN DISTINCT u.screen_name, u.location, r.url

//Q18
MATCH (t:Tweet)-[:HAS_TWEET]-(:Day)-[:HAS_DAY]-(m:Month {month: '1'})-[:HAS_MONTH]-(:Year {year: '2016'})
WITH  t
MATCH (u:User)<-[:MENTIONED]-(t:Tweet)<-[:POSTED]-(u2:User {sub_category: 'GOP'})
WITH u, count(u2.screen_name) as count, collect (DISTINCT u2.screen_name) as mentioningUsers
WHERE u.screen_name <>""
RETURN u.screen_name as mentionedUser, u.location as stateOfMentionedUser, mentioningUsers  ORDER BY count DESC LIMIT 5

//Q23 not working
MATCH (u:User)-[:POSTED]-(t:Tweet)-[:HAS_TWEET]-(:Day)-[:HAS_DAY]-(m:Month {month: '1'})-[:HAS_MONTH]-(:Year {year: '2016'})
WITH t,u
MATCH (h:Hashtag)-[:TAGGED]-(t:Tweet)<-[:POSTED]-(u:User {sub_category: 'GOP'})
WHERE h.name <>""
WITH h, t, u, count(t.id) as numTweets
RETURN h.name, numTweets
ORDER BY numTweets DESC limit 5
