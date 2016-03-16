CREATE TABLE ezdebuglogs
(
  ezdlogid     NUMBER NOT NULL
, tstamp       TIMESTAMP NOT NULL
, who_calls    VARCHAR2(32) NOT NULL
, owner        VARCHAR2(32) NOT NULL
, object_name  VARCHAR2(32) NOT NULL
, x1part       VARCHAR2(4000) NOT NULL
, x2part       VARCHAR2(4000)
, x3part       VARCHAR2(4000)
, x4part       VARCHAR2(4000)
)
/
ALTER TABLE ezdebuglogs ADD CONSTRAINT ezdebuglog_pk PRIMARY KEY (ezdlogid)
/
CREATE SEQUENCE ezdebuglogs_seq
/
