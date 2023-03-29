SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Insert values for `TIPO`
-- ----------------------------
TRUNCATE TIPO;
INSERT INTO TIPO (Tipologia, Ente) VALUES
	('Carta Di Identità', 'Comune'),
	('Passaporto', 'Ministero degli esteri'),
	('Patente', 'Motorizzazione');

-- ----------------------------
--  Insert values for `DOCUMENTODIRICONOSCIMENTO`
-- ----------------------------
TRUNCATE DOCUMENTODIRICONOSCIMENTO;
INSERT INTO DOCUMENTODIRICONOSCIMENTO (NumeroDocumento, DataScadenza, Tipologia) VALUES
	('12345', '2023-04-13', 'Carta Di Identità'),
	('54321', '2025-10-02', 'Patente'),
	('23456', '2033-01-02', 'Carta Di Identità'),
	('65432', '2022-03-12', 'Passaporto'),
	('34567', '2018-12-12', 'Patente');
    
-- ----------------------------
--  Insert values for `UTENTE`
-- ----------------------------
TRUNCATE UTENTE;
INSERT INTO UTENTE (CodiceFiscale, Nome, Cognome, DataNascita, NumeroTelefono, NumeroDocumento) VALUES
	('RSSMRA04P08G702J', 'Mario', 'Ferrari', '2004-09-08', '333-2346352', '12345'),
	('FRRMTT73D10G702K', 'Matteo', 'Ferrari', '1973-04-02',  '345-6273625', '54321'),
	('FNTNLS73T51D612I', 'Annalisa', 'Fontana', '1973-12-11', '321-1234567', '23456'),
	('FRRGDI08D47G702U', 'Giada', 'Ferrari', '2008-04-06', '345-2376284', '65432'),
	('FNTGLD76E60G273N', 'Gilda', 'Fontana', '1976-05-20', '123-7352673', '34567');
    
-- ----------------------------
--  Insert values for `DOMANDASICUREZZA`
-- ----------------------------
TRUNCATE DOMANDASICUREZZA;
INSERT INTO DOMANDASICUREZZA (DomandaSicurezza) VALUES
	('Qual era il cognome da nubile di tua madre?'),
	('Qual era il nome della scuola elementare?'),
	('Il nome del tuo primo animale?'),
	('La tua squadra del cuore?');
    
-- ----------------------------
--  Insert values for `ACCOUNT`
-- ----------------------------
TRUNCATE `ACCOUNT`;
INSERT INTO  `ACCOUNT` (e_mail, NomeUtente, PrivilegioFasce,  `Password`, RispostaSicurezza, CodiceFiscale, IDDomandaSicurezza) VALUES
	('ferrarimario@gmail.com', 'Mario', FALSE, 'pass1', 'Rex', 'RSSMRA04P08G702J', 3),
	('ferrarimatteo@gmail.com', 'Matteo', TRUE, 'pass2', 'Scuola elementare Biagi', 'FRRMTT73D10G702K', 2),
	('fontanaannalisa@gmail.com', 'Annalisa', TRUE, 'pass3', 'Scuola elementare Biagi', 'FNTNLS73T51D612I', 2),
	('ferrarigiada@gmail.com', 'Giada', FALSE, 'pass4', 'Pisa', 'FRRGDI08D47G702U', 4),
	('fontanagilda@gmail.com', 'Gilda', TRUE, 'pass5', 'Bianchi', 'FNTGLD76E60G273N', 1);
    
-- ----------------------------
--  Insert values for `STANZA`
-- ----------------------------
TRUNCATE STANZA;
INSERT INTO  STANZA (Larghezza, Lunghezza, NomeStanza, PianoEdificio) VALUES
	(30, 20, 'Camera', 1),
    (10, 30, 'Camera', 1),
    (50, 30, 'Camera', 1),
    (10, 30, 'Camera', 1),
    (50, 60, 'Camera', 1),
    (30, 60, 'Terrazzo', 1),
    (40, 50, 'Cucina', 0),
    (30, 20, 'Bagno', 0),
    (20, 20, 'Bagno', 1),
    (150, 220, 'Studio', 0),
    (250, 300, 'Salotto', 0),
    (1024, 2300, 'Giardino', 0);
    
-- ----------------------------
--  Insert values for `PORTA`
-- ----------------------------
TRUNCATE PORTA;
INSERT INTO  PORTA (StanzaPrecedente, StanzaSuccessiva) VALUES
	(1, 2),
    (1, 4),
    (2, 1),
    (2, 3),
    (2, 5),
    (3, 2),
    (4, 1),
    (4, 5),
    (4, 9),
    (5, 2),
    (5, 4),
    (5, 6),
    (9, 4),
    (7, 11),
    (7, 10),
    (7, 8),
    (8, 7),
    (8, 10),
    (10, 8),
    (10, 7),
    (10, 11),
    (11, 7),
    (11, 10);
    
-- ----------------------------
--  Insert values for `PUNTOCARDINALE`
-- ----------------------------
TRUNCATE PUNTOCARDINALE;
INSERT INTO  PUNTOCARDINALE (PuntoCardinale) VALUES
	('N'),
    ('NE'),
    ('E'),
    ('SE'),
    ('S'),
    ('SO'),
    ('O'),
    ('NO');
    
-- ----------------------------
--  Insert values for `PORTAFINESTRA`
-- ----------------------------
TRUNCATE PORTAFINESTRA;
INSERT INTO  PORTAFINESTRA (StanzaEsterna, StanzaInterna, PuntoCardinale) VALUES
	(6, 5, 'N'),
    (6, 9, 'O'),
    (12, 11, 'N'),
    (12, 10, 'N');
    
-- ----------------------------
--  Insert values for `FINESTRA`
-- ----------------------------
TRUNCATE FINESTRA;
INSERT INTO  FINESTRA (PuntoCardinale, IDStanza, NumeroFinestra) VALUES
	('N', 1, 1),
    ('O', 1, 1),
    ('N', 2, 1),
    ('N', 3, 1),
    ('S', 3, 1),
    ('O', 4, 1),
    ('E', 5, 1),
    ('S', 9, 1),
    ('O', 9, 1),
    ('N', 7, 1),
    ('N', 7, 2),
    ('N', 11, 1),
    ('E', 11, 1),
    ('O', 8, 1),
    ('S', 8, 1);
    
-- ----------------------------
--  Insert values for `PROPRIETALIVELLO`
-- ----------------------------
TRUNCATE PROPRIETALIVELLO;
INSERT INTO  PROPRIETALIVELLO (IDProprietaLivello, ProprietaLivello) VALUES
	('1', 'Temperatura; tempo; Intensita;'),
    ('2', 'Temperatura; tempo; Modalità; giri'),
    ('3', 'Temperatura; tempo; Modalità;'),
    ('4', 'Temperatura; tempo; Modalità;'),
    ('5', 'Modalità');
    
-- ----------------------------
--  Insert values for `TIPODISPOSITIVO`
-- ----------------------------
TRUNCATE TIPODISPOSITIVO;
INSERT INTO  TIPODISPOSITIVO (TipoDispositivo) VALUES
	('Dispositivo a consumo fisso'),
    ('Dispositivo a ciclo variabile'),
    ('Dispositivo a ciclo non interrompibile'),
    ('Condizionatori'),
    ('Smart Light');
    
-- ----------------------------
--  Insert values for `DISPOSITIVO`
-- ----------------------------
TRUNCATE DISPOSITIVO;
INSERT INTO  DISPOSITIVO (NomeDispositivo, Eliminato, ConsumoKW, IDProprietaLivello, NTipoDispositivo, IDSmartPlug) VALUES
	('Condizionatore Camera 1', FALSE, 2, NULL, 4, 1),
    ('Condizionatore Camera 2', FALSE, 2, NULL, 4, 2),
    ('Condizionatore Camera 3', FALSE, 2, NULL, 4, 3),
    ('Condizionatore Camera 4', FALSE, 2, NULL, 4, 4),
    ('Condizionatore Camera 5', FALSE, 2, NULL, 4, 5),
    ('Lavatrice Bagno 9', FALSE, 1, NULL, 3, 6),
    ('Phon', FALSE, 0.5, NULL, 1, 7),
    ('Piastra', FALSE, 0.5, NULL, 1, 8),
    ('Smart Light camera 1', FALSE, 0.5, NULL, 5, 9),
    ('Smart Light camera 1', FALSE, 0.5, NULL, 5, 10),
    ('Smart Light camera 1', FALSE, 0.5, NULL, 5, 11),
    ('Smart Light camera 2', FALSE, 0.5, NULL, 5, 12),
    ('Smart Light camera 2', FALSE, 0.5, NULL, 5, 13),
    ('Smart Light camera 2', FALSE, 0.5, NULL, 5, 14),
    ('Smart Light camera 3', FALSE, 0.5, NULL, 5, 15),
    ('Smart Light camera 3', FALSE, 0.5, NULL, 5, 16),
    ('Smart Light camera 3', FALSE, 0.5, NULL, 5, 17),
    ('Smart Light camera 4', FALSE, 0.5, NULL, 5, 18),
    ('Smart Light camera 4', FALSE, 0.5, NULL, 5, 19),
    ('Smart Light camera 4', FALSE, 0.5, NULL, 5, 20),
    ('Smart Light camera 5', FALSE, 0.5, NULL, 5, 21),
    ('Smart Light camera 5', FALSE, 0.5, NULL, 5, 22),
    ('Smart Light camera 5', FALSE, 0.5, NULL, 5, 23),
    ('Televisione camera 1', FALSE, 0.5, NULL, 1, 24),
    ('Televisione camera 2', FALSE, 0.5, NULL, 1, 25),
    ('Televisione camera 3', FALSE, 0.5, NULL, 1, 26),
    ('Televisione camera 4', FALSE, 0.5, NULL, 1, 27),
    ('Televisione camera 5', FALSE, 0.5, NULL, 1, 28),
    ('Smart Light Bagno 9', FALSE, 0.5, NULL, 5, 29),
    ('Smart Light Bagno 9', FALSE, 0.5, NULL, 5, 30),
    ('Smart Light Bagno 9', FALSE, 0.5, NULL, 5, 31),
    ('Forno Cucina', FALSE, 3, NULL, 3, 32),
    ('Lavastoviglie Cucina', FALSE, 2, NULL, 3, 33),
    ('Pianocottura Cucina', FALSE, 7, NULL, 2, 34),
    ('Televisione Cucina', FALSE, 0.5, NULL, 1, 35),
    ('Smart Light Cucina', FALSE, 0.5, NULL, 5, 36),
    ('Smart Light Cucina', FALSE, 0.5, NULL, 5, 37),
    ('Smart Light Cucina', FALSE, 0.5, NULL, 5, 38),
    ('Condizionatore Cucina', FALSE, 3, NULL, 4, 39),
    ('Condizionatore Salotto', FALSE, 3, NULL, 4, 40),
    ('Condizionatore Salotto', FALSE, 3, NULL, 4, 41),
    ('Televisione Salotto', FALSE, 0.5, NULL, 1, 42),
    ('Smart Light Salotto', FALSE, 0.5, NULL, 5, 43),
    ('Smart Light Salotto', FALSE, 0.5, NULL, 5, 44),
    ('Smart Light Salotto', FALSE, 0.5, NULL, 5, 45),
    ('Smart Light Bagno 8', FALSE, 0.5, NULL, 5, 46),
    ('Smart Light Bagno 8', FALSE, 0.5, NULL, 5, 47),
    ('Smart Light Bagno 8', FALSE, 0.5, NULL, 5, 48),
	('Lavatrice Bagno 8', FALSE, 2, NULL, 3, 49),
	('Condizionatore Studio', FALSE, 3, NULL, 4, 50),
    ('Ventilatore Studio', FALSE, 0.5, NULL, 2, 51),
    ('Smart Light Studio', FALSE, 0.5, NULL, 5, 52),
    ('Smart Light Studio', FALSE, 0.5, NULL, 5, 53),
    ('Smart Light Studio', FALSE, 0.5, NULL, 5, 54),
    ('Televisione Studio', FALSE, 0.5, NULL, 1, 55),
    ('Smart Light Terrazzo', FALSE, 0.5, NULL, 5, 56),
    ('Smart Light Giardino', FALSE, 0.5, NULL, 5, 57),
    ('Smart Light Giardino', FALSE, 0.5, NULL, 5, 58),
    ('Smart Light Giardino', FALSE, 0.5, NULL, 5, 59);
    
