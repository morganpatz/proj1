
DROP TABLE pictures;
DROP SEQUENCE pic_id_sequence;

CREATE TABLE pictures (
            photo_id int,
	    pic_desc  varchar(100),
	    pic  BLOB,
	    primary key(photo_id)
      );

CREATE SEQUENCE pic_id_sequence;
