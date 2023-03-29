-- -------------------------------------------
-- Trigger, alcuni vincoli generici e businnes rules
-- -------------------------------------------

-- TOLTI PER IMPOSSIBILITA' DI INSERIMENTO

-- Controllo che l'hash della password sia unico, ipotizziamo che l'hash equivalga esattamente alla password

DROP TRIGGER IF EXISTS ControlloPassword;

DELIMITER $$

CREATE TRIGGER ControlloPassword
BEFORE INSERT ON `ACCOUNT`
FOR EACH ROW
BEGIN
	
    DECLARE NumeroPass INT DEFAULT 0;
    
    SELECT COUNT(*) INTO NumeroPass 
	FROM ACCOUNTENT A
    WHERE A.`Password` = NEW.`Password`;
    
    IF(NumeroPass <> 0) THEN
		 SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Password non univoca';
	END IF;
END $$

DELIMITER ;

-- Controllo che l'e-mail sia unica

DROP TRIGGER IF EXISTS ControlloEmail;

DELIMITER $$

CREATE TRIGGER ControlloEmail
BEFORE INSERT ON `ACCOUNT`
FOR EACH ROW
BEGIN
	
    DECLARE NumeroEmail INT DEFAULT 0;
    
    SELECT COUNT(*) INTO NumeroEmail 
	FROM ACCOUNTENT A
    WHERE A.e_mail = NEW.e_mail;
    
    IF(NumeroEmail <> 0) THEN
		 SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'e_mail gia utilizzata';
	END IF;
END $$

DELIMITER ;

-- Controllo che Il numero di telefono sia unico

DROP TRIGGER IF EXISTS ControlloTelefono;

DELIMITER $$

CREATE TRIGGER ControlloTelefono
BEFORE INSERT ON UTENTE
FOR EACH ROW
BEGIN
	
    DECLARE NumeroTelefoni INT DEFAULT 0;
    
    SELECT COUNT(*) INTO NumeroTelefoni 
	FROM UTENTE U
    WHERE U.NumeroTelefono = NEW.NumeroTelefono;
    
    IF(NumeroTelefoni <> 0) THEN
		 SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Numero di telefono già inserito';
	END IF;
END $$

DELIMITER ;

-- Controllo Tipo Documento di riconoscimento

DROP TRIGGER IF EXISTS ControlloTipoDocumento;

DELIMITER $$

CREATE TRIGGER ControlloTipoDocumento
BEFORE INSERT ON DOCUMENTODIRICONOSCIMENTO
FOR EACH ROW 
BEGIN
	IF(NEW.Tipologia) NOT IN('Carta di Identità', 'Passaporto', 'Patente') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Tipo documentoDi riconoscimento Sbagliato';
	END IF;
END $$

DELIMITER ;

-- Controllo Impostazioni Condizionatori

DROP TRIGGER IF EXISTS ControlloTemperaturaCondizionatore;

DELIMITER $$

CREATE TRIGGER ControlloTemperaturaCondizionatore
BEFORE INSERT ON IMPOSTAZIONECONDIZIONATORE
FOR EACH ROW 
BEGIN

	DECLARE finito INT DEFAULT 0;
    DECLARE TemperaturaMassima INT DEFAULT 0;
    DECLARE TemperaturaMinima INT DEFAULT 0;
    
	DECLARE cursoreTemp CURSOR FOR
	WITH IDDISPOSITIVITARGET AS
    (
		SELECT S.IDDispositivo
		FROM SITUATO S
		WHERE S.IDDispositivo IN (
									SELECT C.IDDIspositivo 
									FROM CONDIZIONATORE C
								)
			AND S.IDStanza = NEW.IDStanza
	)
    
    SELECT C.TempMax, C.TempMin
    FROM IDDISPOSITIVITARGET IDT
		NATURAL JOIN
        CONDIZIONATORE C;
        
	DECLARE CONTINUE HANDLER 
    FOR NOT FOUND SET finito = 1;
    
    OPEN cursoreTemp;
    
    scan : LOOP
		FETCH cursoreTemp INTO TemperaturaMassima, TemperaturaMinima;
        
        IF finito = 1 THEN
			LEAVE scan;
		END IF;
        
        IF(NEW.Temperatura < TemperaturaMinima OR NEW.Temperatura > TemperaturaMassima) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La temperatura inserita è sbalgiata';
            LEAVE scan;
		END IF;
	END LOOP scan;
    
    CLOSE cursoreTemp;
