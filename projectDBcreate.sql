CREATE TABLE S24_S003_T7_Person (
    PID NUMBER(15),
    FName VARCHAR2(100),
    LName VARCHAR2(100),
    Email VARCHAR2(100),
    DOB DATE,
    Region VARCHAR2(100),
    Password VARCHAR2(255),
	primary key(PID)
);

CREATE TABLE S24_S003_T7_Person_phone (
    PID NUMBER(15),
    Phone NUMBER(15),
	primary key(PID, Phone)
);

CREATE TABLE S24_S003_T7_User (
    UPID NUMBER(15),
    Following NUMBER(15),
	Timestamp TIMESTAMP,
	primary key(UPID)
);

CREATE TABLE S24_S003_T7_Artist (
    APID NUMBER(15),
    Followers NUMBER(15),
	primary key(APID)
);

CREATE TABLE S24_S003_T7_Genre (
    GID NUMBER(15),
    Name VARCHAR2(100),
	primary key(GID)
);

CREATE TABLE S24_S003_T7_Advertiser (
    AdvertiserID NUMBER(15),
	Name VARCHAR2(100),
    Revenue NUMBER(15),
	primary key(AdvertiserID)
);

CREATE TABLE S24_S003_T7_Podcast (
    PodcastID NUMBER(15),
    Subscribers NUMBER(15),
	Name VARCHAR2(100),
	Timestamp TIMESTAMP,
	APID NUMBER(15),
	GID NUMBER(15),
	primary key(PodcastID),
	FOREIGN KEY(APID)
		REFERENCES S24_S003_T7_Artist(APID) ON DELETE CASCADE,
	FOREIGN KEY(GID)
		REFERENCES S24_S003_T7_Genre(GID)
);

CREATE TABLE S24_S003_T7_Episode (
    EpisodeID NUMBER(15),
	PodcastID NUMBER(15),
    Podcast_format VARCHAR2(50),
	Link VARCHAR2(100),
	Timestamp TIMESTAMP,
	Views NUMBER(15),
	Likes NUMBER(15),
	Dislikes NUMBER(15),
	Duration INT,	
	APID NUMBER(15),
	primary key(EpisodeID, PodcastID),
	FOREIGN KEY(APID)
		REFERENCES S24_S003_T7_Artist(APID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_Ads (
    AdID NUMBER(15),
	AdvertiserID NUMBER(15),
	Link VARCHAR2(100),
	Duration VARCHAR2(50),	
	GID NUMBER(15),
	primary key(AdID, AdvertiserID),
	FOREIGN KEY(GID)
		REFERENCES S24_S003_T7_Genre(GID)
);

CREATE TABLE S24_S003_T7_Listen_To (
    UPID NUMBER(15),
	EID NUMBER(15),
	PodcastID NUMBER(15),
	Start_time NUMBER(15),	
	End_time NUMBER(15),
	Date TIMESTAMP,
	primary key(UPID, EID, PodcastID),
	FOREIGN KEY(UPID)
		REFERENCES S24_S003_T7_User(UPID) ON DELETE SET NULL,
	FOREIGN KEY(EID)
		REFERENCES S24_S003_T7_Episode(EID) ON DELETE SET NULL,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_Podcast(PodcastID) ON DELETE SET NULL
);

CREATE TABLE S24_S003_T7_Subscribes_To (
    UPID NUMBER(15),
	PodcastID NUMBER(15),
	primary key(UPID, PodcastID),
	FOREIGN KEY(UPID)
		REFERENCES S24_S003_T7_User(UPID) ON DELETE CASCADE,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_Podcast(PodcastID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_Displays (
    EID NUMBER(15),
	PodcastID NUMBER(15),
	AdID NUMBER(15),
	AdvertiserID NUMBER(15),
	primary key(EID, PodcastID, AdId, AdvertiserID),
	FOREIGN KEY(EID)
		REFERENCES S24_S003_T7_Episode(EID) ON DELETE SET NULL,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_Podcast(PodcastID) ON DELETE SET NULL,
	FOREIGN KEY(AdID)
		REFERENCES S24_S003_T7_Ads(AdID) ON DELETE CASCADE,
	FOREIGN KEY(AdvertiserID)
		REFERENCES S24_S003_T7_Advertiser(AdvertiserID) ON DELETE CASCADE
);