-- ----------------------------
--  Insert values for `DISPOSITIVOACICLONONINTERROMPIBILE`
-- ----------------------------
TRUNCATE DISPOSITIVOACICLONONINTERROMPIBILE;
INSERT INTO  DISPOSITIVOACICLONONINTERROMPIBILE (IDDispositivo, Durata) VALUES
	(6, '01:15'), (32, '01:30'), (33, '02:15'), (49, '02:10');
-- ----------------------------
--  Insert values for `SMARTPLUG`
-- ----------------------------
TRUNCATE SMARTPLUG;
INSERT INTO  SMARTPLUG (Attiva) VALUES
	(1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
    (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
    (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
    (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
    (1),(1),(1),(1),(1),(1),(1),(1),(1),(1),
    (1),(1),(1),(1),(1),(1),(1),(1),(1);
    
    
-- ----------------------------
--  Insert values for `PRIVILEGI`
-- ----------------------------
TRUNCATE PRIVILEGI;
INSERT INTO  PRIVILEGI (IDDispositivo, IDAccount) VALUES
	(1, 1),(1, 2),(1, 3),(1, 4),(1, 5),
    
    (2, 1),(2, 2),(2, 3),(2, 4),(2, 5),
    
    (3, 1),(3, 2),(3, 3),(3, 4),(3, 5),
    
    (4, 1),(4, 2),(4, 3),(4, 4),(4, 5),
    
    (5, 1),(5, 2),(5, 3),(5, 4),(5, 5),
    
    (6, 1),(6, 2),(6, 3),(6, 4),(6, 5),
    
    (7, 2),(7, 3),(7, 5),
    
    (8, 1),(8, 2),(8, 3),(8, 4),(8, 5),
    
    (9, 1),(9, 2),(9, 3),(9, 4),(9, 5),
    
    (10, 1),(10, 2),(10, 3),(10, 4),(10, 5),
    
    (11, 1),(11, 2),(11, 3),(11, 4),(11, 5),
    
    (12, 1),(12, 2),(12, 3),(12, 4),(12, 5),
    
    (13, 1),(13, 2),(13, 3),(13, 4),(13, 5),
    
    (14, 1),(14, 2),(14, 3),(14, 4),(14, 5),
    
    (15, 1),(15, 2),(15, 3),(15, 4),(15, 5),
    
    (16, 1),(16, 2),(16, 3),(16, 4),(16, 5),
    
    (17, 1),(17, 2),(17, 3),(17, 4),(17, 5),
    
    (18, 1),(18, 2),(18, 3),(18, 4),(18, 5),
    
    (19, 1),(19, 2),(19, 3),(19, 4),(19, 5),
    
    (20, 1),(20, 2),(20, 3),(20, 4),(20, 5),
    
    (21, 1),(21, 2),(21, 3),(21, 4),(21, 5),
    
    (22, 1),(22, 2),(22, 3),(22, 4),(22, 5),
    
    (23, 1),(23, 2),(23, 3),(23, 4),(23, 5),
    
    (24, 1),(24, 2),(24, 3),(24, 4),(24, 5),
    
    (25, 1),(25, 2),(25, 3),(25, 4),(25, 5),
    
    (26, 1),(26, 2),(26, 3),(26, 4),(26, 5),
    
    (27, 1),(27, 2),(27, 3),(27, 4),(27, 5),
    
    (28, 1),(28, 2),(28, 3),(28, 4),(28, 5),
    
    (29, 1),(29, 2),(29, 3),(29, 4),(29, 5),
    
    (30, 1),(30, 2),(30, 3),(30, 4),(30, 5),
    
    (31, 1),(31, 2),(31, 3),(31, 4),(31, 5),
    
    (32, 1),(32, 2),(32, 3),(32, 4),(32, 5),
    
    (33, 2),(33, 3),(33, 5),
    
    (34, 2),(34, 3),(34, 5),
    
    (35, 2),(35, 3),(35, 5),(35, 1),
    
    (36, 1),(36, 2),(36, 3),(36, 4),(36, 5),
    
    (37, 1),(37, 2),(37, 3),(37, 4),(37, 5),
    
    (38, 1),(38, 2),(38, 3),(38, 4),(38, 5),
    
    (39, 1),(39, 2),(39, 3),(39, 4),(39, 5),
    
    (40, 1),(40, 2),(40, 3),(40, 4),(40, 5),
    
    (41, 1),(41, 2),(41, 3),(41, 4),(41, 5),
    
    (42, 1),(42, 2),(42, 3),(42, 4),(42, 5),
    
    (43, 1),(43, 2),(43, 3),(43, 4),(43, 5),
    
    (44, 1),(44, 2),(44, 3),(44, 4),(44, 5),
    
    (45, 1),(45, 2),(45, 3),(45, 4),(45, 5),
    
    (46, 1),(46, 2),(46, 3),(46, 4),(46, 5),
    
    (47, 1),(47, 2),(47, 3),(47, 4),(47, 5),
    
    (48, 1),(48, 2),(48, 3),(48, 4),(48, 5),
    
    (49, 1),(49, 2),(49, 3),(49, 4),(49, 5),
    
    (50, 2),(50, 3),(50, 5),
    
    (51, 1),(51, 2),(51, 3),(51, 4),(51, 5),
    
    (52, 1),(52, 2),(52, 3),(52, 4),(52, 5),
    
    (53, 1),(53, 2),(53, 3),(53, 4),(53, 5),
    
    (54, 1),(54, 2),(54, 3),(54, 4),(54, 5),
    
    (55, 1),(55, 2),(55, 3),(55, 4),(55, 5),
    
    (56, 1),(56, 2),(56, 3),(56, 4),(56, 5),
    
    (57, 1),(57, 2),(57, 3),(57, 4),(57, 5),
    
    (58, 1),(58, 2),(58, 3),(58, 4),(58, 5),
    
    (59, 1),(59, 2),(59, 3),(59, 4),(59, 5);
    
-- ----------------------------
--  Insert values for `SITUATO`
-- ----------------------------
TRUNCATE SITUATO;
INSERT INTO  SITUATO (IDDispositivo, IDStanza) VALUES
	(1, 1),(2, 2),(3, 3),(4, 4),(5, 5),
    (6, 8),(9, 1), (10, 1),(11, 1),(12, 2),
    (13, 2),(14, 2),(15, 3),(16, 3),(17, 3),
    (18, 4),(19, 4),(20, 4),(21, 5),(22, 5),
    (23, 5),(24, 1),(25, 2),(26, 3),(27, 4),
    (28, 5),(29, 9),(30, 9),(31, 9),(32, 7),
    (33, 7),(34, 7),(35, 7),(36, 7),(37, 7),
    (38, 7),(39, 7),(40, 11),(41, 11),(42, 11),
    (43, 11),(44, 11),(45, 11),(46, 8),(47, 8),
    (48, 8),(49, 8),(50, 11),(51, 11),(52, 11),
    (53, 11),(54, 11),(55, 11),(56, 6),(57, 12),
    (58, 12),(59, 12);
    
-- ----------------------------
--  Insert values for `TIPOLIVELLO`
-- ----------------------------
TRUNCATE TIPOLIVELLO;
INSERT INTO  TIPOLIVELLO (NTipoLivello, TipoLivello) VALUES
	(1, 'Livello di consumo energetico personalizzato'),
	(2, 'Livello di Consumo Energetico'),
    (3, 'Livello di potenza personlizzato'),
	(4, 'Livello di potenza'),
    (5, 'Livello di umidità');
    
-- ----------------------------
--  Insert values for `LIVELLO`
-- ----------------------------
TRUNCATE LIVELLO;
INSERT INTO  LIVELLO (NomeLivello, NTipoLivello, Proprieta, LivelloPersonalizzato) VALUES
	('Livello Ventilatore 1', 4, 'Questo prodotto non necessita delle proprietà', FALSE),
    ('Livello Ventilatore 2', 4, 'Questo prodotto non necessita delle proprietà', FALSE),
    ('Livello Ventilatore 3', 4, 'Questo prodotto non necessita delle proprietà', FALSE),
	('Livello Pianocottura 1', 2, '25 gradi; 30 Minuti; 7 di Intensità', FALSE),
    ('Livello Pianocottura 2', 1, '30 gradi; 20 Minuti; 2 di Intensità', TRUE),
    ('Livello Pianocottura 3', 2, '15 gradi; 25 Minuti; 8 di Intensità', FALSE),
    ('Livello Lavatrice 1', 2, '50 gradi; 30 Minuti; cotone; 5000 giri', FALSE),
    ('Livello Lavatrice 2', 2, '50 gradi; 30 Minuti; cotone; 5000 giri', FALSE),
    ('Livello Lavatrice 3', 1, '50 gradi; 30 Minuti; cotone; 5000 giri', TRUE),
    ('Livello forno 1', 2, '50 gradi; 30 Minuti; ventilato;', FALSE),
    ('Livello forno 2', 2, '50 gradi; 30 Minuti; statico;', FALSE),
    ('Livello forno 3', 1, '50 gradi; 30 Minuti; ventilato sopra sotto;', TRUE),
    ('Livello Lavastoviglie 1', 2, '50 gradi; 30 Minuti; carico alto;', FALSE),
    ('Livello Lavastoviglie 2', 2, '50 gradi; 30 Minuti; 70 gradi;', FALSE),
    ('Livello Lavastoviglie 3', 1, '50 gradi; 30 Minuti; eco;', TRUE),
    ('Livello Condizionatore 1', 5, 'Modalità deumidificatore', FALSE),
    ('Livello Condizionatore 2', 5, 'Modalità raffrescamento', FALSE);
  
-- ----------------------------
--  Insert values for `LIVELLOCONSUMOENERGETICO`
-- ----------------------------
TRUNCATE LIVELLOCONSUMOENERGETICO;
INSERT INTO  LIVELLOCONSUMOENERGETICO (IDLivello, Durata) VALUES
	(4, '01:00'), (5, '00:30'), (6, '02:00'), (7, '01:15'), (8, '01:45'), (9, '00:45'), (10, '00:15'), (11, '01:00'), (12, '01:30'), (13, '01:15'), (14, '01:00'), (15, '02:00');
-- ----------------------------
--  Insert values for `POSSIEDE`
-- ----------------------------
TRUNCATE POSSIEDE;
INSERT INTO POSSIEDE(IDDispositivo, IDLivello) VALUES
	(1, 16),
    (1, 17),
    (2, 16),
    (2, 17),
    (3, 16),
    (3, 17),
    (4, 16),
    (4, 17),
    (5, 16),
    (5, 17),
    (6, 7),
    (6, 8),
    (6, 9),
    (32, 10),
    (32, 11),
    (32, 12),
    (33, 13),
    (33, 14),
    (33, 15),
    (34, 4),
    (34, 5),
    (34, 6),
    (39, 16),
    (39, 17),
    (40, 16),
    (40, 17),
    (41, 16),
    (41, 17),
    (49, 7),
    (49, 8),
    (49, 9),
    (50, 16),
    (50, 17),
    (51, 1),
    (51, 2),
    (51, 3);

-- ----------------------------
--  Insert values for `POSSIEDELCE`
-- ----------------------------
TRUNCATE POSSIEDELCE;
INSERT INTO POSSIEDELCE(IDDispositivo, IDLivello) VALUES
	(6, 7), (6, 8), (6, 9),
    (32, 10), (32, 11), (32, 12),
    (33, 13), (33, 14), (33, 15),
    (49, 7), (49, 8), (49, 9);
-- ----------------------------
--  Insert values for `LOGDispositivo`
-- ----------------------------
TRUNCATE LOGDispositivo;
INSERT INTO  LOGDispositivo (IDDispositivo, IDAccount, TimestampFine) VALUES
	(30, 2, current_timestamp() + interval 15 minute),
    (20, 1, current_timestamp() + interval 15 minute),
    (15, 4, current_timestamp() + interval 15 minute),
    (10, 3, current_timestamp() + interval 15 minute),
    (25, 5, current_timestamp() + interval 15 minute),
    (11, 5, current_timestamp() + INTERVAL 1 HOUR),
    (3, 2, current_timestamp() + interval 5 minute),
    (32, 3, current_timestamp() + interval 45 minute),
    (12, 3, current_timestamp() + interval 35 minute),
    (5, 1, current_timestamp() + interval 24 minute);
    
-- ----------------------------
--  Insert values for `LOGLivello`
-- ----------------------------
TRUNCATE LOGLivello;
INSERT INTO  LOGLivello (TimestampInizio, IDDispositivo, IDLivello) VALUES
	(CURRENT_TIMESTAMP, 3, 16),
    (CURRENT_TIMESTAMP, 5, 17),
    (CURRENT_TIMESTAMP, 32, 11);
    
-- ----------------------------
--  Insert values for `DISPOSITIVOLIVELLO`
-- ----------------------------
TRUNCATE DISPOSITIVOLIVELLO;
INSERT INTO  DISPOSITIVOLIVELLO  VALUES
	(51, 1), (51, 2), (51, 3),
    (34, 4), (34, 5), (34, 6),
    (6, 7), (6, 8), (6, 9),
    (49, 7), (49, 8), (49, 9),
    (32, 10), (32, 11), (32, 12),
    (33, 13), (33, 14), (33, 15),
    (1, 16), (1, 17),
    (2, 16), (2, 17),
    (3, 16), (3, 17),
    (4, 16), (4, 17),
    (5, 16), (5, 17),
    (39, 16), (39, 17),
    (40, 16), (40, 17),
    (41, 16), (41, 17),
    (50, 16), (50, 17);
    
-- ----------------------------
--  Insert values for `IMPOSTAZIONEDISPOSITIVI`
-- ----------------------------
TRUNCATE IMPOSTAZIONEDISPOSITIVI;
INSERT INTO  IMPOSTAZIONEDISPOSITIVI (TimestampInizio, IDDispositivo, IDAccount) VALUES
	(current_timestamp() + interval 1 hour, 23, 2),
    (current_timestamp() + interval 1 hour, 4, 1),
    (current_timestamp() + interval 1 hour, 5, 4),
    (current_timestamp() + interval 1 hour, 58, 3),
    (current_timestamp() + interval 1 hour, 25, 5),
    (current_timestamp() + interval 1 hour, 11, 5),
    (current_timestamp() + interval 1 hour, 31, 2 ),
    (current_timestamp() + interval 1 hour, 43, 3 ),
    (current_timestamp() + interval 1 hour, 3,3 ),
    (current_timestamp() + interval 1 hour, 12, 1 );
    
-- ----------------------------
--  Insert values for `IMPLivello`
-- ----------------------------
TRUNCATE LOGLivello;
INSERT INTO  LOGLivello (TimestampInizio, IDDispositivo, IDLivello) VALUES
	(CURRENT_TIMESTAMP, 3, 16),
    (CURRENT_TIMESTAMP, 5, 17),
    (CURRENT_TIMESTAMP, 4, 17);
    
-- ----------------------------
--  Insert values for `GRUPPOSORGENTI`
-- ----------------------------
TRUNCATE GRUPPOSORGENTI;
INSERT INTO  GRUPPOSORGENTI (DataAttivazione, NumeroTotaleKWProdotti) VALUES
	(CURRENT_DATE - INTERVAL 3 YEAR, 30);
    
-- ----------------------------
--  Insert values for `SORGENTEENERGIARINNOVABILE`
-- ----------------------------
TRUNCATE SORGENTEENERGIARINNOVABILE;
INSERT INTO  SORGENTEENERGIARINNOVABILE (KWProdottiMedia, tipo, IDGruppoSorgenti) VALUES
	(2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1),
    (2.0, 'Pannello Fotovoltaico', 1);
    
-- ----------------------------
--  Insert values for `CONDIZIONEATMOSFERICA`
-- ----------------------------
TRUNCATE CONDIZIONEATMOSFERICA;
INSERT INTO  CONDIZIONEATMOSFERICA (CondizioneAtmosferica) VALUES
	('Nuvoloso'),
    ('Sole'),
    ('Soleggiato'),
    ('Pioggia'),
    ('Temporale');
    
-- ----------------------------
--  Insert values for `STORICOPRODUZIONEENERGIA`
-- ----------------------------
TRUNCATE STORICOPRODUZIONEENERGIA;
INSERT INTO  STORICOPRODUZIONEENERGIA (InizioTimeStamp, FineTimeStamp, KWProdotti, IDGruppoSorgenti, IDCondizioneAtmosferica) VALUES
	(CURRENT_TIMESTAMP - INTERVAL 1 HOUR, CURRENT_TIMESTAMP - INTERVAL 45 MINUTE, 10, 1, 1),
    (CURRENT_TIMESTAMP - INTERVAL 45 MINUTE, CURRENT_TIMESTAMP - INTERVAL 30 MINUTE, 20, 1, 2),
    (CURRENT_TIMESTAMP - INTERVAL 30 MINUTE, CURRENT_TIMESTAMP - INTERVAL 15 MINUTE, 20, 1, 2),
    (CURRENT_TIMESTAMP - INTERVAL 15 MINUTE, CURRENT_TIMESTAMP, 20, 1, 2),
    
    ('2021-11-15 09:00:00', '2021-11-15 09:15:00', 10, 1, 1),
    ('2021-11-15 09:15:00', '2021-11-15 09:30:00', 20, 1, 2),
    ('2021-11-15 09:30:00', '2021-11-15 09:45:00', 20, 1, 2),
    ('2021-11-15 09:45:00', '2021-11-15 10:00:00', 20, 1, 2),
    
    ('2021-11-16 09:00:00', '2021-11-16 09:15:00', 10, 1, 1),
    ('2021-11-16 09:15:00', '2021-11-16 09:30:00', 20, 1, 2),
    ('2021-11-16 09:30:00', '2021-11-16 09:45:00', 20, 1, 2),
    ('2021-11-16 09:45:00', '2021-11-16 10:00:00', 20, 1, 2),
    
    ('2021-11-09 09:00:00', '2021-11-09 09:15:00', 10, 1, 1),
    ('2021-11-09 09:15:00', '2021-11-09 09:30:00', 20, 1, 2),
    ('2021-11-09 09:30:00', '2021-11-09 09:45:00', 20, 1, 2),
    ('2021-11-09 09:45:00', '2021-11-09 10:00:00', 20, 1, 2),
    
    ('2021-10-15 09:00:00', '2021-10-15 09:15:00', 10, 1, 1),
    ('2021-10-15 09:15:00', '2021-10-15 09:30:00', 20, 1, 2),
    ('2021-10-15 09:30:00', '2021-10-15 09:45:00', 20, 1, 2),
    ('2021-10-15 09:45:00', '2021-10-15 10:00:00', 20, 1, 2),
    
    ('2021-10-16 09:00:00', '2021-10-16 09:15:00', 10, 1, 1),
    ('2021-10-16 09:15:00', '2021-10-16 09:30:00', 20, 1, 2),
    ('2021-10-16 09:30:00', '2021-10-16 09:45:00', 20, 1, 2),
    ('2021-10-16 09:45:00', '2021-10-16 10:00:00', 20, 1, 2),
    
    ('2021-10-09 09:00:00', '2021-10-09 09:15:00', 10, 1, 1),
    ('2021-10-09 09:15:00', '2021-10-09 09:30:00', 20, 1, 2),
    ('2021-10-09 09:30:00', '2021-10-09 09:45:00', 20, 1, 2),
    ('2021-10-09 09:45:00', '2021-10-09 10:00:00', 20, 1, 2);
    
-- ----------------------------
--  Insert values for `RETESTATALE`
-- ----------------------------
TRUNCATE RETESTATALE;
INSERT INTO  RETESTATALE (CodiceRete, DataAttivazione, IDGruppoSorgenti, Compagnia) VALUES
	('1234', CURRENT_DATE - INTERVAL 1 YEAR, 1, 'ENEL');
    
-- ----------------------------
--  Insert values for `BOLLETTA`
-- ----------------------------
TRUNCATE BOLLETTA;
INSERT INTO  BOLLETTA (InizioCalcoloBolletta, FineCalcoloBolletta, costoTotale, CodiceRete, CodiceFiscale) VALUES
	(CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL 1 MONTH, 40, 1234, 'FRRMTT73D10G702K'),
    (CURRENT_TIMESTAMP + interval 1 month, CURRENT_TIMESTAMP + INTERVAL 2 MONTH, 70, 1234, 'FRRMTT73D10G702K'),
    (CURRENT_TIMESTAMP + interval 2 month, CURRENT_TIMESTAMP + INTERVAL 3 MONTH, 20, 1234, 'FRRMTT73D10G702K');
    
    
-- ----------------------------
--  Insert values for `FASCIAORARIA`
-- ----------------------------
TRUNCATE FASCIAORARIA;
INSERT INTO  FASCIAORARIA (InizioFasciaOraria, FineFasciaOraria, CostoKW) VALUES
	('08:00', '13:00', 1),
    ('13:00', '18:00', 1.5),
    ('18:00', '00:00', 0.5),
    ('00:00', '08:00', 0.5);
    
-- ----------------------------
--  Insert values for `PRELIEVO`
-- ----------------------------
TRUNCATE PRELIEVO;
INSERT INTO  PRELIEVO (TimeStampPrelievo, KWPrelievo, IDFascia, CodiceRete) VALUES
    ('2021-08-03 09:00:00', 5, 1, 1234),
    ('2021-08-03 10:00:00', 10, 2, 1234),
    ('2021-08-03 10:30:00', 5, 3, 1234),
    ('2021-08-04 13:15:00', 10, 2, 1234),
    ('2021-08-04 14:30:00', 10, 2, 1234),
    ('2021-08-05 19:00:00', 10, 2, 1234),
    
    ('2021-09-03 09:30:00', 10, 1, 1234),
    ('2021-09-03 11:00:00', 3, 2, 1234),
    ('2021-09-03 11:30:00', 4, 3, 1234),
    ('2021-09-04 14:15:00', 20, 2, 1234),
    ('2021-09-04 14:30:00', 2, 2, 1234),
    ('2021-09-05 20:00:00', 10, 2, 1234),
    -- ---------
    ('2021-11-03 09:00:00', 5, 1, 1234),
    ('2021-11-03 10:00:00', 10, 2, 1234),
    ('2021-11-03 10:30:00', 5, 3, 1234),
    ('2021-11-04 13:15:00', 10, 2, 1234),
    ('2021-11-04 14:30:00', 10, 2, 1234),
    ('2021-11-05 19:00:00', 10, 2, 1234),
    
    ('2021-10-03 09:30:00', 10, 1, 1234),
    ('2021-10-03 11:00:00', 3, 2, 1234),
    ('2021-10-03 11:30:00', 4, 3, 1234),
    ('2021-10-04 14:15:00', 20, 2, 1234),
    ('2021-10-04 14:30:00', 2, 2, 1234),
    ('2021-10-05 20:00:00', 10, 2, 1234);
    -- ---------
-- ----------------------------
--  Insert values for `IMMISSIONE`
-- ----------------------------
TRUNCATE IMMISSIONE;
INSERT INTO  IMMISSIONE (TimeStampImmissione, KWImmissione, IDFascia, CodiceRete) VALUES
	('2021-08-03 09:00:00', 3, 1, 1234),
    ('2021-08-03 09:15:00', 10, 2, 1234),
    ('2021-08-03 10:30:00', 6, 3, 1234),
    ('2021-08-04 13:15:00', 20, 2, 1234),
    ('2021-08-04 14:30:00', 5, 2, 1234),
    ('2021-08-05 20:30:00', 7, 2, 1234),
    
    ('2021-09-03 09:15:00', 9, 1, 1234),
    ('2021-09-03 09:30:00', 3, 2, 1234),
    ('2021-09-03 10:30:00', 10, 3, 1234),
    ('2021-09-04 22:15:00', 20, 2, 1234),
    ('2021-09-04 23:30:00', 3, 2, 1234),
    ('2021-09-05 23:45:00', 20, 2, 1234),
    
    -- ---------
    ('2021-11-03 09:00:00', 5, 1, 1234),
    ('2021-11-03 10:00:00', 10, 2, 1234),
    ('2021-11-03 10:30:00', 5, 3, 1234),
    ('2021-11-04 13:15:00', 10, 2, 1234),
    ('2021-11-04 14:30:00', 10, 2, 1234),
    ('2021-11-05 19:00:00', 10, 2, 1234),
    
    ('2021-10-03 09:30:00', 10, 1, 1234),
    ('2021-10-03 11:00:00', 3, 2, 1234),
    ('2021-10-03 11:30:00', 4, 3, 1234),
    ('2021-10-04 14:15:00', 20, 2, 1234),
    ('2021-10-04 14:30:00', 2, 2, 1234),
    ('2021-10-05 20:00:00', 10, 2, 1234);
    -- ---------
    
-- ----------------------------
--  Insert values for `ORARIOFASCE`
-- ----------------------------
TRUNCATE ORARIOFASCE;
INSERT INTO  ORARIOFASCE (OraInizio, OraFine, IDFascia, IDAccount) VALUES
	('00:00', '01:00', 3, NULL),
    ('01:00', '02:00', 3, NULL),
    ('02:00', '03:00', 3, NULL),
    ('03:00', '04:00', 3, NULL),
    ('04:00', '05:00', 3, NULL),
    ('05:00', '06:00', 3, 2),
    ('06:00', '07:00', 3, 2),
    ('07:00', '08:00', 3, 2),
    ('08:00', '09:00', 1, NULL),
    ('09:00', '10:00', 1, NULL),
    ('10:00', '11:00', 1, NULL),
    ('11:00', '12:00', 1, NULL),
    ('12:00', '13:00', 1, NULL),
    ('13:00', '14:00', 2, NULL),
    ('14:00', '15:00', 2, NULL),
    ('15:00', '16:00', 2, NULL),
    ('16:00', '17:00', 2, 1),
    ('17:00', '18:00', 2, 1),
    ('18:00', '19:00', 3, 1),
    ('19:00', '20:00', 3, NULL),
    ('20:00', '21:00', 3, NULL),
    ('21:00', '22:00', 3, NULL),
    ('22:00', '23:00', 3, NULL),
    ('23:00', '24:00', 3, NULL);
    
-- ----------------------------
--  Insert values for `DIVISAIN`
-- ----------------------------
TRUNCATE DIVISAIN;
INSERT INTO  DIVISAIN (IDFascia, CodiceRete) VALUES
	('1', '1234'),
    ('2', '1234'),
    ('3', '1234');
    
-- ----------------------------
--  Insert values for `UTILIZZORETE`
-- ----------------------------
TRUNCATE UTILIZZORETE;
INSERT INTO  UTILIZZORETE (OraInizio, OraFine, CodiceRete) VALUES
	('00:00', '01:00', '1234'),
    ('11:00', '12:00', '1234'),
    ('12:00', '13:00', '1234'),
    ('23:00', '24:00', '1234');
    
-- ----------------------------
--  Insert values for `UTILIZZOSE`
-- ----------------------------
TRUNCATE UTILIZZOSE;
INSERT INTO  UTILIZZOSE (OraInizio, OraFine, IDGruppoSorgenti) VALUES
    ('21:00', '22:00', 1),
    ('22:00', '23:00', 1);
    
-- ----------------------------
--  Insert values for `BATTERIA`
-- ----------------------------
TRUNCATE BATTERIA;
INSERT INTO  BATTERIA (CodiceBatteria, capacitaMassima, KWAttuali) VALUES
	(5462, 50, 10);

-- ----------------------------
--  Insert values for `IMMISSIONEBATTERIA`
-- ----------------------------
TRUNCATE IMMISSIONEBATTERIA;
INSERT INTO  IMMISSIONEBATTERIA (TimeStampImmissione, KWImmessi, CodiceBatteria) VALUES
	(CURRENT_TIMESTAMP, 10, 5462),
    (CURRENT_TIMESTAMP + INTERVAL 10 MINUTE, 30, 5462),
    (CURRENT_TIMESTAMP + INTERVAL 39 MINUTE, 20, 5462),
    (CURRENT_TIMESTAMP + INTERVAL 40 MINUTE, 40, 5462),
    (CURRENT_TIMESTAMP + INTERVAL 41 MINUTE, 10, 5462),
    (CURRENT_TIMESTAMP + INTERVAL 43 MINUTE, 50, 5462);
    
-- ----------------------------
--  Insert values for `CONSUMOBATTERIA`
-- ----------------------------
TRUNCATE CONSUMOBATTERIA;
INSERT INTO  CONSUMOBATTERIA (TimeStampConsumo, KWConsumati, IDFascia, CodiceBatteria) VALUES
	(CURRENT_TIMESTAMP, 30, 2, 5462),
    (CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 10, 3, 5462),
    (CURRENT_TIMESTAMP + INTERVAL 50 MINUTE, 25, 3, 5462);
    
-- ----------------------------
--  Insert values for `CONSUMOGRUPPOSORGENTI`
-- ----------------------------
TRUNCATE CONSUMOGRUPPOSORGENTI;
INSERT INTO  CONSUMOGRUPPOSORGENTI (TimeStampConsumo, KWConsumati, IDFascia, IDGruppoSorgenti) VALUES
	(CURRENT_TIMESTAMP, 9, 2, 1),
    (CURRENT_TIMESTAMP + INTERVAL 20 MINUTE, 12, 3, 1),
    (CURRENT_TIMESTAMP + INTERVAL 40 MINUTE, 15, 3, 1);
    
-- ----------------------------
--  Insert values for `CONSUMODISPOSITIVO`
-- ----------------------------
TRUNCATE CONSUMODISPOSITIVO;
INSERT INTO  CONSUMODISPOSITIVO (InizioAccensione, IDDispositivo, FineAccensione, KWConsumati) VALUES
	(CURRENT_TIMESTAMP, 20, CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 10),
    (CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 20, CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 10),
    (CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 20, CURRENT_TIMESTAMP + INTERVAL 35 MINUTE, 2),
    
    (CURRENT_TIMESTAMP, 5, CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 4),
    (CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 5, CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 4),
    (CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 5, CURRENT_TIMESTAMP + INTERVAL 35 MINUTE, 1),
    
    (CURRENT_TIMESTAMP, 3, CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 5),
    (CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 3, CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 5),
    (CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 3, CURRENT_TIMESTAMP + INTERVAL 35 MINUTE, 2),
    
    ('2021-11-15 09:00:00', 3, '2021-11-15 09:15:00', 5),
    ('2021-11-15 09:15:00', 3, '2021-11-15 09:30:00', 5),
    ('2021-11-15 09:30:00', 3, '2021-11-15 09:45:00', 2),
    ('2021-11-15 09:45:00', 3, '2021-11-15 10:00:00', 2),
    
    ('2021-11-16 09:00:00', 3, '2021-11-16 09:15:00', 5),
    ('2021-11-16 09:15:00', 3, '2021-11-16 09:30:00', 5),
    ('2021-11-16 09:30:00', 3, '2021-11-16 09:45:00', 2),
    ('2021-11-16 09:45:00', 3, '2021-11-16 10:00:00', 2),
    
    ('2021-11-09 09:00:00', 3, '2021-11-09 09:15:00', 5),
    ('2021-11-09 09:15:00', 3, '2021-11-09 09:30:00', 5),
    ('2021-11-09 09:30:00', 3, '2021-11-09 09:45:00', 2),
    ('2021-11-09 09:45:00', 3, '2021-11-09 10:00:00', 2),
    
    ('2021-10-15 09:00:00', 3, '2021-10-15 09:15:00', 5),
    ('2021-10-15 09:15:00', 3, '2021-10-15 09:30:00', 10),
    ('2021-10-15 09:30:00', 3, '2021-10-15 09:45:00', 3),
    ('2021-10-15 09:45:00', 3, '2021-10-15 10:00:00', 2),
    
    ('2021-10-16 09:00:00', 3, '2021-10-16 09:15:00', 2),
    ('2021-10-16 09:15:00', 3, '2021-10-16 09:30:00', 4),
    ('2021-10-16 09:30:00', 3, '2021-10-16 09:45:00', 6),
    ('2021-10-16 09:45:00', 3, '2021-10-16 10:00:00', 10),
    
    ('2021-10-09 09:00:00', 3, '2021-10-09 09:15:00', 12),
    ('2021-10-09 09:15:00', 3, '2021-10-09 09:30:00', 3),
    ('2021-10-09 09:30:00', 3, '2021-10-09 09:45:00', 9),
    ('2021-10-09 09:45:00', 3, '2021-10-09 10:00:00', 3);
    
-- ----------------------------
--  Insert values for `CONSUMOLIVELLO`
-- ----------------------------
TRUNCATE CONSUMOLIVELLO;
INSERT INTO  CONSUMOLIVELLO (InizioAccensione, IDDispositivo, IDLivello, IDCondizioneatmosferica) VALUES
	(CURRENT_TIMESTAMP, 3, 17, 2),
    (CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 3, 17, 2),
    (CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 3, 17, 1),
    
	(CURRENT_TIMESTAMP, 5, 16, 5),
     (CURRENT_TIMESTAMP + INTERVAL 15 MINUTE, 5, 16, 3),
     (CURRENT_TIMESTAMP + INTERVAL 30 MINUTE, 5, 16, 4);
     
-- ----------------------------
--  Insert values for `CONDIZIONATORE`
-- ----------------------------
TRUNCATE CONDIZIONATORE;
INSERT INTO  CONDIZIONATORE (IDDispositivo, TempMin, TempMax) VALUES
	(1, 10, 30),
    (2, 10, 30),
    (3, 10, 30),
    (4, 10, 30),
    (5, 10, 30),
    (39, 10, 30),
    (40, 10, 30),
    (41, 10, 30),
    (50, 10, 30);
    
-- ----------------------------
--  Insert values for `SMARTLIGHT`
-- ----------------------------
TRUNCATE SMARTLIGHT;
INSERT INTO  SMARTLIGHT (IDDispositivo, TemperaturaMassima, TemperaturaMinima, IntensitaMassima) VALUES
	(9, 6000, 2700, 430),
    (10, 6000, 2700, 430),
    (11, 6000, 2700, 430),
    (12, 6000, 2700, 430),
    (13, 6000, 2700, 430),
    (14, 6000, 2700, 430),
    (15, 6000, 2700, 430),
    (16, 6000, 2700, 430),
    (17, 6000, 2700, 430),
    (18, 6000, 2700, 430),
    (19, 6000, 2700, 430),
    (20, 6000, 2700, 430),
    (21, 6000, 2700, 430),
    (22, 6000, 2700, 430),
    (23, 6000, 2700, 430),
    (29, 6000, 2700, 430),
    (30, 6000, 2700, 430);
    
-- ----------------------------
--  Insert values for `LIVELLODIUMIDITA`
-- ----------------------------
TRUNCATE LIVELLODIUMIDITA;
INSERT INTO  LIVELLODIUMIDITA (IDLivello) VALUES
	(16),
    (17);
    
-- ----------------------------
--  Insert values for `OFFRE`
-- ----------------------------
TRUNCATE OFFRE;
INSERT INTO  OFFRE (IDLivello, IDDispositivo) VALUES
	(16, 1),
    (16, 2),
    (16, 3),
    (16, 4),
    (16, 5),
    (16, 39),
    (16, 40),
    (16, 41),
    (16, 50),
    (17, 1),
    (17, 2),
    (17, 3),
    (17, 4),
    (17, 5),
    (17, 39),
    (17, 40),
    (17, 41),
    (17, 50);
    
-- ----------------------------
--  Insert values for `EFFICIENZAENERGETICA`
-- ----------------------------
TRUNCATE EFFICIENZAENERGETICA;
INSERT INTO  EFFICIENZAENERGETICA (TemperaturaInizialeInterna, TemperaturaInizialeEsterna, CoefficienteDiDissipazione, ConsumoKW, GiornoDiCacolo) VALUES
	(20, 18, 1, 10, CURRENT_DATE()),
    (23, 20, 1, 5, CURRENT_DATE()),
    (22, 21, 1, 7, CURRENT_DATE()),
    (18, 18, 1, 5, CURRENT_DATE() + INTERVAL 1 DAY),
    (21, 21, 1, 7, CURRENT_DATE() + INTERVAL 1 DAY),
    (23, 21, 1, 7, CURRENT_DATE() + INTERVAL 1 DAY);
    
-- ----------------------------
--  Insert values for `CARATTERIZZATA`
-- ----------------------------
TRUNCATE CARATTERIZZATA;
INSERT INTO  CARATTERIZZATA(IDEfficienzaEnergetica, IDStanza) VALUES
	(3, 1),
    (3, 2),
    (3, 3),
    (1, 2),
    (1, 3),
    (1, 5),
    (6, 3),
    (6, 4),
    (5, 1),
    (5, 3),
    (5, 2);
    
-- ----------------------------
--  Insert values for `IMPOSTAZIONECONDIZIONATORE`
-- ----------------------------
TRUNCATE IMPOSTAZIONECONDIZIONATORE;
INSERT INTO  IMPOSTAZIONECONDIZIONATORE(Temperatura, InizioImpostazione, FineImpostazione, IDLivello, IDAccount, IDStanza) VALUES
	(18, '10:00', '11:00',16, 2, 1),
    (16, '17:00', '20:00',17, 3, 2),
    (17, '13:00', '13:30',17, 2, 11),
    (21, '21:00', '23:00',16, 3, 3),
    (20, '00:00', '03:00' ,17, 1, 4),
    (25, '07:00', '10:00' ,16, 1, 11);
    
-- ----------------------------
--  Insert values for `IMPOSTACOND`
-- ----------------------------
TRUNCATE IMPOSTACOND;
INSERT INTO  IMPOSTACOND(IDImpostazione, IDDispositivo) VALUES
	(1, 1),(2, 2), (3, 3), (4, 4), (5, 7), (6, 40), (6, 41), (6, 50);
    
-- ----------------------------
--  Insert values for `MESE`
-- ----------------------------
TRUNCATE MESE;
INSERT INTO  MESE(Mese) VALUES
	('Gennaio'),
    ('Febbraio'),
    ('Marzo'),
    ('Aprile'),
    ('Maggio'),
    ('Giugno'),
    ('Luglio'),
    ('Agosto'),
    ('Settembre'),
    ('Ottobre'),
    ('Novembre'),
    ('Dicembre');
    
-- ----------------------------
--  Insert values for `GIORNO`
-- ----------------------------
TRUNCATE GIORNO;
INSERT INTO  GIORNO(Giorno) VALUES
	('Lunedì'),
    ('Martedì'),
    ('Mercoledì'),
    ('Giovedì'),
    ('Venerdì'),
    ('Sabato'),
    ('Domenica');
    
-- ----------------------------
--  Insert values for `PERIODO`
-- ----------------------------
TRUNCATE PERIODO;
INSERT INTO  PERIODO(IDImpostazione, IDGiorno, IDMese) VALUES
	(1, 1, 4),
    (1, 2, 4),
    (1, 3, 4),
    (1, 1, 5),
    (1, 2, 5),
    (1, 3, 5),
    
    (2, 1, 2),
    (2, 1, 3),
    
    (3, 5, 9),
    (3, 6, 9),
    (3, 7, 9),
    
    (4, 5, 11),
    
    (5, 7, 1);
    
    
-- ----------------------------
--  Insert values for `IMPOSTAZIONESMARTLIGHT`
-- ----------------------------
TRUNCATE IMPOSTAZIONESMARTLIGHT;
INSERT INTO  IMPOSTAZIONESMARTLIGHT(NumeroImpostazione, IDDispositivo, IDAccount, KTemp, PercInt) VALUES
	(1, 10, 2, 1400, 30),
    (1, 13, 1, 1400, 30),
    (1, 18, 3, 1400, 30),
    (1, 29, 4, 1400, 30),
    (1, 9, 2, 1400, 30);
    
-- ----------------------------
-- Insert values for `IMPOSTAZIONETOTALESMARTLIGHT`
-- ----------------------------
TRUNCATE IMPOSTAZIONETOTALESMARTLIGHT;
INSERT INTO  IMPOSTAZIONETOTALESMARTLIGHT(NumeroImpostazioneTot, IDAccount) VALUES
	(1, 2),
    (2, 3);
    
-- ----------------------------
-- Insert values for `COMPONE`
-- ----------------------------
TRUNCATE COMPONE;
INSERT INTO  COMPONE(NumeroImpostazione, IDDispositivo, NumeroImpostazioneTot) VALUES
	(1, 10, 1),
    (1, 13, 1),
    (1, 18, 1),
    
    (1, 29, 2),
    (1, 9, 2),
    (1, 18, 2);
    
-- ----------------------------
-- Insert values for `MONITORAGGIOLUCI`
-- ----------------------------
TRUNCATE MONITORAGGIOLUCI;
INSERT INTO  MONITORAGGIOLUCI(DataAccensione) VALUES
    (current_date()),
    (current_date() + interval 1 day),
    (current_date() + interval 2 day);
    
-- ----------------------------
-- Insert values for `ACCENSIONE`
-- ----------------------------
TRUNCATE ACCENSIONE;
INSERT INTO  ACCENSIONE(IDDispositivo, DataAccensione, OraAccensione, OraSpegnimento) VALUES
	(10, current_date(), current_time(),  current_time() + interval 1 hour),
    (10, current_date(), current_time() + interval 1 hour, current_time() + interval 2 hour),
    (10, current_date(), '23:00:00', '24:00:00'),
    (10, current_date() + interval 1 day, '00:00:00', '01:00:00'),
    (11, current_date() + INTERVAL 1 DAY, current_time(),  current_time() + interval 1 hour),
    (11, current_date() + INTERVAL 1 DAY, current_time() + interval 1 hour, current_time() + interval 2 hour),
    (12, current_date() + INTERVAL 2 DAY, '23:00:00', '24:00:00'),
    (12, current_date() + interval 2 day, '00:00:00', '01:00:00');
    
-- ----------------------------
-- Insert values for `ACCESAPER`
-- ----------------------------
TRUNCATE ACCESAPER;
INSERT INTO  ACCESAPER(IDDispositivo,DataAccensione, TempoAccensione, TempoSpegnimento) VALUES
	(10, current_date(), '03:00', '21:00'),
    (10, current_date() + interval 1 day, '02:30', '21:30');
    
    
-- ----------------------------------
-- Insert aggiuntive per operazioni
-- ----------------------------------
INSERT INTO  LOGDispositivo (TimestampInizio,IDDispositivo, IDAccount, TimestampFine) VALUES
	(current_timestamp() + interval 30 minute, 20, 2, current_timestamp() + interval 35 minute),
    (current_timestamp() + interval 45 minute, 20, 1, current_timestamp() + interval 1 hour),
    (current_timestamp() + interval 2 HOUR, 20, 4, NULL);
    
-- ----------------------------
--  Insert values for `CONSUMOTEMPERATURA`
-- ----------------------------
TRUNCATE CONSUMOTEMPERATURA;
INSERT INTO  CONSUMOTEMPERATURA (TemperaturaInizialeInterna, TemperaturaInizialeEsterna, ConsumoKW) VALUES
	(24, 26, 1.5),
    (27, 25, 2),
	(25, 27, 4),
    (30, 27, 3),
    (23, 24, 2),
    (29, 29, 1.5),
    (24, 25, 3),
    (27, 26, 2),
    (30, 30, 2),
    (26, 27, 0.5),
    (26, 26, 1);

-- ----------------------------
--  Insert values for `TEMPERATURA`
-- ----------------------------
TRUNCATE TEMPERATURA;
INSERT INTO  TEMPERATURA (IDStanza, TimeStampRilevazione, TemperaturaInizialeInterna, TemperaturaInizialeEsterna) VALUES
	(1, '2018-09-01 10:00:00', 24, 26), (1, '2018-09-01 17:00:00', 29, 29),
    (1, '2018-09-02 10:00:00', 27, 25), (1, '2018-09-02 17:00:00', 29, 29),
    (1, '2018-09-03 10:00:00', 24, 26), (1, '2018-09-03 17:00:00', 24, 26),
    (1, '2018-09-04 10:00:00', 27, 25), (1, '2018-09-04 17:00:00', 29, 29),
    (1, '2018-09-05 10:00:00', 30, 27), (1, '2018-09-05 17:00:00', 24, 26),
    (1, '2018-09-06 10:00:00', 24, 26), (1, '2018-09-06 17:00:00', 24, 26),
    (1, '2018-09-07 10:00:00', 27, 25), (1, '2018-09-07 17:00:00', 24, 26),
    (1, '2018-09-08 10:00:00', 24, 26), (1, '2018-09-08 17:00:00', 29, 29),
    (1, '2018-09-09 10:00:00', 30, 27), (1, '2018-09-09 17:00:00', 29, 29),
    (1, '2018-09-10 10:00:00', 24, 26), (1, '2018-09-10 17:00:00', 27, 25),
    (1, '2018-09-11 10:00:00', 24, 26), (1, '2018-09-11 17:00:00', 30, 27),
    (1, '2018-09-12 10:00:00', 27, 25), (1, '2018-09-12 17:00:00', 27, 25),
    (1, '2018-09-13 10:00:00', 30, 27), (1, '2018-09-13 17:00:00', 24, 26),
    (1, '2018-09-14 10:00:00', 24, 26), (1, '2018-09-14 17:00:00', 24, 26),
    (1, '2018-09-15 10:00:00', 27, 25), (1, '2018-09-15 17:00:00', 27, 25),
    (1, '2018-09-16 10:00:00', 27, 25), (1, '2018-09-16 17:00:00', 30, 27),
    (1, '2018-09-17 10:00:00', 24, 26), (1, '2018-09-17 17:00:00', 27, 25),
    (1, '2018-09-18 10:00:00', 30, 27), (1, '2018-09-18 17:00:00', 24, 26),
    (1, '2018-09-19 10:00:00', 24, 26), (1, '2018-09-19 17:00:00', 30, 27),
    (1, '2018-09-20 10:00:00', 27, 25), (1, '2018-09-20 17:00:00', 27, 25),
    (1, '2018-09-21 10:00:00', 24, 26), (1, '2018-09-21 17:00:00', 30, 27),
    (1, '2018-09-22 10:00:00', 27, 25), (1, '2018-09-22 17:00:00', 24, 26),
    (1, '2018-09-23 10:00:00', 30, 27), (1, '2018-09-23 17:00:00', 30, 27),
    (1, '2018-09-24 10:00:00', 27, 25), (1, '2018-09-24 17:00:00', 27, 25),
    (1, '2018-09-25 10:00:00', 24, 26), (1, '2018-09-25 17:00:00', 27, 25),
    (1, '2018-09-26 10:00:00', 30, 27), (1, '2018-09-26 17:00:00', 24, 26),
    (1, '2018-09-27 10:00:00', 24, 26), (1, '2018-09-27 17:00:00', 27, 25),
    (1, '2018-09-28 10:00:00', 27, 25), (1, '2018-09-28 17:00:00', 24, 26),
    (1, '2018-09-29 10:00:00', 27, 25), (1, '2018-09-29 17:00:00', 30, 27),
    (1, '2018-09-30 10:00:00', 24, 26), (1, '2018-09-30 17:00:00', 24, 26),
    
    
	(1, '2019-09-01 10:00:00', 30, 30), (1, '2019-09-01 17:00:00', 26, 26),
    (1, '2019-09-02 10:00:00', 26, 27), (1, '2019-09-02 17:00:00', 26, 26),
    (1, '2019-09-03 10:00:00', 26, 27), (1, '2019-09-03 17:00:00', 30, 30),
    (1, '2019-09-04 10:00:00', 26, 27), (1, '2019-09-04 17:00:00', 26, 26),
    (1, '2019-09-05 10:00:00', 30, 30), (1, '2019-09-05 17:00:00', 26, 27),
    (1, '2019-09-06 10:00:00', 30, 30), (1, '2019-09-06 17:00:00', 26, 27),
    (1, '2019-09-07 10:00:00', 26, 27), (1, '2019-09-07 17:00:00', 26, 26),
    (1, '2019-09-08 10:00:00', 26, 27), (1, '2019-09-08 17:00:00', 26, 27),
    (1, '2019-09-09 10:00:00', 30, 30), (1, '2019-09-09 17:00:00', 26, 26),
    (1, '2019-09-10 10:00:00', 30, 30), (1, '2019-09-10 17:00:00', 26, 26),
    (1, '2019-09-11 10:00:00', 26, 26), (1, '2019-09-11 17:00:00', 30, 30),
    (1, '2019-09-12 10:00:00', 26, 27), (1, '2019-09-12 17:00:00', 26, 27),
    (1, '2019-09-13 10:00:00', 30, 30), (1, '2019-09-13 17:00:00', 30, 30),
    (1, '2019-09-14 10:00:00', 26, 26), (1, '2019-09-14 17:00:00', 26, 27),
    (1, '2019-09-15 10:00:00', 30, 30), (1, '2019-09-15 17:00:00', 30, 30),
    (1, '2019-09-16 10:00:00', 26, 26), (1, '2019-09-16 17:00:00', 26, 26),
    (1, '2019-09-17 10:00:00', 30, 30), (1, '2019-09-17 17:00:00', 26, 26),
    (1, '2019-09-18 10:00:00', 30, 30), (1, '2019-09-18 17:00:00', 26, 27),
    (1, '2019-09-19 10:00:00', 26, 27), (1, '2019-09-19 17:00:00', 26, 26),
    (1, '2019-09-20 10:00:00', 26, 26), (1, '2019-09-20 17:00:00', 30, 30),
    (1, '2019-09-21 10:00:00', 26, 27), (1, '2019-09-21 17:00:00', 26, 27),
    (1, '2019-09-22 10:00:00', 30, 30), (1, '2019-09-22 17:00:00', 30, 30),
    (1, '2019-09-23 10:00:00', 30, 30), (1, '2019-09-23 17:00:00', 26, 27),
    (1, '2019-09-24 10:00:00', 30, 30), (1, '2019-09-24 17:00:00', 26, 26),
    (1, '2019-09-25 10:00:00', 26, 26), (1, '2019-09-25 17:00:00', 26, 27),
    (1, '2019-09-26 10:00:00', 30, 30), (1, '2019-09-26 17:00:00', 26, 26),
    (1, '2019-09-27 10:00:00', 26, 27), (1, '2019-09-27 17:00:00', 30, 30),
    (1, '2019-09-28 10:00:00', 30, 30), (1, '2019-09-28 17:00:00', 30, 30),
    (1, '2019-09-29 10:00:00', 26, 26), (1, '2019-09-29 17:00:00', 30, 30),
    (1, '2019-09-30 10:00:00', 30, 30), (1, '2019-09-30 17:00:00', 26, 27),
    
    
	(1, '2020-09-01 10:00:00', 25, 27), (1, '2020-09-01 17:00:00', 26, 27),
    (1, '2020-09-02 10:00:00', 26, 27), (1, '2020-09-02 17:00:00', 25, 27),
    (1, '2020-09-03 10:00:00', 30, 30), (1, '2020-09-03 17:00:00', 30, 30),
    (1, '2020-09-04 10:00:00', 25, 27), (1, '2020-09-04 17:00:00', 30, 30),
    (1, '2020-09-05 10:00:00', 30, 30), (1, '2020-09-05 17:00:00', 26, 27),
    (1, '2020-09-06 10:00:00', 25, 27), (1, '2020-09-06 17:00:00', 25, 27),
    (1, '2020-09-07 10:00:00', 25, 27), (1, '2020-09-07 17:00:00', 25, 27),
    (1, '2020-09-08 10:00:00', 30, 30), (1, '2020-09-08 17:00:00', 30, 30),
    (1, '2020-09-09 10:00:00', 25, 27), (1, '2020-09-09 17:00:00', 25, 27),
    (1, '2020-09-10 10:00:00', 30, 30), (1, '2020-09-10 17:00:00', 23, 24),
    (1, '2020-09-11 10:00:00', 25, 27), (1, '2020-09-11 17:00:00', 23, 24),
    (1, '2020-09-12 10:00:00', 23, 24), (1, '2020-09-12 17:00:00', 23, 24),
    (1, '2020-09-13 10:00:00', 25, 27), (1, '2020-09-13 17:00:00', 23, 24),
    (1, '2020-09-14 10:00:00', 23, 24), (1, '2020-09-14 17:00:00', 25, 27),
    (1, '2020-09-15 10:00:00', 30, 30), (1, '2020-09-15 17:00:00', 25, 27),
    (1, '2020-09-16 10:00:00', 24, 26), (1, '2020-09-16 17:00:00', 24, 26),
    (1, '2020-09-17 10:00:00', 25, 27), (1, '2020-09-17 17:00:00', 24, 26),
    (1, '2020-09-18 10:00:00', 24, 26), (1, '2020-09-18 17:00:00', 23, 24),
    (1, '2020-09-19 10:00:00', 25, 27), (1, '2020-09-19 17:00:00', 23, 24),
    (1, '2020-09-20 10:00:00', 26, 26), (1, '2020-09-20 17:00:00', 25, 27),
    (1, '2020-09-21 10:00:00', 25, 27), (1, '2020-09-21 17:00:00', 25, 27),
    (1, '2020-09-22 10:00:00', 24, 26), (1, '2020-09-22 17:00:00', 24, 26),
    (1, '2020-09-23 10:00:00', 25, 27), (1, '2020-09-23 17:00:00', 25, 27),
    (1, '2020-09-24 10:00:00', 25, 27), (1, '2020-09-24 17:00:00', 23, 24),
    (1, '2020-09-25 10:00:00', 25, 27), (1, '2020-09-25 17:00:00', 23, 24),
    (1, '2020-09-26 10:00:00', 24, 26), (1, '2020-09-26 17:00:00', 25, 27),
    (1, '2020-09-27 10:00:00', 26, 26), (1, '2020-09-27 17:00:00', 24, 26),
    (1, '2020-09-28 10:00:00', 26, 26), (1, '2020-09-28 17:00:00', 25, 27),
    (1, '2020-09-29 10:00:00', 26, 26), (1, '2020-09-29 17:00:00', 26, 26),
    (1, '2020-09-30 10:00:00', 25, 27), (1, '2020-09-30 17:00:00', 26, 26),
    
    (1, '2021-09-01 10:00:00', 30, 27), (1, '2021-09-01 17:00:00', 30, 27),
    (1, '2021-09-02 10:00:00', 25, 27), (1, '2021-09-02 17:00:00', 25, 27),
    (1, '2021-09-03 10:00:00', 24, 25), (1, '2021-09-03 17:00:00', 30, 27),
    (1, '2021-09-04 10:00:00', 30, 27), (1, '2021-09-04 17:00:00', 30, 27),
    (1, '2021-09-05 10:00:00', 30, 27), (1, '2021-09-05 17:00:00', 30, 27),
    (1, '2021-09-06 10:00:00', 24, 25), (1, '2021-09-06 17:00:00', 30, 27),
    (1, '2021-09-07 10:00:00', 30, 27), (1, '2021-09-07 17:00:00', 30, 30),
    (1, '2021-09-08 10:00:00', 25, 27), (1, '2021-09-08 17:00:00', 30, 27),
    (1, '2021-09-09 10:00:00', 25, 27), (1, '2021-09-09 17:00:00', 25, 27),
    (1, '2021-09-10 10:00:00', 24, 25), (1, '2021-09-10 17:00:00', 24, 25),
    (1, '2021-09-11 10:00:00', 25, 27), (1, '2021-09-11 17:00:00', 30, 30),
    (1, '2021-09-12 10:00:00', 24, 25), (1, '2021-09-12 17:00:00', 30, 27),
    (1, '2021-09-13 10:00:00', 24, 25), (1, '2021-09-13 17:00:00', 24, 25),
    (1, '2021-09-14 10:00:00', 30, 27), (1, '2021-09-14 17:00:00', 30, 30),
    (1, '2021-09-15 10:00:00', 25, 27), (1, '2021-09-15 17:00:00', 24, 25),
    (1, '2021-09-16 10:00:00', 24, 25), (1, '2021-09-16 17:00:00', 27, 26),
    (1, '2021-09-17 10:00:00', 25, 27), (1, '2021-09-17 17:00:00', 30, 27),
    (1, '2021-09-18 10:00:00', 30, 27), (1, '2021-09-18 17:00:00', 27, 26),
    (1, '2021-09-19 10:00:00', 30, 27), (1, '2021-09-19 17:00:00', 25, 27),
    (1, '2021-09-20 10:00:00', 24, 25), (1, '2021-09-20 17:00:00', 27, 26),
    (1, '2021-09-21 10:00:00', 25, 27), (1, '2021-09-21 17:00:00', 30, 27),
    (1, '2021-09-22 10:00:00', 24, 25), (1, '2021-09-22 17:00:00', 25, 27),
    (1, '2021-09-23 10:00:00', 30, 27), (1, '2021-09-23 17:00:00', 30, 27),
    (1, '2021-09-24 10:00:00', 30, 27), (1, '2021-09-24 17:00:00', 27, 26),
    (1, '2021-09-25 10:00:00', 30, 27), (1, '2021-09-25 17:00:00', 30, 27),
    (1, '2021-09-26 10:00:00', 24, 25), (1, '2021-09-26 17:00:00', 30, 27),
    
    (11, '2018-09-01 10:00:00', 24, 26), (11, '2018-09-01 17:00:00', 29, 29),
    (11, '2018-09-02 10:00:00', 27, 25), (11, '2018-09-02 17:00:00', 29, 29),
    (11, '2018-09-03 10:00:00', 24, 26), (11, '2018-09-03 17:00:00', 24, 26),
    (11, '2018-09-04 10:00:00', 27, 25), (11, '2018-09-04 17:00:00', 29, 29),
    (11, '2018-09-05 10:00:00', 30, 27), (11, '2018-09-05 17:00:00', 24, 26),
    (11, '2018-09-06 10:00:00', 24, 26), (11, '2018-09-06 17:00:00', 24, 26),
    (11, '2018-09-07 10:00:00', 27, 25), (11, '2018-09-07 17:00:00', 24, 26),
    (11, '2018-09-08 10:00:00', 24, 26), (11, '2018-09-08 17:00:00', 29, 29),
    (11, '2018-09-09 10:00:00', 30, 27), (11, '2018-09-09 17:00:00', 29, 29),
    (11, '2018-09-10 10:00:00', 24, 26), (11, '2018-09-10 17:00:00', 27, 25),
    (11, '2018-09-11 10:00:00', 24, 26), (11, '2018-09-11 17:00:00', 30, 27),
    (11, '2018-09-12 10:00:00', 27, 25), (11, '2018-09-12 17:00:00', 27, 25),
    (11, '2018-09-13 10:00:00', 30, 27), (11, '2018-09-13 17:00:00', 24, 26),
    (11, '2018-09-14 10:00:00', 24, 26), (11, '2018-09-14 17:00:00', 24, 26),
    (11, '2018-09-15 10:00:00', 27, 25), (11, '2018-09-15 17:00:00', 27, 25),
    (11, '2018-09-16 10:00:00', 27, 25), (11, '2018-09-16 17:00:00', 30, 27),
    (11, '2018-09-17 10:00:00', 24, 26), (11, '2018-09-17 17:00:00', 27, 25),
    (11, '2018-09-18 10:00:00', 30, 27), (11, '2018-09-18 17:00:00', 24, 26),
    (11, '2018-09-19 10:00:00', 24, 26), (11, '2018-09-19 17:00:00', 30, 27),
    (11, '2018-09-20 10:00:00', 27, 25), (11, '2018-09-20 17:00:00', 27, 25),
    (11, '2018-09-21 10:00:00', 24, 26), (11, '2018-09-21 17:00:00', 30, 27),
    (11, '2018-09-22 10:00:00', 27, 25), (11, '2018-09-22 17:00:00', 24, 26),
    (11, '2018-09-23 10:00:00', 30, 27), (11, '2018-09-23 17:00:00', 30, 27),
    (11, '2018-09-24 10:00:00', 27, 25), (11, '2018-09-24 17:00:00', 27, 25),
    (11, '2018-09-25 10:00:00', 24, 26), (11, '2018-09-25 17:00:00', 27, 25),
    (11, '2018-09-26 10:00:00', 30, 27), (11, '2018-09-26 17:00:00', 24, 26),
    (11, '2018-09-27 10:00:00', 24, 26), (11, '2018-09-27 17:00:00', 27, 25),
    (11, '2018-09-28 10:00:00', 27, 25), (11, '2018-09-28 17:00:00', 24, 26),
    (11, '2018-09-29 10:00:00', 27, 25), (11, '2018-09-29 17:00:00', 30, 27),
    (11, '2018-09-30 10:00:00', 24, 26), (11, '2018-09-30 17:00:00', 24, 26),
    
	(11, '2019-09-01 10:00:00', 30, 30), (11, '2019-09-01 17:00:00', 26, 26),
    (11, '2019-09-02 10:00:00', 26, 27), (11, '2019-09-02 17:00:00', 26, 26),
    (11, '2019-09-03 10:00:00', 26, 27), (11, '2019-09-03 17:00:00', 30, 30),
    (11, '2019-09-04 10:00:00', 26, 27), (11, '2019-09-04 17:00:00', 26, 26),
    (11, '2019-09-05 10:00:00', 30, 30), (11, '2019-09-05 17:00:00', 26, 27),
    (11, '2019-09-06 10:00:00', 30, 30), (11, '2019-09-06 17:00:00', 26, 27),
    (11, '2019-09-07 10:00:00', 26, 27), (11, '2019-09-07 17:00:00', 26, 26),
    (11, '2019-09-08 10:00:00', 26, 27), (11, '2019-09-08 17:00:00', 26, 27),
    (11, '2019-09-09 10:00:00', 30, 30), (11, '2019-09-09 17:00:00', 26, 26),
    (11, '2019-09-10 10:00:00', 30, 30), (11, '2019-09-10 17:00:00', 26, 26),
    (11, '2019-09-11 10:00:00', 26, 26), (11, '2019-09-11 17:00:00', 30, 30),
    (11, '2019-09-12 10:00:00', 26, 27), (11, '2019-09-12 17:00:00', 26, 27),
    (11, '2019-09-13 10:00:00', 30, 30), (11, '2019-09-13 17:00:00', 30, 30),
    (11, '2019-09-14 10:00:00', 26, 26), (11, '2019-09-14 17:00:00', 26, 27),
    (11, '2019-09-15 10:00:00', 30, 30), (11, '2019-09-15 17:00:00', 30, 30),
    (11, '2019-09-16 10:00:00', 26, 26), (11, '2019-09-16 17:00:00', 26, 26),
    (11, '2019-09-17 10:00:00', 30, 30), (11, '2019-09-17 17:00:00', 26, 26),
    (11, '2019-09-18 10:00:00', 30, 30), (11, '2019-09-18 17:00:00', 26, 27),
    (11, '2019-09-19 10:00:00', 26, 27), (11, '2019-09-19 17:00:00', 26, 26),
    (11, '2019-09-20 10:00:00', 26, 26), (11, '2019-09-20 17:00:00', 30, 30),
    (11, '2019-09-21 10:00:00', 26, 27), (11, '2019-09-21 17:00:00', 26, 27),
    (11, '2019-09-22 10:00:00', 30, 30), (11, '2019-09-22 17:00:00', 30, 30),
    (11, '2019-09-23 10:00:00', 30, 30), (11, '2019-09-23 17:00:00', 26, 27),
    (11, '2019-09-24 10:00:00', 30, 30), (11, '2019-09-24 17:00:00', 26, 26),
    (11, '2019-09-25 10:00:00', 26, 26), (11, '2019-09-25 17:00:00', 26, 27),
    (11, '2019-09-26 10:00:00', 30, 30), (11, '2019-09-26 17:00:00', 26, 26),
    (11, '2019-09-27 10:00:00', 26, 27), (11, '2019-09-27 17:00:00', 30, 30),
    (11, '2019-09-28 10:00:00', 30, 30), (11, '2019-09-28 17:00:00', 30, 30),
    (11, '2019-09-29 10:00:00', 26, 26), (11, '2019-09-29 17:00:00', 30, 30),
    (11, '2019-09-30 10:00:00', 30, 30), (11, '2019-09-30 17:00:00', 26, 27),
    
	(11, '2020-09-01 10:00:00', 25, 27), (11, '2020-09-01 17:00:00', 26, 27),
    (11, '2020-09-02 10:00:00', 26, 27), (11, '2020-09-02 17:00:00', 25, 27),
    (11, '2020-09-03 10:00:00', 30, 30), (11, '2020-09-03 17:00:00', 30, 30),
    (11, '2020-09-04 10:00:00', 25, 27), (11, '2020-09-04 17:00:00', 30, 30),
    (11, '2020-09-05 10:00:00', 30, 30), (11, '2020-09-05 17:00:00', 26, 27),
    (11, '2020-09-06 10:00:00', 25, 27), (11, '2020-09-06 17:00:00', 25, 27),
    (11, '2020-09-07 10:00:00', 25, 27), (11, '2020-09-07 17:00:00', 25, 27),
    (11, '2020-09-08 10:00:00', 30, 30), (11, '2020-09-08 17:00:00', 30, 30),
    (11, '2020-09-09 10:00:00', 25, 27), (11, '2020-09-09 17:00:00', 25, 27),
    (11, '2020-09-10 10:00:00', 30, 30), (11, '2020-09-10 17:00:00', 23, 24),
    (11, '2020-09-11 10:00:00', 25, 27), (11, '2020-09-11 17:00:00', 23, 24),
    (11, '2020-09-12 10:00:00', 23, 24), (11, '2020-09-12 17:00:00', 23, 24),
    (11, '2020-09-13 10:00:00', 25, 27), (11, '2020-09-13 17:00:00', 23, 24),
    (11, '2020-09-14 10:00:00', 23, 24), (11, '2020-09-14 17:00:00', 25, 27),
    (11, '2020-09-15 10:00:00', 30, 30), (11, '2020-09-15 17:00:00', 25, 27),
    (11, '2020-09-16 10:00:00', 24, 26), (11, '2020-09-16 17:00:00', 24, 26),
    (11, '2020-09-17 10:00:00', 25, 27), (11, '2020-09-17 17:00:00', 24, 26),
    (11, '2020-09-18 10:00:00', 24, 26), (11, '2020-09-18 17:00:00', 23, 24),
    (11, '2020-09-19 10:00:00', 25, 27), (11, '2020-09-19 17:00:00', 23, 24),
    (11, '2020-09-20 10:00:00', 26, 26), (11, '2020-09-20 17:00:00', 25, 27),
    (11, '2020-09-21 10:00:00', 25, 27), (11, '2020-09-21 17:00:00', 25, 27),
    (11, '2020-09-22 10:00:00', 24, 26), (11, '2020-09-22 17:00:00', 24, 26),
    (11, '2020-09-23 10:00:00', 25, 27), (11, '2020-09-23 17:00:00', 25, 27),
    (11, '2020-09-24 10:00:00', 25, 27), (11, '2020-09-24 17:00:00', 23, 24),
    (11, '2020-09-25 10:00:00', 25, 27), (11, '2020-09-25 17:00:00', 23, 24),
    (11, '2020-09-26 10:00:00', 24, 26), (11, '2020-09-26 17:00:00', 25, 27),
    (11, '2020-09-27 10:00:00', 26, 26), (11, '2020-09-27 17:00:00', 24, 26),
    (11, '2020-09-28 10:00:00', 26, 26), (11, '2020-09-28 17:00:00', 25, 27),
    (11, '2020-09-29 10:00:00', 26, 26), (11, '2020-09-29 17:00:00', 26, 26),
    (11, '2020-09-30 10:00:00', 25, 27), (11, '2020-09-30 17:00:00', 26, 26),
    
    (11, '2021-09-01 10:00:00', 30, 27), (11, '2021-09-01 17:00:00', 30, 27),
    (11, '2021-09-02 10:00:00', 25, 27), (11, '2021-09-02 17:00:00', 25, 27),
    (11, '2021-09-03 10:00:00', 24, 25), (11, '2021-09-03 17:00:00', 30, 27),
    (11, '2021-09-04 10:00:00', 30, 27), (11, '2021-09-04 17:00:00', 30, 27),
    (11, '2021-09-05 10:00:00', 30, 27), (11, '2021-09-05 17:00:00', 30, 27),
    (11, '2021-09-06 10:00:00', 24, 25), (11, '2021-09-06 17:00:00', 30, 27),
    (11, '2021-09-07 10:00:00', 30, 27), (11, '2021-09-07 17:00:00', 30, 30),
    (11, '2021-09-08 10:00:00', 25, 27), (11, '2021-09-08 17:00:00', 30, 27),
    (11, '2021-09-09 10:00:00', 25, 27), (11, '2021-09-09 17:00:00', 25, 27),
    (11, '2021-09-10 10:00:00', 24, 25), (11, '2021-09-10 17:00:00', 24, 25),
    (11, '2021-09-11 10:00:00', 25, 27), (11, '2021-09-11 17:00:00', 30, 30),
    (11, '2021-09-12 10:00:00', 24, 25), (11, '2021-09-12 17:00:00', 30, 27),
    (11, '2021-09-13 10:00:00', 24, 25), (11, '2021-09-13 17:00:00', 24, 25),
    (11, '2021-09-14 10:00:00', 30, 27), (11, '2021-09-14 17:00:00', 30, 30),
    (11, '2021-09-15 10:00:00', 25, 27), (11, '2021-09-15 17:00:00', 24, 25),
    (11, '2021-09-16 10:00:00', 24, 25), (11, '2021-09-16 17:00:00', 27, 26),
    (11, '2021-09-17 10:00:00', 25, 27), (11, '2021-09-17 17:00:00', 30, 27),
    (11, '2021-09-18 10:00:00', 30, 27), (11, '2021-09-18 17:00:00', 27, 26),
    (11, '2021-09-19 10:00:00', 30, 27), (11, '2021-09-19 17:00:00', 25, 27),
    (11, '2021-09-20 10:00:00', 24, 25), (11, '2021-09-20 17:00:00', 27, 26),
    (11, '2021-09-21 10:00:00', 25, 27), (11, '2021-09-21 17:00:00', 30, 27),
    (11, '2021-09-22 10:00:00', 24, 25), (11, '2021-09-22 17:00:00', 25, 27),
    (11, '2021-09-23 10:00:00', 30, 27), (11, '2021-09-23 17:00:00', 30, 27),
    (11, '2021-09-24 10:00:00', 30, 27), (11, '2021-09-24 17:00:00', 27, 26),
    (11, '2021-09-25 10:00:00', 30, 27), (11, '2021-09-25 17:00:00', 30, 27),
    (11, '2021-09-26 10:00:00', 24, 25), (11, '2021-09-26 17:00:00', 30, 27);
    
-- ----------------------------
--  Insert values for `SUGGERIMENTO`
-- ----------------------------
TRUNCATE SUGGERIMENTO;
INSERT INTO  SUGGERIMENTO (TimeStampSuggerimento, IDDispositivo, IDLivello, scelto, DurataAccensioneDispositivo) VALUES
	(CURRENT_TIMESTAMP, 6, 8, 0, '1:15'), (CURRENT_TIMESTAMP, 6, 7, 0, '1:15'), (CURRENT_TIMESTAMP, 6, 9, 0, '1:15'), 
    (CURRENT_TIMESTAMP, 32, 10, 1, '1:15'), (CURRENT_TIMESTAMP, 32, 11, 1, '1:15'), (CURRENT_TIMESTAMP, 32, 12, 1, '1:15'),
    (CURRENT_TIMESTAMP, 33, 13, 0, '1:15'), (CURRENT_TIMESTAMP, 33, 14, 1, '1:15'), (CURRENT_TIMESTAMP, 33, 15, 0, '1:15'),
    (CURRENT_TIMESTAMP, 49, 7, 1, '1:15'), (CURRENT_TIMESTAMP, 49, 8, 0, '1:15'), (CURRENT_TIMESTAMP, 49, 9, 1, '1:15'),
    
    ('2021-09-29 12:00:00' , 6, 8, 0, '1:15'), ('2021-09-29 12:00:00', 6, 7, 0, '1:15'), ('2021-09-29 12:00:00', 6, 9, 0, '1:15'), 
    ('2021-09-29 12:00:00', 32, 10, 1, '1:15'), ('2021-09-29 12:00:00', 32, 11, 0, '1:15'), ('2021-09-29 12:00:00', 32, 12, 0, '1:15'),
    ('2021-09-29 12:00:00', 33, 13, 1, '1:15'), ('2021-09-29 12:00:00', 33, 14, 0, '1:15'), ('2021-09-29 12:00:00', 33, 15, 0, '1:15'),
    ('2021-09-29 12:00:00', 49, 7, 0, '1:15'), ('2021-09-29 12:00:00', 49, 8, 0, '1:15'), ('2021-09-29 12:00:00', 49, 9, 0, '1:15'),
    
    ('2021-09-29 11:00:00' , 6, 8, 1, '1:15'), ('2021-09-29 11:00:00', 6, 7, 1, '1:15'), ('2021-09-29 11:00:00', 6, 9, 1, '1:15'), 
    ('2021-09-29 11:00:00', 32, 10, 1, '1:15'), ('2021-09-29 11:00:00', 32, 11, 0, '1:15'), ('2021-09-29 11:00:00', 32, 12, 0, '1:15'),
    ('2021-09-29 11:00:00', 33, 13, 0, '1:15'), ('2021-09-29 11:00:00', 33, 14, 0, '1:15'), ('2021-09-29 11:00:00', 33, 15, 1, '1:15'),
    ('2021-09-29 11:00:00', 49, 7, 1, '1:15'), ('2021-09-29 11:00:00', 49, 8, 1, '1:15'), ('2021-09-29 11:00:00', 49, 9, 0, '1:15');
    
TRUNCATE MV_Storico;
INSERT INTO  MV_Storico (DataStorico, KWProdotti, KWConsumati, Guadagno, Consumo) VALUES
	(CURRENT_TIMESTAMP - INTERVAL 1 MONTH, 20, 30, 12, 10),
    (CURRENT_TIMESTAMP - INTERVAL 2 MONTH, 20, 30, 12, 10),
    (CURRENT_TIMESTAMP - INTERVAL 3 MONTH, 20, 30, 12, 10);

    
DROP PROCEDURE IF EXISTS PopolamentoDataAnalyticsLOGDISPOSITIVI;

DELIMITER $$

CREATE PROCEDURE PopolamentoDataAnalyticsLOGDISPOSITIVI()
BEGIN
	DECLARE timestampTarget TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    DECLARE conteggioMese INT DEFAULT NULL;
    
    SET conteggioMese = 2880;
    
    WHILE conteggioMese <> 0 DO
		INSERT INTO LOGDISPOSITIVO VALUES(timestampTarget, FLOOR(1 + Rand() * 59), FLOOR(1 + Rand() * 5), timestampTarget + INTERVAL 1 HOUR, 1);
		SET timestampTarget = timestampTarget + INTERVAL 5 MINUTE;
        SET conteggioMese = conteggioMese - 1;
    END WHILE;
END $$

DELIMITER ;

CALL PopolamentoDataAnalyticsLOGDISPOSITIVI;
