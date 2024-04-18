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


-- 3) Get the top 3 advertisers and the total number of ads posted by them which have no more than 5 ads across all episodes and whose total revenue exceeds 5000.

SELECT adv.Name as AdvertiserName, COUNT(ad.AdID) AS TotalAds
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

SELECT artist_details.Lname || ', ' || artist_details.Fname AS ArtistName,
       user_details.Region AS UserRegion,
       P.Name AS PodcastName,
       COUNT(L.UPID) AS TotalListens,
       SUM(E.Likes) AS TotalLikes,
       SUM(E.Dislikes) AS TotalDislikes
FROM S24_S003_T7_LISTENS_TO L
JOIN S24_S003_T7_EPISODE E ON L.EpisodeID = E.EpisodeID AND L.PodcastID = E.PodcastID
JOIN S24_S003_T7_PODCAST P ON L.PodcastID = P.PodcastID
JOIN S24_S003_T7_ARTIST AR ON E.APID = AR.APID
JOIN S24_S003_T7_PERSON artist_details ON artist_details.PID = AR.APID
JOIN S24_S003_T7_PERSON user_details ON user_details.PID = L.UPID
GROUP BY ROLLUP(artist_details.Lname, artist_details.Fname, user_details.Region, P.Name)
ORDER BY artist_details.Lname, artist_details.Fname, user_details.Region, P.Name;


-- 6) Get the advertisers whose ads appear in every episode of every podcast
-- (Division operation)

select adv.* from S24_S003_T7_ADS ad, S24_S003_T7_ADVERTISER adv
where ad.AdvertiserID = adv.AdvertiserID
and (ad.adID, ad.AdvertiserID) in (
SELECT d.AdID, d.AdvertiserID
FROM S24_S003_T7_ADS d
WHERE NOT EXISTS (
    SELECT e.EpisodeID, e.PodcastID
    FROM S24_S003_T7_EPISODE e
    WHERE NOT EXISTS (
        SELECT AdID
        FROM S24_S003_T7_DISPLAYS ds
        WHERE ds.EpisodeID = e.EpisodeID
          AND ds.PodcastID = e.PodcastID
          AND ds.AdID = d.AdID
          AND ds.AdvertiserID = d.AdvertiserID
    )
));

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