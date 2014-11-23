drop sequence item_seq;
drop table item;

create table item (itemId INTEGER PRIMARY KEY,
                   itemName VARCHAR2(100),
                   description VARCHAR2(500));

create sequence item_seq MINVALUE 100;

commit;