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
  `active` BIT NOT NULL DEFAULT 0,
  `lastActivity` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `playerIngame` BIT NOT NULL DEFAULT 0,
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
  INDEX `ROOM_NUMBER_DESC` (`roomNumber` DESC),
  INDEX `MATCH_STATE_ASC` (`state` ASC),
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
  `exitTime` TIMESTAMP NULL DEFAULT NULL,
  `unplacedTanks` INT NOT NULL DEFAULT 0,
  `eliminated` BIT NOT NULL DEFAULT 0,
  `entryOrder` INT NOT NULL DEFAULT 1,
  `winner` BIT NOT NULL DEFAULT 0,
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
  PRIMARY KEY (`matchNumber`, `turnNumber`, `player`),
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
  `attackerLostTanks` INT(3) NOT NULL DEFAULT 0,
  `defenderLostTanks` INT(3) NOT NULL DEFAULT 0,
  INDEX `IDX_FK_DEFENDER` (`defenderPlayer` ASC),
  INDEX `IDX_FK_ATTACKER_NATION` (`attackerNation` ASC),
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
  `player` VARCHAR(45) NOT NULL,
  `rollNumber` SMALLINT UNSIGNED NOT NULL,
  `rollValue` SMALLINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`matchNumber`, `turnNumber`, `actionNumber`, `player`, `rollNumber`),
  INDEX `FK_DICE_PLAYER_idx` (`player` ASC),
  CONSTRAINT `FK_DICE_ATTACK`
    FOREIGN KEY (`matchNumber` , `turnNumber` , `actionNumber`)
    REFERENCES `Risiko`.`Combat` (`matchNumber` , `turnNumber` , `actionNumber`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_DICE_PLAYER`
    FOREIGN KEY (`player`)
    REFERENCES `Risiko`.`User` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
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
  INDEX `IDX_FK_OCCUPIER` (`occupier` ASC),
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
-- Placeholder table for view `Risiko`.`Active_Matches_Number`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Risiko`.`Active_Matches_Number` (`matchNumber` INT);

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
CREATE PROCEDURE `Login` (IN username VARCHAR(45),IN password VARCHAR(45), OUT result BIT, OUT role int)
BEGIN
	SET @hashedPassword := md5(password);
    SET @authenticatedRole := null;

    SELECT U.role 
    INTO @authenticatedRole 
    FROM User AS U 
    WHERE U.username = username AND U.password = @hashedPassword;
    
    START TRANSACTION;
    IF @authenticatedRole IS NOT NULL THEN
		SET result = 1;
        IF @authenticatedRole = 'player' THEN
			SET role = 1;
        ELSE
			SET role = 2;
        END IF;
        UPDATE User AS U
        SET lastActivity  = current_timestamp(), active = 1
        WHERE U.username = username AND U.password = @hashedPassword;
        COMMIT;
	ELSE
		SET result = 0;
        SET role = 0;
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
    IN player VARCHAR(45), IN attackerNation VARCHAR(32),
    IN defenderNation VARCHAR(32)
)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
	START TRANSACTION;
   
        SET @IsPlayerTurn = NULL;
        SELECT turnNumber 
        INTO @IsPlayerTurn
        FROM Turn AS T 
        WHERE T.matchNumber = srcMatchNumber 
        AND T.turnNumber = turnNumber
        AND T.player = player;
        
         IF @IsPlayerTurn IS NULL THEN 
			SIGNAL SQLSTATE '45000' SET message_text = `[ERROR] You can't attack on an other player's turn!`;
            ROLLBACK;
        END IF;

		## Check if Nations are neighbours
		##CALL IsNeighbourNation(attackerNation,defenderNation,@AreNeighbours);
        
		##IF @AreNeighbours IS NULL OR @AreNeighbours = 0 THEN 
			##SIGNAL SQLSTATE '45000' SET message_text = `Attacker and Defender nations have to be neighbours!`;
            ##ROLLBACK;
        ##END IF;
        
    
		## Get Attacker Tanks
		SELECT occupier, occupyingTanksNumber into @Attacker, @AttackerTanks
		FROM Territory AS T
		WHERE T.matchNumber = srcMatchNumber
		AND T.nation = attackerNation
        AND T.occupier = player;
        
		##SELECT 'BREAK POINT 3!';
		## Cancel Attack if Source Nation has 1 or less tanks
        IF @AttackerTanks IS NULL THEN 
			SELECT  'Cant attack from a foreign territory!';
			SIGNAL SQLSTATE '45000' SET message_text = `[ERROR] Can't attack from a foreign territory!`;
            ROLLBACK;
        ELSEIF @AttackerTanks = 1 THEN
			SELECT 'Not enough tanks! (At least 1 tank has to defend the territory)';
        	SIGNAL SQLSTATE '45000' SET message_text = `[ERROR] Not enough tanks! (At least 1 tank has to defend the territory)`;
			ROLLBACK;
		END IF;
        

		##SELECT 'BREAK POINT 4!';
		## Calculate Attacker's Dice Count
		CALL GetThrowableDiceCount(@AttackerTanks,@AttackerDiceCount);
		##SELECT concat(@AttackerTanks,',',@AttackerDiceCount);

 
		## Get Defender Tanks
		SELECT occupier, occupyingTanksNumber into @Defender, @DefenderTanks
		FROM Territory AS T
		WHERE T.matchNumber = srcMatchNumber
		AND T.nation = defenderNation;
        
		##SELECT 'BREAK POINT 5!';

        
        IF @Attacker = @Defender THEN
			SELECT 'You cant attack your own nation!';
			SIGNAL SQLSTATE '45000' SET message_text = `You can't attack your own nation!`;
			ROLLBACK;
        END IF;


		## Calculate Defender's Dice Count
		CALL GetThrowableDiceCount(@DefenderTanks,@DefenderDiceCount);
 		##SELECT concat(@DefenderTanks,',',@DefenderDiceCount);
		SET @ActionNumber = 1; ## Protects From adding another action into the same turn
		
		INSERT INTO `Action`(matchNumber,turnNumber,actionNumber,actionType, player,targetNation,tanksNumber)
		VALUES (srcMatchNumber,turnNumber,@ActionNumber, 'combat',@Attacker,defenderNation,@AttackerTanks);
		
        
        INSERT INTO `Combat`(
			matchNumber,turnNumber,actionNumber, attackerNation,defenderPlayer,defenderTanksNumber
        )
		VALUES (
			srcMatchNumber,turnNumber,@ActionNumber,attackerNation,@Defender,@DefenderTanks
        );

		CALL GetCombatResults(
			srcMatchNumber, turnNumber, 
			@Attacker, @AttackerDiceCount,
			@Defender, @DefenderDiceCount,
			@AttackerLostTanks, @DefenderLostTanks
		);	

		IF @AttackerLostTanks > 0 THEN 
			UPDATE Territory AS T
            SET T.occupier = @Attacker, T.occupyingtanksNumber = (@AttackerTanks - @AttackerLostTanks)
            WHERE T.matchNumber = srcMatchNumber
            AND T.nation = attackerNation;
		END IF;
		

		## AttackSuccess defines if the player occupied that nation
		SET @AttackSuccess := CASE WHEN (@DefenderTanks - @DefenderLostTanks) <= 0 THEN 1 ELSE 0 END;
        
        IF @AttackSuccess = 1 THEN
			UPDATE Territory AS T
            SET T.occupier = @Attacker, T.occupyingtanksNumber = (@AttackerDiceCount - @AttackerLostTanks)
            WHERE T.matchNumber = srcMatchNumber
            AND T.nation = defenderNation;
		ELSEIF @DefenderLostTanks > 0 THEN 
			UPDATE Territory AS T
            SET T.occupier = @Defender, T.occupyingtanksNumber = (@DefenderTanks - @DefenderLostTanks)
            WHERE T.matchNumber = srcMatchNumber
            AND T.nation = defenderNation;
        END IF;
        
		
	UPDATE Combat AS C 
	SET attackerLostTanks = @AttackerLostTanks, 
    defenderLostTanks = @DefenderLostTanks,
	succeded = @AttackSuccess
	WHERE C.matchNumber = srcMatchNumber AND C.turnNumber = turnNumber AND C.actionNumber = @ActionNumber;
        
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
    
		SET @DefaultActionNumber = 1;
		SELECT occupyingTanksNumber INTO @AvailableTanks 
		FROM Territory AS T
		WHERE T.matchNumber = srcMatchNumber
		AND T.nation = sourceNation
		AND T.occupier = player;
    
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

        INSERT INTO `Action`(matchNumber,turnNumber,actionNumber,player,targetNation,tanksNumber,actionType)
		VALUES (srcMatchNumber,turnNumber,@DefaultActionNumber,player,targetNation,tanksNumber,'movement');
				
        INSERT INTO `Movement`(matchNumber,turnNumber,actionNumber,sourceNation)
		VALUES (srcMatchNumber,turnNumber,@DefaultActionNumber,sourceNation);
        
        UPDATE Territory
        SET occupyingTanksNumber = (occupyingTanksNumber - tanksNumber)
        WHERE matchNumber = srcMatchNumber AND occupier = player AND nation = sourceNation;
        
        UPDATE Territory
        SET occupyingTanksNumber = (occupyingTanksNumber + tanksNumber)
        WHERE matchNumber = srcMatchNumber AND occupier = player AND nation = targetNation;
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
    IN player VARCHAR(45), IN targetNation VARCHAR(32), IN tanksNumber INT(3)
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
	START TRANSACTION;
        
		SELECT unplacedTanks INTO @AvailableUnplacedTanks
		FROM Ingame_Players AS IP
		WHERE IP.matchNumber = srcMatchNumber
		AND IP.player = player;
		
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
		
        INSERT INTO `Action`(matchNumber,turnNumber,player,actionType, targetNation,tanksNumber)
		VALUES (srcMatchNumber,turnNumber,player,'placement', targetNation,tanksNumber);
        
        UPDATE Ingame_Players AS IP 
        SET unplacedTanks = (@AvailableUnplacedTanks - tanksNumber)
		WHERE IP.matchNumber = srcMatchNumber AND IP.player = player;
        
        
        UPDATE Territory AS T
        SET occupyingTanksNumber = occupyingTanksNumber + tanksNumber
        WHERE T.matchNumber = srcMatchNumber AND T.occupier = player;
    COMMIT;
