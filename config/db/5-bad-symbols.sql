ALTER TABLE  `bad_symbols` ADD INDEX (  `symbol` );

ALTER TABLE  `bad_symbols` ADD  `verified` SMALLINT NOT NULL;

update `bad_symbols` SET verified = 1 where id > 0;

delete from bad_symbols where symbol = 'HOT' limit 1;

ALTER TABLE  `bad_symbols` ADD UNIQUE (
`symbol`
);