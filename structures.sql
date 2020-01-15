SET SQLBLANKLINES ON
ALTER TABLE BIKES 
DROP CONSTRAINT BIKES_FK;

ALTER TABLE HIRES 
DROP CONSTRAINT HIRES_BIKE_FK;

ALTER TABLE HIRES 
DROP CONSTRAINT HIRES_USER_FK;

ALTER TABLE TERMINALS 
DROP CONSTRAINT TERMINALS_BIKES_FK;

ALTER TABLE TERMINALS 
DROP CONSTRAINT TERMINALS_STATIONS_FK;

DROP TABLE TERMINALS CASCADE CONSTRAINTS;

DROP TABLE HIRES CASCADE CONSTRAINTS;

DROP TABLE BIKES CASCADE CONSTRAINTS;

DROP TABLE USERS CASCADE CONSTRAINTS;

DROP TABLE STATIONS CASCADE CONSTRAINTS;

DROP TABLE BIKE_TYPE_PRICING CASCADE CONSTRAINTS;

CREATE TABLE BIKE_TYPE_PRICING 
(
  BIKE_TYPE CHAR(2) DEFAULT 'S' NOT NULL 
, NAME VARCHAR2(11 CHAR) DEFAULT 'SINGLE' NOT NULL 
, PRICE NUMBER(6, 2) DEFAULT 1.0 NOT NULL 
, CONSTRAINT BIKE_TYPE_PRICING_PK PRIMARY KEY 
  (
    BIKE_TYPE 
  )
  ENABLE 
);

CREATE TABLE STATIONS 
(
  STATION_ID NUMBER(4) NOT NULL 
, ADDRESS_STREET VARCHAR2(20) 
, ADDRESS_NUMBER NUMBER(4) 
, ADDRESS_CITY VARCHAR2(20) 
, CONSTRAINT STATIONS_PK PRIMARY KEY 
  (
    STATION_ID 
  )
  ENABLE 
);

CREATE TABLE USERS 
(
  USER_ID NUMBER(7) NOT NULL 
, SURNAME VARCHAR2(20) 
, EMAIL VARCHAR2(35) NOT NULL 
, PHONE_NUMBER VARCHAR2(9) NOT NULL 
, BALANCE NUMBER(6, 2) DEFAULT 0 NOT NULL 
, CONSTRAINT USERS_PK PRIMARY KEY 
  (
    USER_ID 
  )
  ENABLE 
);

CREATE TABLE BIKES 
(
  BIKE_ID NUMBER(6) NOT NULL 
, TYPE CHAR(2) DEFAULT 'S' NOT NULL 
, OCCUPIED VARCHAR2(1 CHAR) DEFAULT 'N' NOT NULL 
, BROKEN VARCHAR2(1 CHAR) NOT NULL 
, BROKEN_DESCRIPTION VARCHAR2(50) 
, LAST_SERVICE_DATE DATE 
, CONSTRAINT BIKE_PK PRIMARY KEY 
  (
    BIKE_ID 
  )
  ENABLE 
);

CREATE TABLE HIRES 
(
  HIRE_ID NUMBER(8) NOT NULL 
, BIKE_ID NUMBER(6) NOT NULL 
, USER_ID NUMBER(7) NOT NULL 
, START_TIME DATE 
, END_TIME DATE 
, PRICE NUMBER(6, 2) 
, RATING NUMBER(1) 
, CONSTRAINT HIRES_PK PRIMARY KEY 
  (
    HIRE_ID 
  )
  ENABLE 
);

CREATE TABLE TERMINALS 
(
  TERMINAL_ID NUMBER(6) NOT NULL 
, STATION_ID NUMBER(4) NOT NULL 
, BIKE_ID NUMBER(6) 
, BROKEN CHAR DEFAULT 'N' NOT NULL 
, BROKEN_DESCRIPTION VARCHAR2(50 CHAR) 
, CONSTRAINT TERMINALS_PK PRIMARY KEY 
  (
    TERMINAL_ID 
  )
  ENABLE 
);

CREATE INDEX BIKES_TYPES_FK ON BIKES (TYPE ASC);

CREATE INDEX HIRES_BIKES_FK ON HIRES (BIKE_ID ASC);

