SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS MySmartHome;

USE MySmartHome;

-- ----------------------------
--  Table structure for `TIPO`
-- ----------------------------
DROP TABLE IF EXISTS TIPO;
CREATE TABLE TIPO (
    Tipologia VARCHAR(255) NOT NULL PRIMARY KEY,
    Ente VARCHAR(255) NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `DOCUMENTODIRICONOSCIMENTO`
-- ----------------------------
DROP TABLE IF EXISTS DOCUMENTODIRICONOSCIMENTO;
CREATE TABLE DOCUMENTODIRICONOSCIMENTO (
    NumeroDocumento VARCHAR(255) NOT NULL PRIMARY KEY,
    DataScadenza DATE NOT NULL,
    Tipologia VARCHAR(255) NOT NULL,
    FOREIGN KEY (Tipologia) REFERENCES TIPO(Tipologia)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `UTENTE`
-- ----------------------------
DROP TABLE IF EXISTS UTENTE;
CREATE TABLE UTENTE (
    CodiceFiscale CHAR(50) NOT NULL PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Cognome VARCHAR(255) NOT NULL,
    DataNascita DATE NOT NULL,
    NumeroTelefono CHAR(11) NOT NULL,
    NumeroDocumento VARCHAR(255) NOT NULL,
    FOREIGN KEY (NumeroDocumento)
        REFERENCES DOCUMENTODIRICONOSCIMENTO (NumeroDocumento)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `DOMANDASICUREZZA`
-- ----------------------------
DROP TABLE IF EXISTS DOMANDASICUREZZA;
CREATE TABLE DOMANDASICUREZZA (
    IDDomandaSicurezza INT AUTO_INCREMENT PRIMARY KEY,
    DomandaSicurezza VARCHAR(255) NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `ACCOUNT`
-- ----------------------------
DROP TABLE IF EXISTS `ACCOUNT`;
CREATE TABLE `ACCOUNT` (
    IDAccount INT AUTO_INCREMENT PRIMARY KEY,
    e_mail VARCHAR(255) NOT NULL,
    NomeUtente VARCHAR(255) NOT NULL,
    PrivilegioFasce BOOL NOT NULL,
    `Password` VARCHAR(255) NOT NULL,
    RispostaSicurezza VARCHAR(255) NOT NULL,
    CodiceFiscale CHAR(50) NOT NULL,
    IDDomandaSicurezza INT NOT NULL,
    FOREIGN KEY (CodiceFiscale)
        REFERENCES UTENTE (CodiceFiscale),
    FOREIGN KEY (IDDomandaSicurezza)
        REFERENCES DOMANDASICUREZZA (IDDomandaSicurezza)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `STANZA`
-- ----------------------------
DROP TABLE IF EXISTS STANZA;
CREATE TABLE STANZA (
    IDStanza INT AUTO_INCREMENT PRIMARY KEY,
    Larghezza INT NOT NULL,
    Lunghezza INT NOT NULL,
    NomeStanza VARCHAR(255) NOT NULL,
    PianoEdificio INT NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `PORTA`
-- ----------------------------
DROP TABLE IF EXISTS PORTA;
CREATE TABLE PORTA (
    StanzaPrecedente INT NOT NULL,
    StanzaSuccessiva INT NOT NULL,
    PRIMARY KEY (StanzaPrecedente , StanzaSuccessiva),
    FOREIGN KEY (StanzaPrecedente)
        REFERENCES STANZA (IDStanza),
    FOREIGN KEY (StanzaSuccessiva)
        REFERENCES STANZA (IDStanza)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `PUNTOCARDINALE`
-- ----------------------------
DROP TABLE IF EXISTS PUNTOCARDINALE;
CREATE TABLE PUNTOCARDINALE (
    PuntoCardinale CHAR(5) PRIMARY KEY
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `PORTAFINESTRA`
-- ----------------------------
DROP TABLE IF EXISTS PORTAFINESTRA;
CREATE TABLE PORTAFINESTRA (
    StanzaEsterna INT NOT NULL,
    StanzaInterna INT NOT NULL,
    PuntoCardinale CHAR(5) NOT NULL,
    PRIMARY KEY (StanzaEsterna , StanzaInterna , PuntoCardinale),
    FOREIGN KEY (StanzaEsterna)
        REFERENCES STANZA (IDStanza),
    FOREIGN KEY (StanzaInterna)
        REFERENCES STANZA (IDStanza),
    FOREIGN KEY (PuntoCardinale)
        REFERENCES PUNTOCARDINALE (PuntoCardinale)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `FINESTRA`
-- ----------------------------
DROP TABLE IF EXISTS FINESTRA;
CREATE TABLE FINESTRA (
    PuntoCardinale CHAR(5),
    IDStanza INT NOT NULL,
    NumeroFinestra INT NOT NULL,
    PRIMARY KEY (PuntoCardinale , IDStanza , NumeroFinestra),
    FOREIGN KEY (IDStanza)
        REFERENCES STANZA (IDStanza),
    FOREIGN KEY (PuntoCardinale)
        REFERENCES PUNTOCARDINALE (PuntoCardinale)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `PROPRIETALIVELLO`
-- ----------------------------
DROP TABLE IF EXISTS PROPRIETALIVELLO;
CREATE TABLE PROPRIETALIVELLO (
    IDProprietaLivello INT AUTO_INCREMENT PRIMARY KEY,
    ProprietaLivello VARCHAR(255) NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `TIPODISPOSITIVO`
-- ----------------------------
DROP TABLE IF EXISTS TIPODISPOSITIVO;
CREATE TABLE TIPODISPOSITIVO (
    NTipoDispositivo INT AUTO_INCREMENT PRIMARY KEY,
    TipoDispositivo VARCHAR(255) NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `SMARTPLUG`
-- ----------------------------
DROP TABLE IF EXISTS SMARTPLUG;
CREATE TABLE SMARTPLUG (
    IDSmartPlug INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Attiva TINYINT DEFAULT 1
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `DISPOSITIVO`
-- ----------------------------
DROP TABLE IF EXISTS DISPOSITIVO;
CREATE TABLE DISPOSITIVO (
    IDDispositivo INT AUTO_INCREMENT PRIMARY KEY,
    NomeDispositivo VARCHAR(255) NOT NULL,
    Eliminato BOOL NOT NULL,
    ConsumoKW DOUBLE NOT NULL,
    IDProprietaLivello INT DEFAULT NULL,
    NTipoDispositivo INT NOT NULL,
    IDSmartPlug INT NOT NULL,
    FOREIGN KEY (IDProprietaLivello)
        REFERENCES PROPRIETALIVELLO (IDProprietaLivello),
    FOREIGN KEY (NTipoDispositivo)
        REFERENCES TIPODISPOSITIVO (NTipoDispositivo),
    FOREIGN KEY (IDSmartPlug)
        REFERENCES SMARTPLUG (IDSmartPLug)
    -- UNIQUE (IDSmartPlug)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `DISPOSITIVOACICLONONINTERROMPIBILE`
-- ----------------------------
DROP TABLE IF EXISTS DISPOSITIVOACICLONONINTERROMPIBILE;
CREATE TABLE DISPOSITIVOACICLONONINTERROMPIBILE (
	IDDispositivo INT NOT NULL PRIMARY KEY,
    Durata TIME NOT NULL,
    FOREIGN KEY (IDDispositivo) REFERENCES DISPOSITIVO(IDDispositivo)
);
-- ----------------------------
--  Table structure for `PRIVILEGI`
-- ----------------------------
DROP TABLE IF EXISTS PRIVILEGI;
CREATE TABLE PRIVILEGI (
    IDDispositivo INT NOT NULL,
    IDAccount INT NOT NULL,
    PRIMARY KEY (IDDispositivo , IDAccount),
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo),
    FOREIGN KEY (IDAccount)
        REFERENCES ACCOUNTENT (IDAccount)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `SITUATO`
-- ----------------------------
DROP TABLE IF EXISTS SITUATO;
CREATE TABLE SITUATO (
    IDDispositivo INT NOT NULL,
    IDStanza INT NOT NULL,
    PRIMARY KEY (IDDispositivo , IDStanza),
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo),
    FOREIGN KEY (IDStanza)
        REFERENCES STANZA (IDStanza)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `TIPOLIVELLO`
-- ----------------------------
DROP TABLE IF EXISTS TIPOLIVELLO;
CREATE TABLE TIPOLIVELLO (
    NTipoLivello INT NOT NULL PRIMARY KEY,
    TipoLivello VARCHAR(255) NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `LIVELLO`
-- ----------------------------
DROP TABLE IF EXISTS LIVELLO;
CREATE TABLE LIVELLO (
    IDLivello INT AUTO_INCREMENT PRIMARY KEY,
    NomeLivello VARCHAR(255) NOT NULL,
    NTipoLivello INT NOT NULL,
    MediaConsumoKW DOUBLE DEFAULT 0,
    proprieta VARCHAR(255) NOT NULL,
    LivelloPersonalizzato BOOL DEFAULT FALSE,
    FOREIGN KEY (NTipoLivello)
        REFERENCES TIPOLIVELLO (NTipoLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `LIVELLOCONSUMOENERGETICO`
-- ----------------------------
DROP TABLE IF EXISTS LIVELLOCONSUMOENERGETICO;
CREATE TABLE LIVELLOCONSUMOENERGETICO (
	IDLivello INT NOT NULL PRIMARY KEY,
    Durata TIME NOT NULL,
    FOREIGN KEY(IDLivello) REFERENCES LIVELLO(IDLivello)
);

-- ----------------------------
--  Table structure for `POSSIEDE`
-- ----------------------------
DROP TABLE IF EXISTS POSSIEDE;
CREATE TABLE POSSIEDE (
    IDDispositivo INT NOT NULL,
    IDLivello INT NOT NULL,
    PRIMARY KEY(IDDispositivo, IDLivello),
    FOREIGN KEY (IDDispositivo) REFERENCES DISPOSITIVO(IDDispositivo),
    FOREIGN KEY (IDLivello) REFERENCES LIVELLO(IDLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `POSSIEDELCE`
-- ----------------------------
DROP TABLE IF EXISTS POSSIEDELCE;
CREATE TABLE POSSIEDELCE (
    IDDispositivo INT NOT NULL,
    IDLivello INT NOT NULL,
    PRIMARY KEY(IDDispositivo, IDLivello),
    FOREIGN KEY (IDDispositivo) REFERENCES DISPOSITIVOACICLONONINTERROMPIBILE(IDDispositivo),
    FOREIGN KEY (IDLivello) REFERENCES LIVELLOCONSUMOENERGETICO(IDLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `LOGDISPOSITIVO`
-- ----------------------------
DROP TABLE IF EXISTS LOGDISPOSITIVO;
CREATE TABLE LOGDISPOSITIVO (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    IDAccount INT NOT NULL,
    TimestampFine TIMESTAMP DEFAULT NULL,
    DA INT DEFAULT 0,
    PRIMARY KEY (TimestampInizio , IDDispositivo),
    FOREIGN KEY (IDAccount)
        REFERENCES ACCOUNTENT (IDAccount)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `LOGLIVELLO`
-- ----------------------------
DROP TABLE IF EXISTS LOGLIVELLO;
CREATE TABLE LOGLIVELLO (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    IDLivello INT NOT NULL,
    PRIMARY KEY (TimestampInizio , IDDispositivo , IDLivello),
    FOREIGN KEY (TimestampInizio , IDDispositivo)
        REFERENCES LOGDISPOSITIVO (TimestampInizio , IDDispositivo),
    FOREIGN KEY (IDLivello)
        REFERENCES LIVELLO (IDLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `DISPOSITIVOLIVELLO`
-- ----------------------------
DROP TABLE IF EXISTS DISPOSITIVOLIVELLO;
CREATE TABLE DISPOSITIVOLIVELLO (
    IDDispositivo INT NOT NULL,
    IDLivello INT NOT NULL,
    PRIMARY KEY (IDDispositivo , IDLivello),
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo),
    FOREIGN KEY (IDLivello)
        REFERENCES LIVELLO (IDLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPOSTAZIONEDISPOSITIVI`
-- ----------------------------
DROP TABLE IF EXISTS IMPOSTAZIONEDISPOSITIVI;
CREATE TABLE IMPOSTAZIONEDISPOSITIVI (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    IDAccount INT NOT NULL,
    TimestampFine TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (TimestampInizio , IDDispositivo),
    FOREIGN KEY (IDAccount)
        REFERENCES ACCOUNTENT (IDAccount)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPLIVELLO`
-- ----------------------------
DROP TABLE IF EXISTS IMPLIVELLO;
CREATE TABLE IMPLIVELLO (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    IDLivello INT NOT NULL,
    PRIMARY KEY (TimestampInizio , IDDispositivo , IDLivello),
    FOREIGN KEY (TimestampInizio , IDDispositivo)
        REFERENCES LOGDISPOSITIVO (TimestampInizio , IDDispositivo),
    FOREIGN KEY (IDLivello)
        REFERENCES LIVELLO (IDLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `GRUPPOSORGENTI`
-- ----------------------------
DROP TABLE IF EXISTS GRUPPOSORGENTI;
CREATE TABLE GRUPPOSORGENTI (
    IDGruppoSorgenti INT AUTO_INCREMENT PRIMARY KEY,
    DataAttivazione DATE NOT NULL,
    NumeroTotaleKWProdotti DOUBLE NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `SORGENTEENERGIARINNOVABILE`
-- ----------------------------
DROP TABLE IF EXISTS SORGENTEENERGIARINNOVABILE;
CREATE TABLE SORGENTEENERGIARINNOVABILE (
    NSeriale INT AUTO_INCREMENT PRIMARY KEY,
    KWProdottiMedia DOUBLE NOT NULL,
    tipo VARCHAR(255) NOT NULL,
    IDGruppoSorgenti INT NOT NULL,
    FOREIGN KEY (IDGruppoSorgenti)
        REFERENCES GRUPPOSORGENTI (IDGruppoSorgenti)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `CONDIZIONEATMOSFERICA`
-- ----------------------------
DROP TABLE IF EXISTS CONDIZIONEATMOSFERICA;
CREATE TABLE CONDIZIONEATMOSFERICA (
    IDCondizioneAtmosferica INT AUTO_INCREMENT PRIMARY KEY,
    CondizioneAtmosferica VARCHAR(255) NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `STORICOPRODUZIONEENERGIA`
-- ----------------------------
DROP TABLE IF EXISTS STORICOPRODUZIONEENERGIA;
CREATE TABLE STORICOPRODUZIONEENERGIA (
	InizioTimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FineTimeStamp TIMESTAMP DEFAULT (CURRENT_TIMESTAMP() + INTERVAL 15 MINUTE),
    KWProdotti INT NOT NULL,
    IDGruppoSorgenti INT NOT NULL,
    IDCondizioneAtmosferica INT NOT NULL,
    FOREIGN KEY (IDGruppoSorgenti) REFERENCES GRUPPOSORGENTI(IDGruppoSorgenti),
    FOREIGN KEY (IDCondizioneAtmosferica) REFERENCES CONDIZIONEATMOSFERICA(IDCondizioneAtmosferica)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
--  Table structure for `RETESTATALE`
-- ----------------------------
DROP TABLE IF EXISTS RETESTATALE;
CREATE TABLE RETESTATALE (
    CodiceRete INT NOT NULL PRIMARY KEY,
    DataAttivazione DATE NOT NULL,
    IDGruppoSorgenti INT NOT NULL,
    Compagnia VARCHAR(255) NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `FASCIAORARIA`
-- ----------------------------
DROP TABLE IF EXISTS FASCIAORARIA;
CREATE TABLE FASCIAORARIA (
    IDFascia INT AUTO_INCREMENT PRIMARY KEY,
    InizioFasciaOraria TIME NOT NULL,
    FineFasciaOraria TIME NOT NULL,
    CostoKW DOUBLE NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `PRELIEVO`
-- ----------------------------
DROP TABLE IF EXISTS PRELIEVO;
CREATE TABLE PRELIEVO (
    TimeStampPrelievo TIMESTAMP DEFAULT CURRENT_TIMESTAMP PRIMARY KEY,
    KWPrelievo DOUBLE NOT NULL,
    IDFascia INT NOT NULL,
    CodiceRete INT NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMMISSIONE`
-- ----------------------------
DROP TABLE IF EXISTS IMMISSIONE;
CREATE TABLE IMMISSIONE (
    TimeStampImmissione TIMESTAMP DEFAULT CURRENT_TIMESTAMP PRIMARY KEY,
    KWImmissione DOUBLE NOT NULL,
    IDFascia INT NOT NULL,
    CodiceRete INT NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `ORARIOFASCE`
-- ----------------------------
DROP TABLE IF EXISTS ORARIOFASCE;
CREATE TABLE ORARIOFASCE (
    OraInizio TIME NOT NULL,
    OraFine TIME NOT NULL,
    IDFascia INT NOT NULL,
    IDAccount INT DEFAULT NULL,
    PRIMARY KEY (OraInizio , OraFine),
    FOREIGN KEY (IDFascia)
        REFERENCES FASCIAORARIA (IDFascia),
    FOREIGN KEY (IDAccount)
        REFERENCES ACCOUNTENT (IDAccount)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `DIVISAIN`
-- ----------------------------
DROP TABLE IF EXISTS DIVISAIN;
CREATE TABLE DIVISAIN (
    IDFascia INT NOT NULL,
    CodiceRete INT NOT NULL,
    PRIMARY KEY (IDFascia , CodiceRete),
    FOREIGN KEY (IDFascia)
        REFERENCES FASCIAORARIA (IDFascia),
    FOREIGN KEY (CodiceRete)
        REFERENCES RETESTATALE (CodiceRete)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `UTILIZZORETE`
-- ----------------------------
DROP TABLE IF EXISTS UTILIZZORETE;
CREATE TABLE UTILIZZORETE (
    OraInizio TIME NOT NULL,
    OraFine TIME NOT NULL,
    CodiceRete INT NOT NULL,
    PRIMARY KEY (OraInizio , OraFine , CodiceRete),
    FOREIGN KEY (OraInizio , OraFine)
        REFERENCES ORARIOFASCE (OraInizio , OraFine),
    FOREIGN KEY (CodiceRete)
        REFERENCES RETESTATALE (CodiceRete)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `UTILIZZOSE`
-- ----------------------------
DROP TABLE IF EXISTS UTILIZZOSE;
CREATE TABLE UTILIZZOSE (
    OraInizio TIME NOT NULL,
    OraFine TIME NOT NULL,
    IDGruppoSorgenti INT NOT NULL,
    PRIMARY KEY (OraInizio , OraFine , IDGruppoSorgenti),
    FOREIGN KEY (OraInizio , OraFine)
        REFERENCES ORARIOFASCE (OraInizio , OraFine),
    FOREIGN KEY (IDGruppoSorgenti)
        REFERENCES GRUPPOSORGENTI (IDGruppoSorgenti)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `BATTERIA`
-- ----------------------------
DROP TABLE IF EXISTS BATTERIA;
CREATE TABLE BATTERIA (
    CodiceBatteria INT NOT NULL PRIMARY KEY,
    capacitaMassima INT NOT NULL,
    KWAttuali DOUBLE NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMMISSIONEBATTERIA`
-- ----------------------------
DROP TABLE IF EXISTS IMMISSIONEBATTERIA;
CREATE TABLE IMMISSIONEBATTERIA (
    TimeStampImmissione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KWImmessi INT NOT NULL,
    CodiceBatteria INT NOT NULL,
    FOREIGN KEY(CodiceBatteria) REFERENCES BATTERIA(CodiceBatteria)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `CONSUMOBATTERIA`
-- ----------------------------
DROP TABLE IF EXISTS CONSUMOBATTERIA;
CREATE TABLE CONSUMOBATTERIA (
    TimeStampConsumo TIMESTAMP DEFAULT CURRENT_TIMESTAMP PRIMARY KEY,
    KWConsumati INT NOT NULL,
    IDFascia INT NOT NULL,
    CodiceBatteria INT NOT NULL,
    FOREIGN KEY (IDFascia)
        REFERENCES FASCIAORARIA (IDFascia),
    FOREIGN KEY (CodiceBatteria)
        REFERENCES BATTERIA (CodiceBatteria)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `CONSUMOGRUPPOSORGENTI`
-- ----------------------------
DROP TABLE IF EXISTS CONSUMOGRUPPOSORGENTI;
CREATE TABLE CONSUMOGRUPPOSORGENTI (
    TimeStampConsumo TIMESTAMP DEFAULT CURRENT_TIMESTAMP PRIMARY KEY,
    KWConsumati INT NOT NULL,
    IDFascia INT NOT NULL,
    IDGruppoSorgenti INT NOT NULL,
    FOREIGN KEY (IDFascia)
        REFERENCES FASCIAORARIA (IDFascia),
    FOREIGN KEY (IDGruppoSorgenti)
        REFERENCES GRUPPOSORGENTI (IDGruppoSorgenti)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `CONSUMODISPOSITIVO`
-- ----------------------------
DROP TABLE IF EXISTS CONSUMODISPOSITIVO;
CREATE TABLE CONSUMODISPOSITIVO (
	InizioAccensione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    FineAccensione TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 15 MINUTE),
    KWConsumati INT NOT NULL,
    PRIMARY KEY(InizioAccensione, IDDispositivo),
    FOREIGN KEY(IDDispositivo) REFERENCES DISPOSITIVO(IDDispositivo)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
--  Table structure for `CONSUMOLIVELLO`
-- ----------------------------
DROP TABLE IF EXISTS CONSUMOLIVELLO;
CREATE TABLE CONSUMOLIVELLO (
    InizioAccensione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    IDLivello INT NOT NULL,
    IDCondizioneatmosferica INT NOT NULL,
    PRIMARY KEY (InizioAccensione , IDDispositivo , IDLivello, IDCondizioneatmosferica),
    FOREIGN KEY (InizioAccensione)
        REFERENCES CONSUMODISPOSITIVO (InizioAccensione),
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo),
    FOREIGN KEY (IDLivello)
        REFERENCES LIVELLO (IDLivello),
	FOREIGN KEY (IDCondizioneatmosferica)
		REFERENCES condizioneatmosferica (IDCondizioneatmosferica)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `CONDIZIONATORE`
-- ----------------------------
DROP TABLE IF EXISTS CONDIZIONATORE;
CREATE TABLE CONDIZIONATORE (
    IDDispositivo INT NOT NULL PRIMARY KEY,
    TempMin INT NOT NULL,
	TempMax INT NOT NULL,
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `SMARTLIGHT`
-- ----------------------------
DROP TABLE IF EXISTS SMARTLIGHT;
CREATE TABLE SMARTLIGHT (
    IDDispositivo INT NOT NULL PRIMARY KEY,
    TemperaturaMassima INT NOT NULL,
    TemperaturaMinima INT NOT NULL,
    IntensitaMassima INT NOT NULL,
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `LIVELLODIUMIDITA`
-- ----------------------------
DROP TABLE IF EXISTS LIVELLODIUMIDITA;
CREATE TABLE LIVELLODIUMIDITA (
    IDLivello INT NOT NULL PRIMARY KEY,
    FOREIGN KEY (IDLivello)
        REFERENCES LIVELLO (IDLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `OFFRE`
-- ----------------------------
DROP TABLE IF EXISTS OFFRE;
CREATE TABLE OFFRE (
    IDLivello INT NOT NULL,
    IDDispositivo INT NOT NULL,
    PRIMARY KEY (IDLivello , IDDispositivo),
    FOREIGN KEY (IDLivello)
        REFERENCES LIVELLO (IDLivello),
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `EFFICIENZAENERGETICA`
-- ----------------------------
DROP TABLE IF EXISTS EFFICIENZAENERGETICA;
CREATE TABLE EFFICIENZAENERGETICA (
    IDEfficienzaEnergetica INT AUTO_INCREMENT PRIMARY KEY,
    TemperaturaInizialeInterna INT NOT NULL,
    TemperaturaInizialeEsterna INT NOT NULL,
    CoefficienteDiDissipazione INT NOT NULL,
    ConsumoKW INT NOT NULL,
    GiornoDiCacolo DATE NOT NULL
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `CARATTERIZZATA`
-- ----------------------------
DROP TABLE IF EXISTS CARATTERIZZATA;
CREATE TABLE CARATTERIZZATA (
    IDEfficienzaEnergetica INT NOT NULL,
    IDStanza INT NOT NULL,
    PRIMARY KEY (IDEfficienzaEnergetica , IDStanza),
    FOREIGN KEY (IDEfficienzaEnergetica)
        REFERENCES EFFICIENZAENERGETICA (IDEfficienzaEnergetica),
    FOREIGN KEY (IDStanza)
        REFERENCES STANZA (IDStanza)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPOSTAZIONECONDIZIONATORE`
-- ----------------------------
DROP TABLE IF EXISTS IMPOSTAZIONECONDIZIONATORE;
CREATE TABLE IMPOSTAZIONECONDIZIONATORE (
    IDImpostazione INT AUTO_INCREMENT PRIMARY KEY,
    Temperatura INT NOT NULL,
    InizioImpostazione TIME NOT NULL, 
    FineImpostazione TIME NOT NULL,
    IDLivello INT NOT NULL,
    IDAccount INT NOT NULL,
    IDStanza INT NOT NULL,
    FOREIGN KEY (IDLivello)
        REFERENCES LIVELLODIUMIDITA (IDLivello),
    FOREIGN KEY (IDAccount)
        REFERENCES ACCOUNTENT (IDAccount),
    FOREIGN KEY (IDStanza)
        REFERENCES STANZA (IDStanza)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPOSTACOND`
-- ----------------------------
DROP TABLE IF EXISTS IMPOSTACOND;
CREATE TABLE IMPOSTACOND (
    IDImpostazione INT NOT NULL,
    IDDispositivo INT NOT NULL,
    PRIMARY KEY (IDImpostazione , IDDispositivo),
    FOREIGN KEY (IDImpostazione)
        REFERENCES IMPOSTAZIONECONDIZIONATORE (IDImpostazione),
    FOREIGN KEY (IDDispositivo)
        REFERENCES CONDIZIONATORE (IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `MESE`
-- ----------------------------
DROP TABLE IF EXISTS MESE;
CREATE TABLE MESE (
    IDMese INT AUTO_INCREMENT PRIMARY KEY,
    Mese VARCHAR(50)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `GIORNO`
-- ----------------------------
DROP TABLE IF EXISTS GIORNO;
CREATE TABLE GIORNO (
    IDGiorno INT AUTO_INCREMENT PRIMARY KEY,
    Giorno VARCHAR(50)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `PERIODO`
-- ----------------------------
DROP TABLE IF EXISTS PERIODO;
CREATE TABLE PERIODO (
    IDImpostazione INT NOT NULL,
    IDGiorno INT NOT NULL,
    IDMese INT NOT NULL,
    PRIMARY KEY (IDImpostazione , IDGiorno , IDMese),
    FOREIGN KEY (IDImpostazione)
        REFERENCES IMPOSTAZIONECONDIZIONATORE (IDImpostazione),
    FOREIGN KEY (IDGiorno)
        REFERENCES GIORNO (IDGiorno),
    FOREIGN KEY (IDMese)
        REFERENCES MESE (IDMese)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPOSTAZIONESMARTLIGHT`
-- ----------------------------
DROP TABLE IF EXISTS IMPOSTAZIONESMARTLIGHT;
CREATE TABLE IMPOSTAZIONESMARTLIGHT (
    NumeroImpostazione INT NOT NULL,
    IDDispositivo INT NOT NULL,
    IDAccount INT NOT NULL,
    KTemp INT NOT NULL,
    PercInt INT NOT NULL,
    PRIMARY KEY (NumeroImpostazione , IDDispositivo),
    FOREIGN KEY (IDDispositivo)
        REFERENCES SMARTLIGHT (IDDispositivo),
    FOREIGN KEY (IDAccount)
        REFERENCES ACCOUNTENT (IDAccount)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPOSTAZIONETOTALESMARTLIGHT`
-- ----------------------------
DROP TABLE IF EXISTS IMPOSTAZIONETOTALESMARTLIGHT;
CREATE TABLE IMPOSTAZIONETOTALESMARTLIGHT (
    NumeroImpostazioneTot INT AUTO_INCREMENT PRIMARY KEY,
    IDAccount INT NOT NULL,
    FOREIGN KEY (IDAccount)
        REFERENCES ACCOUNTENT (IDAccount)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `COMPONE`
-- ----------------------------
DROP TABLE IF EXISTS COMPONE;
CREATE TABLE COMPONE (
    NumeroImpostazione INT NOT NULL,
    IDDispositivo INT NOT NULL,
    NumeroImpostazioneTot INT NOT NULL,
    PRIMARY KEY (NumeroImpostazione , NumeroImpostazioneTot , IDDispositivo),
    FOREIGN KEY (NumeroImpostazione , IDDispositivo)
        REFERENCES IMPOSTAZIONESMARTLIGHT (NumeroImpostazione , IDDispositivo),
    FOREIGN KEY (NumeroImpostazioneTot)
        REFERENCES IMPOSTAZIONETOTALESMARTLIGHT (NumeroImpostazioneTot)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `LOGTEMPCONDIZIONATORE`
-- ----------------------------
DROP TABLE IF EXISTS LOGTEMPCONDIZIONATORE;
CREATE TABLE LOGTEMPCONDIZIONATORE (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    Temperatura INT NOT NULL,
    PRIMARY KEY (TimestampInizio , IDDispositivo),
    FOREIGN KEY (TimestampInizio , IDDispositivo)
        REFERENCES LOGDISPOSITIVO (TimestampInizio , IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `LOGTEMPINTSMARTLIGHT`
-- ----------------------------
DROP TABLE IF EXISTS LOGTEMPMPINTARTLIGHT;
CREATE TABLE LOGTEMPMPINTARTLIGHT (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    KTemp INT NOT NULL,
    PercInt INT NOT NULL,
    PRIMARY KEY (TimestampInizio , IDDispositivo),
    FOREIGN KEY (TimestampInizio , IDDispositivo)
        REFERENCES LOGDISPOSITIVO (TimestampInizio , IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPTEMPCONDIZIONATORE`
-- ----------------------------
DROP TABLE IF EXISTS IMPTEMPCONDIZIONATORE;
CREATE TABLE IMPTEMPCONDIZIONATORE (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    Temperatura INT NOT NULL,
    PRIMARY KEY (TimestampInizio , IDDispositivo),
    FOREIGN KEY (TimestampInizio , IDDispositivo)
        REFERENCES IMPOSTAZIONEDISPOSITIVI (TimestampInizio , IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `IMPTEMPMPINTARTLIGHT`
-- ----------------------------
DROP TABLE IF EXISTS IMPTEMPMPINTARTLIGHT;
CREATE TABLE IMPTEMPMPINTARTLIGHT (
    TimestampInizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    KTemp INT NOT NULL,
    PercInt INT NOT NULL,
    PRIMARY KEY (TimestampInizio , IDDispositivo),
    FOREIGN KEY (TimestampInizio , IDDispositivo)
        REFERENCES IMPOSTAZIONEDISPOSITIVI (TimestampInizio , IDDispositivo)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `MONITORAGGIOLUCI`
-- ----------------------------
DROP TABLE IF EXISTS MONITORAGGIOLUCI;
CREATE TABLE MONITORAGGIOLUCI (
    DataAccensione DATE NOT NULL,
    PRIMARY KEY (DataAccensione)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `ACCENSIONE`
-- ----------------------------
DROP TABLE IF EXISTS ACCENSIONE;
CREATE TABLE ACCENSIONE (
    IDDispositivo INT NOT NULL,
    DataAccensione DATE NOT NULL,
    OraAccensione TIME NOT NULL,
    OraSpegnimento TIME DEFAULT NULL,
    PRIMARY KEY (IDDispositivo, DataAccensione, OraAccensione),
    FOREIGN KEY (IDDispositivo)
        REFERENCES SMARTLIGHT (IDDispositivo),
	FOREIGN KEY (DataAccensione)
        REFERENCES MONITORAGGIOLUCI (DataAccensione)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `ACCESAPER`
-- ----------------------------
DROP TABLE IF EXISTS ACCESAPER;
CREATE TABLE ACCESAPER (
    IDDispositivo INT NOT NULL,
    DataAccensione DATE NOT NULL,
    TempoAccensione TIME NOT NULL,
    TempoSpegnimento TIME NOT NULL,
    PRIMARY KEY (IDDispositivo, DataAccensione),
    FOREIGN KEY (IDDispositivo)
        REFERENCES DISPOSITIVO (IDDispositivo),
	FOREIGN KEY (DataAccensione)
        REFERENCES MONITORAGGIOLUCI (DataAccensione)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `BOLLETTA`
-- ----------------------------
DROP TABLE IF EXISTS BOLLETTA;
CREATE TABLE BOLLETTA (
    IDFattura INT AUTO_INCREMENT PRIMARY KEY,
    InizioCalcoloBolletta TIMESTAMP NOT NULL,
    FineCalcoloBolletta TIMESTAMP NOT NULL,
    costoTotale DOUBLE NOT NULL,
    CodiceRete INT NOT NULL,
    CodiceFiscale VARCHAR(255) NOT NULL,
    FOREIGN KEY (CodiceRete) REFERENCES RETESTATALE (CodiceRete),
    FOREIGN KEY (CodiceFiscale) REFERENCES UTENTE (CodiceFiscale)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `SUGGERIMENTO`
-- ----------------------------
DROP TABLE IF EXISTS SUGGERIMENTO;
CREATE TABLE SUGGERIMENTO (
    TimeStampSuggerimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IDDispositivo INT NOT NULL,
    IDLivello INT NOT NULL,
	scelto BOOL DEFAULT FALSE,
    DurataAccensioneDispositivo TIME NOT NULL,
    PRIMARY KEY(TimeStampSuggerimento, IDDispositivo, IDLivello),
    FOREIGN KEY(IDDispositivo) REFERENCES DISPOSITIVOACICLONONINTERROMPIBILE(IDDispositivo), 
    FOREIGN KEY(IDLivello) REFERENCES LIVELLO(IDLivello)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;


/* SENTIRE */
-- ----------------------------
--  Table structure for `CONSUMOTEMPERATURA`
-- ----------------------------
DROP TABLE IF EXISTS CONSUMOTEMPERATURA;
CREATE TABLE CONSUMOTEMPERATURA (
    TemperaturaInizialeInterna DOUBLE NOT NULL,
    TemperaturaInizialeEsterna DOUBLE NOT NULL,
    ConsumoKW DOUBLE NOT NULL,
    PRIMARY KEY(TemperaturaInizialeInterna, TemperaturaInizialeEsterna)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `TEMPERATURA`
-- ----------------------------
DROP TABLE IF EXISTS TEMPERATURA;
CREATE TABLE TEMPERATURA (
    IDStanza INT NOT NULL,
    TimeStampRilevazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TemperaturaInizialeInterna DOUBLE NOT NULL,
    TemperaturaInizialeEsterna DOUBLE NOT NULL,
    PRIMARY KEY(IDStanza, TimeStampRilevazione),
    FOREIGN KEY(TemperaturaInizialeInterna, TemperaturaInizialeEsterna) REFERENCES CONSUMOTEMPERATURA(TemperaturaInizialeInterna, TemperaturaInizialeEsterna)
)  ENGINE=INNODB DEFAULT CHARSET=LATIN1;

-- ----------------------------
--  Table structure for `MV_Storico`
-- ----------------------------
DROP TABLE IF EXISTS MV_Storico;
CREATE TABLE MV_Storico(
		DataStorico TIMESTAMP NOT NULL PRIMARY KEY, 
        KWProdotti DOUBLE NOT NULL, 
        KWConsumati DOUBLE NOT NULL, 
        Guadagno DOUBLE NOT NULL, 
        Consumo DOUBLE NOT NULL
) ENGINE=INNODB DEFAULT CHARSET=LATIN1;
    
-- -------------------------------------------
-- Trigger, alcuni vincoli generici e businnes rules
-- -------------------------------------------

-- TOLTI PER IMPOSSIBILITA' DI INSERIMENTO
/*
-- Controllo che l'hash della password sia unico, ipotizziamo che l'hash equivalga esattamente alla password

DROP TRIGGER IF EXISTS ControlloPassword;

DELIMITER $$

CREATE TRIGGER ControlloPassword
BEFORE INSERT ON ACCOUNTENT
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
BEFORE INSERT ON ACCOUNTENT
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
    
    SELECT IDT.TempMax, IDT.TempMin
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
		END IF;
	END LOOP scan;
    
    CLOSE cursoreTemp;
END $$

-- Accenisone Dispositivo

DELIMITER ;

drop procedure if exists turnOn;

delimiter $$

create procedure turnOn(in _IDD int)
	begin
		declare isActive tinyint default 0;
    
		select Attiva into isActive
        from dispoditivo D inner join smartplug S
        on D.IDDispositivo = S.IDDispositivo;
        
        if(!isActive) then
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
-- 	call getEnergyData(current_time(), date_add(current_time(), interval 15 minute), RAND() * 100, 1, 2);
    
-- Temperatura SmartLight nei limiti

/*

NON MI TORNA

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



TOLTO ALTRIMENTI NON POTEVO INSERIRE LE STANZE
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

*/