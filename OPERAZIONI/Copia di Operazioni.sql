/*
	Periodo produzione energia
*/

drop procedure if exists creaStorico;
delimiter $$
create procedure creaStorico(in inizioPeriodo timestamp, in finePeriodo timestamp)
begin
	DECLARE KWProdotti INT DEFAULT 0;
	DECLARE KWImmessi INT DEFAULT 0;
	DECLARE KWPrelevati INT DEFAULT 0;
	DECLARE guadagno DOUBLE DEFAULT 0;
    DECLARE spesa DOUBLE DEFAULT 0;
    DECLARE KWConsumatiSorgente DOUBLE DEFAULT 0;
    DECLARE KWConsumatiBatteria DOUBLE DEFAULT 0;
    DECLARE KWConsumatiTotale DOUBLE DEFAULT 0;
    
	SELECT IFNULL(sum(KWProdotti), 0) INTO KWProdotti
	FROM storicoproduzioneenergia
    WHERE InizioTimeStamp >= inizioPeriodo and FineTimeStamp <= finePeriodo;
    
    SELECT IFNULL(sum(KWImmissione), 0) INTO KWImmessi
    FROM immissione 
	WHERE TimeStampImmissione >= inizioPeriodo and TimeStampImmissione <= finePeriodo;
    
    SELECT IFNULL(sum(KWPrelievo), 0) INTO KWPrelevati
	FROM prelievo 
	WHERE TimeStampPrelievo >= inizioPeriodo and TimeStampPrelievo <= finePeriodo;
        
    SELECT IFNULL(sum(KWConsumati), 0) INTO KWConsumatiTotale
	FROM CONSUMODISPOSITIVO 
	WHERE InizioAccensione >= inizioPeriodo and FineAccensione <= finePeriodo;
    
    SELECT IFNULL(sum(KWConsumati), 0) INTO KWConsumatiSorgente
	FROM ConsumoGruppoSorgenti  CGS
	WHERE CGS.TimeStampConsumo >= inizioPeriodo and CGS.TimeStampConsumo <= finePeriodo;
    
    SELECT IFNULL(sum(KWConsumati), 0) INTO KWConsumatiBatteria
	FROM ConsumoBatteria  CB
	WHERE CB.TimeStampConsumo >= inizioPeriodo and CB.TimeStampConsumo <= finePeriodo;
    
    SELECT IFNULL(SUM(I.KWImmissione*FA.CostoKW), 0) INTO guadagno
	FROM IMMISSIONE I
		INNER JOIN
		FASCIAORARIA FA ON I.IDFascia = FA.IDFascia
	WHERE TimeStampImmissione >= inizioPeriodo and TimeStampImmissione <= finePeriodo;

	SELECT IFNULL(SUM(P.KWPrelievo*FA.CostoKW), 0) INTO spesa
	FROM PRELIEVO P
		INNER JOIN
		FASCIAORARIA FA ON P.IDFascia = FA.IDFascia
	WHERE TimeStampPrelievo >= inizioPeriodo and TimeStampPrelievo <= finePeriodo;
    
    SELECT KWProdotti, KWConsumatiTotale, KWConsumatiSorgente, KWConsumatiBatteria, KWPrelevati, spesa, KWImmessi, guadagno;
    
end $$

delimiter ;

-- EVENT

DROP EVENT IF EXISTS statisticaMese;

DROP PROCEDURE IF EXISTS statisticaMese;

DELIMITER $$

