      ******************************************************************
      **  TRBFNCX4 : BTM TRAITEMENT DES PPR "GIRBET"                   *
      **  ------------------------------------------                   *
      **                                                               *
      **  - CREATION MODULE BBF                                        *
      **  - CREATION USER 500001 (BACTAP)                              *
      **                                                               *
      **  - CREATION REMOTE 500001                                     *
      **  - CREATION REMOTE 500002                                     *
      **  - CREATION REMOTE 500006 (DISCORDANCE ENTRE                  *
      **      NO BANCAIRE CONNU ET INTRODUIT)                          *
      **                                                               *
      **  23.06.2005 JVE UITBREIDING BBF-MODULE                        *
      **                 INITIALISATIE 2 NIEUWE ZONES                  *
      **                 BBF-CODE-MAF    BBF-JAAR-MAF                  *
      **                                                               *
      ** MTU01 : SC229498 : RETRAIT CODE LIBELLE 70                    *
      ** MIS01 101222 : DOCSOL - MODIFICATION POUR NE PLUS GENERER LE  *
      **                DOC 541006                                     *
      ******************************************************************
      * 02/2011: AANPASSING DOOR ANN (CFR. IBAN10)
      *          AANPASSINGEN TGV PROJECT SEPA
      *          - WIJZIGINGEN DIE VERBAND HOUDEN MET IBAN: AANGEDUID
      *            MET 'IBAN10')
      ******************************************************************# EASY *
JGO004*JGO004: aanpassing om ADM-TAAL = 0 op te vangen                 *
      *----------------------------------------------------------------
279363* Incident #279363 rijksnummer vermelden i.p.v. M-nummer         *
      *----------------------------------------------------------------
       IDENTIFICATION DIVISION.
      *----------------------------------------------------------------
      **** Identification Division ***
      *----------------------------------------------------------------
       PROGRAM-ID. TRBFNCX4.
Y2000+*+***************************************************************
Y2000+*+  EDITED BY CGA/ARC RENOVATOR RENOALL V6.02 ON 1998-5-10 11:14
Y2000+*+***************************************************************
      *AUTHOR.  VAN ESCH VINCENT 11/1/1996
      *---------------------------------------------------------------
EVP   *
EVP   * TOEVOEGEN CODES CERA => KBC                  EVP 29/12/2004
EVP   * CR-20046151                                  FIND 'CERA'
EVP   *
      *----------------------------------------------------------------
