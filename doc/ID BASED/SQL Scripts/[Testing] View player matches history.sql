SET @Player = 'player4';

SELECT * FROM `Match`;


## Get The Match History of a Player
SELECT IP.matchNumber AS 'Match', IP.player AS 'Player',
(M.matchStartCountdown + INTERVAL 2 MINUTE) AS 'Match Start Time',
CASE WHEN IP.winner = 1 THEN 'Won' ELSE 
	(CASE WHEN eliminated = 1 THEN 'Lost' ELSE 'Lefft' END)
END as 'Result'
FROM Ingame_Players AS IP
JOIN `Match` AS M
ON IP.matchNumber = M.matchNumber
WHERE player = @Player
AND (exitTime IS NOT NULL OR winner = 1);

SELECT * FROM `Match`;

## Get Current Active Rooms and Number of Player inside
SELECT count(*) as  'Number of Started Rooms', sum(numberOfPlayers) as 'Number of Participating Players'
FROM `Match`
WHERE state = 'started'
ORDER BY matchNumber DESC;



## Get Players with less than 15 Minutes activity and Not inside a Room
## To check in an efficient manner use TimeLowerBound and check if it is newer or not
DROP TEMPORARY TABLE IF EXISTS Players_Recently_Active;
CREATE TEMPORARY TABLE IF NOT EXISTS Players_Recently_Active (
	username VARCHAR(45) primary key
);

SET @TimeLowerBound = (current_timestamp() - INTERVAL 15 MINUTE);
SELECT *
FROM User
WHERE role = 'player'
AND lastActivity >= @TimeLowerBound; ## Should check if lastActivity >= @TimeLowerBound

SELECT player
FROM Players_Recently_Active
WHERE 

UPDATE User SET lastActivity = current_timestamp() WHERE username NOT IN ('player5','player2');


SELECT *
FROM Ingame_Players AS IP