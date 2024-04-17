-- Tables creation:
CREATE TABLE S24_S003_T7_PERSON (
    PID NUMBER,
    FName VARCHAR2(100),
    LName VARCHAR2(100),
    Email VARCHAR2(100) NOT NULL,
    DOB DATE,
    Region VARCHAR2(100),
    Password VARCHAR2(255) NOT NULL,
	CONSTRAINT PERSON_PK PRIMARY KEY(PID) ENABLE
);

CREATE TABLE S24_S003_T7_PERSON_PHONE (
    PID NUMBER,
    Phone NUMBER(10),
	CONSTRAINT PERSON_PHONE_PK PRIMARY KEY(PID, Phone) ENABLE,
	FOREIGN KEY (PID)
		REFERENCES S24_S003_T7_PERSON(PID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_USER (
    UPID NUMBER,
    Following NUMBER(15) CHECK (Following >= 0),
	Timestamp TIMESTAMP,
	CONSTRAINT USER_PK PRIMARY KEY(UPID) ENABLE,
	FOREIGN KEY (UPID)
		REFERENCES S24_S003_T7_PERSON(PID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_ARTIST (
    APID NUMBER,
    Followers NUMBER(15) CHECK (Followers >= 0),
	CONSTRAINT ARTIST_PK PRIMARY KEY(APID) ENABLE,
	FOREIGN KEY (APID)
		REFERENCES S24_S003_T7_PERSON(PID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_GENRE (
    GID NUMBER,
    Name VARCHAR2(100) NOT NULL,
	CONSTRAINT GENRE_PK PRIMARY KEY(GID)
);

CREATE TABLE S24_S003_T7_ADVERTISER (
    AdvertiserID NUMBER,
	Name VARCHAR2(100),
    Revenue NUMBER(15) CHECK (Revenue >= 0),
	CONSTRAINT ADVERTISER_PK PRIMARY KEY(AdvertiserID) ENABLE
);

CREATE TABLE S24_S003_T7_PODCAST (
    PodcastID NUMBER,
    Subscribers NUMBER(15) CHECK (Subscribers >= 0),
	Name VARCHAR2(100) NOT NULL,
	Timestamp TIMESTAMP,
	APID NUMBER(15),
	GID NUMBER(15),
	UNIQUE (Name),
	CONSTRAINT PODCAST_PK PRIMARY KEY(PodcastID) ENABLE,
	FOREIGN KEY(APID)
		REFERENCES S24_S003_T7_ARTIST(APID) ON DELETE CASCADE,
	FOREIGN KEY(GID)
		REFERENCES S24_S003_T7_GENRE(GID) ON DELETE SET NULL
);

CREATE TABLE S24_S003_T7_EPISODE (
    EpisodeID NUMBER,
	PodcastID NUMBER,
    Episode_format VARCHAR2(50),
	Link VARCHAR2(100) NOT NULL,
	Timestamp TIMESTAMP,
	Views NUMBER(15) CHECK (Views >= 0),
	Likes NUMBER(15) CHECK (Likes >= 0),
	Dislikes NUMBER(15) CHECK (Dislikes >= 0),
	Duration NUMBER(15) CHECK (Duration >= 0),
	APID NUMBER(15),
	CONSTRAINT EPISODE_PK PRIMARY KEY(EpisodeID, PodcastID) ENABLE,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_PODCAST(PodcastID) ON DELETE CASCADE,
	FOREIGN KEY(APID)
		REFERENCES S24_S003_T7_ARTIST(APID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_ADS (
    AdID NUMBER,
	AdvertiserID NUMBER,
	Link VARCHAR2(100) NOT NULL,
	Duration NUMBER(15) CHECK (Duration >= 0),
	GID NUMBER(15),
	CONSTRAINT ADS_PK PRIMARY KEY(AdID, AdvertiserID) ENABLE,
	FOREIGN KEY(AdvertiserID)
		REFERENCES S24_S003_T7_ADVERTISER(AdvertiserID) ON DELETE CASCADE,
	FOREIGN KEY(GID)
		REFERENCES S24_S003_T7_GENRE(GID) ON DELETE SET NULL
);

CREATE TABLE S24_S003_T7_LISTENS_TO (
    UPID NUMBER,
	EpisodeID NUMBER,
	PodcastID NUMBER,
	Start_time NUMBER,	
	End_time NUMBER,
	Last_Listened_Date TIMESTAMP,
	CONSTRAINT LISTENS_TO_PK PRIMARY KEY(UPID, EpisodeID, PodcastID) ENABLE,
	FOREIGN KEY(UPID)
		REFERENCES S24_S003_T7_USER(UPID) ON DELETE SET NULL,
	FOREIGN KEY(EpisodeID, PodcastID)
		REFERENCES S24_S003_T7_EPISODE(EpisodeID, PodcastID) ON DELETE SET NULL
);

CREATE TABLE S24_S003_T7_SUBSCRIBES_TO (
    UPID NUMBER,
	PodcastID NUMBER,
	CONSTRAINT SUBSCRIBES_TO_PK PRIMARY KEY(UPID, PodcastID) ENABLE,
	FOREIGN KEY(UPID)
		REFERENCES S24_S003_T7_USER(UPID) ON DELETE CASCADE,
	FOREIGN KEY(PodcastID)
		REFERENCES S24_S003_T7_PODCAST(PodcastID) ON DELETE CASCADE
);

CREATE TABLE S24_S003_T7_DISPLAYS (
    EpisodeID NUMBER,
	PodcastID NUMBER,
	AdID NUMBER,
	AdvertiserID NUMBER,
	CONSTRAINT DISPLAYS_PK PRIMARY KEY(EpisodeID, PodcastID, AdId, AdvertiserID) ENABLE,
	FOREIGN KEY(EpisodeID, PodcastID)
		REFERENCES S24_S003_T7_EPISODE(EpisodeID, PodcastID) ON DELETE SET NULL,
	FOREIGN KEY(AdID, AdvertiserID)
		REFERENCES S24_S003_T7_ADS(AdID, AdvertiserID) ON DELETE CASCADE
);


-- Indexes:
CREATE INDEX PERSON_LOGIN_IDX ON S24_S003_T7_PERSON (Email, Password);

CREATE INDEX GENRE_NAME_IDX ON S24_S003_T7_GENRE (Name);

CREATE INDEX EPISODE_LINK_IDX ON S24_S003_T7_EPISODE (Link);

CREATE INDEX ADS_LINK_IDX ON S24_S003_T7_ADS (Link);

CREATE INDEX LISTENS_TO_DURATION_IDX ON S24_S003_T7_LISTENS_TO (Start_time, End_time);

-- Triggers:
CREATE OR REPLACE TRIGGER check_episode_format
BEFORE INSERT OR UPDATE ON S24_S003_T7_EPISODE
FOR EACH ROW
BEGIN
    IF UPPER(:NEW.Episode_format) NOT IN ('AUDIO', 'VIDEO') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Podcast format must be either ''Audio'' or ''Video''.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER check_listen_times
BEFORE INSERT OR UPDATE ON S24_S003_T7_LISTENS_TO
FOR EACH ROW
DECLARE
    v_episode_duration INT;
BEGIN
    SELECT Duration
    INTO v_episode_duration
    FROM S24_S003_T7_EPISODE
    WHERE EpisodeID = :NEW.EpisodeID AND PodcastID = :NEW.PodcastID;

    IF :NEW.End_time > v_episode_duration OR :NEW.Start_time < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid Start_time or End_time for the episode.');
    END IF;
END;
/