CREATE INDEX HIRES_USERS_FK ON HIRES (USER_ID ASC);

CREATE INDEX TERMINALS_STATIONS_FK ON TERMINALS (STATION_ID ASC);

ALTER TABLE TERMINALS
ADD CONSTRAINT TERMINALS_BIKE_ID_UK UNIQUE 
(
  BIKE_ID 
)
ENABLE;

ALTER TABLE BIKES
ADD CONSTRAINT BIKES_FK FOREIGN KEY
(
  TYPE 
)
REFERENCES BIKE_TYPE_PRICING
(
  BIKE_TYPE 
)
ENABLE;

ALTER TABLE HIRES
ADD CONSTRAINT HIRES_BIKE_FK FOREIGN KEY
(
  BIKE_ID 
)
REFERENCES BIKES
(
  BIKE_ID 
)
ENABLE;

ALTER TABLE HIRES
ADD CONSTRAINT HIRES_USER_FK FOREIGN KEY
(
  USER_ID 
)
REFERENCES USERS
(
  USER_ID 
)
ENABLE;

ALTER TABLE TERMINALS
ADD CONSTRAINT TERMINALS_BIKES_FK FOREIGN KEY
(
  BIKE_ID 
)
REFERENCES BIKES
(
  BIKE_ID 
)
ENABLE;

ALTER TABLE TERMINALS
ADD CONSTRAINT TERMINALS_STATIONS_FK FOREIGN KEY
(
  STATION_ID 
)
REFERENCES STATIONS
(
  STATION_ID 
)
ENABLE;

ALTER TABLE BIKES
ADD CONSTRAINT BIKES_BROKEN_LETTER_CHK CHECK 
(BROKEN = 'Y' OR BROKEN = 'N')
ENABLE;

ALTER TABLE BIKES
ADD CONSTRAINT BIKES_OCCUPIED_LETTER_CHK CHECK 
(OCCUPIED = 'Y' OR OCCUPIED= 'N')
ENABLE;

ALTER TABLE HIRES
ADD CONSTRAINT HIRES_RATING_RANGE_CHK CHECK 
(RATING >= 0 AND RATING <= 5 )
ENABLE;

ALTER TABLE TERMINALS
ADD CONSTRAINT TERMINALS_BROKEN_LETTER_CHK CHECK 
(BROKEN = 'Y' OR BROKEN = 'N')
ENABLE;

COMMENT ON COLUMN BIKES.TYPE IS 'Bike''s type used to calculate the hire price through a link with BIKE_TYPES_PRICING table.';

COMMENT ON COLUMN BIKES.OCCUPIED IS 'Set to "Y" if bike is occupied, "N" otherwise.';

COMMENT ON COLUMN BIKES.BROKEN IS 'Set to "Y" if bike is broken and needs repair, "N" otherwise.';

COMMENT ON COLUMN BIKES.BROKEN_DESCRIPTION IS 'Description of the malfunction indicated by BROKEN field.';

COMMENT ON COLUMN BIKES.LAST_SERVICE_DATE IS 'Date of the last maintenance service for the bike.';

COMMENT ON COLUMN BIKE_TYPE_PRICING.BIKE_TYPE IS 'Letter code for a bike type, possible values: S, D, SE, DE.';

COMMENT ON COLUMN BIKE_TYPE_PRICING.NAME IS 'Bike type, possible values: SINGLE, DOUBLE, SINGLE_ELEC, DOUBLE_ELEC.';

COMMENT ON COLUMN BIKE_TYPE_PRICING.PRICE IS 'Price per hour for a certain bike type.';

COMMENT ON COLUMN HIRES.PRICE IS 'Full price for the hire.';

COMMENT ON COLUMN HIRES.RATING IS 'Rating of the service given by the user.';

COMMENT ON COLUMN TERMINALS.BROKEN IS 'Set to ''Y'' if terminal is broken, ''N'' otherwise.';

COMMENT ON COLUMN TERMINALS.BROKEN_DESCRIPTION IS 'Description of the malfunction indicated by BROKEN field.';

COMMENT ON COLUMN USERS.BALANCE IS 'Amount of money in users account.';