END$$

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
-- procedure GetActionDetails
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetActionDetails`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetActionDetails` 
(
	IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED, IN actionNumber INT(3) UNSIGNED, IN actionType ENUM('placement', 'movement', 'combat')
)
BEGIN
       IF actionType = 'placement' THEN
			SELECT  A.matchNumber AS 'Match', A.turnNumber AS 'Turn', A.actionNumber AS "Action",
			A.player AS 'Player',A.tanksNumber AS 'Placed Tanks',
            A.targetNation AS 'Placed at'
            FROM Action AS A
            WHERE A.matchNumber = srcMatchNumber AND A.turnNumber = turnNumber and A.actionNumber = actionNumber;
		ELSEIF actionType = 'movement' THEN
        	SELECT A.matchNumber AS 'Match', A.turnNumber AS 'Turn', A.actionNumber AS "Action",
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
            AND A.actionNumber = actionNumber;
		ELSEIF actionType = 'combat' THEN
			SELECT A.matchNumber AS 'Match', A.turnNumber AS 'Turn', A.actionNumber AS "Action",
				 A.player AS 'Attacker', C.attackerNation AS 'Attacker Nation', A.tanksNumber AS 'Attacker Tanks', 
				 C.attackerLostTanks AS 'Attacker Lost Tanks', C.defenderPlayer AS 'Defender', A.targetNation AS 'Defender Nation', C.defenderTanksNumber AS 'Defender Tanks',
				 C.defenderLostTanks AS 'Defender Lost Tanks', C.succeded as 'Nation Occupied'
            FROM `Action` AS A JOIN Combat AS C 
            ON (
				A.matchNumber = C.matchNumber 
				AND A.turnNumber = C.turnNumber
				AND A.actionNumber = C.actionNumber
            )
            WHERE A.matchNumber = srcMatchNumber 
            AND A.turnNumber = turnNumber
            AND A.actionNumber = actionNumber;
		ELSE
			SELECT NULL;
        END IF;
