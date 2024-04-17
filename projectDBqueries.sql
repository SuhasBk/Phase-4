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