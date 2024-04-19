-- 1) Get the podcast ID, name and total views of podcasts belonging to the Technology genre which have at least 150 total views across all its episodes.

SELECT p.PodcastID,
       p.Name AS PodcastName,
       SUM(e.Views) AS TotalViews
FROM S24_S003_T7_PODCAST p
JOIN S24_S003_T7_EPISODE e ON p.PodcastID = e.PodcastID
JOIN S24_S003_T7_GENRE g ON p.GID = g.GID
WHERE g.Name = 'Technology'
GROUP BY p.PodcastID, p.Name, p.Subscribers, g.Name
HAVING SUM(e.Views) >= 150;


-- 2) Get podcast names and genres that have at least 2 video episodes.

SELECT 
    p.PodcastID as Podcast_ID,
    p.Name AS PodcastName,
    g.Name AS GenreName,
    COUNT(e.Episode_format) AS VideoCount
FROM S24_S003_T7_PODCAST p
JOIN S24_S003_T7_EPISODE e ON p.PodcastID = e.PodcastID
JOIN S24_S003_T7_GENRE g ON p.GID = g.GID
WHERE e.Episode_format LIKE '%VIDEO%' or e.Episode_format LIKE '%video%'
GROUP BY p.PodcastID, p.Name, g.Name
HAVING COUNT(e.Episode_format) >= 2
ORDER BY VideoCount DESC;


-- 3) Get the top 3 advertisers and the total number of ads posted by them which have no more than 5 ads across all episodes and whose revenue exceeds 5000.

SELECT adv.AdvertiserID, adv.Name as AdvertiserName, sum(adv.revenue) as total_revenue, COUNT(ad.AdID) AS TotalAds
FROM S24_S003_T7_ADVERTISER adv
JOIN S24_S003_T7_ADS ad ON ad.AdvertiserID = adv.AdvertiserID
JOIN S24_S003_T7_DISPLAYS d ON d.AdID = ad.AdID AND d.AdvertiserID = adv.AdvertiserID
WHERE adv.revenue > 5000
GROUP BY adv.Name, adv.AdvertiserID
HAVING COUNT(ad.AdID) <= 5
ORDER BY TotalAds DESC
FETCH FIRST 3 ROWS ONLY;


-- 4) Get the total number of listens across different combinations of region, podcast format and genre with subtotals and grand totals for each.

SELECT PR.Region,
       E.Episode_format AS Podcast_format,
       G.Name AS Genre,
       COUNT(*) AS ListenCount
FROM S24_S003_T7_LISTENS_TO L
JOIN S24_S003_T7_EPISODE E ON L.EpisodeID = E.EpisodeID AND L.PodcastID = E.PodcastID
JOIN S24_S003_T7_PODCAST P ON L.PodcastID = P.PodcastID
JOIN S24_S003_T7_PERSON PR ON L.UPID = PR.PID
JOIN S24_S003_T7_GENRE G ON P.GID = G.GID
GROUP BY CUBE(PR.Region, E.Episode_format, G.Name);


-- 5) Get the user names, their region, podcast name, total number of listens, total likes and dislikes across artists, user region and podcasts

SELECT user_details.Lname,
       user_details.Region AS UserRegion,
       P.Name AS PodcastName,
       COUNT(L.UPID) AS TotalListens,
       SUM(E.Likes) AS TotalLikes,
       SUM(E.Dislikes) AS TotalDislikes
FROM S24_S003_T7_LISTENS_TO L
JOIN S24_S003_T7_EPISODE E ON L.EpisodeID = E.EpisodeID AND L.PodcastID = E.PodcastID
JOIN S24_S003_T7_PODCAST P ON L.PodcastID = P.PodcastID
JOIN S24_S003_T7_ARTIST AR ON E.APID = AR.APID
JOIN S24_S003_T7_PERSON user_details ON user_details.PID = L.UPID
GROUP BY ROLLUP(user_details.Lname, user_details.Region, P.Name)
ORDER BY user_details.Lname, user_details.Region, P.Name;


-- 6) Get the advertisers whose ads appear in every episode of every podcast
-- (Division operation)

SELECT adv.name, adv.revenue
FROM S24_S003_T7_ADVERTISER adv
WHERE NOT EXISTS (
    SELECT e.EpisodeID, e.PodcastID
    FROM S24_S003_T7_EPISODE e
    WHERE NOT EXISTS (
        SELECT 1
        FROM S24_S003_T7_DISPLAYS ds
        WHERE ds.PodcastID = e.PodcastID
          AND ds.AdvertiserID = adv.AdvertiserID
    )
);

-- 7) Within each genre, calculate the ranking of episodes based on the number of likes it has recieved.

SELECT e.EpisodeID,
       e.PodcastID,
       e.Likes,
       p.Name AS PodcastName,
       g.Name AS GenreName,
       ROW_NUMBER() OVER (PARTITION BY g.Name ORDER BY e.Likes DESC) AS episode_rank_in_genre
FROM S24_S003_T7_EPISODE e
JOIN S24_S003_T7_PODCAST p ON e.PodcastID = p.PodcastID
JOIN S24_S003_T7_GENRE g ON p.GID = g.GID;

--8) Most listened per country

SELECT p.Region AS Country, SUM(e.End_time - e.Start_time) AS TotalListenedTime
FROM S24_S003_T7_PERSON p
JOIN S24_S003_T7_LISTENS_TO e ON p.PID = e.UPID
GROUP BY p.Region
ORDER BY TotalListenedTime DESC
FETCH FIRST 5 ROWS ONLY;

--9) listened MINUTES based on the genre

WITH UserListeningDetails AS (
    SELECT
        lt.UPID AS User_ID,
        p.fname || ' ' || p.lname AS User_Name,
        g.Name AS Genre_Name,
        ROUND((SUM(lt.End_time - lt.Start_time) / 60),2) AS Total_Listening_Minutes
    FROM
        S24_S003_T7_LISTENS_TO lt
    JOIN
        S24_S003_T7_EPISODE e ON lt.EpisodeID = e.EpisodeID AND lt.PodcastID = e.PodcastID
    JOIN
        S24_S003_T7_PODCAST pc ON lt.PodcastID = pc.PodcastID
    JOIN
        S24_S003_T7_GENRE g ON pc.GID = g.GID
    JOIN
        S24_S003_T7_PERSON p ON lt.UPID = p.PID
    GROUP BY
        lt.UPID,
        p.fname || ' ' || p.lname,
        g.Name
)
SELECT
    User_ID,
    User_Name,
    Genre_Name,
    Total_Listening_Minutes,
    RANK() OVER (PARTITION BY User_ID ORDER BY Total_Listening_Minutes DESC) AS Listening_Minutes_Rank
FROM
    UserListeningDetails
ORDER BY
    User_ID,
    Listening_Minutes_Rank;

--10) Most listened days of the week

SELECT
    TO_CHAR(Last_Listened_Date, 'DAY') AS Weekday,
    COUNT(*) AS Listen_Count
FROM
    S24_S003_T7_LISTENS_TO
GROUP BY
    TO_CHAR(Last_Listened_Date, 'DAY')
ORDER BY LISTEN_COUNT DESC;