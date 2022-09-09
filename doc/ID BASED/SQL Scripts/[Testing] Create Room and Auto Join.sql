CALL CreateRoom(3,'CptPackage',@RoomNumber);
SET @MatchNum = (SELECT matchNumber FROM `Match` WHERE roomNumber = @RoomNumber ORDER BY matchNumber DESC LIMIT 1);
CALL JoinMatch(@RoomNumber,'player1',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player4',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player2',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player5',@JoinedRoom);
SELECT * FROM `Match` WHERE matchNumber = @MatchNum;
SELECT * FROM Turn;
SELECT * FROM `Match`;
SELECT * FROM Ingame_Players;
SELECT * FROM To_Check_Matches;
DROP TEMPORARY TABLE Full_Scan_Logs;
DROP TEMPORARY TABLE To_Check_Matches;
DROP TEMPORARY TABLE Current_Check_Turns;
SET @MatchNum = 3;
SHOW EVENTS;
CALL AbandonMatch(@MatchNum,'player1');
CALL AbandonMatch(@MatchNum,'player4');
CALL AbandonMatch(@MatchNum,'player2');
CALL AbandonMatch(@MatchNum,'player5');


SELECT IP.matchNumber AS 'Match', IP.player AS 'Player',
(M.matchStartCountdown + INTERVAL 2 MINUTE) AS 'Match Start Time',
CASE WHEN IP.winner = 1 THEN 'Won' ELSE 'Eliminated' END as 'Result',
CASE WHEN IP.winner THEN M.matchEndTime ELSE IP.exitTime END as 'Exit Time'
FROM Ingame_Players AS IP
JOIN `Match` AS M
ON IP.matchNumber = M.matchNumber
WHERE player = 'player1'
AND (exitTime IS NOT NULL OR winner = 1);