CREATE PROCEDURE statisticaMese()
BEGIN
	DECLARE KWProdottiMese DOUBLE DEFAULT 0.0;
    DECLARE KWConsumatiMese DOUBLE DEFAULT 0.0;
    DECLARE SpesaMese DOUBLE DEFAULT 0.0;
	DECLARE GuadagnoMese DOUBLE DEFAULT 0.0;
    
    DECLARE PercentualeKWProdotti DOUBLE DEFAULT 0.0;
    DECLARE PercentualeKWConsumo DOUBLE DEFAULT 0.0;
    DECLARE PercentualeKWSpesa DOUBLE DEFAULT 0.0;
	DECLARE PercentualeKWGuadagno DOUBLE DEFAULT 0.0;
    
    DECLARE Risultato VARCHAR(255) DEFAULT '';
    
	SELECT SUM(SPE.KWProdotti) INTO KWProdottiMese
	FROM STORICOPRODUZIONEENERGIA SPE
	WHERE YEAR(SPE.InizioTimeStamp) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(SPE.InizioTimeStamp) = MONTH(CURRENT_TIMESTAMP) - 1
		OR 
		YEAR(SPE.InizioTimeStamp) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(SPE.InizioTimeStamp) = 12;

	SELECT SUM(CD.KWConsumati) INTO KWConsumatiMese
	FROM CONSUMODISPOSITIVO CD
	WHERE (YEAR(CD.InizioAccensione) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(CD.InizioAccensione) = MONTH(CURRENT_TIMESTAMP) - 1)
		OR 
		(YEAR(CD.InizioAccensione) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(CD.InizioAccensione) = 12);

	SELECT SUM(P.KWPrelievo*FA.CostoKW) INTO SpesaMese
	FROM PRELIEVO P
		INNER JOIN
		FASCIAORARIA FA ON P.IDFascia = FA.IDFascia
	WHERE (YEAR(P.TimeStampPrelievo) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(P.TimeStampPrelievo) = MONTH(CURRENT_TIMESTAMP) - 1)
		OR 
		(YEAR(P.TimeStampPrelievo) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(P.TimeStampPrelievo) = 12);

	SELECT SUM(I.KWImmissione*FA.CostoKW) INTO GuadagnoMese
	FROM IMMISSIONE I
		INNER JOIN
		FASCIAORARIA FA ON I.IDFascia = FA.IDFascia
	WHERE (YEAR(I.TimeStampImmissione) = YEAR(CURRENT_TIMESTAMP)
		AND MONTH(I.TimeStampImmissione) = MONTH(CURRENT_TIMESTAMP) - 1)
		OR 
		(YEAR(I.TimeStampImmissione) = YEAR(CURRENT_TIMESTAMP) - 1
		AND MONTH(I.TimeStampImmissione) = 12);
        
	INSERT INTO MV_Storico(DataStorico, KWProdotti, KWConsumati, Guadagno, Consumo) VALUES(CURRENT_DATE, KWProdottiMese, KWConsumatiMese, SpesaMese, GuadagnoMese);
    
    WITH TableTarget AS
	(
		SELECT MVS.*, LEAD(MVS.KWPRodotti) OVER w AS KWProdottiSucc, LEAD(MVS.KWConsumati) OVER w AS KWConsumatiSucc, LEAD(MVS.Guadagno) OVER w AS GuadagnoSucc, LEAD(MVS.Consumo) OVER w AS ConsumoSucc
		FROM MV_Storico MVS
		WHERE (MONTH(MVS.DataStorico) >= MONTH(CURRENT_TIMESTAMP) - 1
			AND YEAR(MVS.DataStorico) = YEAR(CURRENT_TIMESTAMP))
			OR
			(MONTH(MVS.DataStorico) = 12
			AND YEAR(MVS.DataStorico) = YEAR(CURRENT_TIMESTAMP) - 1)
			AND MONTH(MVS.DataStorico) = 1
			AND YEAR(MVS.DataStorico) = YEAR(CURRENT_TIMESTAMP)
		WINDOW w AS
		(
			ORDER BY MVS.DataStorico
		)
	)

	SELECT 100 - ((TT.KWProdottiSucc*100)/TT.KWProdotti), 100 - ((TT.KWConsumatiSucc*100)/TT.KWConsumati), 100 - ((TT.GuadagnoSucc*100)/TT.Guadagno), 100 - ((TT.ConsumoSucc*100)/TT.Consumo) INTO PercentualeKWProdotti, PercentualeKWConsumo, PercentualeKWSpesa, PercentualeKWGuadagno
	FROM TableTarget TT
	WHERE KWProdottiSucc IS NOT NULL;
    
    SET Risultato = CONCAT('Produzione KW: ', FLOOR(ABS(PercentualeKWProdotti)), IF(PercentualeKWProdotti > 0, ' in meno.', ' in più.'),
						'   Consumo KW: ', FLOOR(ABS(PercentualeKWConsumo)), IF(PercentualeKWConsumo > 0, ' in meno.', ' in più.'),
						'   Spesa KW: ', FLOOR(ABS(PercentualeKWSpesa)), IF(PercentualeKWSpesa > 0, ' in meno.', ' in più.'),
						'   Guadagno KW: ', FLOOR(ABS(PercentualeKWGuadagno)), IF(PercentualeKWGuadagno < 0, ' in meno.', ' in più.'));
    
    SELECT Risultato;
