TRUNCATE Rolls;

CREATE TEMPORARY TABLE IF NOT EXISTS Rolls(
    roll_value INT,
    player VARCHAR(45)
);

INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player1');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player1');
INSERT INTO Rolls(roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player1');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player2');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player2');
INSERT INTO Rolls( roll_value, player) VALUES(truncate(rand() * 6 + 1,0),'player2');

INSERT INTO Dice_Roll(matchNumber, turnNumber, actionNumber, player, rollValue)  
SELECT 1,1,1,R.player,R.roll_value from Rolls AS R where player = 'player1' ORDER BY R.roll_value DESC;

INSERT INTO Dice_Roll(matchNumber, turnNumber, actionNumber, player, rollValue)  
SELECT 1,1,1,R.player,R.roll_value from Rolls AS R where player = 'player2' ORDER BY R.roll_value DESC;

SELECT * FROM Rolls;

## IMP: AS @Confronted_Dices_Num (The number of that are actually confronted as when one player has more dice, 
## the extra dice with lowest value gets discarded) depends on the tanks available on that nation for the player

SELECT MIN(RR.Rolls) AS 'Real Rolls Number' into @RollsNumber
FROM (SELECT COUNT(player) as 'Rolls' FROM Rolls GROUP BY player) AS RR ;

SELECT @RollsNumber;

SELECT * FROM Dice_Roll;

## FULL Detailed Joining (Player1 Attacker & Player2 Defender)
SELECT DR1.matchNumber, DR1.turnNumber, DR1.actionNumber, DR1.player AS 'Attacker', DR1.rollValue AS 'Attacker Roll',
DR2.player AS 'Defender', DR2.rollValue AS 'Defender Roll', 
CASE WHEN (DR1.rollValue - DR2.rollValue > 0) THEN DR1.player ELSE DR2.player END AS 'Winner'
 FROM Dice_Roll AS DR1 JOIN (
SELECT * FROM Dice_Roll AS R
WHERE R.matchNumber = 1
AND R.turnNumber = 1
AND R.actionNumber = 1
AND R.player = 'player2'
) AS DR2 ON DR1.rollNumber = DR2.rollNumber
WHERE DR1.matchNumber = 1
AND DR1.turnNumber = 1
AND DR1.actionNumber = 1
AND DR1.player = 'player1';


##Lost Tanks By User (Player1 Attacker & Player2 Defender)
SELECT CASE WHEN (DR1.rollValue - DR2.rollValue > 0) THEN DR2.player ELSE DR1.player END AS 'Player',
(count(*)) AS 'Lost Tanks'
 FROM Dice_Roll AS DR1 JOIN (
SELECT * FROM Dice_Roll AS R
WHERE R.matchNumber = 1
AND R.turnNumber = 1
AND R.actionNumber = 1
AND R.player = 'player2'
) AS DR2 ON DR1.rollNumber = DR2.rollNumber
WHERE DR1.matchNumber = 1
AND DR1.turnNumber = 1
AND DR1.actionNumber = 1
AND DR1.player = 'player1'
group by Player;

## Alternative Clean Style for Performance Profiling
## BUG: When a player has lost all rolls he isn't included in the query
SELECT CASE WHEN (DR1.rollValue - DR2.rollValue > 0) THEN DR2.player ELSE DR1.player END AS 'Player',
(count(*)) AS 'Lost Tanks'
 FROM Dice_Roll AS DR1 
JOIN Dice_Roll AS DR2
ON DR1.rollNumber = DR2.rollNumber
AND DR1.matchNumber = DR2.matchNumber
AND DR1.turnNumber = DR2.turnNumber
AND DR1.actionNumber = DR2.actionNumber
AND DR2.player = 'player2'
WHERE DR1.matchNumber = 1
AND DR1.turnNumber = 1
AND DR1.actionNumber = 1
AND DR1.player = 'player1'
group by Player;

select * from Action;
select * from Combat;