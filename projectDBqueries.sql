-- 1) Get the podcast ID, name, subscribers, genre and total views of podcasts belonging to the Technology genre which have at least 10000 total views.

SELECT
    p.PodcastID,
    p.Name AS PodcastName,
    p.Subscribers,
    g.Name AS GenreName,
    SUM(e.Views) AS TotalViews
FROM
    S24_S003_T7_PODCAST p
JOIN
    S24_S003_T7_EPISODE e ON p.PodcastID = e.PodcastID
JOIN
    S24_S003_T7_GENRE g ON p.GID = g.GID
WHERE
    g.Name = 'Technology'
GROUP BY
    p.PodcastID,
    p.Name,
    p.Subscribers,
    g.Name
HAVING
    SUM(e.Views) >= 10000;


-- 2) Get podcast names and genres that have at least 50 video episodes.

SELECT
    p.Name AS PodcastName,
    g.Name AS GenreName,
    COUNT(e.Episode_format) AS VideoCount
FROM
    S24_S003_T7_PODCAST p
JOIN
    S24_S003_T7_EPISODE e ON p.PodcastID = e.PodcastID
JOIN
    S24_S003_T7_GENRE g ON p.GID = g.GID
WHERE
    UPPER(e.Episode_format) LIKE '%VIDEO%'
GROUP BY
    p.Name,
    g.Name
HAVING
    COUNT(e.Episode_format) >= 50
ORDER BY VideoCount desc;


-- 3) Get the top 3 advertisers and the total number of ads posted by them which have no more than 5 ads across all episodes and whose total revenue exceeds 10000.

SELECT
    adv.Name,
    COUNT(ad.AdID) TotalAds
FROM
    S24_S003_T7_ADVERTISER adv
JOIN
    S24_S003_T7_ADS ad ON ad.AdvertiserID = adv.AdvertiserID
JOIN
    S24_S003_T7_DISPLAYS d ON d.AdID = ad.AdID AND d.AdvertiserID = adv.AdvertiserID
WHERE
    adv.revenue > 10000
GROUP BY
    adv.Name,
    adv.AdvertiserID
HAVING
    COUNT(ad.adID) <= 5
ORDER BY
    TotalAds DESC
FETCH FIRST 3 ROWS ONLY;


-- 4) Get the total number of listens across different combinations of region, podcast format and genre with subtotals and grand totals for each.

SELECT
    Region,
    Podcast_format,
    Genre,
    COUNT(*) AS ListenCount
FROM
    S24_S003_T7_LISTENS_TO L
JOIN
    S24_S003_T7_EPISODE E ON L.EpisodeID = E.EpisodeID AND L.PodcastID = E.PodcastID
JOIN
    S24_S003_T7_PODCAST P ON L.PodcastID = P.PodcastID
JOIN
    S24_S003_T7_PERSON PR ON L.UPID = PR.PID
GROUP BY
    CUBE(Region, Podcast_format, Genre);


-- 5) Get the user names, their region, podcast name, total number of listens, total likes and dislikes across artists, user region and podcasts

SELECT
    artist_details.Lname || ', ' || artist_details.Fname AS ArtistName,
    user_details.Region AS UserRegion,
    P.Name AS PodcastName,
    COUNT(L.UPID) AS TotalListens,
    SUM(E.Likes) AS TotalLikes,
    SUM(E.Dislikes) AS TotalDislikes
FROM
    S24_S003_T7_LISTENS_TO L
JOIN
    S24_S003_T7_EPISODE E ON L.EpisodeID = E.EpisodeID AND L.PodcastID = E.PodcastID
JOIN
    S24_S003_T7_PODCAST P ON L.PodcastID = P.PodcastID
JOIN
    S24_S003_T7_ARTIST AR ON E.APID = AR.APID
JOIN
    S24_S003_T7_PERSON artist_details ON artist_details.PID = AR.APID
JOIN
    S24_S003_T7_PERSON user_details ON user_details.PID = L.UPID
GROUP BY
    ROLLUP(artist_details.Lname, artist_details.Fname, user_details.Region, P.Name)
ORDER BY
    artist_details.Lname, artist_details.Fname, user_details.Region, P.Name;