MTU   *
MTU   * MODIFICATION PROJET INFOREK : 15/02/2002
MTU   *                                                                 
      *---------------------------------------------------------------- 
      * R140562: dagelijkse betaling via 2 banken: Belfius en KBC     * 
      *          zowel voor Betfin, UITK, Reisverzek. en Girbet       * 
      * (weglaten van document 500002 (copy BFN52GZU)                 * 
      ***************************************************************** 
      * EATTEST JGO 20160628   MARKED WITH EATT                       * 
      ***************************************************************** 
      * 6DE STAATSHERVORMING MARKED WITH JGO001                       * 
      ***************************************************************** 
CDU001* 01/07/2019 - CDU - 6DE STAATSHERVORMING
      ***************************************************************** 
      * KVS001 02/05/2023 JIRA-4224                                   *
      *     DETAILLIJNEN FLUX 500001 IN CSV EN NIET MEER IN PAPYRUS   *
      *****************************************************************
      * KVS002 16/06/2023 JIRA-4311                                   *
      *     ADAPTATION DU PAIFIN - BELFIUS                            *
      *****************************************************************
MSA001* 20240723 MSA JIRA-4837 CORREG                                 *
      ***************************************************************** 
MSA002* 20250130 MSA JIRA-???? BULK                                   *
      *****************************************************************
             ENVIRONMENT DIVISION.                                                                                      
      **********************
           COPY CNFIGXSD. 
       SPECIAL-NAMES. 
           COPY SPNAMXSD. .

       DATA DIVISION.
      ***************
       WORKING-STORAGE SECTION.
      *************************
ABXBS2 COPY ABX00XSW.
       COPY WRNRSXDW.
       COPY WDATEXDW.
       COPY LIDVZASW.
       COPY VBONDASW.
       COPY TBLIBCXW.
IBAN10 COPY SEPAAUKU.
       COPY BFN51GZR.
140562*COPY BFN52GZU.
       COPY BFN54GZR.
       COPY BFN56CXR.
       COPY LIBPNCXW.
IBAN10 COPY SEPAKCXW.
IBAN10 COPY SEBNKUKW.
      *
       01  TEST-MUTUALITE PIC 9(3).
           88 MUT-FR        VALUE 109, 116, 127, 128, 129, 130, 132,
      *                           133, 134, 135, 136.
CDU001                            133, 134, 135, 136, 167, 168.           
           88 MUT-NL        VALUE 101, 102, 104, 105, 108, 110, 111,
                                  112, 113, 114, 115, 117, 118, 119,
      *                           120, 121, 122, 126, 131.
CDU001                            120, 121, 122, 126, 131, 169.                    
      *    88 MUT-BILINGUE  VALUE 106, 107.
CDU001     88 MUT-BILINGUE  VALUE 106, 107, 150, 166.          
           88 MUT-VERVIERS  VALUE 137.
      *
       01  TABLE-LIB-AU.
           05 FILLER        PIC X(5) VALUE " TOT ".
           05 FILLER        PIC X(5) VALUE " AU  ".
           05 FILLER        PIC X(5) VALUE " BIS ".
       01  TABLE-LIB-AU-RED REDEFINES TABLE-LIB-AU.
           05 LIB-AU   PIC X(5) OCCURS 3.
      *----------------------------------------------------------------
      *ZONES POUR TEST LIBELLES1 ET 2
      *----------------------------------------------------------------
       01  SAV-LIB1.
           05  SAV-DATE1-DMY.
               10  SAV-DATE1-DD    PIC 99.
               10  SAV-DATE1-MM    PIC 99.
               10  SAV-DATE1-YY    PIC 99.
           05  FILLER              PIC X(8).
       01  SAV-LIB2.
           05  SAV-DATE2-DMY.
               10  SAV-DATE2-DD    PIC 99.
               10  SAV-DATE2-MM    PIC 99.
               10  SAV-DATE2-YY    PIC 99.
           05  FILLER              PIC X(8).
      *----------------------------------------------------------------
      *----------------------------------------------------------------
      *DESCRIPTION ZONE COMMUNICATION
      *EXTRAIT DE COMPTE
      *----------------------------------------------------------------
       01  COMMENT                     PIC  X(106) VALUE SPACE.
       01  COMMENT1 REDEFINES COMMENT.
           05  BANK-VELD1              PIC  X(53).
           05  REF-VELD1               PIC  X(07).
           05  KONSTANTE-VELD1         PIC  9(10).
           05  VOLGNR-VELD1            PIC  9(03).
           05  FILLER                  PIC  X.
           05  OMSCH1-VELD1            PIC  X(14).
           05  FILLER                  PIC  X.
           05  OMSCH2-VELD1            PIC  X(14).
           05  FILLER                  PIC  X(03).
      *----------------------------------------------------------------
279363 01  WS-RIJKSNUMMER            PIC  X(13).
       01  SAV-WELKEBANK   PIC 9.
IBAN10 01  SAV-IBAN        PIC X(34).
IBAN10 01  WS-IBAN         PIC X(34).
       01  SAV-RNRBIN      PIC S9(8) COMP.
       01  SW-TROP-JEUNE   PIC 9.
       01  SAV-LIBELLE     PIC X(53).
       01  SAV-TYPE-COMPTE PIC X(4).
       01  I               PIC 9(2).
       01  SECTION-TROUVEE PIC 999.
       01  SW-TROUVE       PIC XXX.
       01  WS-BIC          PIC X(11).
JGO004 01  WS-LIDVZ-OP-TAAL     PIC  9(01).
JGO004 01  WS-LIDVZ-AP-TAAL     PIC  9(01).
Y2000+*+** CGA/ARC A274: COPY STATEMENT ADDED
Y2000+     COPY CGACVXSW.
      *
KVS001 01  WS-CREATION-CODE-43          PIC 9(01).
KVS001     88 SW-NO-CREA-CODE-43        VALUE 0.         
KVS001     88 SW-CREA-CODE-43           VALUE 1.
      *
       LINKAGE SECTION.
      *****************
           COPY UAREADBW SUPPRESS.
           COPY TRBFNCXP REPLACING TRBFNCXP BY PPR-RECORD.
      *
       PROCEDURE DIVISION.
      ********************
      *----------------------------------------------------------------
      ******** ENTRY POINT *******
      ****   G I R B E T P P   ***
      *----------------------------------------------------------------
           ENTRY "GIRBETPP" USING USAREA1 PPR-RECORD.
      *----------------------------------------------------------------
       TRAITEMENT-BTM SECTION.
      *----------------------------------------------------------------
      *SQUELETTE DU TRAITEMENT
      *----------------------------------------------------------------
       PAR-TRAITEMENT-BTM.
      *----------------------------------------------------------------
      *SEARCH LID
      *----------------------------------------------------------------
JGO004     MOVE 0 TO WS-LIDVZ-OP-TAAL.
JGO004     MOVE 0 TO WS-LIDVZ-AP-TAAL.
           MOVE ZEROES        TO STAT1
           MOVE TRBFN-PPR-RNR TO RNRBIN
           PERFORM SCH-LID
           IF STAT1 NOT = ZEROES
           THEN
              PERFORM PPRNVW
           END-IF
      *----------------------------------------------------------------
           PERFORM RECHERCHE-SECTION
           MOVE 1 TO GETTP
           PERFORM GET-ADM
JGO004     IF ADM-TAAL = 0
JGO004         IF WS-LIDVZ-AP-TAAL NOT = 0
JGO004             MOVE WS-LIDVZ-AP-TAAL TO ADM-TAAL
JGO004         ELSE
JGO004             IF WS-LIDVZ-OP-TAAL NOT = 0
JGO004                 MOVE WS-LIDVZ-OP-TAAL TO ADM-TAAL
JGO004             ELSE
JGO004                 MOVE "TAALCODE ONBEKEND/CODE LANGUE INCONNU"
JGO004                           TO BBF-N54-DIAG
JGO004                 PERFORM CREER-REMOTE-500004
JGO004                 PERFORM FIN-BTM
JGO004             END-IF
JGO004         END-IF
JGO004     END-IF
279363     PERFORM ZOEK-RIJKSNUMMER
           IF TRBFN-CODE-LIBEL NOT < 90
           THEN
      *----------------------------------------------------------------
      *REMPLIR SAV-LIBELLE ET
      *SAV-TYPE-COMPTE AVEC LES
      *RENSEIGNEMENTS DE LA DB MUTF08
      *SI PAS TROUVE => FAIRE REJET
      *----------------------------------------------------------------
              MOVE TRBFN-DEST TO TEST-MUTUALITE
      *----------------------------------------------------------------
      *SCHLID MUTF08 + RECHERCHE MODULE
      *PAR CORRESPONDANT
      *----------------------------------------------------------------
              MOVE RNRBIN TO SAV-RNRBIN
              ADD 6000000 TRBFN-DEST GIVING RNRBIN
              PERFORM SCH-LID08
              IF STAT1 = ZEROES OR = 4
              THEN
                 MOVE 1 TO GETTP
                 PERFORM GET-PAR
                 PERFORM WITH TEST BEFORE UNTIL
                 STAT1 NOT  = ZEROES OR
                 LIBP-NRLIB = TRBFN-CODE-LIBEL
                    MOVE 2 TO GETTP
                    PERFORM GET-PAR
                 END-PERFORM
              END-IF
              MOVE SAV-RNRBIN TO RNRBIN
              IF STAT1 = ZEROES
              THEN
                 MOVE LIBP-TYPE-COMPTE TO SAV-TYPE-COMPTE
      *----------------------------------------------------------------
      *REMPLIR SAV-LIBELLE EN FONCTION
      *DU REGIME LINGUISTIQUE DE LA FEDERATION
      *----------------------------------------------------------------
                 IF MUT-FR
                 THEN
                    MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
                 END-IF
                 IF MUT-NL
                 THEN
                    MOVE LIBP-LIBELLE-NL TO SAV-LIBELLE
                 END-IF
                 IF MUT-BILINGUE
                 THEN
                    IF ADM-TAAL = 1
                    THEN
                       MOVE LIBP-LIBELLE-NL TO SAV-LIBELLE
                    ELSE
                       MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
                    END-IF
                 END-IF
                 IF MUT-VERVIERS
                 THEN
                    IF ADM-TAAL = 3
                    THEN
                       MOVE LIBP-LIBELLE-AL TO SAV-LIBELLE
                    ELSE
                       MOVE LIBP-LIBELLE-FR TO SAV-LIBELLE
                    END-IF
                 END-IF
              ELSE
                 MOVE "ONBEK. OMSCHR./LIBELLE INCONNU" TO BBF-N54-DIAG
                 PERFORM CREER-REMOTE-500004
                 PERFORM FIN-BTM
              END-IF
           ELSE
      *----------------------------------------------------------------
      *REMPLIR SAV-LIBELLE ET
      *SAV-TYPE-COMPTE AVEC LES
      *RENSEIGNEMENTS DE LA TABLE TBLIBCXW
      *----------------------------------------------------------------
              MOVE TBLIB-LIBELLE
               (TRBFN-CODE-LIBEL, ADM-TAAL) TO SAV-LIBELLE
              MOVE TBLIB-TYPE
                (TRBFN-CODE-LIBEL) TO SAV-TYPE-COMPTE
      *----------------------------------------------------------------
           END-IF
           PERFORM VOIR-DOUBLES
           PERFORM VOIR-BANQUE-DEBIT
           PERFORM CREER-BBF
IBAN10*    als betalingswijze een circulaire cheque betreft, mag
IBAN10*    deze enkel aangemaakt als begunstigde over Belgisch
IBAN10*    adres beschikt:
IBAN10     IF (TRBFN-BETWYZ = "C" OR "D" OR "E" OR "F") AND
IBAN10        (ADM-LND <> "B  ")
IBAN10        MOVE "CC - PAYS/LAND NOT = B        " TO BBF-N54-DIAG
IBAN10        PERFORM CREER-REMOTE-500004
IBAN10     ELSE
IBAN10        PERFORM CREER-USER-500001
IBAN10        PERFORM CREER-REMOTE-500001
140562*       PERFORM CREER-REMOTE-500002
           END-IF
           IF TRBFN-COMPTE-MEMBRE = ZEROES
           THEN
              PERFORM CREER-REMOTE-500006
           END-IF
           PERFORM FIN-BTM
           .
      *
      *----------------------------------------------------------------
      *
      *----------------------------------------------------------------
      **** ROUTINES SECTION ***
      *----------------------------------------------------------------
       ROUTINES SECTION.
      ******************
       VOIR-DOUBLES.
      **************
           MOVE 1 TO GETTP
           PERFORM GET-BBF
           PERFORM WITH TEST BEFORE UNTIL STAT1 NOT = ZEROES
              IF
              TRBFN-MONTANT   = BBF-BEDRAG AND
              TRBFN-CONSTANTE = BBF-KONST
              THEN
                 MOVE "DUBBELE BETALING/DOUBLE PAIEMENT" TO BBF-N54-DIAG
                 PERFORM CREER-REMOTE-500004
                 PERFORM FIN-BTM
              END-IF
              MOVE 2 TO GETTP
              PERFORM GET-BBF
           END-PERFORM
           .
      *
       VOIR-BANQUE-DEBIT.
      *******************
IBAN10     MOVE SPACES TO WS-BIC.
IBAN10     MOVE TRBFN-IBAN     TO WS-SEBNK-IBAN-IN
IBAN10     MOVE TRBFN-BETWYZ   TO WS-SEBNK-BETWYZ-IN
IBAN10     PERFORM WELKE-BANK
           MOVE TRBFN-DEST TO TEST-MUTUALITE
KVS002*    IF MUT-FR OR MUT-VERVIERS
           MOVE "0"            TO WS-SEBNK-WELKEBANK
KVS002*    END-IF
KVS002*    IF (WS-SEBNK-WELKEBANK = 0 AND WS-SEBNK-STAT-OUT = 0)
KVS002     IF (WS-SEBNK-WELKEBANK = 0 
KVS002             AND WS-SEBNK-STAT-OUT = (0 OR 1 OR 2)) THEN
IBAN10        MOVE WS-SEBNK-BIC-OUT TO WS-BIC
IBAN10     ELSE
KVS002*       IF (WS-SEBNK-STAT-OUT NOT = 1 AND NOT = 2)
IBAN10        MOVE "IBAN FOUTIEF/IBAN ERRONE" TO BBF-N54-DIAG
IBAN10        PERFORM CREER-REMOTE-500004
KVS002*       ELSE
KVS002*          MOVE WS-SEBNK-BIC-OUT TO WS-BIC
KVS002*       END-IF
IBAN10     END-IF.

           EVALUATE TRBFN-CODE-LIBEL
           WHEN 90 THRU 99
           WHEN  1 THRU 49
EATT       WHEN 52 THRU 57
MSA002     WHEN 71
MSA001     WHEN 73
EATT       WHEN 74
EATT       WHEN 76
EATT       WHEN 78           
IBAN10           IF WS-SEBNK-WELKEBANK = "0"
IBAN10              MOVE 1 TO SAV-WELKEBANK
IBAN10           END-IF
KVS002*          IF WS-SEBNK-WELKEBANK = "1"
KVS002*             MOVE 2 TO SAV-WELKEBANK
KVS002*          END-IF
           WHEN 50
              MOVE 1 TO SAV-WELKEBANK
           WHEN 51
              MOVE 1 TO SAV-WELKEBANK
           WHEN 60
              MOVE 1 TO SAV-WELKEBANK
           WHEN 80
              MOVE 1 TO SAV-WELKEBANK
           WHEN OTHER
              MOVE 1 TO SAV-WELKEBANK
           END-EVALUATE
           .

       CREER-BBF.
      ***********
           INITIALIZE BBF-REC
           MOVE 9                TO BBF-TYPE
           MOVE TRBFN-CODE-LIBEL TO BBF-LIBEL
      *     MOVE TRBFN-DEST TO BBF-VERB
           MOVE TRBFN-MONTANT TO BBF-BEDRAG
EURO       MOVE TRBFN-MONTANT-DV TO BBF-BEDRAG-DV
           MOVE TRBFN-NO-SUITE TO BBF-VOLGNR
           MOVE TRBFN-CONSTANTE TO BBF-KONST
           MOVE SP-ACTDAT       TO BBF-DATINB
           IF TRBFN-CODE-LIBEL = 50 OR = 60
           THEN
              MOVE TRBFN-LIBELLE1 TO SAV-LIB1
              MOVE TRBFN-LIBELLE2 TO SAV-LIB2
              MOVE SAV-DATE1-DD TO BBF-DATVAN-DD
              MOVE SAV-DATE1-MM TO BBF-DATVAN-MM
Y2000+        MOVE SAV-DATE1-YY TO CGACVT-SUP1-N
Y2000+        MOVE -1 TO CGACVT-POS1
ABXBS2        MOVE "CGACVXD9" TO CA--PROG
ABXBS2        CALL CA--PROG USING CGACVT-EXPAND CGACVT-AREA
Y2000+        MOVE CGACVT-EXP1-N TO BBF-DATVAN-CCYY
              MOVE SAV-DATE2-DD TO BBF-DATTOT-DD
              MOVE SAV-DATE2-MM TO BBF-DATTOT-MM
Y2000+        MOVE SAV-DATE2-YY TO CGACVT-SUP1-N
Y2000+        MOVE -1 TO CGACVT-POS1
ABXBS2        MOVE "CGACVXD9" TO CA--PROG
ABXBS2        CALL CA--PROG USING CGACVT-EXPAND CGACVT-AREA
Y2000+        MOVE CGACVT-EXP1-N TO BBF-DATTOT-CCYY
           ELSE
              MOVE ZEROES TO BBF-DATVAN
                             BBF-DATTOT
           END-IF
MTU        MOVE ZEROES TO BBF-INFOREK
MTU        MOVE ZEROES TO BBF-LINKNR
JVE        MOVE SPACES TO BBF-CODE-MAF
JVE        MOVE ZEROES TO BBF-JAAR-MAF
IBAN10     MOVE TRBFN-IBAN    TO BBF-IBAN
IBAN10     MOVE SPACES        TO WS-IBAN
IBAN10     IF TRBFN-IBAN NOT = SPACES
IBAN10        MOVE TRBFN-IBAN TO WS-IBAN
IBAN10        IF WS-IBAN(1:2) = "BE"
IBAN10           MOVE WS-IBAN(5:12) TO BBF-REKNR
IBAN10        ELSE
IBAN10           MOVE ZEROES TO BBF-REKNR
IBAN10        END-IF
IBAN10     ELSE
IBAN10        MOVE ZEROES TO BBF-REKNR
IBAN10     END-IF.
IBAN10     MOVE TRBFN-BETWYZ  TO BBF-BETWY
JGO001     EVALUATE TRBFN-TYPE-COMPTA
JGO001         WHEN 3
JGO001                MOVE 1 TO BBF-TAGREG-OP
CDU001                MOVE 167 TO BBF-VERB
JGO001         WHEN 4
JGO001                MOVE 2 TO BBF-TAGREG-OP
CDU001                MOVE 169 TO BBF-VERB
JGO001         WHEN 5
JGO001                MOVE 4 TO BBF-TAGREG-OP
CDU001                MOVE 166 TO BBF-VERB
JGO001         WHEN 6
JGO001                MOVE 7 TO BBF-TAGREG-OP
CDU001                MOVE 168 TO BBF-VERB
JGO001         WHEN OTHER
JGO001                MOVE 9 TO BBF-TAGREG-OP
CDU001                MOVE TRBFN-DEST TO BBF-VERB
JGO001     END-EVALUATE
           PERFORM ADD-BBF
           .
      *
      *----------------------------------------------------------------
      **** CREER-USER-500001: SEPAAUKU ***
      *----------------------------------------------------------------
       CREER-USER-500001.
      *******************
IBAN10     INITIALIZE   SEPAAUKU
IBAN10*    MOVE 471           TO REC-LENGTE
CDU001     MOVE 475           TO REC-LENGTE
           MOVE 41            TO REC-CODE
IBAN10*    MOVE "500001"      TO USERCOD
IBAN10     MOVE "5N0001"      TO USERCOD
      *     MOVE TRBFN-DEST    TO USERFED
           MOVE TRBFN-PPR-RNR TO USERRNR
           MOVE SECTION-TROUVEE TO USERMY
           
CDU001* WELKEBANK = 0 = BELFIUS
CDU001* WELKEBANK = 1 = KBC
CDU001* U-BAC-KODE = 13 = AO
CDU001* U-BAC-KODE = 23 = AL          
           EVALUATE SAV-WELKEBANK
           WHEN 1
              MOVE 0 TO WELKEBANK
              IF TRBFN-TYPE-COMPTA = 1
JGO001            OR 3 OR 4 OR 5 OR 6
              THEN
                 MOVE 13 TO U-BAC-KODE
              ELSE
                 MOVE 23 TO U-BAC-KODE
              END-IF
           WHEN 2
      *        MOVE 1 TO WELKEBANK
      *        IF TRBFN-TYPE-COMPTA = 1
JGO001*            OR 3 OR 4 OR 5 OR 6
      *        THEN
      *           MOVE 113 TO U-BAC-KODE
      *        ELSE
      *           MOVE 123 TO U-BAC-KODE
CDU001* POUR LES COMPTES REGIONAUX, ON A SEULEMENT DES COMPTES BANCAIRES
CDU001* CHEZ BELFIUS
CDU001        IF TRBFN-TYPE-COMPTA = 3 OR 4 OR 5 OR 6
CDU001           MOVE 0 TO WELKEBANK
CDU001           MOVE 13 TO U-BAC-KODE
CDU001        ELSE
KVS002*          MOVE 1 TO WELKEBANK
KVS002           MOVE 0 TO WELKEBANK
CDU001           IF TRBFN-TYPE-COMPTA = 1
CDU001              MOVE 113 TO U-BAC-KODE
CDU001           ELSE
CDU001              MOVE 123 TO U-BAC-KODE
CDU001           END-IF
CDU001        END-IF
           END-EVALUATE
           MOVE 1          TO ALOIS-RAF
      *     MOVE TRBFN-DEST TO VRBOND
           MOVE ADM-TAAL   TO TAAL
           IF TRBFN-CODE-LIBEL = 60
           THEN
              MOVE 1 TO BAC-DATM61
           ELSE
              IF TRBFN-TYPE-COMPTA = 1
JGO001            OR 3 OR 4 OR 5 OR 6
              THEN
                 MOVE ZEROES TO BAC-DATM61
              ELSE
                 MOVE 2 TO BAC-DATM61
              END-IF
           END-IF
           MOVE SP-ACTDAT      TO U-ACTDAT
IBAN10     MOVE TRBFN-IBAN     TO U-IBAN
           MOVE SPACES         TO U-BNK-REKHOUDER
           STRING ADM-NAAM    DELIMITED BY SIZE
                  ADM-VOORN   DELIMITED BY SIZE
                        INTO U-BNK-REKHOUDER
           END-STRING
           MOVE ADM-LND        TO U-BNK-LND
           MOVE ADM-POSTNR     TO U-BNK-POSTNR
           MOVE ADM-GEM        TO U-BNK-GEM
           MOVE ADM-NAAM      TO U-ADM-NAAM
           MOVE ADM-VOORN     TO U-ADM-VNAAM
           MOVE ADM-STRAAT    TO U-ADM-STR
           MOVE ADM-HUISNR    TO U-ADM-HUIS
           MOVE ADM-INDEX     TO U-ADM-INDEX
           MOVE ADM-BUS       TO U-ADM-BUS
           MOVE ADM-LND       TO U-ADM-LND
           MOVE ADM-POSTNR    TO U-ADM-POST
           MOVE ADM-GEM       TO U-ADM-GEM
           MOVE SPACES TO COMMENT
           EVALUATE TRBFN-CODE-LIBEL
           WHEN 35
              MOVE SPACES TO BANK-VELD1
              STRING SAV-LIBELLE                  DELIMITED BY "  "
                     "-"                          DELIMITED BY SIZE
                     ADM-NAAM                     DELIMITED BY "  "
                     SPACE                        DELIMITED BY SIZE
                     ADM-VOORN                    DELIMITED BY SIZE
                                 INTO BANK-VELD1
           WHEN 50
              MOVE SPACES TO BANK-VELD1
              STRING SAV-LIBELLE           DELIMITED BY "  "
                     SPACE                 DELIMITED BY SIZE
                     SAV-DATE1-DMY         DELIMITED BY SIZE
                     LIB-AU (ADM-TAAL)     DELIMITED BY SIZE
                     SAV-DATE2-DMY         DELIMITED BY SIZE
                                  INTO BANK-VELD1
              END-STRING
           WHEN 60
              MOVE SPACES TO BANK-VELD1
              STRING SAV-LIBELLE           DELIMITED BY "  "
                     SPACE                 DELIMITED BY SIZE
                     SAV-DATE1-DMY         DELIMITED BY SIZE
                     LIB-AU (ADM-TAAL)     DELIMITED BY SIZE
                     SAV-DATE2-DMY         DELIMITED BY SIZE
                                  INTO BANK-VELD1
              END-STRING
           WHEN OTHER
              MOVE SAV-LIBELLE TO BANK-VELD1
           END-EVALUATE
           EVALUATE ADM-TAAL
           WHEN 1
              MOVE "O.REF.:" TO REF-VELD1
           WHEN 2
              MOVE "N.REF.:" TO REF-VELD1
           WHEN OTHER
              MOVE "U.KENZ:" TO REF-VELD1
           END-EVALUATE
           MOVE TRBFN-CONSTANTE TO KONSTANTE-VELD1
           MOVE TRBFN-NO-SUITE  TO VOLGNR-VELD1
           IF TRBFN-CODE-LIBEL = 50 OR = 60
           THEN
              MOVE SPACES TO OMSCH1-VELD1
              MOVE SPACES TO OMSCH2-VELD1
           ELSE
279363        IF TRBFN-LIBELLE1 (11:1) = "M"
279363            MOVE WS-RIJKSNUMMER TO OMSCH1-VELD1
279363        ELSE
                  MOVE TRBFN-LIBELLE1 TO OMSCH1-VELD1
279363        END-IF
              IF OMSCH1-VELD1 = SPACES
              THEN
279363            MOVE WS-RIJKSNUMMER TO OMSCH1-VELD1
              END-IF
              MOVE TRBFN-LIBELLE2 TO OMSCH2-VELD1
           END-IF
           MOVE COMMENT TO COMMENTAAR
           MOVE TRBFN-MONTANT TO NETBEDRAG
EURO       MOVE TRBFN-MONTANT-DV TO REC-DV
IBAN10     MOVE TRBFN-BETWYZ TO U-BETWYZ.
IBAN10     MOVE WS-BIC       TO U-BIC.
CDU001     EVALUATE TRBFN-TYPE-COMPTA
CDU001         WHEN 3
CDU001                MOVE 1 TO TAG-REG-OP TAG-REG-LEG
CDU001                MOVE 167 TO USERFED VRBOND                      
CDU001         WHEN 4
CDU001                MOVE 2 TO TAG-REG-OP TAG-REG-LEG
CDU001                MOVE 169 TO USERFED VRBOND 
CDU001         WHEN 5
CDU001                MOVE 4 TO TAG-REG-OP TAG-REG-LEG
CDU001                MOVE 166 TO USERFED VRBOND 
CDU001         WHEN 6
CDU001                MOVE 7 TO TAG-REG-OP TAG-REG-LEG
CDU001                MOVE 168 TO USERFED VRBOND 
CDU001         WHEN OTHER
CDU001                MOVE 9 TO TAG-REG-OP TAG-REG-LEG
CDU001                MOVE TRBFN-DEST TO USERFED VRBOND 
CDU001     END-EVALUATE
           .
           COPY ADLOGDBD
IBAN10         REPLACING LOGT1-REC BY SEPAAUKU .
           .
      *
      *----------------------------------------------------------------
       RECHERCHE-SECTION.
      *******************
           MOVE ZEROES TO SECTION-TROUVEE.
           MOVE "NOK" TO SW-TROUVE.
           COPY LIDVZASD. .
           IF LIDVZ-STATUS = 2
      *
      * 1. RECHERCHE DANS LES DONNEES TITULAIRE OUVERTES
      *
              PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3 OR SW-TROUVE
                                                              = "OK"
                 IF LIDVZ-OT-DATOND (I) NOT = ZEROES AND
      *             LIDVZ-OT-KOD1   (I) NOT < 600    AND
      *             LIDVZ-OT-KOD1   (I)     < 700    AND
                    LIDVZ-OT-KOD1   (I) NOT = 609    AND
                    LIDVZ-OT-KOD1   (I) NOT = 659    AND
                    LIDVZ-OT-KOD1   (I) NOT = 679    AND
                    LIDVZ-OT-KOD1   (I) NOT = 689
                 THEN
                    MOVE "OK" TO SW-TROUVE
                    MOVE LIDVZ-ADM-MY TO SECTION-TROUVEE
                 END-IF
              END-PERFORM
      *
      * 2. RECHERCHE DANS LES DONNEES PAC OUVERTES
      *
              PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3 OR SW-TROUVE
                                                              = "OK"
                 IF LIDVZ-OP-DATINS (I) NOT = ZEROES AND
      *             LIDVZ-OP-KOD1   (I) NOT < 600    AND
      *             LIDVZ-OP-KOD1   (I)     < 700    AND
                    LIDVZ-OP-KOD1   (I) NOT = 609    AND
                    LIDVZ-OP-KOD1   (I) NOT = 659    AND
                    LIDVZ-OP-KOD1   (I) NOT = 679    AND
                    LIDVZ-OP-KOD1   (I) NOT = 689
                 THEN
                    MOVE "OK" TO SW-TROUVE
                    MOVE LIDVZ-OP-MY(I) TO SECTION-TROUVEE
JGO004              MOVE LIDVZ-OP-TAAL(I)  TO WS-LIDVZ-OP-TAAL
                 END-IF
              END-PERFORM
      *
      * 3. RECHERCHE DANS LES DONNEES TITULAIRE CLOTUREES
      *
              PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3 OR SW-TROUVE
                                                              = "OK"
                 IF LIDVZ-AT-DATOND (I) NOT = ZEROES AND
      *             LIDVZ-AT-KOD1   (I) NOT < 600    AND
      *             LIDVZ-AT-KOD1   (I)     < 700    AND
                    LIDVZ-AT-KOD1   (I) NOT = 609    AND
                    LIDVZ-AT-KOD1   (I) NOT = 659    AND
                    LIDVZ-AT-KOD1   (I) NOT = 679    AND
                    LIDVZ-AT-KOD1   (I) NOT = 689
                 THEN
                    MOVE "OK" TO SW-TROUVE
                    MOVE LIDVZ-ADM-MY TO SECTION-TROUVEE
                 END-IF
              END-PERFORM
      *
      * 4. RECHERCHE DANS LES DONNEES PAC CLOTUREES
      *
              PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3 OR SW-TROUVE
                                                              = "OK"
                 IF LIDVZ-AP-DATINS (I) NOT = ZEROES AND
      *             LIDVZ-AP-KOD1   (I) NOT < 600    AND
      *             LIDVZ-AP-KOD1   (I)     < 700    AND
                    LIDVZ-AP-KOD1   (I) NOT = 609    AND
                    LIDVZ-AP-KOD1   (I) NOT = 659    AND
                    LIDVZ-AP-KOD1   (I) NOT = 679    AND
                    LIDVZ-AP-KOD1   (I) NOT = 689
                 THEN
                    MOVE "OK" TO SW-TROUVE
                    MOVE LIDVZ-AP-MY(I) TO SECTION-TROUVEE
JGO004              MOVE LIDVZ-AP-TAAL(I)  TO WS-LIDVZ-AP-TAAL
                 END-IF
              END-PERFORM
           END-IF.
      *----------------------------------------------------------------
      **** CREER-REMOTE-500001 ***
      *----------------------------------------------------------------
       CREER-REMOTE-500001.
      *********************
IBAN10*     MOVE 199           TO BBF-N51-LENGTH
CDU001     MOVE 213           TO BBF-N51-LENGTH           
JGO001*           MOVE 40            TO BBF-N51-CODE
           IF TRBFN-DEST = 153
           THEN
              MOVE "C"           TO BBF-N51-DEVICE-OUT
           ELSE
              MOVE "L"           TO BBF-N51-DEVICE-OUT
           END-IF
           MOVE "*"           TO BBF-N51-SWITCHING
JGO001*           IF TRBFN-DEST = 141
JGO001*           THEN
JGO001*              MOVE 116           TO BBF-N51-DESTINATION
JGO001*              MOVE "541001"      TO BBF-N51-NAME
JGO001*           ELSE
JGO001*              MOVE TRBFN-DEST    TO BBF-N51-DESTINATION
JGO001*              MOVE "500001"      TO BBF-N51-NAME
JGO001*           END-IF
KVS001     SET SW-NO-CREA-CODE-43    TO TRUE
JGO001     EVALUATE TRBFN-TYPE-COMPTA
JGO001         WHEN 03 MOVE "500071" TO BBF-N51-NAME
JGO001                 MOVE 43       TO BBF-N51-CODE
JGO001                 MOVE 151      TO BBF-N51-DESTINATION
JGO001         WHEN 04 MOVE "500091" TO BBF-N51-NAME
JGO001                 MOVE 151      TO BBF-N51-DESTINATION
JGO001                 MOVE 43       TO BBF-N51-CODE
JGO001         WHEN 05 MOVE "500061" TO BBF-N51-NAME
JGO001                 MOVE 43       TO BBF-N51-CODE
JGO001                 MOVE 151      TO BBF-N51-DESTINATION
JGO001         WHEN 06 MOVE "500081" TO BBF-N51-NAME
JGO001                 MOVE 151      TO BBF-N51-DESTINATION
JGO001                 MOVE 43       TO BBF-N51-CODE
JGO001*        WHEN OTHER MOVE "500001" TO BBF-N51-NAME
JGO001         WHEN OTHER MOVE 40       TO BBF-N51-CODE
CDU001                    IF TRBFN-DEST = 141
CDU001                       MOVE 116           TO BBF-N51-DESTINATION
CDU001                       MOVE "541001"      TO BBF-N51-NAME
CDU001                    ELSE
CDU001                       MOVE TRBFN-DEST    TO BBF-N51-DESTINATION
CDU001                       MOVE "500001"      TO BBF-N51-NAME
KVS001                       SET SW-CREA-CODE-43          TO TRUE
CDU001                   END-IF
JGO001     END-EVALUATE.

           MOVE SPACE            TO BBF-N51-PRIORITY
           MOVE SPACES           TO BBF-N51-KEY
      *    MOVE TRBFN-DEST       TO BBF-N51-VERB
JGO001*           IF TRBFN-TYPE-COMPTA = 1
JGO001*           THEN
JGO001*              MOVE 2 TO BBF-N51-AFK
JGO001*           ELSE
JGO001*              MOVE 3 TO BBF-N51-AFK
JGO001*           END-IF
JGO001*     EVALUATE TRBFN-TYPE-COMPTA
JGO001*        WHEN 1 MOVE 2 TO BBF-N51-AFK
JGO001*        WHEN 2 MOVE 3 TO BBF-N51-AFK
JGO001*        WHEN 3 MOVE 4 TO BBF-N51-AFK
JGO001*        WHEN 4 MOVE 5 TO BBF-N51-AFK
JGO001*        WHEN 5 MOVE 6 TO BBF-N51-AFK
JGO001*        WHEN 6 MOVE 7 TO BBF-N51-AFK
JGO001*     END-EVALUATE
CDU001     IF TRBFN-TYPE-COMPTA = 1 OR 3 OR 4 OR 5 OR 6
CDU001        MOVE 2 TO BBF-N51-AFK
CDU001     ELSE  
CDU001        MOVE 3 TO BBF-N51-AFK
CDU001     END-IF.
CDU001      
           MOVE TRBFN-CONSTANTE TO BBF-N51-KONST
           MOVE TRBFN-NO-SUITE  TO BBF-N51-VOLGNR
279363     MOVE WS-RIJKSNUMMER   TO BBF-N51-RNR
           MOVE ADM-NAAM         TO BBF-N51-NAAM
           MOVE ADM-VOORN        TO BBF-N51-VOORN
           MOVE TRBFN-CODE-LIBEL TO BBF-N51-LIBEL
IBAN10     MOVE ZEROES             TO BBF-N51-REKNR
           MOVE TRBFN-MONTANT      TO BBF-N51-BEDRAG
EURO       MOVE TRBFN-MONTANT-DV TO BBF-N51-DV
EURO       IF TRBFN-MONTANT-DV = "E"
EURO          MOVE 2 TO BBF-N51-DN
EURO       ELSE
EURO          MOVE 0 TO BBF-N51-DN
EURO       END-IF
           MOVE SAV-WELKEBANK      TO BBF-N51-BANK
MTU        MOVE ZEROES TO BBF-N51-INFOREK
           IF TRBFN-CODE-LIBEL >= 90 AND
              TRBFN-CODE-LIBEL <= 99
           THEN
              PERFORM P-RECHERCHE-TYPE-COMPTE
           ELSE
              MOVE SPACES TO BBF-N51-TYPE-COMPTE
           END-IF
IBAN10     MOVE TRBFN-IBAN       TO BBF-N51-IBAN
IBAN10     MOVE TRBFN-BETWYZ     TO BBF-N51-BETWY
CDU001     EVALUATE TRBFN-TYPE-COMPTA
CDU001         WHEN 3
CDU001                MOVE 1 TO BBF-N51-TAGREG-OP
CDU001                MOVE 167 TO BBF-N51-VERB
CDU001         WHEN 4
CDU001                MOVE 2 TO BBF-N51-TAGREG-OP
CDU001                MOVE 169 TO BBF-N51-VERB
CDU001         WHEN 5
CDU001                MOVE 4 TO BBF-N51-TAGREG-OP
CDU001                MOVE 166 TO BBF-N51-VERB
CDU001         WHEN 6
CDU001                MOVE 7 TO BBF-N51-TAGREG-OP
CDU001                MOVE 168 TO BBF-N51-VERB
CDU001         WHEN OTHER
CDU001                MOVE 9 TO BBF-N51-TAGREG-OP
CDU001                MOVE TRBFN-DEST TO BBF-N51-VERB
CDU001     END-EVALUATE
           .
           COPY ADLOGDBD
               REPLACING LOGT1-REC BY BFN51GZR .

KVS001     IF SW-CREA-CODE-43 THEN
KVS001         MOVE "5DET01"                     TO BBF-N51-NAME
KVS001         MOVE 43                           TO BBF-N51-CODE
KVS001         MOVE 151                          TO BBF-N51-DESTINATION
KVS001         COPY ADLOGDBD
KVS001             REPLACING LOGT1-REC BY BFN51GZR.
KVS001     END-IF.          

      *
      *----------------------------------------------------------------
      *----------------------------------------------------------------
      **** CREER-REMOTE-500002 ***
      *----------------------------------------------------------------
140562*CREER-REMOTE-500002.
140562*********************
140562*    MOVE 191           TO BBF-N52-LENGTH
140562*    MOVE 40            TO BBF-N52-CODE
140562*    MOVE "L"           TO BBF-N52-DEVICE-OUT
140562*    MOVE "*"           TO BBF-N52-SWITCHING
140562*    IF TRBFN-DEST = 141
140562*    THEN
140562*       MOVE 116           TO BBF-N52-DESTINATION
140562*       MOVE "541002"      TO BBF-N52-NAME
140562*    ELSE
140562*       MOVE TRBFN-DEST    TO BBF-N52-DESTINATION
140562*       MOVE "500002"      TO BBF-N52-NAME
140562*    END-IF
140562*    MOVE SPACE            TO BBF-N52-PRIORITY
140562*    MOVE SPACES           TO BBF-N52-KEY
140562*    MOVE TRBFN-DEST       TO BBF-N52-VERB
140562*    MOVE TRBFN-CONSTANTE TO BBF-N52-KONST
140562*    MOVE TRBFN-NO-SUITE  TO BBF-N52-VOLGNR
140562*    MOVE ADM-TAAL        TO BBF-N52-TAAL
279363*    MOVE ADM-RNR2         TO BBF-N52-RNR
279363*    MOVE WS-RIJKSNUMMER   TO BBF-N52-RNR
140562*    MOVE ADM-NAAM         TO BBF-N52-NAAM
140562*    MOVE ADM-VOORN        TO BBF-N52-VOORN
140562*    MOVE ADM-STRAAT       TO BBF-N52-STRAAT
140562*    MOVE ADM-HUISNR       TO BBF-N52-HUISNR
140562*    MOVE ADM-BUS          TO BBF-N52-BUS
140562*    MOVE ADM-INDEX        TO BBF-N52-INDEX
140562*    MOVE ADM-POSTNR       TO BBF-N52-POSTNR
140562*    MOVE ADM-NIS   TO LOK-NIS
140562*    COPY GTLOKDRD .
140562*    IF ADM-TAAL = 2
140562*    THEN
140562*       MOVE LOK-NAAMF TO BBF-N52-GEM
140562*    ELSE
140562*       MOVE LOK-NAAMN TO BBF-N52-GEM
140562*    END-IF
140562*    MOVE ADM-LND          TO BBF-N52-LND
140562*    .
140562*    COPY ADLOGDBD
140562*        REPLACING LOGT1-REC BY BFN52GZU .
140562*    .
      *
      *----------------------------------------------------------------
      *----------------------------------------------------------------
      **** CREER-REMOTE-500004 ***
      *----------------------------------------------------------------
       CREER-REMOTE-500004.
      *********************
IBAN10*     MOVE 214           TO BBF-N54-LENGTH
CDU001     MOVE 259           TO BBF-N54-LENGTH           
JGO001*           MOVE 40            TO BBF-N54-CODE
           IF TRBFN-DEST = 153
           THEN
              MOVE "C"           TO BBF-N54-DEVICE-OUT
           ELSE
              MOVE "L"           TO BBF-N54-DEVICE-OUT
           END-IF
           MOVE "*"           TO BBF-N54-SWITCHING
           MOVE SPACE         TO BBF-N54-PRIORITY
JGO001*           IF TRBFN-DEST = 141
JGO001*           THEN
JGO001*              MOVE "541004"      TO BBF-N54-NAME
JGO001*              MOVE 116           TO BBF-N54-DESTINATION
JGO001*           ELSE
JGO001*              MOVE "500004"      TO BBF-N54-NAME
JGO001*              MOVE TRBFN-DEST    TO BBF-N54-DESTINATION
JGO001*           END-IF
JGO001     EVALUATE TRBFN-TYPE-COMPTA
JGO001         WHEN 03 MOVE "500074" TO BBF-N54-NAME
JGO001                 MOVE 43       TO BBF-N54-CODE
JGO001                 MOVE 151      TO BBF-N54-DESTINATION
JGO001         WHEN 04 MOVE "500094" TO BBF-N54-NAME
JGO001                 MOVE 151      TO BBF-N54-DESTINATION
JGO001                 MOVE 43       TO BBF-N54-CODE
JGO001         WHEN 05 MOVE "500064" TO BBF-N54-NAME
JGO001                 MOVE 43       TO BBF-N54-CODE
JGO001                 MOVE 151      TO BBF-N54-DESTINATION
JGO001         WHEN 06 MOVE "500084" TO BBF-N54-NAME
JGO001                 MOVE 151      TO BBF-N54-DESTINATION
JGO001                 MOVE 43       TO BBF-N54-CODE
JGO001*        WHEN OTHER MOVE "500004" TO BBF-N54-NAME
JGO001         WHEN OTHER MOVE 40       TO BBF-N54-CODE
CDU001                    IF TRBFN-DEST = 141
CDU001                       MOVE 116           TO BBF-N54-DESTINATION
CDU001                       MOVE "541004"      TO BBF-N54-NAME
CDU001                    ELSE
CDU001                       MOVE TRBFN-DEST    TO BBF-N54-DESTINATION
CDU001                       MOVE "500004"      TO BBF-N54-NAME
CDU001                   END-IF
JGO001     END-EVALUATE.

           MOVE SPACES           TO BBF-N54-KEY
      *     MOVE TRBFN-DEST       TO BBF-N54-VERB
           MOVE TRBFN-CONSTANTE  TO BBF-N54-KONST
                                    BBF-N54-KONSTA
           MOVE TRBFN-NO-SUITE   TO BBF-N54-VOLGNR
                                    BBF-N54-VOLGNR-M30
           MOVE ADM-TAAL         TO BBF-N54-TAAL
      *     MOVE TRBFN-DEST       TO BBF-N54-VBOND
           MOVE TRBFN-BETWYZ     TO BBF-N54-BETWYZ
279363     MOVE WS-RIJKSNUMMER   TO BBF-N54-RNR
           MOVE TRBFN-MONTANT    TO BBF-N54-BEDRAG
EURO       MOVE TRBFN-MONTANT-DV TO BBF-N54-DV
EURO       IF TRBFN-MONTANT-DV = "E"
EURO          MOVE 2 TO BBF-N54-DN
EURO       ELSE
EURO          MOVE 0 TO BBF-N54-DN
EURO       END-IF
           MOVE TRBFN-CODE-LIBEL TO BBF-N54-BETKOD
IBAN10     MOVE ZEROES           TO BBF-N54-REKNR
MTU        MOVE ZEROES TO BBF-N54-INF
MTU        MOVE ZEROES TO BBF-N54-INF-VOL
MTU        MOVE ZEROES TO BBF-N54-PREST
MTU        MOVE ZEROES TO BBF-N54-SPEC
MTU        MOVE ZEROES TO BBF-N54-AANT
MTU        MOVE ZEROES TO BBF-N54-DATE
MTU        MOVE ZEROES TO BBF-N54-HONOR
MTU        MOVE SPACES TO BBF-N54-RNR2
IBAN10     MOVE TRBFN-IBAN       TO BBF-N54-IBAN
CDU001     EVALUATE TRBFN-TYPE-COMPTA
CDU001         WHEN 3
CDU001                MOVE 1 TO BBF-N54-TAGREG-OP
CDU001                MOVE 167 TO BBF-N54-VERB BBF-N54-VBOND
CDU001         WHEN 4
CDU001                MOVE 2 TO BBF-N54-TAGREG-OP
CDU001                MOVE 169 TO BBF-N54-VERB BBF-N54-VBOND
CDU001         WHEN 5
CDU001                MOVE 4 TO BBF-N54-TAGREG-OP
CDU001                MOVE 166 TO BBF-N54-VERB BBF-N54-VBOND
CDU001         WHEN 6
CDU001                MOVE 7 TO BBF-N54-TAGREG-OP
CDU001                MOVE 168 TO BBF-N54-VERB BBF-N54-VBOND
CDU001         WHEN OTHER
CDU001                MOVE 9 TO BBF-N54-TAGREG-OP
CDU001                MOVE TRBFN-DEST TO BBF-N54-VERB BBF-N54-VBOND
CDU001     END-EVALUATE
           COPY ADLOGDBD           
               REPLACING LOGT1-REC BY BFN54GZR .
           .
      *----------------------------------------------------------------
      **** CREER-REMOTE-500006 ***
      *----------------------------------------------------------------
       CREER-REMOTE-500006.
      *********************
           PERFORM RECH-NO-BANCAIRE
           IF SAV-IBAN NOT = TRBFN-IBAN
           THEN                
IBAN10*        MOVE 241           TO BBF-N56-LENGTH
CDU001        MOVE 258           TO BBF-N56-LENGTH
              MOVE 40            TO BBF-N56-CODE
              IF TRBFN-DEST = 153
              THEN
                 MOVE "C"           TO BBF-N56-DEVICE-OUT
              ELSE
                 MOVE "L"           TO BBF-N56-DEVICE-OUT
              END-IF
              MOVE "*"           TO BBF-N56-SWITCHING
              MOVE SPACE         TO BBF-N56-PRIORITY
JGO001*              IF TRBFN-DEST = 141
JGO001*              THEN
JGO001*                 MOVE "541006"      TO BBF-N56-NAME
JGO001*                 MOVE 116           TO BBF-N56-DESTINATION
JGO001*              ELSE
JGO001*                 MOVE "500006"      TO BBF-N56-NAME
JGO001*                 MOVE TRBFN-DEST    TO BBF-N56-DESTINATION
JGO001*              END-IF
JGO001         EVALUATE TRBFN-TYPE-COMPTA
JGO001             WHEN 03 MOVE "500076" TO BBF-N56-NAME
JGO001                     MOVE 43       TO BBF-N56-CODE
JGO001                     MOVE 151      TO BBF-N56-DESTINATION
JGO001             WHEN 04 MOVE "500096" TO BBF-N56-NAME
JGO001                     MOVE 151      TO BBF-N56-DESTINATION
JGO001                     MOVE 43       TO BBF-N56-CODE
JGO001             WHEN 05 MOVE "500066" TO BBF-N56-NAME
JGO001                     MOVE 43       TO BBF-N56-CODE
JGO001                     MOVE 151      TO BBF-N56-DESTINATION
JGO001             WHEN 06 MOVE "500086" TO BBF-N56-NAME
JGO001                     MOVE 151      TO BBF-N56-DESTINATION
JGO001                     MOVE 43       TO BBF-N56-CODE
JGO001*            WHEN OTHER MOVE "500006" TO BBF-N56-NAME
JGO001             WHEN OTHER MOVE 40       TO BBF-N56-CODE
CDU001                    IF TRBFN-DEST = 141
CDU001                       MOVE 116           TO BBF-N56-DESTINATION
CDU001                       MOVE "541006"      TO BBF-N56-NAME
CDU001                    ELSE
CDU001                       MOVE TRBFN-DEST    TO BBF-N56-DESTINATION
CDU001                       MOVE "500006"      TO BBF-N56-NAME
CDU001                    END-IF
JGO001         END-EVALUATE

              MOVE SPACES           TO BBF-N56-KEY
      *        IF TRBFN-TYPE-COMPTA = 1
      *        THEN
      *           MOVE 2 TO BBF-N56-AFK
      *        ELSE
      *           MOVE 3 TO BBF-N56-AFK
      *        END-IF
CDU001*        EVALUATE TRBFN-TYPE-COMPTA
CDU001*           WHEN 1 MOVE 2 TO BBF-N56-AFK
CDU001*           WHEN 2 MOVE 3 TO BBF-N56-AFK
CDU001*           WHEN 3 MOVE 4 TO BBF-N56-AFK
CDU001*           WHEN 4 MOVE 5 TO BBF-N56-AFK
CDU001*           WHEN 5 MOVE 6 TO BBF-N56-AFK
CDU001*           WHEN 6 MOVE 7 TO BBF-N56-AFK
CDU001*        END-EVALUATE
CDU001        IF TRBFN-TYPE-COMPTA = 1 OR 3 OR 4 OR 5 OR 6
CDU001           MOVE 2 TO BBF-N56-AFK
CDU001        ELSE  
CDU001           MOVE 3 TO BBF-N56-AFK
CDU001     END-IF
CDU001     
      
      *        MOVE TRBFN-DEST       TO BBF-N56-VERB
              MOVE TRBFN-CONSTANTE  TO BBF-N56-KONST
              MOVE TRBFN-NO-SUITE   TO BBF-N56-VOLGNR
279363        MOVE WS-RIJKSNUMMER   TO BBF-N56-RNR
              MOVE ADM-NAAM         TO BBF-N56-NAAM
              MOVE ADM-VOORN        TO BBF-N56-VOORN
              MOVE TRBFN-MONTANT    TO BBF-N56-BEDRAG
EURO          MOVE TRBFN-MONTANT-DV TO BBF-N56-DV
EURO          IF TRBFN-MONTANT-DV = "E"
EURO             MOVE 2 TO BBF-N56-DN
EURO          ELSE
EURO             MOVE 0 TO BBF-N56-DN
EURO          END-IF
              MOVE TRBFN-CODE-LIBEL TO BBF-N56-LIBEL
IBAN10        IF TRBFN-IBAN NOT = SPACES
              THEN
IBAN10           MOVE SPACES      TO BBF-N56-IBAN
IBAN10           MOVE SPACES      TO BBF-N56-REKNR
IBAN10           MOVE TRBFN-IBAN  TO BBF-N56-IBAN
              ELSE
IBAN10           MOVE SPACES    TO BBF-N56-REKNR
IBAN10           MOVE SPACES    TO BBF-N56-IBAN
              END-IF
IBAN10        IF SAV-IBAN NOT = SPACES
              THEN
IBAN10           MOVE SPACES      TO BBF-N56-IBAN-MUT
IBAN10           MOVE SPACES      TO BBF-N56-REKNR-MUT
IBAN10           MOVE SAV-IBAN    TO BBF-N56-IBAN-MUT
              ELSE
IBAN10           MOVE SPACES    TO BBF-N56-REKNR-MUT
IBAN10           MOVE SPACES    TO BBF-N56-IBAN-MUT
              END-IF
IBAN10        MOVE TRBFN-BETWYZ     TO BBF-N56-BETWY
CDU001        EVALUATE TRBFN-TYPE-COMPTA
CDU001            WHEN 3
CDU001                MOVE 1 TO BBF-N56-TAGREG-OP
CDU001                MOVE 167 TO BBF-N56-VERB
CDU001            WHEN 4
CDU001                MOVE 2 TO BBF-N56-TAGREG-OP
CDU001                MOVE 169 TO BBF-N56-VERB
CDU001            WHEN 5
CDU001                MOVE 4 TO BBF-N56-TAGREG-OP
CDU001                MOVE 166 TO BBF-N56-VERB
CDU001            WHEN 6
CDU001                MOVE 7 TO BBF-N56-TAGREG-OP
CDU001                MOVE 168 TO BBF-N56-VERB
CDU001            WHEN OTHER
CDU001                MOVE 9 TO BBF-N56-TAGREG-OP
CDU001                MOVE TRBFN-DEST TO BBF-N56-VERB
CDU001        END-EVALUATE
MIS01         IF BBF-N56-NAME NOT = "541006"
MIS01            COPY ADLOGDBD REPLACING LOGT1-REC BY BFN56CXR .
MIS01         END-IF
           END-IF
           .
      *----------------------------------------------------------------
      **** RECH-NO-BANCAIRE ***
      *----------------------------------------------------------------
       RECH-NO-BANCAIRE.
      ******************
IBAN10     MOVE SPACES TO SAV-IBAN
      *----------------------------------------------------------------
      *TEST AGE (16 - 14 ANS MIN)
      *----------------------------------------------------------------
           MOVE ZEROES TO SW-TROP-JEUNE
Y2000M     MOVE TRBFN-RNR  TO WS-RNREBC
           MOVE WS-RNREBC-YY TO WS-DATEBC-YY-1
           MOVE WS-RNREBC-MM TO WS-DATEBC-MM-1
Y2000R     MOVE WS-RNREBC-DD TO WS-DATEBC-DD-1
           COPY RREBBXDD.
           IF WS-STAT1 = ZEROES
              MOVE WS-RNREBCDIC-CC TO WS-DATEBC-CC-1
           END-IF
           IF WS-RNREBC-MAN
           THEN
              MOVE 16 TO WS-DATEBC-CONSTANT
           ELSE
              MOVE 14 TO WS-DATEBC-CONSTANT
           END-IF
           .
           COPY DWYERXDD .
           IF WS-DATEBC-2 > SP-ACTDAT
           THEN
              MOVE 1 TO SW-TROP-JEUNE
           END-IF
           IF SW-TROP-JEUNE = ZEROES
           THEN
              PERFORM RECHERCHE-CPTE-MEMBRE
           ELSE
              COPY LIDVZASD .
              IF LIDVZ-STATUS = 2
              THEN
                 MOVE SPACES TO WS-RNREBC
      *----------------------------------------------------------------
      *RECHERCHE TITULAIRE
      *----------------------------------------------------------------
                 PERFORM WITH TEST BEFORE VARYING
                 I FROM 1 BY 1 UNTIL I > 3
                    IF
                    LIDVZ-OP-DATINS (I) NOT = ZEROES AND
                    LIDVZ-OP-KOD1   (I) NOT < 600    AND
                    LIDVZ-OP-KOD1   (I)     < 700    AND
                    LIDVZ-OP-KOD1   (I) NOT = 609    AND
                    LIDVZ-OP-KOD1   (I) NOT = 659    AND
                    LIDVZ-OP-KOD1   (I) NOT = 679    AND
                    LIDVZ-OP-KOD1   (I) NOT = 689
                    THEN
                       MOVE LIDVZ-OP-RNRTIT2 (I) TO WS-RNREBC
                    END-IF
                 END-PERFORM
                 IF WS-RNREBC NOT = SPACES AND NOT = ZEROES
                 THEN
                    MOVE RNRBIN TO SAV-RNRBIN
      *
                    MOVE ZEROES TO WS-STAT1
                                   STAT1
      *----------------------------------------------------------------
      *SEARCH-LID DU TITULAIRE
      *----------------------------------------------------------------
                    COPY RREBBXDD .
                    IF WS-STAT1 NOT = ZEROES
                    THEN
                       MOVE "ERROR CONVERT RNR" TO BTMMSG
                       PERFORM PPRNVW
                    ELSE
                       MOVE WS-RNRBIN TO RNRBIN
                       PERFORM SCH-LID
                       IF STAT1 NOT = ZEROES AND NOT = 4
                       THEN
                          MOVE "ERROR SCHLID RNR" TO BTMMSG
                          PERFORM PPRNVW
                       END-IF
                    END-IF
                    PERFORM RECHERCHE-CPTE-MEMBRE
                    MOVE SAV-RNRBIN TO RNRBIN
                    MOVE 1 TO GETTP
                    PERFORM GET-ADM
                 END-IF
              END-IF
           END-IF
           .
      *----------------------------------------------------------------
      **** RECHERCHE-CPTE-MEMBRE ***
      *----------------------------------------------------------------
       RECHERCHE-CPTE-MEMBRE.
      ***********************
           MOVE TRBFN-CODE-LIBEL TO SCHRK-CODE-LIBEL
           MOVE ZEROES           TO SCHRK-BKF-TIERS
           MOVE SP-ACTDAT        TO SCHRK-DAT-VAL
           MOVE TRBFN-DEST       TO SCHRK-FED
IBAN10     COPY SEPAKCXD .
           IF SCHRK-STATUS NOT = ZEROES AND NOT = 1
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR ROUTINE SCHRKCX9 STATUS : "
                                          DELIMITED BY SIZE
                     SCHRK-STATUS         DELIMITED BY SIZE
                      INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           IF SCHRK-STATUS = ZEROES
           THEN
IBAN10        MOVE SCHRK-IBAN   TO SAV-IBAN
           ELSE
IBAN10        MOVE SPACES TO SAV-IBAN
           END-IF
           .

       P-RECHERCHE-TYPE-COMPTE.
      *************************
              MOVE RNRBIN TO SAV-RNRBIN
              ADD 6000000 TRBFN-DEST GIVING RNRBIN
              PERFORM SCH-LID08
              IF STAT1 = ZEROES OR = 4
              THEN
                 MOVE 1 TO GETTP
                 PERFORM GET-PAR
                 PERFORM WITH TEST BEFORE UNTIL
                 STAT1 NOT  = ZEROES OR
                 LIBP-NRLIB = TRBFN-CODE-LIBEL
                    MOVE 2 TO GETTP
                    PERFORM GET-PAR
                 END-PERFORM
              END-IF
              MOVE SAV-RNRBIN TO RNRBIN
              IF STAT1 = ZEROES
              THEN
                 MOVE LIBP-TYPE-COMPTE TO BBF-N51-TYPE-COMPTE
              END-IF.

IBAN10 WELKE-BANK.
IBAN10******************
IBAN10     MOVE "SEBNKUK9" TO CA--PROG
IBAN10     CALL CA--PROG USING
IBAN10                 USAREA1 SEBNKUKW.

279363 ZOEK-RIJKSNUMMER.
279363     MOVE ALL " " TO WS-RIJKSNUMMER.
279363     IF ADM-RNR2-MUT = " "
279363         MOVE ADM-RNR2 TO WS-RIJKSNUMMER
279363     ELSE
279363         IF ADM-NRNR2-MUT = " "
279363             AND
279363            ADM-NRNR2G NOT = ALL " "
279363             MOVE ADM-NRNR2 TO WS-RIJKSNUMMER
279363         ELSE
279363             MOVE TRBFN-RNR TO WS-RIJKSNUMMER
279363         END-IF
279363     END-IF.


      *----------------------------------------------------------------
      **** ROUTINES ACCES DB MUT ***
      *----------------------------------------------------------------
       PAR-MUT SECTION.
      *****************
       SCH-LID08.
      ***********
           MOVE ZEROES TO STAT1
           COPY SCH08DBD.
           IF STAT1 NOT = ZEROES AND NOT = 4
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR SCH08DBD STAT1 = "   DELIMITED BY SIZE
                     STAT1                        DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           .
      *
       GET-PAR.
      *********
           COPY GTPARDBD.
           IF STAT1 NOT = ZEROES AND NOT = 3
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR GET PAR  STAT1 = "   DELIMITED BY SIZE
                     STAT1                        DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           ELSE
              IF STAT1 = ZEROES
              THEN
                 MOVE PAR-DATA TO LIBPNCXW
              END-IF
           END-IF
           .
       SCH-LID.
      *********
           MOVE ZEROES TO STAT1
           COPY SCHLDDBD .
           IF STAT1 NOT = ZEROES AND NOT = 1 AND NOT = 4
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR SCHLDDBD STAT1 = "   DELIMITED BY SIZE
                     STAT1                        DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           .
      *
       GET-ADM.
      *********
           COPY GTADMDBD .
           IF STAT1 NOT = ZEROES AND NOT = 3
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR GET ADM STAT1 = "   DELIMITED BY SIZE
                     STAT1                       DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           .
      *
       GET-MUT.
      *********
           COPY GTMUTDBD .
           IF STAT1 NOT = ZEROES AND NOT = 3
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR GET MUT STAT1 = "   DELIMITED BY SIZE
                     STAT1                       DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           .
      *
       GET-PTL.
      *********
           COPY GTPTLDBD .
           IF STAT1 NOT = ZEROES AND NOT = 3
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR GET PTL STAT1 = "   DELIMITED BY SIZE
                     STAT1                       DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           .
      *
       GET-BBF.
      *********
           COPY GTBBFDBD .
           IF STAT1 NOT = ZEROES AND NOT = 3
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR GET BBF STAT1 = "   DELIMITED BY SIZE
                     STAT1                       DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           .
      *
       ADD-BBF.
      *********
           COPY ADBBFDBD .
           IF STAT1 NOT = ZEROES
           THEN
              MOVE SPACES TO BTMMSG
              STRING "ERREUR ADD BBF STAT1 = "   DELIMITED BY SIZE
                     STAT1                       DELIMITED BY SIZE
                                 INTO BTMMSG
              END-STRING
              PERFORM PPRNVW
           END-IF
           .
      *
       FIN-BTM.
      *********
           EXIT PROGRAM
           .
           COPY ERMUTDBD .
           COPY BTMPRDBD
           .
