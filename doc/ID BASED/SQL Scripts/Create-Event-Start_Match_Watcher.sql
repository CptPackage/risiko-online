DROP TABLE IF EXISTS Events_Log;
CREATE TABLE IF NOT EXISTS Events_Log(
	matchNumber  int primary key,
    currentState VARCHAR(45),
    nextState VARCHAR(45)
);

DROP EVENT IF EXISTS match_start_watcher;

delimiter $$
CREATE EVENT  IF NOT EXISTS match_start_watcher
ON SCHEDULE EVERY 2 SECOND 
DO
	BEGIN
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
			SELECT matchNumber FROM To_Start_Matches WHERE ((matchStartCountdown + interval 30 second) - current_timestamp()) < 2
        );
        
        INSERT INTO Events_Log
        SELECT matchNumber, state, 'started'
		FROM To_Start_Matches;
        
    END$$
delimiter ;;


UPDATE `Match` SET state = 'countdown', numberOfPlayers = 6, matchStartCountdown = current_timestamp();

SELECT * FROM `Match`;
SELECT * FROM Events_Log;

SHOW EVENTS;

