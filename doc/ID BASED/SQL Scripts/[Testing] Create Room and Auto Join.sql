CALL CreateRoom(40,'CptPackage',@RoomNumber);
SET @MatchNum = (SELECT matchNumber FROM `Match` WHERE roomNumber = @RoomNumber ORDER BY matchNumber DESC LIMIT 1);
SET @RoomNumber = 5;
SET @MatchNum = 1;
SELECT @RoomNumber;
SELECT @MatchNum;
CALL JoinRoom(@RoomNumber,'player1',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player4',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player2',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player5',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player6',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player7',@JoinedRoom);
CALL JoinRoom(@RoomNumber,'player3',@JoinedRoom);
SELECT * FROM `Match`;
SELECT * FROM Ingame_Players;
SELECT matchNumber, count(*) FROM Turn GROUP BY matchNumber ORDER BY count(*) DESC;
CALL DidPlayerLeave(2,'player5',@Result);

SELECT * FROM Turn ORDER BY turnNumber DESC;




CALL GetMatchPlayers(4);
SELECT @Result;
SELECT * FROM Ingame_Players ORDER BY matchNumber, entryOrder;
SELECT * FROM Ingame_Players WHERE player = 'player1';
SELECT * FROM `Match`;
SELECT * FROM Room;
SELECT * FROM Turn ORDER BY turnNumber DESC LIMIT 1000;
SELECT * FROM User;
UPDATE User
SET playerIngame = 1
WHERE username = 'player1';
CALL Logout('player1');
SHOW EVENTS;
SELECT * FROM Ingame_Players;
SELECT * FROM Ingame_Players WHERE matchNumber = @MatchNum;
SELECT * FROM To_Check_Matches;
DROP TEMPORARY TABLE Full_Scan_Logs;
DROP TEMPORARY TABLE To_Check_Matches;
DROP TEMPORARY TABLE Current_Check_Turns;
SET @MatchNum = 3;
SHOW EVENTS;
SELECT @Result;

SELECT * FROM Ingame_Players;


CALL AbandonMatch(@MatchNum,'player1');
CALL AbandonMatch(@MatchNum,'player2');
CALL AbandonMatch(@MatchNum,'player3');
CALL AbandonMatch(@MatchNum,'player4');
CALL AbandonMatch(@MatchNum,'player5');
CALL AbandonMatch(@MatchNum,'player7');
CALL AbandonMatch(@MatchNum,'player6');
CALL GetPlayerHistory('player1');
CALL GetLatestTurn(4);
CALL Reward_Player(3,'player2');

SELECT * FROM Ingame_Players;
SELECT * FROM Action;
SELECT * FROM Movement;
SELECT * FROM Combat;
SELECT * FROM Territory;
SELECT * FROM Turn ORDER BY turnNumber DESC;
SELECT *, current_timestamp() FROM Turn ORDER BY turnStartTime DESC;
CALL PlaceTanks(3,13,'player2','Siberia',1);


		SET @CurrentTurnPlayer = NULL;
        SELECT player
        INTO @CurrentTurnPlayer
        FROM Turn AS T 
        WHERE T.matchNumber = 3
        ORDER BY turnNumber DESC
        LIMIT 1;
        
        UPDATE Territory SET occupier = 'player2' WHERE matchNumber = 5 AND occupier = 'player4' AND nation <> 'Alberta';
        SELECT *
        FROM Neighbour_Nations
        WHERE neighbour = 'Alberta';
        
        SELECT @CurrentTurnPlayer;
CALL Move(3,1,'player1','Brasile','Congo',1);
CALL Attack(3,13,'player1','Argentina','Cita');
CALL GetActionDetails(3,13,1,2);
  SELECT player
        FROM Turn AS T 
        WHERE T.matchNumber = 3
        ORDER BY turnNumber DESC
        LIMIT 1;
CALL GetAttackableTerritories(3,'player1','America Centrale');
CALL GetNeighbourTerritories(3,'player1','America Centrale');
CALL GetPlayerTerritories(3,'player1');
Update Action SET tanksNumber = 99 WHERE turnNumber = 22;

CALL GetScoreboard(3);
SELECT * FROM Ingame_Players;
UPDATE Ingame_Players SET unplacedTanks = 5 WHERE player = 'player2';
SELECT matchNumber, occupier,count(nation) FROM Territory GROUP BY matchNumber,occupier;
SELECT * FROM Turn;

UPDATE Ingame_Players SET unplacedTanks = 10;

	SET @TerritoriesCount = 0;
    SET @Increment = 0;
    
	SELECT count(nation) INTO @TerritoriesCount
	FROM Territory
	WHERE matchNumber = 3
	AND occupier = 'player2';
    
	SET @Increment = CEILING(@TerritoriesCount / 3);
            SELECT @Increment;
	UPDATE Ingame_Players
	SET unplacedTanks = (unplacedTanks + @Increment)
	WHERE matchNumber = 3
	AND player = 'player2';


	SELECT count(nation)
	FROM Territory
	WHERE matchNumber = 3
	AND occupier = 'player2';

SELECt nation
FROM Territory AS T
WHERE T.matchNumber = 3
AND T.occupier = 'player2'
AND T.nation = 'Africa del Nord';

SELECT actionNumber
FROM Action
WHERE matchNumber = 3
AND turnNumber = 73;

CALL GetPlayerCurrentStatus(3,'player1',@Result);
SELECT @Result;


SELECT * FROM Ingame_Players;
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
SELECT * FROM Turn;
	SELECT * FROM Ingame_Players;
    
    SELECT T.matchNumber, occupier, count(T.nation), SUM(occupyingTanksNumber), IP.unplacedTanks, (SUM(occupyingTanksNumber) + IP.unplacedTanks)
    FROM Territory AS T
    JOIN Ingame_Players AS IP
    ON T.matchNumber = IP.matchNumber
    AND T.occupier = IP.player
    WHERE T.matchNumber = 3
    GROUP BY occupier;
	
    
    ## Get Player Territories
    SELECT matchNumber, nation, occupier, occupyingTanksNumber
    FROM Territory AS T
    WHERE T.matchNumber = 3
    AND T.occupier = 'player1'
    ORDER BY occupyingTanksNumber DESC;
    
    
	SELECT matchNumber, nation, occupier, occupyingTanksNumber
    FROM Territory AS T
    WHERE T.matchNumber = 3
    ORDER BY occupyingTanksNumber DESC;

    SELECT T.matchNumber, T.turnNumber, T.player, T.turnStartTime
	FROM Turn AS T
    WHERE matchNumber = 3
    ORDER BY turnNumber DESC;    
    
    SELECT T.matchNumber, T.turnNumber, T.player, T.turnStartTime
	FROM Turn AS T
    WHERE matchNumber = 3
    ORDER BY turnNumber DESC
    LIMIT 1;
    
    
    SELECT T.matchNumber, NN.neighbour AS 'Neighbour',
    T.occupier AS 'Occupier', T.occupyingTanksNumber AS 'Occupying Tanks'
	FROM Neighbour_Nations AS NN JOIN Territory AS T ON (NN.neighbour = T.nation AND T.matchNumber = 3) 
	WHERE NN.nation = 'Cina' AND T.occupier <> 'player1';
    
    SELECT T.matchNumber, NN.neighbour AS 'Neighbour',
    T.occupier AS 'Occupier', T.occupyingTanksNumber AS 'Occupying Tanks'
	FROM Neighbour_Nations AS NN JOIN Territory AS T ON (NN.neighbour = T.nation AND T.matchNumber = 3) 
	WHERE NN.nation = 'Cina' AND T.occupier ='player1';
    
    SELECT * FROM Territory WHERE matchNumber =3 ;
    
    
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