END $$

-- Accensisone Dispositivo

DELIMITER ;

drop procedure if exists turnOn;

delimiter $$

create procedure turnOn(in _IDD int)
	begin
		declare isActive tinyint default 0;
    
		select Attiva into isActive
        from dispositivo D 
			inner join 
			smartplug S
        on D.IDSmartPlug = S.IDSmartPlug
        WHERE D.IDDispositivo = _IDD;
        
        if(isActive IS FALSE) then
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La Smart Plug collegata al dispositivo non è attiva!';
        end if;
    end $$
    
DELIMITER ;

-- Memorizzazione sincrona per produzione energia

drop procedure if exists getEnergyData;
delimiter $$
create procedure getEnergyData(in inizio timestamp, in fine timestamp, in kw int, idSorg int, in idAtm int)
	begin
		insert into storicoproduzioneenergia
        values (inizio, fine, kw, idSorg, idAtm);
	end $$
delimiter ;

drop event if exists storeEnergyData;

create event storeEnergyData
on schedule every 15 minute
do
	/*
		La chiamata alla stored procedure utilizza le funzioni current_time, date_add e RAND per simulare
        il sistema di immissione dei dati da parte delle fonti di energia
	*/
 	call getEnergyData(current_time(), date_add(current_time(), interval 15 minute), RAND() * 100, 1, 2);
    
-- Temperatura SmartLight nei limiti

/*
TRIGGER ERRATO

drop trigger if exists checkSmartLightTemp;

delimiter $$

create trigger checkSmartLightTemp
before insert on impostazionesmartlight
for each row
begin
    -- prendo i dispositivi che sono smart light e stanno
    -- nella stessa stanza del dispositivo inserito
    
    declare finito INT DEFAULT 0;
    declare TempMax INT DEFAULT 0;
    declare TempMin INT DEFAULT 0;
    
	declare cursoreTemp cursor for
	with iddispositivitarget as
	(
		select S.IDDispositivo
		from situato S
		where S.IDDispositivo in
		(
			select SL.IDDispositivo
			from smartLight SL
		)
		and S.IDStanza = new.IDStanza  -- NON CAPISCO QUESTO
	)
	
    -- prendo temperatura massima e minima della smart light che voglio impostare
	select IDT.TemperaturaMassima, IDT.TemperaturaMinima
    from iddispositivitarget IDT natural join SmartLight;
    
    declare continue handler
    for not found set finito = 1;
    
    open cursoreTemp;
    
    scan : loop
    
		fetch cursoreTemp into TempMax, TempMin;
        
        if finito = 1 then
			leave scan;
		end if;
        
        -- se il valore inserito è fuori dai limiti segnalo un errore
        if(new.Temperatura < TempMin or new.Temperatura > TempMax) then
			signal sqlstate '45000'
            set message_text = 'La temperatura inserita non rientra nei limiti previsti.';
		end if;
	end loop scan;
    
    close cursoreTemp;
end $$

delimiter ;
*/

-- trigger corretto
drop trigger if exists checkSmartLightTemp;

delimiter $$

create trigger checkSmartLightTemp
before insert on impostazionesmartlight
for each row
begin
    -- prendo i dispositivi che sono smart light e stanno
    -- nella stessa stanza del dispositivo inserito
    
    declare finito INT DEFAULT 0;
    declare TemperaturaMassima INT DEFAULT 0;
    declare IntensitaMassima INT DEFAULT 0;
	
    -- prendo temperatura massima e minima della smart light che voglio impostare
	select SL.TemperaturaMassima, SL.IntensitaMassima INTO TemperaturaMassima, IntensitaMassima
    from SmartLight SL
    where SL.IDDispositivo = NEW.IDDispositivo;
    
	-- se il valore inserito è fuori dai limiti segnalo un errore
	if(new.KTemp > TemperaturaMassima or new.KTemp < 0 or new.PercInt > IntensitaMassima or new.PercInt < 0) then
		signal sqlstate '45000'
		set message_text = 'La temperatura/intensitàs inserita non rientra nei limiti previsti.';
	end if;
