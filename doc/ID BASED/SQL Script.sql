-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

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
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `role` ENUM('player', 'moderator') NOT NULL DEFAULT 'player',
  `lastAccess` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`username`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Nation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Nation` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Nation` (
  `name` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Room`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Room` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Room` (
  `roomNumber` INT(6) UNSIGNED NOT NULL AUTO_INCREMENT,
  `turnDuration` INT(3) UNSIGNED NOT NULL DEFAULT 30,
  `createdBy` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`roomNumber`),
  INDEX `IDX_CREATED_BY` (`createdBy` ASC),
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
  `matchNumber` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `roomNumber` INT(6) UNSIGNED NOT NULL,
  `matchEndTime` TIMESTAMP NULL DEFAULT NULL,
  `matchStartCountdown` TIMESTAMP NULL DEFAULT NULL,
  `state` ENUM('lobby', 'countdown', 'started', 'finished') NOT NULL DEFAULT 'lobby',
  `numberOfPlayers` SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`matchNumber`),
  CONSTRAINT `FK_MATCH_ROOM`
    FOREIGN KEY (`roomNumber`)
    REFERENCES `Risiko`.`Room` (`roomNumber`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Ingame_Players`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Ingame_Players` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Ingame_Players` (
  `matchNumber` INT UNSIGNED NOT NULL,
  `player` VARCHAR(45) NOT NULL,
  `entryTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `exitTime` TIMESTAMP NULL DEFAULT NULL,
  `unplacedTanks` INT NOT NULL DEFAULT 0,
  `eliminated` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`matchNumber`, `player`),
  INDEX `IDX_FK_USER` (`player` ASC),
  CONSTRAINT `FK_INGAME_PLAYER`
    FOREIGN KEY (`player`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Turn`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Turn` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Turn` (
  `matchNumber` INT UNSIGNED NOT NULL,
  `turnNumber` INT(3) UNSIGNED NOT NULL,
  `player` VARCHAR(45) NOT NULL,
  `turnStartTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `IDX_FK_PLAYER` (`player` ASC),
  PRIMARY KEY (`matchNumber`, `turnNumber`),
  CONSTRAINT `FK_TURN_USER`
    FOREIGN KEY (`player`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TURN_MATCH`
    FOREIGN KEY (`matchNumber`)
    REFERENCES `Risiko`.`Match` (`matchNumber`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Action`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Action` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Action` (
  `matchNumber` INT UNSIGNED NOT NULL,
  `turnNumber` INT(3) UNSIGNED NOT NULL,
  `actionNumber` INT(2) UNSIGNED NOT NULL,
  `player` VARCHAR(45) NOT NULL,
  `actionType` ENUM('placement', 'movement', 'combat') NOT NULL DEFAULT 'placement',
  `targetNation` VARCHAR(32) NOT NULL,
  `tanksNumber` INT(3) NOT NULL,
  PRIMARY KEY (`matchNumber`, `turnNumber`, `actionNumber`),
  INDEX `IDX_FK_TARGET_NATION` (`targetNation` ASC),
  CONSTRAINT `FK_ACTION_TURN`
    FOREIGN KEY (`matchNumber` , `turnNumber`)
    REFERENCES `Risiko`.`Turn` (`matchNumber` , `turnNumber`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ACTION_NATION`
    FOREIGN KEY (`targetNation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Combat`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Combat` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Combat` (
  `matchNumber` INT UNSIGNED NOT NULL,
  `turnNumber` INT(3) UNSIGNED NOT NULL,
  `actionNumber` INT(2) UNSIGNED NOT NULL,
  `attackerNation` VARCHAR(32) NOT NULL,
  `defenderPlayer` VARCHAR(45) NOT NULL,
  `defenderTanksNumber` INT(3) NOT NULL,
  `succeded` BIT NOT NULL DEFAULT 0,
  INDEX `IDX_FK_DEFENDER` (`defenderPlayer` ASC),
  INDEX `IDX_FK_ATTACKED_NATION` (`attackerNation` ASC),
  PRIMARY KEY (`matchNumber`, `turnNumber`, `actionNumber`),
  CONSTRAINT `FK_ATTACK_ACTION`
    FOREIGN KEY (`matchNumber` , `turnNumber` , `actionNumber`)
    REFERENCES `Risiko`.`Action` (`matchNumber` , `turnNumber` , `actionNumber`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ATTACK_PLAYER`
    FOREIGN KEY (`defenderPlayer`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_ATTACK_NATION`
    FOREIGN KEY (`attackerNation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Movement`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Movement` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Movement` (
  `matchNumber` INT UNSIGNED NOT NULL,
  `turnNumber` INT(3) UNSIGNED NOT NULL,
  `actionNumber` INT(2) UNSIGNED NOT NULL,
  `sourceNation` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`matchNumber`, `turnNumber`, `actionNumber`),
  INDEX `IDX_FK_SOURCE_NATION` (`sourceNation` ASC),
  CONSTRAINT `FK_MOVEMENT_ACTION`
    FOREIGN KEY (`matchNumber` , `turnNumber` , `actionNumber`)
    REFERENCES `Risiko`.`Action` (`matchNumber` , `turnNumber` , `actionNumber`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_MOVEMENT_NATION`
    FOREIGN KEY (`sourceNation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Dice_Roll`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Dice_Roll` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Dice_Roll` (
  `matchNumber` INT UNSIGNED NOT NULL,
  `turnNumber` INT(3) UNSIGNED NOT NULL,
  `actionNumber` INT(2) UNSIGNED NOT NULL,
  `rollNumber` SMALLINT UNSIGNED NOT NULL,
  `rollValue` SMALLINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`matchNumber`, `turnNumber`, `actionNumber`, `rollNumber`),
  CONSTRAINT `FK_DICE_ATTACK`
    FOREIGN KEY (`matchNumber` , `turnNumber` , `actionNumber`)
    REFERENCES `Risiko`.`Combat` (`matchNumber` , `turnNumber` , `actionNumber`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Territory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Territory` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Territory` (
  `matchNumber` INT UNSIGNED NOT NULL,
  `nation` VARCHAR(32) NOT NULL,
  `occupier` VARCHAR(45) NOT NULL COMMENT 'Occupier is NULL When there is no owner player',
  `occupyingTanksNumber` INT(3) NOT NULL DEFAULT 0,
  PRIMARY KEY (`matchNumber`, `nation`),
  INDEX `IDX_FK_NATION` (`nation` ASC),
  INDEX `IDX_FK_GOVERNER` (`occupier` ASC),
  CONSTRAINT `FK_TERRITORY_NATION`
    FOREIGN KEY (`nation`)
    REFERENCES `Risiko`.`Nation` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_TERRITORY_MATCH`
    FOREIGN KEY (`matchNumber`)
    REFERENCES `Risiko`.`Match` (`matchNumber`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_TERRITORY_USER`
    FOREIGN KEY (`occupier`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Risiko`.`Neighbour_Nations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Neighbour_Nations` ;

CREATE TABLE IF NOT EXISTS `Risiko`.`Neighbour_Nations` (
  `nation` VARCHAR(32) NOT NULL,
  `neighbour` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`nation`, `neighbour`),
  INDEX `IDX_FK_NEIGHBOUR` (`neighbour` ASC),
  INDEX `IDX_FK_NATION` (`nation` ASC),
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

USE `Risiko` ;

-- -----------------------------------------------------
-- Placeholder table for view `Risiko`.`Active_Matches_ID`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Risiko`.`Active_Matches_ID` (`matchNumber` INT);

-- -----------------------------------------------------
-- procedure CreatePlayer
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CreatePlayer`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CreatePlayer` (IN username VARCHAR(18),IN password VARCHAR(32), OUT result BIT)
BEGIN
	DECLARE userExists BIT;
    DECLARE hashedPassword VARCHAR(32);
    SET userExists = (SELECT count(username) FROM User AS U WHERE U.username = username);
    SET hashedPassword = md5(password);
    
    START TRANSACTION;
		IF userExists = 0 THEN
			INSERT INTO USER(username,password,role,active) VALUES (username,md5(password),'player',1);
			SET result = 1;
			COMMIT;
		ELSE
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Player already exists!';
			SET result = 0;
			ROLLBACK;
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Login
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`Login`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `Login` (IN username VARCHAR(18),IN password VARCHAR(32), OUT result BIT, OUT role ENUM('player','moderator'))
BEGIN
	SET @hashedPassword := md5(password);
    
    SELECT U.role 
    INTO @authenticatedRole 
    FROM User AS U 
    WHERE U.username = username AND U.password = hashedPassword;
    
    START TRANSACTION;
    IF @authenticatedRole IS NOT NULL THEN
		SET result = 1;
        SET role = @authenticatedRole;
        UPDATE User AS U
        SET lastAccess=CURRENT_TIMESTAMP AND active=1
        WHERE U.username = username AND U.password = hashedPassword;
        COMMIT;
	ELSE
		SET result = 0;
        SET role = NULL;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wrong username or password!';
        ROLLBACK;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CreateMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CreateMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CreateMatch` (IN srcRoomNumber INT(6) UNSIGNED)
BEGIN
	SET @MatchAlreadyCreated = (
    SELECT COUNT(M.matchNumber)
    FROM `Match` as M
    WHERE M.roomNumber = srcRoomNumber
    AND M.state <> 'finished'
    );
    
    IF @MatchAlreadyCreated = 0 THEN
		INSERT INTO `Match`(roomNumber,state) VALUES (srcRoomNumber,'lobby');
        SET @NewMatchNumber = last_insert_id();
        CALL CreateMatchPollEvent(@NewMatchNumber);
    END IF;
END;$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CreateTurn
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CreateTurn`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CreateTurn` (IN srcMatchNumber INT UNSIGNED,IN turnDuration INT(3) UNSIGNED, IN initialTurn BIT)
BEGIN
	CALL GetNextTurnNumber(srcMatchNumber, initialTurn,@NextTurnNumber);
	CALL GetNextTurnPlayer(srcMatchNumber, @NextTurnNumber, @NextTurnPlayer);
    
    SELECT @NextTurnNumber AS "Turn Number", @NextTurnPlayer AS "Player Number";
    
    IF @NextTurnNumber > 15 AND initialTurn = 0 THEN
		CALL CheckAnyWinner(srcMatchNumber,@AnyWinner, @WinnerPlayer);
    
		IF @AnyWinner <> 0 OR @WinnerPlayer IS NOT NULL THEN
			UPDATE `Match`
            SET state = 'finished'
            WHERE matchNumber = srcMatchNumber AND state <> 'finished';
		ELSE 
			CALL InsertTurn(srcMatchNumber, @NextTurnNumber, @NextTurnPlayer,turnDuration);
		END IF;
	ELSE
		CALL InsertTurn(srcMatchNumber, @NextTurnNumber, @NextTurnPlayer,turnDuration);
    END IF;
END;$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Attack
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`Attack`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `Attack` 
(
	IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED,
    IN attacker VARCHAR(18),IN attackerNation VARCHAR(32), IN defenderNation VARCHAR(32)
)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
	START TRANSACTION;
		CALL IsNeighbourNation(attackerNation,defenderNation,@AreNeighbours);
        
		IF @AreNeighbours IS NULL OR @AreNeighbours = 0 THEN 
			SIGNAL SQLSTATE '45000' SET message_text = `Attacker and Defender nations have to be neighbours!`;
            ROLLBACK;
        END IF;
		
		SET @AttackerTanks = (
			SELECT tanksNumber
            FROM Territory AS T
            WHERE T.matchNumber = srcMatchNumber
            AND T.nation = sourceNation
            AND T.governer = player
        );
		
        IF @AttackerTanks IS NULL THEN 
			SIGNAL SQLSTATE '45000' SET message_text = `Can't attack from a foreign territory!`;
            ROLLBACK;
        ELSEIF @AttackerTanks = 1 THEN
        	SIGNAL SQLSTATE '45000' SET message_text = `Not enough tanks! (At least 1 tank has to defend the territory)`;
			ROLLBACK;
		END IF;
        
		SET @AttackSuccess := 1;
        SET @DefenderTanks = (
			SELECT tanksNumber
            FROM Territory AS T
            WHERE T.matchNumber = srcMatchNumber
            AND T.nation = defenderNation
        );
                
        IF @DefenderTanks = 0 THEN
			SET @AttackSuccess := 1;
        END IF;
		
        INSERT INTO `Action`(matchNumber,turnNumber,player,targetNation,tanksNumber)
		VALUES (srcMatchNumber,turnNumber,attacker,defenderNation,@AttackerTanks);
		
        SET @ActionNumber = last_insert_id();
		
        INSERT INTO `Attack`(
			matchNumber,turnNumber,actionNumber, attackerNation,
			defenderPlayer,defenderTanksNumber, succeded
        )
		VALUES (
			srcMatchNumber,turnNumber,actionNumber,attackerNation,
			@DefenderPlayer,@DefenderTanks,@AttackSuccess
        );
        
        IF @AttackSuccess = 1 THEN
			UPDATE Territory AS T
            SET T.governer = attacker AND T.tanksNumber = @RemainingAttackTanks
            WHERE T.matchNumber = srcMatchNumber
            AND T.nation = defenderNation;
        END IF;
        
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Move
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`Move`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `Move` 
(
	IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED,
    IN player VARCHAR(18),IN sourceNation VARCHAR(32), IN targetNation VARCHAR(32),
    IN tanksNumber INT(3)
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
	START TRANSACTION;
    
    	CALL IsNeighbourNation(sourceNation,targetNation,@AreNeighbours);
        
		IF @AreNeighbours IS NULL OR @AreNeighbours = 0 THEN 
			SIGNAL SQLSTATE '45000' SET message_text = `You can only move tanks to neighbour nations!`;
            ROLLBACK;
        END IF;
        
		SET @AvailableTanks = (
			SELECT tanksNumber
            FROM Territory AS T
            WHERE T.matchNumber = srcMatchNumber
            AND T.nation = sourceNation
            AND T.governer = player
        );
		
        IF @AvailableTanks IS NULL THEN 
			SIGNAL SQLSTATE '45000' SET message_text = `Can't move tanks from a foreign territory!`;
            ROLLBACK;
        ELSEIF @AvailableTanks = 0 THEN
        	SIGNAL SQLSTATE '45000' SET message_text = `No tanks available at that territory!`;
			ROLLBACK;
        ELSEIF tanksNumber > @AvailableTanks THEN
			SIGNAL SQLSTATE '45000' SET message_text = `Insufficient tanks in that territory!`;
			ROLLBACK;
		ELSEIF tanksNumber = @AvailableTanks THEN
			SIGNAL SQLSTATE '45000' SET message_text = `At least 1 tank has to defend the current territory!`;
			ROLLBACK;
        END IF;
		
        INSERT INTO `Action`(matchNumber,turnNumber,player,targetNation,tanksNumber)
		VALUES (srcMatchNumber,turnNumber,player,targetNation,tanksNumber);
		
        SET @ActionNumber = last_insert_id();
		
        INSERT INTO `Move`(matchNumber,turnNumber,actionNumber,sourceNation)
		VALUES (srcMatchNumber,turnNumber,actionNumber,sourceNation);
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure PlaceTanks
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`PlaceTanks`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `PlaceTanks` 
(
	IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED,
    IN player VARCHAR(18), IN targetNation VARCHAR(32), IN tanksNumber INT(3)
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
	START TRANSACTION;
		SET @AvailableUnplacedTanks = (
			SELECT unplacedTanks
            FROM Ingame_Players AS IP
            WHERE IP.matchNumber = srcMatchNumber
            AND IP.player = player
        );
		
        IF @AvailableUnplacedTanks IS NULL THEN 
			SIGNAL SQLSTATE '45000' SET message_text = `You aren't a part of the match!`;
            ROLLBACK;
        ELSEIF @AvailableUnplacedTanks = 0 THEN
        	SIGNAL SQLSTATE '45000' SET message_text = `You don't have any unplaced tanks!`;
			ROLLBACK;
        ELSEIF tanksNumber > @AvailableUnplacedTanks THEN
			SIGNAL SQLSTATE '45000' SET message_text = `Insufficient unplaced tanks!`;
			ROLLBACK;
        END IF;
		
        INSERT INTO `Action`(matchNumber,turnNumber,player,targetNation,tanksNumber)
		VALUES (srcMatchNumber,turnNumber,player,targetNation,tanksNumber);
        
        UPDATE Ingame_Players AS IP 
        SET unplacedTanks = (@AvailableUnplacedTanks - tanksNumber)
		WHERE IP.matchNumber = srcMatchNumber AND IP.player = player;
        
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CreateMatchPollEvent
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CreateMatchPollEvent`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CreateMatchPollEvent` (IN srcMatchNumber INT UNSIGNED)
BEGIN
	#CREATE EVENT IF NOT EXISTS `md5(CONCAT('match-polling-event',srcMatchNumber))`
    #ON SCHEDULE EVERY 20 SECOND
    #STARTS CURRENT_TIMESTAMP
    #DO CALL CheckMatch(srcMatchNumber);
END;$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure AnyForwardTurns
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`AnyForwardTurns`;

DELIMITER $$
USE `Risiko`$$
#Checks if there is any turns done after the last turn (Forward Turns)
CREATE PROCEDURE `AnyForwardTurns` (IN matchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED,OUT forwardTurnsExist BIT)
BEGIN
	SELECT COUNT(*)
    INTO @ForwardTurnsCount
    FROM Turn AS T
    WHERE T.matchNumber = matchNumber AND T.turnNumber > turnNumber;
    
    if @ForwardTurnsCount > 0 THEN
		SET forwardTurnsExist = 1;
	ELSE
		SET forwardTurnsExist = 0;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetActionsInTurn
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetActionsInTurn`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetActionsInTurn` 
(
	IN srcMatchNumber INT UNSIGNED,IN player VARCHAR(18), IN turnNumber INT(3) UNSIGNED,
	IN actionType ENUM('placement', 'movement', 'attack'), OUT anyActions INT
)
BEGIN
	CALL CheckActionsInTurn(srcMatchNumber,player,turnNumber,@AnyActionHappened);
    
    IF @AnyActionHappened = 1 THEN
        IF actionType = 'placement' THEN
			SELECT  A.matchNumber, A.turnNumber, A.actionNumber,
			A.player AS 'Player',A.tanksNumber AS 'Placed Tanks',
            A.targetNation AS 'Placed at'
            FROM Action AS A
            WHERE A.matchNumber = srcMatchNumber AND A.turnNumber = turnNumber;
		ELSEIF actionType = 'movement' THEN
        	SELECT A.matchNumber, A.turnNumber, A.actionNumber,
			A.player AS 'Player', M.sourceNation AS 'Moving From',
            A.targetNation AS 'Moving to', A.tanksNumber AS 'Moved Tanks'
            FROM Action AS A JOIN Movement AS M 
            ON (
				A.matchNumber = M.matchNumber 
				AND A.turnNumber = M.turnNumber
				AND A.actionNumber = M.actionNumber
            )
            WHERE A.matchNumber = srcMatchNumber 
            AND A.turnNumber = turnNumber
            AND A.actionType = actionType;
		ELSEIF actionType = 'action' THEN
			SELECT A.matchNumber, A.turnNumber, A.actionNumber,
				A.player AS 'Attacker', ATK.attackerNation AS 'Attacker Nation',
                A.tanksNumber AS 'Attacker Tanks', ATK.defenderPlayer AS 'Defender',
                A.targetNation AS 'Defender Nation', ATK.defenderTanksNumber AS 'Defender Tanks',
                ATK.succeded AS 'Attack Succeded'
            FROM `Action` AS A JOIN Attack AS ATK 
            ON (
				A.matchNumber = ATK.matchNumber 
				AND A.turnNumber = ATK.turnNumber
				AND A.actionNumber = ATK.actionNumber
            )
            WHERE A.matchNumber = srcMatchNumber 
            AND A.turnNumber = turnNumber
            AND A.actionType = actionType;
		ELSE
			SELECT NULL;
        END IF;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CanMatchCountdown
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CanMatchCountdown`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CanMatchCountdown` (IN srcMatchNumber INT UNSIGNED, OUT canStart BIT)
BEGIN
	SET canStart = 0;
	call GetMatchParticipants(srcMatchNumber,@PlayersCount);
    
    IF @PlayersCount >= 3 THEN
		SET canStart = 1;
    END IF;
    
END;$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure StartMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`StartMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `StartMatch` (IN srcMatchNumber INT UNSIGNED)
BEGIN
	DECLARE srcRoomNumber INT(6);
	START TRANSACTION;
        SET srcRoomNumber = (SELECT roomNumber FROM `Match` AS M WHERE M.matchNumber = srcMatchNumber);
		SELECT R.turnDuration into @TurnDuration FROM Room AS R WHERE roomNumber=srcRoomNumber;
		CALL GenerateTerritories(srcMatchNumber);
		CALL CreateTurn(srcMatchNumber,@TurnDuration,1);
		UPDATE `MATCH` SET state='started' WHERE matchNumber = srcMatchNumber;
        COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetNextTurnPlayer
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetNextTurnPlayer`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetNextTurnPlayer` (IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED,OUT playerUsername VARCHAR(18))
BEGIN
	CALL GetMatchParticipants(srcMatchNumber,@PlayersCount);
    SET @FirstPlayerTurn = (CASE WHEN MOD(turnNumber - 1,@PlayersCount) = 0 THEN 1 ELSE 0 END);
    
    IF @PlayersCount = 0 THEN
		CALL CleanupAbandonedMatch(srcMatchNumber);
	END IF;

    IF @PlayersCount > 1 THEN
		IF turnNumber = 1 OR @FirstPlayerTurn = 1 THEN
			SELECT player INTO playerUsername 
			FROM Ingame_Players AS IP 
			WHERE IP.matchNumber = srcMatchNumber 
            AND IP.exitTime IS NULL
			ORDER BY entryTime ASC LIMIT 1;
		ELSE
			SELECT player INTO playerUsername 
			FROM Ingame_Players AS IP 
			WHERE IP.matchNumber = srcMatchNumber
            AND IP.exitTime IS NULL
			AND IP.entryTime > (
				SELECT IIP.entryTime
					FROM Turn AS T JOIN Ingame_Players AS IIP
                    ON (T.player = IIP.player)
					WHERE T.matchNumber = srcMatchNumber
					ORDER BY T.turnNumber DESC
					LIMIT 1
			)
			ORDER BY entryTime ASC 
            LIMIT 1;
		END IF;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetNextTurnNumber
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetNextTurnNumber`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetNextTurnNumber` (IN srcMatchNumber INT UNSIGNED, IN initialTurn BIT, OUT nextTurnNumber INT(3) UNSIGNED)
BEGIN
	IF initialTurn = 1 THEN
		SET nextTurnNumber = 1;
    ELSE
		SELECT (turnNumber) + 1 
        INTO nextTurnNumber 
        FROM Turn AS T 
        WHERE T.matchNumber = srcMatchNumber 
        ORDER BY turnNumber DESC
        LIMIT 1;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CheckAnyWinner
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CheckAnyWinner`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CheckAnyWinner` (IN srcMatchNumber INT UNSIGNED,OUT anyWinner BIT, OUT winnerPlayer VARCHAR(18))
BEGIN
	SET @NationsCount = (SELECT COUNT(name) FROM Nation);
	SET @Conquerer = NULL;
    
	SELECT governer
    INTO @Conquerer
    FROM Territory AS T
    WHERE T.matchNumber = srcMatchNumber
    GROUP BY governer
	HAVING COUNT(T.nation) = @NationsCount;
    
    CALL GetMatchParticipants(srcMatchNumber,@PlayersCount);
	
    IF @PlayersCount = 1 THEN    
		SET anyWinner = 1;
        SELECT player
        INTO @Conquerer
        FROM Ingame_Players AS IP
        WHERE IP.matchNumber = srcMatchNumber;        
        #SET winnerPlayer = (SELECT governer FROM Territory AS T WHERE T.matchNumber = srcMatchNumber LIMIT 1);
	END IF;

	IF @Conquerer IS NOT NULL OR @PlayersCount = 1 THEN    
		SET anyWinner = 1;        
        SET winnerPlayer = @Conquerer;
        #SET winnerPlayer = (SELECT governer FROM Territory AS T WHERE T.matchNumber = srcMatchNumber LIMIT 1);
	ELSE
   		SET anyWinner = 0;
        SET winnerPlayer = NULL;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure InsertTurn
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`InsertTurn`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `InsertTurn` (IN srcMatchNumber INT UNSIGNED ,IN nextTurnNumber INT(3) UNSIGNED ,IN nextTurnPlayer VARCHAR(18),IN turnDuration INT(3) UNSIGNED)
BEGIN
	START TRANSACTION;
		INSERT INTO Turn(matchNumber,turnNumber,player) VALUES (srcMatchNumber,nextTurnNumber,nextTurnPlayer);
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GenerateTerritories
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GenerateTerritories`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GenerateTerritories` (IN srcMatchNumber INT UNSIGNED)
BEGIN
    DECLARE playersScanned BIT DEFAULT 0;
    DECLARE nationsScanned BIT DEFAULT 0;
    DECLARE currentPlayer VARCHAR(18);
    DECLARE currentNation VARCHAR(32);

    DECLARE playersCursor CURSOR FOR SELECT player FROM Ingame_Players AS IP WHERE IP.matchNumber = srcMatchNumber;

    DECLARE nationsCursor CURSOR FOR SELECT name FROM Nation AS N ORDER BY RAND();

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET playersScanned = 1;
    
    SET @PlayersCount := (SELECT COUNT(player) FROM Ingame_Players AS IP WHERE IP.matchNumber = srcMatchNumber);
    SET @NationsCount := (SELECT COUNT(name) FROM Nation);
    SET @NationsPerPlayer := FLOOR(@NationsCount / @PlayersCount);
    SET @AssignedCount := 0; #Number of nations assigned to the current player.
    SET @ResidueNations := MOD(@NationsCount,@PlayersCount); # As Nations are "42" AND with 4/5 players,
							  # we have 40 Nations assigned AND 2 Unassigned (Residue) nations!    
    OPEN nationsCursor;
    OPEN playersCursor;
    
    playersLoop: LOOP
		FETCH playersCursor INTO currentPlayer;
		IF playersScanned = 1 THEN
			CLOSE nationsCursor;
			CLOSE playersCursor;
			LEAVE playersLoop;
		END IF;        
		
        nationsAssignment: BEGIN
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET nationsScanned = 1;
			nationsLoop: LOOP
				IF nationsScanned = 1 THEN
					CLOSE nationsCursor;
					CLOSE playersCursor;
					LEAVE playersLoop;
				END IF;
                
                IF @AssignedCount < @NationsPerPlayer THEN
						FETCH nationsCursor INTO currentNation;
						CALL AssignTerritory(srcMatchNumber,currentPlayer,currentNation,1);
                        SET @AssignedCount = (@AssignedCount + 1);
				END IF;
                
                IF  @AssignedCount = @NationsPerPlayer THEN
						#IF @ResidueNations > 0 AND @PlayersCount = 4 OR @PlayersCount = 5 THEN 
						IF @ResidueNations > 0 THEN 
							FETCH nationsCursor INTO currentNation;
							CALL AssignTerritory(srcMatchNumber,currentPlayer,currentNation,1);
							SET @AssignedCount = (@AssignedCount + 1);
                            SET @ResidueNations = (@ResidueNations - 1);						
                        END IF;
						LEAVE nationsLoop;
                END IF;
            END LOOP nationsLoop;
			SET @AssignedCount = 0;
        END;
    END LOOP playersLoop;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ScheduleTurns
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`ScheduleTurns`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `ScheduleTurns` ()
BEGIN
	DECLARE currentMatch INT UNSIGNED;
	DECLARE currentTurnDuration INT(3) UNSIGNED;
    DECLARE doneChecking BIT DEFAULT 0;
	DECLARE matchesCursor CURSOR FOR (
		SELECT DISTINCT M.matchNumber, R.turnDuration
        FROM Room AS R Join `Match` AS M
        ON (R.roomNumber = M.roomNumber AND M.state = 'started')
        ORDER BY matchStartCountdown ASC
    );
    DECLARE EXIT HANDLER FOR NOT FOUND set doneChecking = 1;
    
    OPEN matchesCursor;
    
    startedMatches: LOOP
		IF doneChecking = 0 THEN
			LEAVE startedMatches;
		END IF;
        
        FETCH matchesCursor INTO currentMatch,currentTurnDuration;
        CALL CanNewTurnStart(currentMatch,currentTurnDuration,@CanTurnStart);
        
        IF CanTurnStart = 0 THEN
			ITERATE startedMatches;
        END IF;	
		
        CALL CreateTurn(matchNumber,currentTurnDuration,0);
    END LOOP startedMatches;
    
    CLOSE matchesCursor;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ScheduleStartMatches
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`ScheduleStartMatches`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `ScheduleStartMatches` ()
BEGIN
	DECLARE currentMatch INT UNSIGNED;
    DECLARE doneChecking BIT DEFAULT 0;
	DECLARE matchesCursor CURSOR FOR (
		SELECT matchNumber
        FROM Room AS R Join `Match` AS M
        ON (R.roomNumber = M.roomNumber AND M.state = 'countdown')
        ORDER BY matchStartCountdown ASC
    );
    DECLARE EXIT HANDLER FOR NOT FOUND set doneChecking = 1;
    
    OPEN matchesCursor;
    
    countdownMatches: LOOP
		IF doneChecking = 0 THEN
			LEAVE countdownMatches;
		END IF;
        
        FETCH matchesCursor INTO currentMatch;
        CALL CanMatchStart(currentMatch,@CanMatchStart);
        
        IF CanMatchStart = 0 THEN
			ITERATE countdownMatches;
        END IF;	
		
        CALL StartMatch(currentMatch);
    END LOOP countdownMatches;
    
    CLOSE matchesCursor;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CreateRoom
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CreateRoom`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CreateRoom` (IN roomName VARCHAR(28),IN turnDuration INT(3) UNSIGNED, IN moderatorName VARCHAR(18))
BEGIN
	SET @userRole := (SELECT role
    FROM User AS U
	WHERE U.username = moderatorName);

	START TRANSACTION;
        IF @userRole = 'moderator' THEN
			INSERT INTO Room(roomName,turnDuration,createdBy) VALUES (roomName,turnDuration,moderatorName);
			SET @roomNumber = last_insert_id();
			#CALL CreateMatch(@roomNumber);
			COMMIT;
		ELSE
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No moderator found with the provided moderatorName!';
                ROLLBACK;
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure FinishMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`FinishMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `FinishMatch` (IN srcMatchNumber INT UNSIGNED)
BEGIN
	CALL CheckAnyWinner(srcMatchNumber,@AnyWinner,@WinnerPlayer);
    IF @AnyWinner = 1 THEN
		SET @srcRoomNumber := (SELECT roomNumber FROM `Match` AS M WHERE M.matchNumber = srcMatchNumber);
        CALL EndMatch(srcMatchNumber,@srcRoomNumber);
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CreateModerator
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CreateModerator`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CreateModerator` (IN username VARCHAR(18),IN password VARCHAR(32), OUT result BIT)
BEGIN
	DECLARE userExists BIT;
    DECLARE hashedPassword VARCHAR(32);
    SET userExists = (SELECT count(username) FROM User AS U WHERE U.username = username);
    SET hashedPassword = md5(password);
	
    START TRANSACTION;
		IF userExists = 0 THEN
			INSERT INTO User(username,password,role,active) VALUES (username,md5(password),'moderator',1);
			SET result = 1;
			COMMIT;
		ELSE
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Moderator already exists!';
			SET result = 0;
            ROLLBACK;
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Logout
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`Logout`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `Logout` (IN username VARCHAR(18))
BEGIN
	START TRANSACTION;
		UPDATE User AS U
		SET active = 0
        WHERE U.username = username;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure AssignTerritory
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`AssignTerritory`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `AssignTerritory` (IN srcMatchNumber INT UNSIGNED, IN player VARCHAR(18), IN nationName VARCHAR(32), IN tanksNumber INT)
BEGIN
		REPLACE INTO Territory (matchNumber,nation,governer,tanksNumber) 
		VALUES (srcMatchNumber,nationName,player,tanksNumber);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure AssignTanks
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`AssignTanks`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `AssignTanks` (IN srcMatchNumber INT UNSIGNED, IN player VARCHAR(18))
BEGIN
	SET @TerritoriesCount := (SELECT COUNT(nation) FROM Territory WHERE governer = player);
    SET @TanksCountIncrement = CEILING(@TerritoriesCount / 3);
    SET @CurrentTanksCount = (
		SELECT tanksCount 
		FROM Ingame_Players AS IP
		WHERE IP.matchNumber = srcMatchNumber AND IP.player = player
    );
    
    START TRANSACTION;
		UPDATE Ingame_Players AS IP
        SET tanksCount = (@CurrentTanksCount + @TanksCountIncrement)
        WHERE IP.matchNumber = srcMatchNumber AND IP.player = player;
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CheckActionsInTurn
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CheckActionsInTurn`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CheckActionsInTurn` (IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED, IN player VARCHAR(18), OUT anyActionHappened BIT)
BEGIN
	SET @ActionsCount := 0;
	IF player IS NULL THEN
    	SET @ActionsCount := (
			SELECT Count(actionNumber)
			FROM Action AS A
			WHERE A.matchNumber = srcMatchNumber 
			AND A.turnNumber = turnNumber
		);
    ELSE
		SET @ActionsCount := (
			SELECT Count(actionNumber)
			FROM Action AS A
			WHERE A.matchNumber = srcMatchNumber 
			AND A.turnNumber = turnNumber 
			AND A.player = player
		);
	END IF;
    
    IF @ActionsCount > 0 THEN
		SET anyActionHappened = 1;
	ELSE
		SET anyActionHappened = 0;
	END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetMatchParticipants
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetMatchParticipants`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetMatchParticipants` (IN srcMatchNumber INT UNSIGNED,OUT participants INT(3))
BEGIN
	SET participants = (
		SELECT COUNT(player) 
		FROM Ingame_Players AS IP 
		WHERE IP.matchNumber = srcMatchNumber
    );
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetAdjacentNations
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetAdjacentNations`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetAdjacentNations` 
(
	IN nation VARCHAR(32)
)
BEGIN
	SELECT neighbour
    FROM Neighbour_Nations AS NN
    WHERE NN.nation = nation;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure IsNeighbourNation
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`IsNeighbourNation`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `IsNeighbourNation` 
( 
IN srcNation VARCHAR(32), IN targetNation VARCHAR(32), OUT neighbours BIT
)
BEGIN
		SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS 'Are Neighbours?'
        INTO neighbours
		FROM Neighbour_Nations AS NN
		WHERE NN.nation = nation
		AND NN.neighbour = targetNation;		
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetAvailableAttackerNations
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetAvailableAttackerNations`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetAvailableAttackerNations` 
(
	IN srcMatchNumber INT UNSIGNED,IN player VARCHAR(18)
)
BEGIN
	SELECT T.nation
    FROM Territory AS T
    Where T.matchNumber = srcMatchNumber
    AND T.governer = player
	AND T.tanksNumber > 1;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetAttackableNations
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetAttackableNations`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetAttackableNations` 
(
	IN srcMatchNumber INT UNSIGNED,IN player VARCHAR(18)
)
BEGIN
	SELECT DISTINCT NN.neighbour AS 'Your Nations', T.nation AS 'Attackable Neighbour Nations'
    FROM Territory AS T JOIN Neighbour_Nations AS NN
    ON (T.nation = NN.nation)
    Where T.matchNumber = srcMatchNumber
    AND T.governer <> player
    AND NN.neighbour IN (
		SELECT T.nation
		FROM Territory AS T 
		Where T.matchNumber = srcMatchNumber
        AND T.governer = player
        AND T.tanksNumber > 1
    );    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CleanupAbandonedMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CleanupAbandonedMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CleanupAbandonedMatch` (IN srcMatchNumber INT UNSIGNED)
BEGIN

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure EndMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`EndMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `EndMatch` (IN srcMatchNumber INT UNSIGNED, IN srcRoomNumber INT(6))
BEGIN
	START TRANSACTION;
	    UPDATE `Match` SET state = 'finished' WHERE matchNumber = srcMatchNumber;
		#CALL CreateMatch(srcRoomNumber);
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure JoinMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`JoinMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `JoinMatch` (IN roomNumber INT(6) UNSIGNED, IN player VARCHAR(18), OUT joined BIT)
BEGIN
	SET @MatchNumber = (
		SELECT matchNumber
        FROM Room AS R JOIN `Match` AS M
        ON (R.roomNumber = M.roomNumber AND (M.state = 'lobby' OR M.state = 'countdown' ))
        WHERE R.roomNumber = roomNumber
    );
    
    START TRANSACTION;
		IF @MatchNumber IS NULL THEN
			SIGNAL SQLSTATE "45000" SET message_text = "Can't join a match that has already started!";
            ROLLBACK;
        END IF;
    
		CALL GetMatchParticipants(@MatchNumber,@PlayersCount);
        IF @PlayersCount = 6 THEN
			SIGNAL SQLSTATE '45000' SET message_text = 'Joining failed, the match is already full!';
            ROLLBACK;
		ELSEIF @PlayerCount = 2 THEN
			INSERT INTO Ingame_Players(matchNumber,player) VALUES(@MatchNumber,player);
            UPDATE `Match` AS M 
            SET M.state = 'countdown' AND M.matchStartCountdown = CURRENT_TIMESTAMP
            WHERE M.matchNumber = @MatchNumber 
            AND M.roomNumber = roomNumber
            AND M.state = 'lobby';
            COMMIT;
		ELSE
        	INSERT INTO Ingame_Players(matchNumber,player) VALUES(@MatchNumber,player);
            COMMIT;
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure LeaveMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`LeaveMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `LeaveMatch` (IN srcMatchNumber INT UNSIGNED,IN player VARCHAR(18),OUT result BIT)
BEGIN
	START TRANSACTION;
		CALL GetMatchParticipants(@MatchNumber,@PlayersCount);
        IF @PlayersCount > 2 THEN
			SIGNAL SQLSTATE '45000' SET message_text = `Can't leave match after countdown has started!`;
            ROLLBACK;
		ELSE
			DELETE FROM Ingame_Players
            WHERE matchNumber = srcMatchNumber
            AND player = player;
            COMMIT;
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CanNewTurnStart
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CanNewTurnStart`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CanNewTurnStart` 
(
	IN srcMatchNumber INT UNSIGNED,
    IN turnDuration INT(3) UNSIGNED,
    OUT canANewTurnStart BIT
)
BEGIN
	SET canANewTurnStart = 0;
	SET @CurrentTurnStartTime = (
		SELECT turnStartTime
        FROM `Match` AS M JOIN  Turn AS T
        ON (M.matchNumber = T.matchNumber)
        WHERE M.matchNumber = srcMatchNumber
        ORDER BY turnNumber DESC
        LIMIT 1
    );
    
    SET @TimeDifference = TIMESTAMPDIFF(SECOND,
    NOW(),
    (@CurrentTurnStartTime + interval turnDuration SECOND));
    
    IF @TimeDifference < 1 THEN
		SET canANewTurnStart = 1;
	END IF;    
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CanMatchStart
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CanMatchStart`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CanMatchStart` (IN srcMatchNumber INT UNSIGNED, OUT canMatchStart BIT)
BEGIN
	SET canMatchStart = 0;
    SET @CountdownDuration = 2;
	SET @MatchStartCountdownTime = (
		SELECT matchStartCountdown
        FROM `Match` AS M 
        WHERE M.matchNumber = srcMatchNumber
    );
    
    SET @TimeDifference = TIMESTAMPDIFF(SECOND,
    NOW(),
    (@MatchStartCountdownTime + interval @CountdownDuration Minute));
    
    IF @TimeDifference < 1 THEN
		SET canMatchStart = 1;
	END IF;    

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure CanDoNewAction
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`CanDoNewAction`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `CanDoNewAction` 
(	IN srcMatchNumber INT UNSIGNED,
    OUT canDoAction BIT
)
BEGIN
	#SET @TurnDuration = ();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `Risiko`.`Active_Matches_ID`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Active_Matches_ID`;
DROP VIEW IF EXISTS `Risiko`.`Active_Matches_ID` ;
USE `Risiko`;
CREATE  OR REPLACE VIEW `Active_Matches_ID` AS
SELECT matchNumber FROM `Match` as M WHERE state = 'finished';
USE `Risiko`;

DELIMITER $$

USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Room_AFTER_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Room_AFTER_INSERT` AFTER INSERT ON `Room` FOR EACH ROW
BEGIN
	CALL CreateMatch(NEW.roomNumber);
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Match_AFTER_UPDATE` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Match_AFTER_UPDATE` AFTER UPDATE ON `Match` FOR EACH ROW
BEGIN
	IF NEW.state = "finished" THEN
		INSERT INTO `Match`(roomNumber) VALUES (NEW.roomNumber);
    END IF;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Ingame_Players_BEFORE_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Ingame_Players_BEFORE_INSERT` BEFORE INSERT ON `Ingame_Players` FOR EACH ROW
BEGIN
	CALL GetMatchParticipants(NEW.matchNumber,@PlayersCount);
    
    IF @PlayersCount > 5 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Can't join the match, the room is full!";
	END IF;
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS Player;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Player';

SET SQL_MODE = '';
DROP USER IF EXISTS Moderator;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Moderator';

SET SQL_MODE = '';
DROP USER IF EXISTS Login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Login';


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `Risiko`.`User`
-- -----------------------------------------------------
START TRANSACTION;
USE `Risiko`;
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `lastAccess`, `active`) VALUES ('CptPackage', '969e1afbaa4a7942eca272ee31b4cfa1', 'moderator', '2022-01-04 23:54:50', 1);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Risiko`.`Nation`
-- -----------------------------------------------------
START TRANSACTION;
USE `Risiko`;
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Afghanistan');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Africa del Nord');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Africa Meridionale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Africa Orientale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Alaska');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Alberta');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('America Centrale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Argentina');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Australia Occidentale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Australia Orientale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Brasile');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Cina');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Cita');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Congo');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Egitto');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Europa Meridionale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Europa Occidentale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Europa Settentrionale');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Giappone');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Gran Bretagna');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Groenlandia');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('India');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Indonesia');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Islanda');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Jacuzia');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Kamchatka');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Madagascar');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Medio Oriente');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Mongolia');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Nuova Guinea');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Ontario');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Perù');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Quebec');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Scandinavia');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Siam');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Siberia');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Stati Uniti Occidentali');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Stati Uniti Orientali');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Territori del Nord Ovest');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Ucraina');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Urali');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Venezuela');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Risiko`.`Room`
-- -----------------------------------------------------
START TRANSACTION;
USE `Risiko`;
INSERT INTO `Risiko`.`Room` (`roomNumber`, `turnDuration`, `createdBy`) VALUES (1, 20, 'CptPackage');
INSERT INTO `Risiko`.`Room` (`roomNumber`, `turnDuration`, `createdBy`) VALUES (2, 20, 'CptPackage');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Risiko`.`Match`
-- -----------------------------------------------------
START TRANSACTION;
USE `Risiko`;
INSERT INTO `Risiko`.`Match` (`matchNumber`, `roomNumber`, `matchEndTime`, `matchStartCountdown`, `state`, `numberOfPlayers`) VALUES (1, 1, NULL, NULL, 'lobby', 0);
INSERT INTO `Risiko`.`Match` (`matchNumber`, `roomNumber`, `matchEndTime`, `matchStartCountdown`, `state`, `numberOfPlayers`) VALUES (2, 2, NULL, NULL, 'lobby', 0);

COMMIT;

