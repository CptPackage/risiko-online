CALL CreateRoom(3,'CptPackage',@RoomNumber);
#SELECT matchNumber FROM `Match` WHERE roomNumber = @RoomNumber ORDER BY roomNumber DESC LIMIT 1;
#SELECT @RoomNumber;
#SET @RoomNumber = 3;
#SELECT * FROM `Match`;
INSERT `Match`(roomNumber) VALUES (3);
SET @RoomNumber = 3;
SELECT @RoomNumber;
SET @MatchNum = (SELECT matchNumber FROM `Match` WHERE roomNumber = @RoomNumber ORDER BY matchNumber DESC LIMIT 1);
SELECT * FROM `Match`;
SELECT * FROM `Match` WHERE roomNumber = @RoomNumber;
SELECT matchStartCountdown, 
(matchStartCountdown + INTERVAL 2 MINUTE), 
((matchStartCountdown + INTERVAL 2 MINUTE)  - current_timestamp()) > 0
FROM `Match` WHERE roomNumber = @RoomNumber;
SELECT * FROM `Match`;
SELECT * FROM Ingame_Players WHERE matchNumber = @MatchNum ORDER BY exitTime DESC;
SELECT * FROM Ingame_Players;
SELECT * FROM Turn;
SELECT * FROM Territory WHERE matchNumber = @MatchNum;
SELECT * FROM Territory WHERE matchNumber = @MatchNum AND occupier = 'player2';
SELECT @MatchNum;
	SELECT player
	FROM Ingame_Players AS IP
	WHERE IP.matchNumber = @MatchNum
	AND IP.player = 'player4'
	AND IP.exitTime IS NULL;
    
CALL JoinMatch(@RoomNumber,'player1',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player4',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player2',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player5',@JoinedRoom);
CALL JoinMatch(@RoomNumber,'player3',@JoinedRoom);
CALL ExitRoom(@RoomNumber,'player4');
CALL JoinMatch(@RoomNumber,'player6',@JoinedRoom);
UPDATE Ingame_Players SET winner = 0 WHERE matchNumber = 5;

CALL AbandonMatch(@MatchNum,'player1');
CALL AbandonMatch(@MatchNum,'player4');
CALL AbandonMatch(@MatchNum,'player2');
CALL AbandonMatch(@MatchNum,'player5');
CALL AbandonMatch(@MatchNum,'player6');
CALL AbandonMatch(@MatchNum,'player3');
CALL AbandonMatch(@MatchNum,'player7');

SELECT count(player) 
		FROM Ingame_Players
		WHERE matchNumber = @MatchNum;

SELECT count(player) 
		FROM Ingame_Players
		WHERE matchNumber = @MatchNum
        AND exitTime IS NULL;


CALL GenerateTerritories(@MatchNum);
CALL ExitRoom(@RoomNumber,'player1');
CALL ExitRoom(@RoomNumber,'player4');
-- CALL GenerateTerritories(@MatchNumber);
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player1');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player2');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player3');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player4');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player5');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player6');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player1');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player2');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player3');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player4');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player5');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player6');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player1');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player2');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player3');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player4');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player5');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player6');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player1');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player2');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player3');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player4');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player5');
-- INSERT INTO Turn(matchNumber, player) VALUES (@MatchNumber,'player6');
-- SELECT occupier,count(nation) FROM Territory WHERE matchNumber = @MatchNumber GROUP BY occupier;
-- SELECT * FROM Turn;
-- SELECT * FROM Territory;
-- SELECT * FROM `Match`;
-- SELECT * FROM Ingame_Players;
-- SELECT * FROM `Match` WHERE state = 'countdown';
-- CALL UpdatePlayerActivity('player1');
-- SELECT * FROM User;

-- SELECT * FROM `Match`;
-- SELECT * FROM Turn WHERE matchNumber = 5;
-- SELECT * FROM Ingame_Players;
-- SELECT player FROM Territory WHERE matchNumber = 6 group by occupier;