end $$

delimiter ;

-- Efficienza energetica quando scatta un'impostazione

drop procedure if exists computeEfficency;

delimiter $$

create procedure computeEfficency(in timeInizio timestamp)
begin
	-- da finire, calcoli inimmaginabili :/
	insert into efficienzaenergetica
    values (RAND() * 100, RAND() * 100, current_date());
end $$

delimiter ;

drop trigger if exists checkTime;

delimiter $$

create trigger checkTime
before insert on logdispositivo
for each row
begin
	declare timeCheck timestamp;
    
SELECT 
    TimestampInizio
INTO timeCheck FROM
    impostazionedispositivi
WHERE
    TimeStampInizio = CURRENT_TIMESTAMP();
    
    if(timeCheck is not null) then
		call computeEfficency(timeCheck);
    end if;
end$$

delimiter ;



-- TOLTO ALTRIMENTI NON POTEVO INSERIRE LE STANZE
-- Calcolo misure stanza

drop trigger if exists checkArea;

delimiter $$

create trigger checkArea
before insert on Stanza
for each row
begin
	declare areapianoterra int;
	declare areapianonew int;

	select sum(Larghezza * Lunghezza) into areapianoterra
    from stanza
    where PianoEdificio = 0 and NomeStanza != "Giardino";
    
    -- controllo che l'area del piano di NEW sia <= all'area del piano terra
    
    select sum(Larghezza * Lunghezza) into areapianonew
    from stanza
    where PianoEdificio = NEW.PianoEdificio and NomeStanza != "Giardino";
    
    if(areapianonew > areapianoterra) then
		signal sqlstate '45000'
			set message_text = "Impossibile aggiungere la stanza";
    end if;
end $$

delimiter ;

-- controllo impostazione condizionatore riguardi condizionatori della stanza target

DROP TRIGGER IF EXISTS ControlloCondizionatoriStanzaImpostazione;

DELIMITER $$

CREATE TRIGGER ControlloCondizionatoriStanzaImpostazione
BEFORE INSERT ON IMPOSTACOND 
FOR EACH ROW
BEGIN
	DECLARE finito INT DEFAULT 1;
    DECLARE Dispositivo INT DEFAULT 0;
    DECLARE verifica INT DEFAULT 0;
    
	WITH StanzaImpostazione AS
    (
		SELECT IC.IDStanza
		FROM IMPOSTAZIONECONDIZIONATORE IC
		WHERE IC.IDImpostazione = NEW.IDImpostazione
	),
    CondizionatoriStanzaTarget AS
    (
		SELECT S.IDDIspositivo
		FROM SITUATO S
			INNER JOIN
			StanzaImpostazione SI ON S.IDStanza = SI.IDStanza
		WHERE S.IDDispositivo IN (
									SELECT C.IDDispositivo
									FROM CONDIZIONATORE C
								)
	)

	SELECT 1 INTO verifica
	FROM CondizionatoriStanzaTarget CDT
	WHERE CDT.IDDispositivo = NEW.IDDIspositivo;
    
    IF(verifica <> 1) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Questo condizionatore non si trova nella stanza in cui si vuole applicare l''impostazione';
    END IF;
END $$

DELIMITER ;



DROP TRIGGER IF EXISTS ControlloPassword;
DROP TRIGGER IF EXISTS ControlloEmail;
DROP TRIGGER IF EXISTS ControlloTelefono;
DROP TRIGGER IF EXISTS ControlloTipoDocumento;
DROP TRIGGER IF EXISTS ControlloTemperaturaCondizionatore;
drop procedure if exists turnOn;
drop procedure if exists getEnergyData;
drop procedure if exists computeEfficency;
drop trigger if exists checkTime;
drop trigger if exists checkArea;
drop trigger if exists ControlloCondizionatoriStanzaImpostazione;