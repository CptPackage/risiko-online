DROP EVENT IF EXISTS turn_end_watcher;

delimiter $$
CREATE EVENT  IF NOT EXISTS turn_end_watcher
ON SCHEDULE EVERY 2 SECOND 
DO 
BEGIN
CREATE TEMPORARY TABLE IF NOT EXISTS To_Check_Matches (
	matchNumber INT, 
	roomNumber INT,
	turnDuration INT,
    lastChecked TIMESTAMP, 
	PRIMARY KEY(roomNumber),
    INDEX MatchIndex(matchNumber)
);

CREATE TEMPORARY TABLE IF NOT EXISTS Current_Check_Turns(
	matchNumber INT Primary key,
    turnNumber INT,
    turnStartTime TIMESTAMP,
    turnDuration INT,
    turnExpiration TIMESTAMP,
    PRIMARY KEY(matchNumber)
);


TRUNCATE To_Check_Matches;

INSERT INTO To_Check_Matches 
SELECT M.matchNumber, R.turnDuration
FROM Room AS R
JOIN `Match` AS M
ON R.roomNumber = M.roomNumber AND M.state = 'started'
ORDER BY matchNumber DESC;


SELECT TCA.matchNumber, T.turnNumber
FROM To_Check_Matches AS TCA
INNER JOIN (
	SELECT matchNumber, turnNumber, turnStartTime, player 
	FROM Turn
    ORDER BY matchNumber,turnNumber DESC
) AS T
ON TCA.matchNumber = T.matchNumber
GROUP BY TCA.matchNumber, T.matchNumber;



SELECT TCA.matchNumber, T.tn
FROM To_Check_Matches AS TCA
INNER JOIN (
	SELECT matchNumber, MAX(turnNumber) as tn,turnStartTime, player 
	FROM Turn
	GROUP BY matchNumber, turnStartTime, player
) AS T
ON TCA.matchNumber = T.matchNumber 	
GROUP BY TCA.matchNumber, T.matchNumber, T.tn;

        
        SELECT M.matchNumber, R.turnDuration
		FROM Room AS R
        JOIN `Match` AS M
        ON R.roomNumber = M.roomNumber AND M.state = 'started'
		ORDER BY matchNumber DESC;
        
    END$$
delimiter ;