END$$

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
	SET @PlayersCount := (SELECT COUNT(player) FROM Ingame_Players AS IP WHERE IP.matchNumber = srcMatchNumber);
    IF @PlayersCount < 3 THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'A match needs 3 players at least to start!';
    END IF;
    
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
            AND IP.eliminated = 0
			ORDER BY entryTime ASC LIMIT 1;
		ELSE
			SELECT player INTO playerUsername 
			FROM Ingame_Players AS IP 
			WHERE IP.matchNumber = srcMatchNumber
            AND IP.exitTime IS NULL
            AND IP.eliminated = 0
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
    SET @PlayersCount = 0;
    
	SELECT occupier
    INTO @Conquerer
    FROM Territory AS T
    WHERE T.matchNumber = srcMatchNumber
    GROUP BY occupier
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
    DECLARE currentPlayer VARCHAR(45);
    DECLARE currentNation VARCHAR(32);
	
    DECLARE playersCursor CURSOR FOR SELECT player FROM Ingame_Players AS IP WHERE IP.matchNumber = srcMatchNumber AND IP.exitTime IS NULL AND eliminated = 0;

    DECLARE nationsCursor CURSOR FOR SELECT name FROM Nation AS N ORDER BY RAND();

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET playersScanned = 1;
    
	SET @PlayersCount := (SELECT numberOfPlayers FROM `Match` WHERE matchNumber = srcMatchNumber);
    SET @NationsCount := (SELECT COUNT(name) FROM Nation);
    SET @NationsPerPlayer := FLOOR(@NationsCount / @PlayersCount);
    SET @AssignedCount := 0; #Number of nations assigned to the current player.
    SET @ResidueNations := MOD(@NationsCount,@PlayersCount); # As Nations are "42" AND with 4/5 players,
							  # we have 40 Nations assigned AND 2 Unassigned (Residue) nations!    
	SET @TanksNumberPerPlayer = 20 + (5 * (6 - @PlayersCount)); # As 3 Players = 35 Tanks, 6 players = 20 tanks
    SET @ExtraAssignableTanksPerPlayer = @TanksNumberPerPlayer - @NationsPerPlayer;
    SET @RemainingTanksPerPlayer = @TanksNumberPerPlayer;
	SET @CurrentTanksNumber = 1;
    
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
                
                IF  @RemainingTanksPerPlayer <= (@NationsPerPlayer - @AssignedCount) THEN
					SET @CurrentTanksNumber = 1;
				ELSE
					SET @RandomTanksNumber = TRUNCATE(RAND()*(4-1)+1,0); ## 1 <= RAND <= 4

					IF @RandomTanksNumber > @RemainingTanksPerPlayer
                    OR (@RemainingTanksPerPlayer - @RandomTanksNumber) < (@NationsPerPlayer - @AssignedCount)
                    THEN
						SET @CurrentTanksNumber = 1;
					ELSE
						SET @CurrentTanksNumber = @RandomTanksNumber; 
                    END IF;
				END IF;
                SET @RemainingTanksPerPlayer = @RemainingTanksPerPlayer - @CurrentTanksNumber;
                
                IF @AssignedCount < @NationsPerPlayer THEN
						FETCH nationsCursor INTO currentNation;
						CALL AssignTerritory(srcMatchNumber,currentPlayer,currentNation,@CurrentTanksNumber);
                        SET @AssignedCount = (@AssignedCount + 1);
				END IF;
                
                IF  @AssignedCount = @NationsPerPlayer THEN                
					IF @ResidueNations > 0 THEN 
						FETCH nationsCursor INTO currentNation;
						SET @RemainingTanksPerPlayer = @RemainingTanksPerPlayer - @CurrentTanksNumber;
						CALL AssignTerritory(srcMatchNumber,currentPlayer,currentNation,@CurrentTanksNumber);
						SET @AssignedCount = (@AssignedCount + 1);
						SET @ResidueNations = (@ResidueNations - 1);						
					END IF;
                        
					IF @RemainingTanksPerPlayer > 0 THEN
						UPDATE Ingame_Players SET unplacedTanks = @RemainingTanksPerPlayer	WHERE matchNumber = srcMatchNumber AND player = currentPlayer;
                    END IF;
                    
                    LEAVE nationsLoop;
                END IF;
            END LOOP nationsLoop;
			SET @AssignedCount = 0;
			SET @RemainingTanksPerPlayer = @TanksNumberPerPlayer;
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
	DECLARE currentMatchNumber INT;
	DECLARE currentTurnNumber INT;
	DECLARE currentTurnPlayer VARCHAR(45);
	DECLARE currentTurnStartTime timestamp;
	DECLARE currentTurnDuration int;
    DECLARE finished INT DEFAULT 0;
    DECLARE turnsOffset INT DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

	CREATE TEMPORARY TABLE IF NOT EXISTS Full_Scan_Logs (
		lastScanTime TIMESTAMP,
		primary key(lastScanTime)
	);

	CREATE TEMPORARY TABLE IF NOT EXISTS To_Check_Matches (
		matchNumber INT, 
		roomNumber INT,
		turnDuration INT,
		numberOfPlayers INT,
		lastChecked timestamp,
		PRIMARY KEY(roomNumber),
		INDEX MatchIndex(matchNumber)
	);

	CREATE TEMPORARY TABLE IF NOT EXISTS Current_Check_Turns(
		matchNumber INT,
		turnNumber INT,
		turnDuration INT,
		turnStartTime TIMESTAMP,
		turnExpirationTime TIMESTAMP,
		currentPlayer VARCHAR(45),
		PRIMARY KEY(matchNumber)
	);

	SET @LastScanTime = NULL;

	SELECT lastScanTime INTO @LastScanTime
    FROM Full_Scan_Logs ORDER BY lastScanTime DESC;

	IF @LastScanTime IS NULL OR (@LastScanTime + INTERVAL 90 SECOND) <= current_timestamp() THEN
		## FULL SCAN ROOMS AND MATCHES
		REPLACE INTO To_Check_Matches(roomNumber,matchNumber,turnDuration, numberOfPlayers, lastChecked)
		SELECT R.roomNumber, M.matchNumber, R.turnDuration, M.numberOfPlayers, current_timestamp()
		FROM Room AS R
		JOIN `Match` AS M
		ON R.roomNumber = M.roomNumber AND M.state = 'started'
		ORDER BY matchNumber DESC;

		##SCAN ALL TURNS
        REPLACE INTO Current_Check_Turns(matchNumber, turnNumber, turnDuration, turnStartTime, turnExpirationTime, currentPlayer)
		SELECT TCA.matchNumber, T.turnNumber, TCA.turnDuration,
		T.turnStartTime, (T.turnStartTime + INTERVAL TCA.turnDuration SECOND) AS 'turnExpirationTime', T.player
		FROM To_Check_Matches AS TCA
		JOIN Turn AS T
		ON T.turnNumber = (
			SELECT turnNumber
			FROM Turn
			WHERE matchNumber = TCA.matchNumber
			ORDER BY turnNumber DESC
			LIMIT 1
		) AND T.matchNumber = TCA.matchNumber;
        TRUNCATE Full_Scan_Logs;
        INSERT INTO Full_Scan_Logs(lastScanTime) VALUES (current_timestamp());
	ELSE 
		CREATE TEMPORARY TABLE Partial_Updates 
        SELECT TCA.roomNumber, M.matchNumber, TCA.turnDuration, M.numberOfPlayers, current_timestamp()
		FROM To_Check_Matches AS TCA
		JOIN `Match` AS M
		ON TCA.roomNumber = M.roomNumber AND M.state = 'started'
		WHERE TCA.numberOfPlayers < 3 
        AND (TCA.lastChecked + INTERVAL TCA.turnDuration SECOND) <= current_timestamp();
		
        REPLACE INTO To_Check_Matches(roomNumber,matchNumber,turnDuration, numberOfPlayers, lastChecked)
        SELECT * FROM Partial_Updates;
        
		DROP TEMPORARY TABLE IF EXISTS Partial_Updates;
    END IF;

	SET turnsOffset = 0;

	DROP TEMPORARY TABLE IF EXISTS Updateable_Turns;
  
	CREATE TEMPORARY TABLE Updateable_Turns
	SELECT matchNumber, turnNumber, turnStartTime, turnDuration, currentPlayer
	FROM Current_Check_Turns;
    
    SET @UpdatablesSize = (SELECT COUNT(matchNumber) FROM Updateable_Turns);
    	
	WHILE(turnsOffset < @UpdatablesSize) DO
        	SELECT matchNumber, turnNumber, turnStartTime, turnDuration, currentPlayer
			INTO currentMatchNumber, currentTurnNumber, currentTurnStartTime, 
			currentTurnDuration, currentTurnPlayer
			FROM Updateable_Turns 
			ORDER BY matchNumber
			LIMIT 1 OFFSET turnsOffset;
            
			SELECT matchNumber, turnNumber, turnStartTime, player
			INTO @TempMatchNumber, @TempTurnNumber, @TempTurnStartTime, @TempTurnPlayer
			FROM Turn
			WHERE matchNumber = currentMatchNumber
			ORDER BY turnNumber DESC LIMIT 1;
				
		IF (@TempTurnNumber <> currentTurnNumber 
        OR @TempTurnStartTime > currentTurnStartTime
        OR @TempTurnPlayer <> currentTurnPlayer) 
		AND (@TempTurnStartTime + INTERVAL currentTurnDuration SECOND ) > current_timestamp() THEN
           UPDATE Current_Check_Turns SET turnNumber = @TempTurnNumber,
            turnStartTime = @TempTurnStartTime, currentPlayer = @TempTurnPlayer
			WHERE matchNumber = @TempMatchNumber;
		ELSE    
			IF @TempTurnNumber = currentTurnNumber
			AND	(@TempTurnStartTime + INTERVAL currentTurnDuration SECOND ) < current_timestamp() 
            THEN
				CALL PassTurn(@TempMatchNumber, @TempTurnPlayer);
				SELECT matchNumber, turnNumber, turnStartTime, player
				INTO @TempMatchNumber, @TempTurnNumber, @TempTurnStartTime, @TempTurnPlayer
				FROM Turn
				WHERE matchNumber = currentMatchNumber
				ORDER BY turnNumber DESC LIMIT 1;
               
                
                IF @TempTurnNumber = currentTurnNumber AND  @TempTurnStartTime = currentTurnStartTime THEN
					SET @SuspectedMatchNumber = NULL;
                    SELECT M.matchNumber INTO @SuspectedMatchNumber
                    FROM `Match` AS M
                    WHERE M.matchNumber = currentMatchNumber
					AND M.state = 'started';
					 
                    IF @SuspectedMatchNumber IS NULL THEN
						DELETE FROM Current_Check_Turns WHERE matchNumber = currentMatchNumber;
						DELETE FROM To_Check_Matches WHERE matchNumber = currentMatchNumber;
                ELSE					
					UPDATE Current_Check_Turns SET turnNumber = @TempTurnNumber,
					turnStartTime = @TempTurnStartTime, currentPlayer = @TempTurnPlayer
					WHERE matchNumber = @TempMatchNumber;                
                END IF;
                
				END IF;
			END IF;
		END IF;
            
		SET turnsOffset = turnsOffset + 1;        
	END WHILE;
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
CREATE PROCEDURE `CreateRoom` (IN turnDuration INT(3) UNSIGNED, IN moderatorName VARCHAR(45), OUT createdRoomNumber INT)
BEGIN
	SET @userRole := (SELECT role
    FROM User AS U
	WHERE U.username = moderatorName);

	START TRANSACTION;
        IF @userRole = 'moderator' THEN
			INSERT INTO Room(turnDuration,createdBy) VALUES (turnDuration,moderatorName);
			SET createdRoomNumber = last_insert_id();
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
CREATE PROCEDURE `Logout` (IN username VARCHAR(45))
BEGIN
		SET @IsPlayerIngame = 0;
        SELECT playerIngame INTO @IsPlayerIngame
        FROM User AS U
        WHERE U.username = username;
        IF @IsPlayerIngame <> 0 THEN
			SET @IngameMatchNumber = NULL;
			SELECT matchNumber INTO @IngameMatchNumber
            FROM Ingame_Players AS IP
            WHERE player = username
            AND exitTime IS NULL
            ORDER BY matchNumber DESC
            LIMIT 1;
            
            IF @IngameMatchNumber IS NOT NULL THEN 
				CALL AbandonMatch(@IngameMatchNumber,username);
            END IF;
        END IF;
        

		UPDATE User AS U
		SET active = 0, playerIngame = 0
        WHERE U.username = username;
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
		REPLACE INTO Territory (matchNumber,nation,occupier,occupyingTanksNumber) 
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
CREATE PROCEDURE `CheckActionsInTurn` (IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED, OUT actionsCount INT)
BEGIN
    	SET @actionsCount:= (
			SELECT Count(actionNumber)
			FROM Action AS A
			WHERE A.matchNumber = srcMatchNumber 
			AND A.turnNumber = turnNumber
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
		WHERE NN.nation = srcNation
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
	SELECT T.nation AS 'Nation', T.occupyingTanksNumber AS 'Available Tanks'
    FROM Territory AS T
    Where T.matchNumber = srcMatchNumber
    AND T.occupier = player
	AND T.occupyingTanksNumber > 1;
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
	IN srcMatchNumber INT UNSIGNED,IN player VARCHAR(45), IN attackerNation VARCHAR(32)
)
BEGIN
	SELECT T.matchNumber, NN.nation AS 'Nation', NN.neighbour AS 'Neighbour', T.occupier AS 'Occupier', T.occupyingTanksNumber AS 'Occupying Tanks'
	FROM Neighbour_Nations AS NN JOIN Territory AS T ON (NN.neighbour = T.nation AND T.matchNumber = srcMatchNumber) 
	WHERE NN.nation = attackerNation;
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
CREATE PROCEDURE `EndMatch` (IN srcMatchNumber INT UNSIGNED)
BEGIN
	START TRANSACTION;
		SELECT roomNumber INTO @srcRoomNumber FROM `MATCH` WHERE matchNumber = srcMatchNumber;
	    UPDATE `Match` SET state = 'finished' WHERE matchNumber = srcMatchNumber;
		CALL CreateMatch(@srcRoomNumber);
	COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure JoinRoom
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`JoinRoom`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `JoinRoom` (IN roomNumber INT(6) UNSIGNED, IN player VARCHAR(45), OUT joined BIT)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
			ROLLBACK;
            RESIGNAL;
    END;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SET joined = 0;
	SELECT matchNumber 
    INTO @MatchNumber
    FROM `Match` as M
    WHERE M.roomNumber = roomNumber AND (M.state = 'lobby' OR M.state = 'countdown')
    ORDER BY M.matchNumber DESC
    LIMIT 1;
	REPLACE INTO Ingame_Players(matchNumber,player,exitTime) 
    VALUES(@MatchNumber,player, NULL);
    CALL UpdatePlayerActivity(player);
    SET joined = 1;
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
        SELECT state
        INTO @MatchState
        FROM `Match`
        WHERE matchNumber = srcMatchNumber;
        
        IF @PlayersCount > 2 OR @MatchState = 'countdown' THEN
			SIGNAL SQLSTATE '45000' SET message_text = `Can't leave match after countdown has started!`;
		ELSE
			UPDATE Ingame_Players SET exitTime=current_timestamp()
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
-- procedure GetStartedMatchesNumber
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetStartedMatchesNumber`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetStartedMatchesNumber` (IN numberOfMatches INT)
BEGIN
	SELECT COUNT(matchNumber)
    INTO numberOfMatches
    FROM `Match` AS M
    WHERE M.state = 'started'
    GROUP BY state;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetActivePlayersCount
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetActivePlayersCount`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetActivePlayersCount` (OUT numberOfPlayers INT)
BEGIN
	SELECT COUNT(username)
    INTO numberOfPlayers
    FROM User AS U
    WHERE U.active = 1
    AND U.role = 'player';
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetJoinableRooms
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetJoinableRooms`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetJoinableRooms` (IN PageSize INT)
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET TRANSACTION READ ONLY;
	SELECT matchNumber, roomNumber, numberOfPlayers, CASE WHEN state = 'lobby' THEN 0 ELSE 1 END as 'state'
    FROM `Match` AS M
    WHERE M.state = 'lobby'
    OR M.state = 'countdown'
    AND M.numberOfPlayers < 6
    LIMIT PageSize;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetTurnActions
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetTurnActions`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetTurnActions` (IN srcMatchNumber INT UNSIGNED, IN turnNumber INT(3) UNSIGNED)
BEGIN
	SELECT 
    A.matchNumber AS 'Match', A.turnNumber AS 'Turn', A.actionNumber AS "Action",
    A.player AS 'Player', A.targetNation AS 'Target', A.tanksNumber AS 'Tanks'
    FROM Action AS A
    WHERE A.matchNumber = srcMatchNumber
    AND A.turnNumber = turnNumber;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure RollDice
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`RollDice`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `RollDice` ()
BEGIN	
CREATE TEMPORARY TABLE IF NOT EXISTS Rolls(
    roll_value INT,
    player VARCHAR(45)
);

INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player1');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player1');
INSERT INTO Rolls(roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player1');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player2');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player2');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player2');

INSERT INTO Dice_Roll(matchNumber, turnNumber, actionNumber, player, rollValue)  
SELECT 1,1,1,R.player,R.roll_value from Rolls AS R where player = 'player1' ORDER BY R.roll_value DESC;

INSERT INTO Dice_Roll(matchNumber, turnNumber, actionNumber, player, rollValue)  
SELECT 1,1,1,R.player,R.roll_value from Rolls AS R where player = 'player2' ORDER BY R.roll_value DESC;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetThrowableDiceCount
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetThrowableDiceCount`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetThrowableDiceCount` (IN tanksNumber INT, OUT diceCount INT)
BEGIN	
	SET @TanksNumber = tanksNumber;
	SET @MaximumDice = 3;
	SET @ActualDice = CASE WHEN @TanksNumber > 1 THEN @TanksNumber - 1 ELSE 1 END;
	SET @Dice = CASE WHEN @ActualDice <= @MaximumDice THEN @ActualDice ELSE @MaximumDice END;
    SET diceCount = @Dice;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetCombatResults
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetCombatResults`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetCombatResults` (
IN srcMatchNumber INT, IN turnNumber INT,
IN attackerPlayer VARCHAR(45), IN attackerDiceCount INT,
IN defenderPlayer VARCHAR(45), IN defenderDiceCount INT,
OUT attackerLostTanks INT, OUT defenderLostTanks INT 
)
BEGIN
	SET attackerLostTanks = 0;
    SET defenderLostTanks = 0;
    SET @defaultActionNumber = 1;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS Rolls(
		roll_value INT,
		player VARCHAR(45)
	);
    
    CREATE TEMPORARY TABLE IF NOT EXISTS Results(
		player VARCHAR(45),
        lostTanks INT
	);

	SET @I = 0;
	## Do Attacker Rolls
    WHILE @I < attackerDiceCount DO
		INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0), attackerPlayer);
        SET @I = @I + 1;
    END WHILE;

	SET @I = 0;
	## Do Defender Rolls
    WHILE @I < defenderDiceCount DO
		INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0), defenderPlayer);
		SET @I = @I + 1;
    END WHILE;

	INSERT INTO Dice_Roll(matchNumber, turnNumber, actionNumber, player, rollValue)  
	SELECT srcMatchNumber,turnNumber,1,R.player,R.roll_value 
    FROM Rolls AS R 
    WHERE player = attackerPlayer 
    ORDER BY R.roll_value DESC;

	INSERT INTO Dice_Roll(matchNumber, turnNumber, actionNumber, player, rollValue)  
	SELECT srcMatchNumber,turnNumber,1,R.player,R.roll_value 
	FROM Rolls AS R 
	WHERE player = defenderPlayer 
	ORDER BY R.roll_value DESC;
	
	INSERT INTO Results(player,lostTanks)
	SELECT CASE WHEN (DR1.rollValue - DR2.rollValue > 0) THEN DR2.player ELSE DR1.player END AS 'player',
	(count(*)) AS 'lostTanks'
	 FROM Dice_Roll AS DR1 
	JOIN Dice_Roll AS DR2
	ON DR1.rollNumber = DR2.rollNumber
	AND DR1.matchNumber = DR2.matchNumber
	AND DR1.turnNumber = DR2.turnNumber
	AND DR1.actionNumber = DR2.actionNumber
	AND DR2.player = defenderPlayer
	WHERE DR1.matchNumber = srcMatchNumber
	AND DR1.turnNumber = turnNumber
	AND DR1.actionNumber = @defaultActionNumber
	AND DR1.player = attackerPlayer
	group by player;
    
    SELECT coalesce(lostTanks,0) INTO attackerLostTanks
    FROM Results WHERE player = attackerPlayer;
    
    SELECT coalesce(lostTanks,0) INTO defenderLostTanks
    FROM Results WHERE player = defenderPlayer;
    
	DROP TABLE Rolls;
	DROP TABLE Results;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure UpdatePlayerActivity
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`UpdatePlayerActivity`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `UpdatePlayerActivity` (IN player VARCHAR(45))
BEGIN
	UPDATE User SET lastActivity = current_timestamp() WHERE username = player;
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure PassTurn
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`PassTurn`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `PassTurn` (IN matchNumber INT, IN currentTurnPlayer VARCHAR(45))
BEGIN
 		SET @NextTurnPlayer = NULL;
        
		DROP TEMPORARY TABLE IF EXISTS Game_Players;
        CREATE TEMPORARY TABLE Game_Players (
			player varchar(45),
			entryOrder int,
            PRIMARY KEY(player)
        );
        
        INSERT INTO Game_Players
        SELECT player, entryOrder
        FROM Ingame_Players AS IP
        WHERE IP.matchNumber = matchNumber
        AND IP.exitTime IS NULL
        AND eliminated = 0
        AND winner = 0
        ORDER BY entryOrder ASC;
        
        SELECT MAX(entryOrder) INTO @MaxPlayerOrder
        FROM Game_Players;
        
        SELECT entryOrder INTO @CurrentPlayerOrder
        FROM Game_Players
        WHERE player = currentTurnPlayer;
        
        ## When the current turn player has abandoned the match during his turn
        IF @CurrentPlayerOrder IS NULL THEN 
		SELECT entryOrder INTO @CurrentPlayerOrder
			FROM Ingame_Players AS IP
			WHERE IP.matchNumber = matchNumber            
            AND IP.player = currentTurnPlayer
            ORDER BY matchNumber DESC
            LIMIT 1;
        END IF;
                
        IF @CurrentPlayerOrder = @MaxPlayerOrder THEN
			SELECT player INTO @NextTurnPlayer
            FROM Game_Players
            WHERE player <> currentTurnPlayer
            ORDER BY entryOrder ASC
            LIMIT 1;
		ELSE
			SELECT player INTO @NextTurnPlayer
            FROM Game_Players
            WHERE entryOrder > @CurrentPlayerOrder
            ORDER BY entryOrder ASC
            LIMIT 1;
        END IF;
        
        IF @NextTurnPlayer IS NOT NULL THEN
	        INSERT Turn(matchNumber,player) VALUES (matchNumber,@NextTurnPlayer);
        END IF;
        
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ExitRoom
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`ExitRoom`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `ExitRoom` (IN roomNumber INT, IN player VARCHAR(45),OUT result INT)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
			ROLLBACK;
            RESIGNAL;
    END;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SET @MatchNumber = NULL;
    SET result = 0;
    
    SELECT matchNumber 
    INTO @MatchNumber
    FROM `Match` as M
    WHERE M.roomNumber = roomNumber AND M.state = 'lobby'
    ORDER BY M.matchNumber DESC
    LIMIT 1;
    
	IF @MatchNumber = NULL THEN
		SIGNAL SQLSTATE '45000' SET message_text = `[ERROR] Can't leave a Room with a started Match!`;
		ROLLBACK;
    END IF;
    
    
    UPDATE Ingame_Players AS IP
    SET exitTime = current_timestamp()
    WHERE IP.matchNumber = @MatchNumber AND IP.player = player;
	
    
    
	UPDATE `Match` AS M
    SET numberOfPlayers = (numberOfPlayers - 1)
    WHERE M.matchNumber = @MatchNumber;

    CALL UpdatePlayerActivity(player);
    SET result = 1;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure AbandonMatch
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`AbandonMatch`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `AbandonMatch` (IN srcMatchNumber INT, IN player VARCHAR(45))
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
			ROLLBACK;
            RESIGNAL;
    END;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	SET @FoundPlayer = NULL;    
	SELECT IP.player, IP.exitTime, IP.eliminated INTO @FoundPlayer, @PlayerExitTime,@PlayerEliminated
    FROM Ingame_Players AS IP
    WHERE IP.matchNumber = srcMatchNumber AND IP.player = player;
    
    IF @FoundPlayer IS NULL THEN
		SIGNAL SQLSTATE '45000' SET message_text = `[ERROR] You're are not a part of this room!`;
		ROLLBACK;
	END IF;
    
    IF @PlayerExitTIme IS NOT NULL OR @PlayerEliminated <> 0 THEN
		SIGNAL SQLSTATE '45000' SET message_text = `[ERROR] Can't abandon a match you don't belong to!`;
		ROLLBACK;
	END IF;
           
    UPDATE Ingame_Players AS IP
    SET unplacedTanks = 0, eliminated = 1
    WHERE IP.matchNumber = srcMatchNumber AND IP.player = player AND IP.winner = 0;
    
    UPDATE Territory AS T
    SET occupyingTanksNumber = 1
    WHERE T.matchNumber = srcMatchNumber AND T.occupier = player;
    
	UPDATE `Match` AS M
	SET numberOfPlayers = (numberOfPlayers - 1)
	WHERE M.matchNumber = srcMatchNumber;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetStartedMatchesAndPlayers
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetStartedMatchesAndPlayers`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetStartedMatchesAndPlayers` (OUT numberOfStartedMatches INT,OUT numberOfIngamePlayers INT)
BEGIN
	SELECT count(matchNumber),COALESCE(sum(numberOfPlayers),0)
    INTO numberOfStartedMatches, numberOfIngamePlayers
	FROM `Match`
	WHERE state = 'started'
	ORDER BY matchNumber DESC;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetRecentlyActivePlayers
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetRecentlyActivePlayers`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetRecentlyActivePlayers` (OUT numberOfRecentlyActive INT)
BEGIN
	SET @TimeLowerBound = (current_timestamp() - INTERVAL 15 MINUTE);
	SELECT count(username) 
    INTO numberOfRecentlyActive
    FROM User
	WHERE active = 1
	AND playerIngame = 0
	AND lastActivity >= @TimeLowerBound
    AND role = 'player';
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetRoomsCount
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetRoomsCount`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetRoomsCount` (OUT roomsCount INT)
BEGIN
	SELECT count(roomNumber) INTO roomsCount 
    FROM Room;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure GetPlayerHistory
