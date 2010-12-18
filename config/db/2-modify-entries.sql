ALTER TABLE  `entries` ADD  `subject` TEXT NOT NULL ,
ADD  `body` LONGTEXT NOT NULL;

ALTER TABLE  `entries` CHANGE  `url`  `url` VARCHAR( 512 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL;

ALTER TABLE  `entries` CHANGE  `subject`  `subject` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL ,
CHANGE  `body`  `body` LONGTEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL;