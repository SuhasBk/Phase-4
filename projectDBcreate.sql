-- Tables creation:
CREATE TABLE S24_S003_T7_PERSON (
    PID NUMBER(15),
    FName VARCHAR2(100),
    LName VARCHAR2(100),
    Email VARCHAR2(100),
    DOB DATE,
    Region VARCHAR2(100),
    Password VARCHAR2(255),
	PRIMARY KEY(PID)
);

CREATE TABLE S24_S003_T7_PERSON_PHONE (
    PID NUMBER(15),
    Phone NUMBER(15),
	PRIMARY KEY(PID, Phone)
);

CREATE TABLE S24_S003_T7_USER (
    UPID NUMBER(15),
    Following NUMBER(15) CHECK (Following >= 0),
	Timestamp TIMESTAMP,
	PRIMARY KEY(UPID),
	FOREIGN KEY (UPID)
		REFERENCES S24_S003_T7_PERSON(PID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_ARTIST (
    APID NUMBER(15),
    Followers NUMBER(15) CHECK (Followers >= 0),
	PRIMARY KEY(APID),
	FOREIGN KEY (APID)
		REFERENCES S24_S003_T7_PERSON(PID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_GENRE (
    GID NUMBER(15),
    Name VARCHAR2(100),
	PRIMARY KEY(GID)
);

CREATE TABLE S24_S003_T7_ADVERTISER (
    AdvertiserID NUMBER(15),
	Name VARCHAR2(100),
    Revenue NUMBER(15) CHECK (Revenue >= 0),
	PRIMARY KEY(AdvertiserID)
);

CREATE TABLE S24_S003_T7_PODCAST (
    PodcastID NUMBER(15),
    Subscribers NUMBER(15) CHECK (Subscribers >= 0),
	Name VARCHAR2(100),
	Timestamp TIMESTAMP,
	APID NUMBER(15),
	GID NUMBER(15),
	PRIMARY KEY(PodcastID),
	FOREIGN KEY(APID)
		REFERENCES S24_S003_T7_ARTIST(APID) ON DELETE CASCADE,
	FOREIGN KEY(GID)
		REFERENCES S24_S003_T7_GENRE(GID) ON DELETE SET NULL
);

CREATE TABLE S24_S003_T7_EPISODE (
    EpisodeID NUMBER(15),
	PodcastID NUMBER(15),
    Podcast_format VARCHAR2(50),
	Link VARCHAR2(100),
	Timestamp TIMESTAMP,
	Views NUMBER(15) CHECK (Views >= 0),
	Likes NUMBER(15) CHECK (Likes >= 0),
	Dislikes NUMBER(15) CHECK (Dislikes >= 0),
	Duration NUMBER(15) CHECK (Duration >= 0),
	APID NUMBER(15),
	PRIMARY KEY(EpisodeID, PodcastID),
	FOREIGN KEY(APID)
		REFERENCES S24_S003_T7_ARTIST(APID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_ADS (
    AdID NUMBER(15),
	AdvertiserID NUMBER(15),
	Link VARCHAR2(100),
	Duration NUMBER(15) CHECK (Duration >= 0),
	GID NUMBER(15),
	PRIMARY KEY(AdID, AdvertiserID),
	FOREIGN KEY(GID)
		REFERENCES S24_S003_T7_GENRE(GID) ON DELETE SET NULL
);

CREATE TABLE S24_S003_T7_LISTENS_TO (
    UPID NUMBER(15),
	EID NUMBER(15),
	PodcastID NUMBER(15),
	Start_time NUMBER(15),	
	End_time NUMBER(15),
	Date TIMESTAMP,
	PRIMARY KEY(UPID, EID, PodcastID),
	FOREIGN KEY(UPID)
		REFERENCES S24_S003_T7_USER(UPID) ON DELETE SET NULL,
	FOREIGN KEY(EID)
		REFERENCES S24_S003_T7_EPISODE(EID) ON DELETE SET NULL,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_PODCAST(PodcastID) ON DELETE SET NULL,

	CONSTRAINT EPISODE_DURATION_CONSTRAINT CHECK (NOT EXISTS(
		select * from S24_S003_T7_LISTENS_TO l, S24_S003_T7_EPISODE e
		where e.EID = l.EID and e.PodcastID = l.PodcastID
		and l.End_time > e.Duration or l.Start_time < 0
	))
);

CREATE TABLE S24_S003_T7_SUBSCRIBES_TO (
    UPID NUMBER(15),
	PodcastID NUMBER(15),
	PRIMARY KEY(UPID, PodcastID),
	FOREIGN KEY(UPID)
		REFERENCES S24_S003_T7_USER(UPID) ON DELETE CASCADE,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_PODCAST(PodcastID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_DISPLAYS (
    EID NUMBER(15),
	PodcastID NUMBER(15),
	AdID NUMBER(15),
	AdvertiserID NUMBER(15),
	PRIMARY KEY(EID, PodcastID, AdId, AdvertiserID),
	FOREIGN KEY(EID)
		REFERENCES S24_S003_T7_EPISODE(EID) ON DELETE SET NULL,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_PODCAST(PodcastID) ON DELETE SET NULL,
	FOREIGN KEY(AdID)
		REFERENCES S24_S003_T7_ADS(AdID) ON DELETE CASCADE,
	FOREIGN KEY(AdvertiserID)
		REFERENCES S24_S003_T7_ADS(AdvertiserID) ON DELETE CASCADE
);


-- Indexes:
CREATE INDEX PERSON_LOGIN_IDX ON S24_S003_T7_PERSON (Email, Password);

CREATE INDEX GENRE_NAME_IDX ON S24_S003_T7_GENRE (Name);

CREATE INDEX EPISODE_LINK_IDX ON S24_S003_T7_EPISODE (Link);

CREATE INDEX ADS_LINK_IDX ON S24_S003_T7_ADS (Link);

CREATE INDEX LISTENS_TO_DURATION_IDX ON S24_S003_T7_LISTENS_TO (Start_time, End_time);

-- Triggers:
CREATE OR REPLACE TRIGGER check_podcast_format
BEFORE INSERT OR UPDATE ON S24_S003_T7_EPISODE
FOR EACH ROW
BEGIN
    IF UPPER(:NEW.Podcast_format) NOT IN ('AUDIO', 'VIDEO') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Podcast format must be either ''Audio'' or ''Video''.');
    END IF;
END;
/

