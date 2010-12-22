CREATE TABLE  `pumpdump_production`.`email_contents` (
`id` INT NOT NULL AUTO_INCREMENT ,
`entry_id` INT NOT NULL ,
`subject` TEXT NOT NULL ,
`body` LONGTEXT NOT NULL ,
PRIMARY KEY (  `id` )
) ENGINE = MYISAM ;