-- -----------------------------------------------------

USE `Risiko`;
DROP procedure IF EXISTS `Risiko`.`GetPlayerHistory`;

DELIMITER $$
USE `Risiko`$$
CREATE PROCEDURE `GetPlayerHistory` (IN player VARCHAR(45))
BEGIN
	SELECT IP.matchNumber AS 'Match Number', M.roomNumber AS 'Room Number',
	(M.matchStartCountdown + INTERVAL 2 MINUTE) AS 'Match Start Time',
	CASE WHEN IP.winner THEN M.matchEndTime ELSE IP.exitTime END as 'Exit Time',
	CASE WHEN IP.winner = 1 THEN 1 ELSE 0 END as 'Result'
	FROM Ingame_Players AS IP
	JOIN `Match` AS M
	ON IP.matchNumber = M.matchNumber
	WHERE IP.player = player
	AND (IP.exitTime IS NOT NULL OR IP.winner = 1);
    
    CALL UpdatePlayerActivity(player);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `Risiko`.`Active_Matches_Number`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Risiko`.`Active_Matches_Number`;
DROP VIEW IF EXISTS `Risiko`.`Active_Matches_Number` ;
USE `Risiko`;
CREATE  OR REPLACE VIEW `Active_Matches_Number` AS
SELECT matchNumber FROM `Match` as M WHERE state = 'started';
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
DROP TRIGGER IF EXISTS `Risiko`.`Match_BEFORE_UPDATE` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Match_BEFORE_UPDATE` BEFORE UPDATE ON `Match` FOR EACH ROW
BEGIN
	IF NEW.numberOfPlayers >= 3 AND NEW.state = 'lobby' THEN
		SET NEW.state = 'countdown';
        SET NEW.matchStartCountdown = current_timestamp();
	END IF;

    IF  NEW.state = 'started' AND NEW.numberOfPlayers <= 1 THEN
    	SET NEW.state = 'finished';
        SET NEW.matchEndTime = current_timestamp();
    END IF;
    
    IF NEW.numberOfPlayers < 0 THEN
		SET NEW.numberOfPlayers = 0;
	END IF;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Match_AFTER_UPDATE` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Match_AFTER_UPDATE` AFTER UPDATE ON `Match` FOR EACH ROW
