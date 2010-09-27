ALTER TABLE  `entries` ADD  `action` INT NULL;

ALTER TABLE  `entries` ADD INDEX (  `sent_at` );
ALTER TABLE  `quotes` ADD INDEX (  `symbol` );

ALTER TABLE  `entries` ADD INDEX (  `symbol` );