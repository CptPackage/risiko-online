CALL CreateRoom(3,'CptPackage',@RoomNumber);
SET @MatchNum = (SELECT matchNumber FROM `Match` WHERE roomNumber = @RoomNumber ORDER BY matchNumber DESC LIMIT 1);
SET @RoomNumber = 7;
CALL JoinRoom(@RoomNumber,'player1',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player4',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player2',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player5',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player6',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player7',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player3',@JoinedRoom);
SELECT * FROM `Match`;
SELECT matchNumber, count(*) FROM Turn GROUP BY matchNumber ORDER BY count(*) DESC;
CALL DidPlayerLeave(2,'player5',@Result);
SELECT @Result;
SELECT * FROM Ingame_Players;
SELECT * FROM `Match`;
SELECT * FROM Turn ORDER BY turnNumber DESC;
SHOW EVENTS;
SELECT * FROM Ingame_Players WHERE matchNumber = @MatchNum;
SELECT * FROM To_Check_Matches;
DROP TEMPORARY TABLE Full_Scan_Logs;
DROP TEMPORARY TABLE To_Check_Matches;
DROP TEMPORARY TABLE Current_Check_Turns;
SET @MatchNum = 7;
SHOW EVENTS;
CALL AbandonMatch(@MatchNum,'player1');
CALL AbandonMatch(@MatchNum,'player4');
CALL AbandonMatch(@MatchNum,'player2');
CALL AbandonMatch(@MatchNum,'player5');
CALL AbandonMatch(@MatchNum,'player7');
CALL AbandonMatch(@MatchNum,'player3');
CALL GetPlayerHistory('player1');

SELECT IP.matchNumber AS 'Match Number', M.roomNumber AS 'Room Number',
(M.matchStartCountdown + INTERVAL 2 MINUTE) AS 'Match Start Time',
CASE WHEN IP.winner THEN M.matchEndTime ELSE IP.exitTime END as 'Exit Time',
CASE WHEN IP.winner = 1 THEN 'Won' ELSE 'Eliminated' END as 'Result'
FROM Ingame_Players AS IP
JOIN `Match` AS M
ON IP.matchNumber = M.matchNumber
WHERE player = 'player1'
AND (exitTime IS NOT NULL OR winner = 1);


	SET @TimeLowerBound = (current_timestamp() - INTERVAL 15 MINUTE);
	SELECT username 
    FROM User
	WHERE active = 1
	AND playerIngame = 0
	AND lastActivity >= @TimeLowerBound
    AND role = 'player';
    
    SELECT * FROM `Match`;
    
    
    ## Get Player Territories
    SELECT *
    FROM Territory AS T
    WHERE T.matchNumber = 3
    AND T.occupier = 'player1'
    ORDER BY occupyingTanksNumber;
    
    
    ## Get Player Unplaced Tanks
    SELECT unplacedTanks
    FROM Ingame_Players AS IP
    WHERE IP.matchNumber = 3
    AND IP.player = 'player1';
    
    ## Get Latest Turn
    SELECT *
    FROM Turn AS T
    WHERE T.matchNumber = 3
    ORDER BY T.turnNumber DESC
    LIMIT 1;
    
	CALL PlaceTanks(3,1161, 'player1', 'Cina',1);
    
    ## Get Turn Action
    SELECT *
    FROM Action AS A
    WHERE A.matchNumber = 3
    AND A.turnNumber = 1161;
    
    ## Get Player Current Status
	SELECT CASE WHEN IP.winner = 1 THEN 1 
		   WHEN IP.eliminated = 1 THEN 2
		   ELSE 0 END as 'Current Status'
	INTO currentStatus
	FROM Ingame_Players AS IP
	WHERE IP.matchNumber = matchNumber
    AND IP.player = player;

	SELECT *
	FROM Action;