BEGIN
	# @MatchJustStarted - Makes sure new Territories aren't generated on match updates
    # @ToleranceSeconds - Makes sure that Match gets started if there was lag up to 4 Seconds
    # Production Note: Change 2 SECOND to 2 MINUTE AND Tolerance Seconds to 2 OR 4 Seconds
    SET @ToleranceSeconds = 4;
	SET @MatchJustStarted = ((NEW.matchStartCountdown + INTERVAL 2 SECOND)  - current_timestamp()) + @ToleranceSeconds > 0;
    IF NEW.state = 'started' AND @MatchJustStarted = 1 THEN
		CALL GenerateTerritories(NEW.matchNumber);
        SELECT IP.player INTO @PreviousTurnPlayer
        FROM Ingame_Players AS IP
        WHERE IP.matchNumber = NEW.matchNumber
        AND IP.exitTime IS NULL AND IP.eliminated = 0
		ORDER BY IP.entryOrder DESC
        LIMIT 1;
        CALL PassTurn(NEW.matchNumber,@PreviousTurnPlayer);
    END IF;
    
	IF  NEW.state = 'finished' AND NEW.numberOfPlayers = 1 THEN
		UPDATE Ingame_Players AS IP
		SET winner = 1
		WHERE IP.matchNumber = NEW.matchNumber 
        AND IP.eliminated = 0
		ORDER BY exitTime ASC LIMIT 1;
    END IF;
 
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Ingame_Players_BEFORE_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Ingame_Players_BEFORE_INSERT` BEFORE INSERT ON `Ingame_Players` FOR EACH ROW
BEGIN
	SET @MatchNumber = NULL;

	SELECT matchNumber, numberOfPlayers INTO @MatchNumber,@PlayersCount
	FROM `Match` AS M
	WHERE M.matchNumber = NEW.matchNumber 
	AND (M.state = 'lobby' OR M.state = 'countdown');
     
	IF @MatchNumber IS NULL THEN
		SIGNAL SQLSTATE "45000" SET message_text = "Can't join a match that has already started!";
	END IF;
    
    ##SELECT numberOfPlayers
    ##into @PlayersCount
    ##FROM `Match`
    ##WHERE matchNumber = NEW.matchNumber;
    
    SET @AlreadyInside = NULL;
    
	SELECT player
	INTO @AlreadyInside
	FROM Ingame_Players AS IP
	WHERE IP.matchNumber = @MatchNumber
	AND IP.player = NEW.player
	AND IP.exitTime IS NULL;
	
    If @AlreadyInside IS NOT NULL THEN
		SIGNAL SQLSTATE "45000" SET message_text = "Can't join a match that you are already in!";
	END IF;  
   

    IF @PlayersCount >= 6 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Can't join the match, the room is full!";
    ELSE
    
			SET @LastOrder = NULL;
            
			SELECT entryOrder INTO @LastOrder
            FROM Ingame_Players 
            WHERE matchNumber = NEW.matchNumber
            ORDER BY entryOrder DESC
            LIMIT 1;
            IF @LastOrder IS NULL THEN
				SET @LastOrder = 0;
            END IF;
            SET NEW.entryOrder = @LastOrder + 1;
    END IF;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Ingame_Players_AFTER_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Ingame_Players_AFTER_INSERT` AFTER INSERT ON `Ingame_Players` FOR EACH ROW
BEGIN
		UPDATE `Match` SET numberOfPlayers = (numberOfPlayers + 1) WHERE matchNumber = NEW.matchNumber AND (state = 'lobby' OR state = 'countdown');
		UPDATE User SET playerIngame = 1 WHERE username = NEW.player;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Ingame_Players_BEFORE_UPDATE` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Ingame_Players_BEFORE_UPDATE` BEFORE UPDATE ON `Ingame_Players` FOR EACH ROW
