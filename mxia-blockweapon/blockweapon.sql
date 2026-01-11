CREATE TABLE IF NOT EXISTS `revive_cooldowns` (
  `identifier` VARCHAR(50) NOT NULL PRIMARY KEY,
  `cooldown_end` BIGINT NOT NULL
);
