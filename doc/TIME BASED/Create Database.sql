-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
#SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
-- -----------------------------------------------------
-- Schema Risiko
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `Risiko` ;

-- -----------------------------------------------------
-- Schema Risiko
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Risiko` DEFAULT CHARACTER SET utf8 ;
USE `Risiko` ;

-- -----------------------------------------------------
-- Table `Risiko`.`User`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`User` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`User` (
  `username` VARCHAR(18) NOT NULL,
  `password` VARCHAR(18) NOT NULL,
  `role` ENUM('player', 'moderator') NOT NULL DEFAULT 'player',
  PRIMARY KEY (`username`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Nation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Nation` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Nation` (
  `name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Room`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Room` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Room` (
  `roomNumber` INT NOT NULL AUTO_INCREMENT,
  `roomName` VARCHAR(28) NOT NULL,
  `turnDuration` TIME NOT NULL DEFAULT 30,
  `createdBy` VARCHAR(18) NOT NULL,
  PRIMARY KEY (`roomNumber`),
  INDEX `IDX_CREATED_BY` (`createdBy` ASC) ,
  CONSTRAINT `FK_ROOM_MODERATOR`
    FOREIGN KEY (`createdBy`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Match`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Match` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Match` (
  `roomNumber` INT NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `matchStartTime` TIMESTAMP NULL,
  `state` ENUM('lobby', 'countdown', 'started', 'finished') NOT NULL DEFAULT 'lobby',
  PRIMARY KEY (`roomNumber`, `matchSetupTime`),
  CONSTRAINT `FK_MATCH_ROOM`
    FOREIGN KEY (`roomNumber`)
    REFERENCES `Risiko`.`Room` (`roomNumber`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Ingame_Players`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Ingame_Players` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Ingame_Players` (
  `player` VARCHAR(18) NOT NULL,
  `roomNumber` INT NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL,
  `entryTime` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`roomNumber`, `player`, `matchSetupTime`),
  INDEX `IDX_FK_MATCH` (`roomNumber` ASC, `matchSetupTime` ASC) ,
  INDEX `IDX_FK_USER` (`player` ASC) ,
  CONSTRAINT `FK_INGAME_PLAYER`
    FOREIGN KEY (`player`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_INGAME_MATCH`
    FOREIGN KEY (`roomNumber` , `matchSetupTime`)
    REFERENCES `Risiko`.`Match` (`roomNumber` , `matchSetupTime`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Turn`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Turn` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Turn` (
  `roomNumber` INT NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL,
  `player` VARCHAR(18) NOT NULL,
  `turnStartTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `IDX_FK_PLAYER` (`player` ASC) ,
  INDEX `IDX_FK_MATCH` (`roomNumber` ASC, `matchSetupTime` ASC) ,
  PRIMARY KEY (`roomNumber`, `matchSetupTime`, `player`, `turnStartTime`),
  CONSTRAINT `FK_TURN_USER`
    FOREIGN KEY (`player`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_TURN_MATCH`
    FOREIGN KEY (`roomNumber` , `matchSetupTime`)
    REFERENCES `Risiko`.`Match` (`roomNumber` , `matchSetupTime`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Action`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Action` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Action` (
  `roomNumber` INT NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL,
  `turnStartTime` TIMESTAMP NOT NULL,
  `player` VARCHAR(18) NOT NULL,
  `actionTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actionType` ENUM('placement', 'movement', 'attack') NOT NULL DEFAULT 'placement',
  `targetNation` VARCHAR(20) NOT NULL,
  INDEX `IDX_FK_TURN` (`turnStartTime` ASC, `matchSetupTime` ASC, `roomNumber` ASC, `player` ASC) ,
  PRIMARY KEY (`roomNumber`, `matchSetupTime`, `turnStartTime`, `player`, `actionTime`),
  INDEX `IDX_FK_TARGET_NATION` (`targetNation` ASC) ,
  CONSTRAINT `FK_ACTION_TURN`
    FOREIGN KEY (`roomNumber` , `matchSetupTime` , `player` , `turnStartTime`)
    REFERENCES `Risiko`.`Turn` (`roomNumber` , `matchSetupTime` , `player` , `turnStartTime`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_ACTION_NATION`
    FOREIGN KEY (`targetNation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Attack`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Attack` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Attack` (
  `roomNumber` INT NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL,
  `turnStartTime` TIMESTAMP NOT NULL,
  `actionTime` TIMESTAMP NOT NULL,
  `attackPlayer` VARCHAR(18) NOT NULL,
  `attackNation` VARCHAR(20) NOT NULL,
  `defendPlayer` VARCHAR(18) NOT NULL,
  `succeded` BIT NOT NULL DEFAULT 0,
  INDEX `IDX_FK_ACTION` (`turnStartTime` ASC, `matchSetupTime` ASC, `roomNumber` ASC, `attackPlayer` ASC, `actionTime` ASC) ,
  INDEX `IDX_FK_DEFENDER` (`defendPlayer` ASC) ,
  INDEX `IDX_FK_ATTACKED_NATION` (`attackNation` ASC) ,
  PRIMARY KEY (`roomNumber`, `matchSetupTime`, `attackPlayer`, `turnStartTime`, `actionTime`),
  CONSTRAINT `FK_ATTACK_ACTION`
    FOREIGN KEY (`roomNumber` , `matchSetupTime` , `attackPlayer` , `turnStartTime` , `actionTime`)
    REFERENCES `Risiko`.`Action` (`roomNumber` , `matchSetupTime` , `player` , `turnStartTime` , `actionTime`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_ATTACK_PLAYER`
    FOREIGN KEY (`defendPlayer`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_ATTACK_NATION`
    FOREIGN KEY (`attackNation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Movement`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Movement` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Movement` (
  `turnStartTime` TIMESTAMP NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL,
  `roomNumber` INT NOT NULL,
  `player` VARCHAR(18) NOT NULL,
  `actionTime` TIMESTAMP NOT NULL,
  `sourceNation` VARCHAR(20) NOT NULL,
  INDEX `IDX_FK_ACTION` (`turnStartTime` ASC, `matchSetupTime` ASC, `roomNumber` ASC, `player` ASC, `actionTime` ASC) ,
  PRIMARY KEY (`turnStartTime`, `matchSetupTime`, `roomNumber`, `player`, `actionTime`),
  INDEX `IDX_FK_SOURCE_NATION` (`sourceNation` ASC) ,
  CONSTRAINT `FK_MOVEMENT_ACTION`
    FOREIGN KEY (`roomNumber` , `matchSetupTime` , `turnStartTime` , `player` , `actionTime`)
    REFERENCES `Risiko`.`Action` (`roomNumber` , `matchSetupTime` , `turnStartTime` , `player` , `actionTime`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_MOVEMENT_NATION`
    FOREIGN KEY (`sourceNation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Dice_Rolls`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Dice_Rolls` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Dice_Rolls` (
  `roomNumber` INT NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL,
  `turnStartTime` TIMESTAMP NOT NULL,
  `player` VARCHAR(18) NOT NULL,
  `actionTime` TIMESTAMP NOT NULL,
  `rollNumber` INT NOT NULL,
  `rollValue` INT NOT NULL,
  PRIMARY KEY (`roomNumber`, `matchSetupTime`, `turnStartTime`, `actionTime`, `player`, `rollNumber`),
  CONSTRAINT `FK_DICE_ATTACK`
    FOREIGN KEY (`roomNumber` , `matchSetupTime` , `player` , `turnStartTime` , `actionTime`)
    REFERENCES `Risiko`.`Attack` (`roomNumber`, `matchSetupTime`, `attackPlayer`, `turnStartTime`, `actionTime`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Territory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Territory` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Territory` (
  `roomNumber` INT NOT NULL,
  `matchSetupTime` TIMESTAMP NOT NULL,
  `nation` VARCHAR(20) NOT NULL,
  `governer` VARCHAR(18) NULL DEFAULT NULL COMMENT 'Governer is NULL When there is no owner player',
  `tanksNumber` INT NULL DEFAULT NULL,
  PRIMARY KEY (`roomNumber`, `matchSetupTime`, `nation`),
  INDEX `IDX_FK_NATION` (`nation` ASC) ,
  INDEX `IDX_FK_MATCH` (`roomNumber` ASC, `matchSetupTime` ASC) ,
  INDEX `IDX_FK_GOVERNER` (`governer` ASC) ,
  CONSTRAINT `FK_TERRITORY_NATION`
    FOREIGN KEY (`nation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_TERRITORY_MATCH`
    FOREIGN KEY (`roomNumber` , `matchSetupTime`)
    REFERENCES `Risiko`.`Match` (`roomNumber` , `matchSetupTime`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_TERRITORY_USER`
    FOREIGN KEY (`governer`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Neighbour_Nations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Neighbour_Nations` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Neighbour_Nations` (
  `nation` VARCHAR(20) NOT NULL,
  `neighbour` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`nation`, `neighbour`),
  INDEX `IDX_FK_NEIGHBOUR` (`neighbour` ASC) ,
  INDEX `IDX_FK_NATION` (`nation` ASC) ,
  CONSTRAINT `FK_NATION`
    FOREIGN KEY (`nation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_NEIGHBOUR`
    FOREIGN KEY (`neighbour`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;