BEGIN
	IF NEW.winner = 1 THEN
		SET NEW.unplacedTanks = 0;
    END IF;

	IF NEW.eliminated = 1 AND NEW.exitTime IS NULL THEN
		SET NEW.exitTime = current_timestamp();
        SET NEW.unplacedTanks = 0;
	END IF;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Ingame_Players_AFTER_UPDATE` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Ingame_Players_AFTER_UPDATE` AFTER UPDATE ON `Ingame_Players` FOR EACH ROW
BEGIN    
	IF NEW.eliminated = 1 OR NEW.exitTime IS NOT NULL THEN	
		SET @RemainingPlayersCount = NULL;
        
		SELECT count(player) INTO @RemainingPlayersCount
		FROM Ingame_Players
		WHERE matchNumber = NEW.matchNumber
        AND exitTime IS NULL;
        
		IF @RemainingPlayersCount <= 1 THEN
			SET @RoomNumber = NULL;
            SELECT roomNumber into @RoomNumber
			FROM `Match`
			WHERE matchNumber = NEW.matchNumber
            AND state = 'started';
			IF @RoomNumber IS NOT NULL THEN
				INSERT `Match`(roomNumber) VALUES (@RoomNumber);
            END IF;
		END IF;
	END IF;
    
    
	IF NEW.winner = 1 OR NEW.eliminated = 1 OR NEW.exitTime IS NOT NULL THEN
		UPDATE User SET playerIngame = 0 WHERE username = NEW.player;
    END IF;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Turn_BEFORE_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Turn_BEFORE_INSERT` BEFORE INSERT ON `Turn` FOR EACH ROW
BEGIN
	SET @LastTurnNumber = 0;
    
	SELECT coalesce(turnNumber,0) INTO @LastTurnNumber
    FROM Turn AS T
    WHERE T.matchNumber = NEW.matchNumber 
    ORDER BY T.turnNumber DESC
    LIMIT 1;
    
    SET NEW.turnNumber = @LastTurnNumber + 1;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Action_BEFORE_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Action_BEFORE_INSERT` BEFORE INSERT ON `Action` FOR EACH ROW
BEGIN
	SET @LastActionNumber = 0;

