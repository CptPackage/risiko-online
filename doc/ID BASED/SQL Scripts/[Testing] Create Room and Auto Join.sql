CALL CreateRoom(3,'CptPackage',@RoomNumber);
SET @MatchNum = (SELECT matchNumber FROM `Match` WHERE roomNumber = @RoomNumber ORDER BY matchNumber DESC LIMIT 1);
CALL JoinMatch(@RoomNumber,'player1',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player4',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player2',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player5',@JoinedRoom);
SELECT * FROM `Match` WHERE matchNumber = @MatchNum;
SELECT * FROM Turn;
SELECT * FROM `Match`;
SELECT * FROM To_Check_Matches;
DROP TEMPORARY TABLE Full_Scan_Logs;
DROP TEMPORARY TABLE To_Check_Matches;
DROP TEMPORARY TABLE Current_Check_Turns;

SHOW EVENTS;
CALL AbandonMatch(@MatchNum,'player1');
CALL AbandonMatch(@MatchNum,'player4');
CALL AbandonMatch(@MatchNum,'player2');
CALL AbandonMatch(@MatchNum,'player5');
