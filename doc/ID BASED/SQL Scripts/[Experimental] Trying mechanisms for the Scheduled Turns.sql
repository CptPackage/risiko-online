DECLARE currentMatchNumber INT;
DECLARE currentTurnNumber INT;
DECLARE currentTurnPlayer VARCHAR(45);
DECLARE currentTurnStartTime timestamp;
DECLARE currentTurnDuration int;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
DECLARE CURSOR Updatable_Turns_Cursor FOR SELECT matchNumber, turnNumber, turnStartTime, turnDuration, currentPlayer
	FROM Current_Check_Turns WHERE turnExpirationTime >= current_timestamp();

DROP TABLE IF EXISTS Full_Scan_Logs;    
CREATE TEMPORARY TABLE IF NOT EXISTS Full_Scan_Logs (
	lastScanTime TIMESTAMP,
    primary key(lastScanTime)
);

DROP TABLE IF EXISTS To_Check_Matches;    
CREATE TEMPORARY TABLE IF NOT EXISTS To_Check_Matches (
	matchNumber INT, 
	roomNumber INT,
	turnDuration INT,
    numberOfPlayers INT,
	PRIMARY KEY(roomNumber),
    INDEX MatchIndex(matchNumber)
);

DROP TABLE IF EXISTS Current_Check_Turns;
CREATE TEMPORARY TABLE IF NOT EXISTS Current_Check_Turns(
	matchNumber INT,
    turnNumber INT,
    turnDuration INT,
    turnStartTime TIMESTAMP,
	turnExpirationTime TIMESTAMP,
    currentPlayer VARCHAR(45),
    PRIMARY KEY(matchNumber)
);

## CONVERT THIS IF AS WHERE
	SET @LastScanTime = NULL;

	SELECT lastScanTime INTO @LastScanTime
    FROM Full_Scan_Logs ORDER BY lastScanTime DESC;

	IF @LastScanTime IS NULL OR (@LastScanTime + INTERVAL 2 MINUTE) <= current_timestamp() THEN
		## FULL SCAN ROOMS AND MATCHES
		REPLACE INTO To_Check_Matches(roomNumber,matchNumber,turnDuration, numberOfPlayers)
		SELECT R.roomNumber, M.matchNumber, R.turnDuration, M.numberOfPlayers
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
		REPLACE INTO To_Check_Matches(roomNumber,matchNumber,turnDuration, numberOfPlayers, lastChecked)
		SELECT R.roomNumber, M.matchNumber, R.turnDuration, M.numberOfPlayers, current_timestamp()
		FROM Room AS R
		JOIN `Match` AS M
		ON R.roomNumber = M.roomNumber AND M.state = 'started'
        WHERE numberOfPlayers < 3 
        AND (lastChecked + INTERVAL turnDuration SECOND) <= current_timestamp()
		ORDER BY matchNumber DESC;
    END IF;
    
    FETCH Updatable_Turns_Cursor INTO currentMatchNumber, currentTurnNumber, currentTurnStartTime,currentTurnDuration, currentTurnPlayer;
    
    SELECT matchNumber, turnNumber, turnStartTime, player
    INTO @TempMatchNumber, @TempTurnNumber, @TempTurnStartTime, @TempTurnPlayer
    FROM Turn
    WHERE matchNumber = currentMatchNumber
    ORDER BY turnNumber DESC LIMIT 1;
    
    IF (@TempTurnNumber <> currentTurnNumber OR @TempTurnStartTime > currentTurnStartTime) 
    AND (@TempTurnStartTime + INTERVAL currentTurnDuration SECOND ) > current_timestamp() THEN
		UPDATE Current_Check_Turns SET turnNumber = @TempTurnNumber, turnStartTime = @TempTurnStartTime, currentPlayer = @TempTurnPlayer
        WHERE matchNumber = @TempMatchNumber;
	ELSE    
		IF (@TempTurnStartTime + INTERVAL currentTurnDuration SECOND ) > current_timestamp() THEN
			CALL PassTurn(@TempMatchNumber, @TempTurnPlayer);

			SELECT matchNumber, turnNumber, turnStartTime, player
			INTO @TempMatchNumber, @TempTurnNumber, @TempTurnStartTime, @TempTurnPlayer
			FROM Turn
			WHERE matchNumber = currentMatchNumber
			ORDER BY turnNumber DESC LIMIT 1;
			
			UPDATE Current_Check_Turns SET turnNumber = @TempTurnNumber, turnStartTime = @TempTurnStartTime, currentPlayer = @TempTurnPlayer
			WHERE matchNumber = @TempMatchNumber;
        END IF;
    END IF;

    
    	## CURSOR LOOPING ON Entries with turnExpirationTime <= current_timestamp()
	## Action:: Check if the lastPlayingPlayer is the same, if so then pass turn, if not update the record in current_check_turns


SELECT * FROM To_Check_Matches;

REPLACE INTO To_Check_Matches(roomNumber,matchNumber,turnDuration, numberOfPlayers, lastChecked)
SELECT R.roomNumber, M.matchNumber, R.turnDuration, M.numberOfPlayers, current_timestamp()
FROM Room AS R
JOIN `Match` AS M
ON R.roomNumber = M.roomNumber AND M.state = 'started'
ORDER BY matchNumber DESC;

## Update To Check Matches Table
EXPLAIN ANALYZE SELECT R.roomNumber, M.matchNumber, R.turnDuration, M.numberOfPlayers, current_timestamp()
FROM Room AS R
JOIN `Match` AS M
ON R.roomNumber = M.roomNumber AND M.state = 'started'
ORDER BY matchNumber DESC;

SELECT * FROM Turn;
CALL PassTurn(7,'player1');

SELECT * FROM Ingame_Players;
SELECT * FROM Turn;

REPLACE INTO Current_Check_Turns(matchNumber, turnNumber, turnDuration, turnStartTime, turnExpirationTime, currentTurnPlayer)
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

## CURSOR LOOPING ON Entries with turnExpirationTime <= current_timestamp()
## Action:: Check if the lastPlayingPlayer is the same, if so then pass turn, if not update the record in current_check_turns


SELECT * FROM Current_Check_Turns;


SELECT * FROM Ingame_Players;
SELECT * FROM Turn;