#	SET @LastActionNumber = 0;
#	SELECT coalesce(actionNumber,0) INTO @LastActionNumber
#    FROM Action AS A
#    WHERE A.matchNumber = NEW.matchNumber
#    AND A.turnNumber = NEW.turnNumber
#    ORDER BY A.actionNumber DESC
#    LIMIT 1;
    SET NEW.actionNumber = @LastActionNumber + 1;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Action_AFTER_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Action_AFTER_INSERT` AFTER INSERT ON `Action` FOR EACH ROW
BEGIN
	SET @TerritoriesCount = 0;
    
	SELECT count(*) INTO @TerritoriesCount
	FROM Territory
	WHERE matchNumber = NEW.matchNumber
	AND occupier = NEW.player;
    
	SET @TerritoriesCount = CEILING(@TerritoriesCount / 3);
            
	UPDATE Ingame_Players
	SET unplacedTanks = (unplacedTanks + @TerritoriesCount)
	WHERE matchNumber = NEW.matchNumber
	AND player = NEW.player;
    
	CALL PassTurn(NEW.matchNumber,NEW.player);
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Combat_AFTER_UPDATE` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Combat_AFTER_UPDATE` AFTER UPDATE ON `Combat` FOR EACH ROW
BEGIN
	IF NEW.succeded = 1 THEN
		SET @RemainingDefenderNations = 0;
		SELECT count(nation) INTO @RemainingDefenderNations
        FROM Territory AS T
        WHERE T.matchNumber = NEW.matchNumber
        AND T.occupier = NEW.defenderPlayer;
        
        IF @RemainingDefenderNations = 0 THEN
			UPDATE Ingame_Players 
            SET eliminated = 1
            WHERE matchNumber = NEW.matchNumber
            AND player = NEW.defenderPlayer;
            
		## WHEN DEFEATED:
        ## Minus 1 when a player has lost his last tank on his last territory
        UPDATE `Match` SET numberOfPlayers = (numberOfPlayers - 1)
        WHERE matchNumber = NEW.matchNumber;
        END IF;
    END IF;
END$$


USE `Risiko`$$
DROP TRIGGER IF EXISTS `Risiko`.`Dice_Roll_BEFORE_INSERT` $$
USE `Risiko`$$
CREATE DEFINER = CURRENT_USER TRIGGER `Risiko`.`Dice_Roll_BEFORE_INSERT` BEFORE INSERT ON `Dice_Roll` FOR EACH ROW
BEGIN
	SET @LastRollNumber = 0;

	SELECT coalesce(rollNumber,0) INTO @LastRollNumber
    FROM Dice_Roll AS DR
    WHERE DR.matchNumber = NEW.matchNumber 
    AND DR.turnNumber = NEW.turnNumber
    AND DR.actionNumber = NEW.actionNumber
    AND DR.player = NEW.player
    ORDER BY DR.rollNumber DESC
    LIMIT 1;
    
    SET NEW.rollNumber = @LastRollNumber + 1;
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS Player;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Player' IDENTIFIED BY 'player_pass';

GRANT EXECUTE ON procedure `Risiko`.`CreatePlayer` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`AnyForwardTurns` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`Logout` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`RollDice` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`PlaceTanks` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`PassTurn` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`Move` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`JoinRoom` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`LeaveMatch` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`AbandonMatch` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`EndMatch` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`GetJoinableRooms` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`GetAdjacentNations` TO 'Player';
GRANT EXECUTE ON procedure `Risiko`.`GetPlayerHistory` TO 'Player';
SET SQL_MODE = '';
DROP USER IF EXISTS Moderator;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Moderator' IDENTIFIED BY 'mod_pass';

GRANT EXECUTE ON procedure `Risiko`.`Logout` TO 'Moderator';
GRANT EXECUTE ON procedure `Risiko`.`GetActivePlayersCount` TO 'Moderator';
GRANT EXECUTE ON procedure `Risiko`.`CreateRoom` TO 'Moderator';
GRANT EXECUTE ON procedure `Risiko`.`GetRecentlyActivePlayers` TO 'Moderator';
GRANT EXECUTE ON procedure `Risiko`.`GetStartedMatchesAndPlayers` TO 'Moderator';
GRANT EXECUTE ON procedure `Risiko`.`GetRoomsCount` TO 'Moderator';
SET SQL_MODE = '';
DROP USER IF EXISTS Login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'Login' IDENTIFIED BY 'login_pass';

GRANT EXECUTE ON procedure `Risiko`.`Login` TO 'Login';
GRANT EXECUTE ON procedure `Risiko`.`Logout` TO 'Login';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `Risiko`.`User`
-- -----------------------------------------------------
START TRANSACTION;
USE `Risiko`;
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('CptPackage', '4297f44b13955235245b2497399d7a93', 'moderator', 1, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player1', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player2', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player3', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player4', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player5', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player6', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player7', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player8', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player9', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('player10', '4297f44b13955235245b2497399d7a93', 'player', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod1', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod2', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod3', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod4', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod5', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod6', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod7', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod8', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod9', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);
INSERT INTO `Risiko`.`User` (`username`, `password`, `role`, `active`, `lastActivity`, `playerIngame`) VALUES ('mod10', '4297f44b13955235245b2497399d7a93', 'moderator', 0, DEFAULT, DEFAULT);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Risiko`.`Nation`
-- -----------------------------------------------------
START TRANSACTION;
USE `Risiko`;
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Afghanistan');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Africa del Nord');
INSERT INTO `Risiko`.`Nation` (`name`) VALUES ('Africa del Sud');
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
-- Data for table `Risiko`.`Neighbour_Nations`
-- -----------------------------------------------------
START TRANSACTION;
USE `Risiko`;
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Afghanistan', 'Cina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Afghanistan', 'Medio Oriente');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Afghanistan', 'Urali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Afghanistan', 'Ucraina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Nord', 'Egitto');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Nord', 'Europa Occidentale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Nord', 'Europa Meridionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Nord', 'Congo');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Nord', 'Africa Orientale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Nord', 'Brasile');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Sud', 'Africa Orientale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Sud', 'Congo');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Africa del Sud', 'Madagascar');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Alaska', 'Alberta');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Alaska', 'Kamchatka');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Alaska', 'Territori del Nord Ovest');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Alberta', 'Alaska');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Alberta', 'Stati Uniti Occidentali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Alberta', 'Ontario');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Alberta', 'Territori del Nord Ovest');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('America Centrale', 'Stati Uniti Occidentali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('America Centrale', 'Stati Uniti Orientali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('America Centrale', 'Venezuela');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Argentina', 'Perù');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Argentina', 'Brasile');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Australia Occidentale', 'Indonesia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Australia Occidentale', 'Nuova Guinea');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Australia Occidentale', 'Australia Orientale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Australia Orientale', 'Australia Occidentale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Australia Orientale', 'Nuova Guinea');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Brasile', 'Africa del Nord');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Brasile', 'Argentina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Brasile', 'Perù');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Brasile', 'Venezuela');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cina', 'Mongolia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cina', 'Siam');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cina', 'India');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cina', 'Afghanistan');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cina', 'Siberia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cina', 'Urali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cina', 'Medio Oriente');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cita', 'Mongolia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cita', 'Siberia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cita', 'Jacuzia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Cita', 'Kamchatka');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Congo', 'Africa Orientale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Congo', 'Africa del Nord');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Congo', 'Africa del Sud');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Egitto', 'Africa Orientale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Egitto', 'Africa del Nord');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Egitto', 'Europa Meridionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Egitto', 'Medio Oriente');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Meridionale', 'Egitto');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Meridionale', 'Medio Oriente');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Meridionale', 'Europa Occidentale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Meridionale', 'Europa Settentrionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Meridionale', 'Africa del Nord');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Meridionale', 'Ucraina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Occidentale', 'Europa Settentrionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Occidentale', 'Europa Meridionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Occidentale', 'Africa del Nord');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Occidentale', 'Gran Bretagna');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Settentrionale', 'Europa Meridionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Settentrionale', 'Europa Occidentale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Settentrionale', 'Gran Bretagna');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Settentrionale', 'Ucraina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Europa Settentrionale', 'Scandinavia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Giappone', 'Kamchatka');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Giappone', 'Mongolia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Gran Bretagna', 'Europa Settentrionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Gran Bretagna', 'Europa Occidentale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Gran Bretagna', 'Scandinavia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Gran Bretagna', 'Islanda');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Groenlandia', 'Islanda');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Groenlandia', 'Quebec');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Groenlandia', 'Ontario');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Groenlandia', 'Territori del Nord Ovest');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('India', 'Cina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('India', 'Siam');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('India', 'Medio Oriente');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Indonesia', 'Siam');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Indonesia', 'Nuova Guinea');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Indonesia', 'Australia Occidentale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Islanda', 'Gran Bretagna');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Islanda', 'Scandinavia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Islanda', 'Groenlandia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Jacuzia', 'Cita');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Jacuzia', 'Kamchatka');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Jacuzia', 'Siberia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Kamchatka', 'Jacuzia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Kamchatka', 'Cita');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Kamchatka', 'Giappone');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Kamchatka', 'Mongolia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Kamchatka', 'Alaska');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Madagascar', 'Africa del Sud');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Madagascar', 'Africa Orientale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Medio Oriente', 'Egitto');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Medio Oriente', 'India');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Medio Oriente', 'Afghanistan');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Medio Oriente', 'Ucraina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Medio Oriente', 'Europa Meridionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Mongolia', 'Giappone');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Mongolia', 'Cita');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Mongolia', 'Cina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Mongolia', 'Siberia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Mongolia', 'Kamchatka');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Nuova Guinea', 'Australia Occidentale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Nuova Guinea', 'Australia Orientale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Nuova Guinea', 'Indonesia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ontario', 'Quebec');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ontario', 'Stati Uniti Orientali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ontario', 'Stati Uniti Occidentali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ontario', 'Alberta');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ontario', 'Territori del Nord Ovest');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ontario', 'Groenlandia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Perù', 'Brasile');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Perù', 'Argentina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Perù', 'Venezuela');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Quebec', 'Stati Uniti Orientali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Quebec', 'Ontario');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Quebec', 'Groenlandia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Scandinavia', 'Ucraina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Scandinavia', 'Islanda');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Scandinavia', 'Gran Bretagna');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Scandinavia', 'Europa Settentrionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siam', 'Cina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siam', 'India');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siam', 'Indonesia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siberia', 'Urali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siberia', 'Cita');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siberia', 'Jacuzia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siberia', 'Mongolia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Siberia', 'Cina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Occidentali', 'Alberta');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Occidentali', 'Ontario');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Occidentali', 'America Centrale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Occidentali', 'Stati Uniti Orientali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Orientali', 'Stati Uniti Occidentali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Orientali', 'America Centrale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Orientali', 'Ontario');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Stati Uniti Orientali', 'Quebec');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Territori del Nord Ovest', 'Alaska');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Territori del Nord Ovest', 'Alberta');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Territori del Nord Ovest', 'Ontario');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Territori del Nord Ovest', 'Groenlandia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ucraina', 'Urali');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ucraina', 'Afghanistan');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ucraina', 'Medio Oriente');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ucraina', 'Europa Meridionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ucraina', 'Europa Settentrionale');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Ucraina', 'Scandinavia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Urali', 'Siberia');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Urali', 'Ucraina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Urali', 'Afghanistan');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Urali', 'Cina');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Venezuela', 'Brasile');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Venezuela', 'Perù');
INSERT INTO `Risiko`.`Neighbour_Nations` (`nation`, `neighbour`) VALUES ('Venezuela', 'America Centrale');

COMMIT;

-- begin attached script 'Setup Events'
DROP EVENT IF EXISTS match_start_watcher;
DROP EVENT IF EXISTS turn_end_watcher;

delimiter $$
CREATE EVENT  IF NOT EXISTS turn_end_watcher
ON SCHEDULE EVERY 1 SECOND 
DO 
BEGIN
	CALL ScheduleTurns();
END$$ 

CREATE EVENT  IF NOT EXISTS match_start_watcher
ON SCHEDULE EVERY 2 SECOND 
DO
	BEGIN
		DROP TEMPORARY TABLE IF EXISTS To_Start_Matches;
		CREATE TEMPORARY TABLE IF NOT EXISTS To_Start_Matches (
        matchNumber int, 
		roomNumber int, 
		matchStartCountdown timestamp,
		state enum('lobby','countdown','started','finished'),
		numberOfPlayers smallint,
        PRIMARY KEY(roomNumber));
        
		INSERT INTO To_Start_Matches 
        SELECT matchNumber, roomNumber, matchStartCountdown, state, numberOfPlayers
		FROM `Match`
		WHERE state = 'countdown'
		ORDER BY matchNumber DESC;
        
        UPDATE `Match` SET state = 'started' WHERE matchNumber in (
			SELECT matchNumber FROM To_Start_Matches WHERE ((matchStartCountdown + interval 2 second) - current_timestamp()) < 2
        );
    END$$
delimiter ;;
-- end attached script 'Setup Events'
