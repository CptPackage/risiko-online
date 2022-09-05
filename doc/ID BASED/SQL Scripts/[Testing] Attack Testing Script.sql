DELETE FROM `Match` WHERE matchNumber = 6;

SELECT * FROM `Match`;
SELECT * FROM Ingame_Players;
SELECT *,current_timestamp() FROM `Match` WHERE matchNumber = @MatchNum;
SELECT * FROM Action WHERE matchNumber = @MatchNum;
SELECT occupier,count(*) FROM Territory WHERE matchNumber = @MatchNum GROUP BY occupier;
SELECT * FROM Ingame_Players WHERE matchNumber = @MatchNum ORDER BY entryOrder;
SELECT * FROM Territory WHERE matchNumber = @MatchNum AND occupier in (@PlayerA,@PlayerB);
SELECT turnNumber FROM Turn AS T WHERE T.matchNumber = @MatchNum AND T.turnNumber = @TurnNumber AND T.player = @PlayerA;
SELECT * FROM Turn;
SET @PlayerA := (SELECT player FROM Turn WHERE matchNumber = @MatchNum ORDER BY turnNumber DESC LIMIT 1);
SET @PlayerB := 'player2';
SET @PlayerANation1 := (SELECT nation FROM Territory WHERE occupier = @PlayerA AND occupyingTanksNumber > 1 AND matchNumber = @MatchNum ORDER BY nation ASC LIMIT 1);
SET @PlayerANation2 = (SELECT nation FROM Territory WHERE occupier = @PlayerA AND occupyingTanksNumber > 1 AND matchNumber = @MatchNum ORDER BY nation DESC LIMIT 1);
SET @PlayerBNation1 = (SELECT nation FROM Territory WHERE occupier = @PlayerB AND occupyingTanksNumber = 1 AND matchNumber = @MatchNum ORDER BY nation ASC LIMIT 1);
SET @PlayerBNation2 = (SELECT nation FROM Territory WHERE occupier = @PlayerB AND occupyingTanksNumber = 1 AND matchNumber = @MatchNum ORDER BY nation DESC LIMIT 1);
SET @AttackerNationTanks = 5;
SET @DefenderNationTanks = 5;
SET @MatchNum := 3;
SET @TurnNumber = (SELECT turnNumber FROM Turn WHERE matchNumber = @MatchNum ORDER BY turnNumber DESC LIMIT 1);
set @ActionNumber = 1;
SET @CurrentTurnPlayer = (SELECT player FROM Turn WHERE matchNumber = @MatchNum ORDER BY turnNumber DESC LIMIT 1);
CALL PassTurn(@MatchNum,@CurrentTurnPlayer);

SELECT @MatchNum, @TurnNumber, @ActionNumber, 
		@PlayerA, @PlayerANation1, @PlayerANation2,
        @PlayerB, @PlayerBNation1, @PlayerBNation2, @CurrentTurnPlayer;
        
CALL PlaceTanks(@MatchNum,@TurnNumber,@PlayerA,@PlayerANation1,5);

CALL Move(@MatchNum,@TurnNumber,@PlayerA,@PlayerANation1,@PlayerANation2,1);

SELECT * FROM Ingame_Players WHERE matchNumber = @MatchNum ORDER BY entryOrder;
SELECT * FROM Turn WHERE matchNumber = @MatchNum;
SELECT * FROM Action WHERE matchNumber = @MatchNum;
SELECT * FROM Combat WHERE matchNumber = @MatchNum;
SELECT * FROM Territory WHERE matchNumber = @MatchNum;
SELECT * FROM Territory WHERE matchNumber = @MatchNum AND occupier IN (@PlayerA,@PlayerB) order by occupier;

UPDATE Territory SET occupier='player3' WHERE matchNumber = @MatchNumber AND nation = 'Madagascar';

UPDATE Territory AS T
SET T.occupier = @PlayerA
WHERE T.matchNumber = @MatchNum AND T.occupier = @PlayerB AND T.nation <> @PlayerBNation1;
UPDATE Territory AS T
SET T.occupyingTanksNumber = 1 
WHERE T.matchNumber = @MatchNum AND T.occupier = @PlayerB AND T.nation = @PlayerBNation1;

CALL Attack(@MatchNum,@TurnNumber,@PlayerA,@PlayerANation1,@PlayerBNation1);
CALL GetActionDetails(@MatchNum,@TurnNumber,@ActionNumber,'combat');


SELECT defenderPlayer, succeded INTO @DefenderPlayer, @AttackSucceded
FROM Combat WHERE matchNumber = matchNumber AND turnNumber = @TurnNumber;
		
        SELECT count(nation)
        FROM Territory AS T
        WHERE T.matchNumber = @MatchNum
        AND T.occupier = @PlayerB;
        

        SELECT turnNumber 
        FROM Turn AS T 
        WHERE T.matchNumber = @MatchNum 
        AND T.turnNumber = @TurnNumber
        AND T.player = @PlayerA;


SELECT occupier, occupyingTanksNumber
	FROM Territory AS T
	WHERE T.matchNumber = @MatchNum
	AND T.nation = @AttackerNationA
	AND T.occupier = @PlayerA;
    
    
SELECT T.matchNumber, occupier, SUM(occupyingTanksNumber),IP.unplacedTanks, (SUM(occupyingTanksNumber) + IP.unplacedTanks), 
count(T.occupier) FROM Territory AS T JOIN Ingame_Players AS IP ON T.matchNumber = IP.matchNumber AND T.occupier = IP.player
GROUP BY matchNumber, occupier;