END $$

DELIMITER ;

/*
	Genera un suggerimento
*/
drop procedure if exists creaSuggerimento
delimiter $$
create procedure creaSuggerimento(in meteo int)
	begin
		declare avgKWProdottiMeteo double default 0.0;
		declare finito int default 0;
		declare IDDispositivo int default 0;
		declare IDLivello int default 0;
		declare mediaKWConsumati double default 0.0;
        
        create temporary table suggerimento(
			IDDispositivo int not null,
            IDLivello int not null,
            MediaKWConsumati double not null,
            primary key (IDDispositivo, IDLivello)
        );
        
        declare cursureSugg cursor for
		with mediaKW_Meteo as(
			select avg(KWProdotti) into avgKWProdottiMeteo
			from storicoproduzioneenergia
			where IDCondizioneatmosferica = meteo
        ),
        mediaKW_Consumati_Livelli as(
			select IDLivello, avg(KWConsumati) as mediaKWConsumati
			from consumolivello L
			inner join consumodispositivo D on L.IDDispositivo = D.IDDispositivo
			where IDCondizioneatmosferica = meteo
			group by IDLivello
        ),
        mediaKW_Consumati_noLivelli as(
			select IDDispositivo, NULL as IDLivello, avg(KWConsumati) as mediaKWConsumati
			from consumodispositivo
			where IDConsumodispositivo in (
				select IDDispositivo
				from dispositivo
				where NTipoDispositivo = 1 or NTipoDispositivo = 5
			)
			group by IDDispositivo
        ),
		temp as(
			select IDDispositivo, IDLivello, mediaKWConsumati
			from livello natural join mediaKW_Consumati_Livelli natural join possiede natural join dispositivo
        )
        
        select *
        from temp union mediaKW_Consumati_noLivelli;
        
        declare continue handler for not found set finito = 1;
        
        open cursoreSugg;
        
        scan: loop
			fetch cursoreSugg into IDDIspositivo, IDLivello, mediaKWConsumati
            
            IF finito = 1 THEN
				LEAVE scan;
			END IF;
            
            if(mediaKWConsumati < avgKWProdottiMeteo) then
				insert into suggerimento
                values(IDDIspositivo, IDLivello, mediaKWConsumati);
            end if;
		end loop scan;
        
        close cursoreSugg;
        
SELECT 
    *
FROM
    suggerimento;
	end

delimiter ;

drop trigger if exists suggerisci;

delimiter $$

create trigger suggerisci
after insert on immissionebatteria
for each row
	begin
		call creaSuggerimento(FLOOR(RAND()*6));
    end $$

delimiter ;

/*
	Crea un'impostazione
*/
drop procedure if exists create_setting;
delimiter $$
create procedure create_setting(
								in _ID integer, 
                                in _Inizio date,
                                in _fine date,
                                in e_mail varchar (31)
                                )
	begin
		insert into ImpostazioneDispositivi
		values (_ID, _inizio, _fine, _e_mail);
	end $$
delimiter ;

/*
	Trova la classe di dispositivi più presente
    nei suggerimenti accettati
    
    NO RIDONDANZA
*/
drop procedure if exists get_top_class;

delimiter $$

create procedure get_top_class()
	begin
		select D.NTipoDispositivo
		from Dispositivo D natural join
		(
			select IDDispositivo, max(accettati_per_dispositivo) as accettati
            from (
				select count(*) as accettati_per_dispositivo, IDDispositivo
				from Suggerimento
                where Scelto = 1
				group by IDDispositivo
            ) as c
            group by IDDispositivo
        ) as M
        where D.eliminato != 1
        group by D.NTipoDispositivo;
    end $$
delimiter ;

-- OPERAZIONE DI RANKING

drop procedure if exists d_rank;

delimiter $$

create procedure d_rank()
begin
	WITH TabellaTarget AS(
		SELECT S.IDDispositivo, COUNT(*) AS NumeroVolteCheEStatoScelto
		FROM SUGGERIMENTO S
		WHERE S.Scelto = 1
		GROUP BY S.IDDispositivo
	)

	SELECT TT.IDDispositivo, TT.NumeroVolteCheEStatoScelto, DENSE_RANK() OVER w AS Classifica
	FROM TabellaTarget TT
	WINDOW w AS
	(
		ORDER BY TT.NumeroVolteCheEStatoScelto DESC
	);
end$$
delimiter ;
