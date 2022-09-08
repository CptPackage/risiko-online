CREATE PROCEDURE `ScheduleTurnsV3` ()
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
                        
            INSERT INTO Debug_Logs(message,messageTime)
			VALUES(CONCAT('I:', turnsOffset, ' - Target:', @UpdatablesSize, ' - ',currentMatchNumber, 
			currentTurnNumber, ' "', currentTurnStartTime , '" ', currentTurnDuration, currentTurnPlayer), current_timestamp());
            
            INSERT INTO Debug_Logs(message,messageTime)
			VALUES(CONCAT('[@Temps] I:', turnsOffset, ' - Target:', @UpdatablesSize, ' - ',@TempMatchNumber, 
			@TempTurnNumber, ' "', @TempTurnStartTime , '" ', currentTurnDuration, @TempTurnPlayer), current_timestamp());
			## BODY START
				
		IF (@TempTurnNumber <> currentTurnNumber 
        OR @TempTurnStartTime > currentTurnStartTime
        OR @TempTurnPlayer <> currentTurnPlayer) 
		AND (@TempTurnStartTime + INTERVAL currentTurnDuration SECOND ) > current_timestamp() THEN
			INSERT INTO Debug_Logs(message, messageTime) VALUES ('Updated by someone else',current_timestamp());
           UPDATE Current_Check_Turns SET turnNumber = @TempTurnNumber,
            turnStartTime = @TempTurnStartTime, currentPlayer = @TempTurnPlayer
			WHERE matchNumber = @TempMatchNumber;
		ELSE    
			INSERT INTO Debug_Logs(message, messageTime) VALUES ('INSIDE THE ELSE',current_timestamp());
			IF (@TempTurnStartTime + INTERVAL currentTurnDuration SECOND ) < current_timestamp() THEN
				INSERT INTO Debug_Logs(message, messageTime) VALUES ('ABOUT TO PASS TURN',current_timestamp());
				CALL PassTurn(@TempMatchNumber, @TempTurnPlayer);
				SELECT matchNumber, turnNumber, turnStartTime, player
				INTO @TempMatchNumber, @TempTurnNumber, @TempTurnStartTime, @TempTurnPlayer
				FROM Turn
				WHERE matchNumber = currentMatchNumber
				ORDER BY turnNumber DESC LIMIT 1;
               
                
                IF @TempTurnNumber = currentTurnNumber AND  @TempTurnStartTime = currentTurnStartTime THEN
					INSERT INTO Debug_Logs(message, messageTime) VALUES ('INSIDE SUSPECTED LOOP',current_timestamp());
					SET @SuspectedMatchNumber = NULL;
                    SELECT M.matchNumber INTO @SuspectedMatchNumber
                    FROM `Match` AS M
                    WHERE M.matchNumber = currentMatchNumber
					AND M.state = 'started';
					 
                    IF @SuspectedMatchNumber IS NULL THEN
						INSERT INTO Debug_Logs(message, messageTime) VALUES ('INSIDE DELETE SUSPECTED',current_timestamp());
						DELETE FROM Current_Check_Turns WHERE matchNumber = currentMatchNumber;
						DELETE FROM To_Check_Matches WHERE matchNumber = currentMatchNumber;
                ELSE					
					INSERT INTO Debug_Logs(message, messageTime) VALUES ('INSIDE NOT SUSPECTED',current_timestamp());
					UPDATE Current_Check_Turns SET turnNumber = @TempTurnNumber,
					turnStartTime = @TempTurnStartTime, currentPlayer = @TempTurnPlayer
					WHERE matchNumber = @TempMatchNumber;                
                END IF;
                
				END IF;
			END IF;
		END IF;
            
		SET turnsOffset = turnsOffset + 1;        
	END WHILE;
END