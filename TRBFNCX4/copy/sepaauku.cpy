      ************************************************************
      *   BESCHRIJVING USERRECORD 3N0001,2N0001,5N0001,ENZ
      *   VOOR HET VORMEN VAN DE BANDEN VOOR BAC EN CERA, MET DE
      *   BETALINGEN LANGS FINANCIELE WEG.
      *************************************************************
      * JGO 13/11/2018                                             
      *     6de staatshervorming                                   
      * R224154                                                    
      *   bijvoegen van zone TAGREG-OP TAGREG-LEG achteraan        
      * IDB toevoegen van ALOIS-REF = 5 en 6                       
      * IDB1 toevoegen van ALOIS-REF = 7
      **************************************************************
       01  SEPAAUKU.
           05  REC-LENGTE                    PIC S9(4) COMP.
           05  REC-CODE                      PIC S9(4) COMP.
           05  REC-NUM                       PIC 9(8).
           05  USERCOD                       PIC X(6).
               88  UITKREC VALUE "3N0001".
               88  GEZOREC VALUE "2N0001"
                                 "5N0001"
                                 "9N0001".
               88  VHSREC  VALUE "4N0001".
               88  HOSPREC VALUE "1N0001".
           05  USERFED                       PIC 999.
           05  USERRNR                       PIC S9(8) COMP.
           05  USERMY                        PIC 999.
           05  REC-DV                        PIC X.
           05  FILLER                        PIC X(10).
           05  EIGENL-REC.
               06  KEY2.
                   10  U-BAC-KODE            PIC 9(4).
               06  KEY-REC.
                   08  KEY1.
                       10  WELKEBANK         PIC 9.
                           88  HOOFDBANK VALUE ZERO.
                           88  ALTERNATIEVEBANK VALUE 1.
                       10  KEY4.
                           15  ALOIS-RAF     PIC 9.
                               88  VERGOED        VALUE ZERO.
                               88  BETFIN         VALUE 1.
                               88  REISVERZ       VALUE 2.
                               88  VOORHUW        VALUE 3.
                               88  HOSPVZ         VALUE 4.
                               88  EATTEST        VALUE 5.
                               88  CORREG         VALUE 6.
                               88  BULK-INPUT     VALUE 7.
                               88  AFHOUDING-GEZO VALUE 8.
                           15  VRBOND        PIC 999.
                   08  KEY3.
                       10  TAAL              PIC 9.
                       10  BAC-DATM61        PIC 9(8).
                       10  RIJKSNR.
                           15  EEUW          PIC 99.
                           15  RESTNR        PIC X(13).
                       10  REFNR REDEFINES RIJKSNR.
                           15  FILLER        PIC XX.
                           15  REF           PIC 9(13).
               06  REST-REC.
                   10  U-ACTDAT              PIC 9(8).
      ************************************************************
      *    GEGEVENS UIT DE BNK-RECORD.
      ************************************************************
                   10  FILLER                PIC X(12).
                   10  U-BNK-ADRES.
                       15  U-BNK-REKHOUDER   PIC X(30).
                       15  U-BNK-LND         PIC XXX.
                       15  U-BNK-POSTNR      PIC S9(8) COMP.
                       15  U-BNK-GEM         PIC X(15).
      ************************************************************
      *    NAAM , ADRES VAN DE ZIEKE- OF VAN GEDEELTELIJK VERGOEDE
      ************************************************************
                   10  U-ADM-ADRES.
                       15  U-ADM-NAAM-VNAAM.
                           20  U-ADM-NAAM    PIC X(18).
                           20  U-ADM-VNAAM   PIC X(12).
                       15  U-ADM-STR         PIC X(21).
                       15  U-ADM-HUIS        PIC S9(4) COMP.
                       15  U-ADM-INDEX       PIC XXX.
                       15  U-ADM-BUS         PIC 9(4).
                       15  U-ADM-LND         PIC XXX.
                       15  U-ADM-POST        PIC S9(8) COMP.
                       15  U-ADM-GEM         PIC X(15).
      ************************************************************
                   10  COMMENTAAR            PIC X(106).
                   10  COMMENTUITK REDEFINES COMMENTAAR.
                       15  BERICHT           PIC 9.
                       15  DAT-BERICHT       PIC 9(8).
                       15  DATVAN            PIC 9(8).
                       15  DATTOT            PIC 9(8).
                       15  BAC-VGD           PIC 999.
                       15  BAC-DBDR          PIC 9(4).
                       15  GUTKOM            PIC X(18).
                       15  GUTINDIKATIE      PIC X.
                       15  NAAMZIEKE         PIC X(18).
                       15  VNAAMZIEKE.
                           20  VNGEWOON.
                               30  VNCQ      PIC X.
                               30  FILLER    PIC X(9).
                           20  FILLER        PIC XX.
                       15  BAC-VADADO        PIC X.
                       15  BAC-DBDR-U        PIC X(5).
                       15  FILLER            PIC X(19).
                   10  KOM-GESTRUK-MEDE REDEFINES COMMENTAAR.
                       15  GESTRUK-MEDE      PIC X(12).
                       15  FILLER            PIC X(94).
                   10  KOM-GEZO-BANK REDEFINES COMMENTAAR.
                       15  TEKST-GROOT       PIC X(53).
                       15  TEKST-KENMERK     PIC X(9).
                       15  REF-NUMMER        PIC 9(10).
                       15  FILLER            PIC X.
                       15  VOLG-NUMMER       PIC 9(4).
                       15  FILLER            PIC X.
                       15  OMSCHRIJVING1     PIC X(14).
                       15  OMSCHRIJVING2     PIC X(14).
                   10  KOM-GEZO-POST REDEFINES COMMENTAAR.
                       15  ROF-JEF           PIC X(28).
                       15  TEKST-KLEIN       PIC X(28).
                       15  OMSCHRIJVING-P    PIC X(14).
                       15  REFNUMMER-P       PIC 9(10).
                       15  VOLGNUMMER-P      PIC 9(4).
                       15  FILLER            PIC X(22).
                   10  BEDRAGEN-UITK.
                       15  DOSSIER           PIC S9(8) COMP.
                       15  UITGIFTE          PIC 9(8).
                       15  NETBEDRAG         PIC S9(8) COMP.
                       15  BDR-C21           PIC S9(8) COMP.
                       15  BDR-C23           PIC S9(8) COMP.
                       15  BDR-PIAR          PIC S9(8) COMP.
                       15  BDR-PI23          PIC S9(8) COMP.
                       15  BDR-MIP           PIC S9(8) COMP.
                       15  BDR-C421          PIC S9(8) COMP.
                       15  BDR-PIZLF         PIC S9(8) COMP.
                       15  BDR-RWP           PIC S9(8) COMP.
                       15  BDR-GUT           PIC S9(8) COMP.
                       15  BDR-PI3           PIC S9(8) COMP.
                       15  BDR-C423          PIC S9(8) COMP.
                       15  BDR-PI423         PIC S9(8) COMP.
                       15  BDR-B23           PIC S9(8) COMP.
                       15  BDR-VH            PIC S9(8) COMP.
                   10  GEG-VHSP REDEFINES BEDRAGEN-UITK.
                       15  FILLER            PIC X(12).
                       15  VHSNET            PIC S9(8) COMP.
                       15  VHSNRM61          PIC 9(3).
                       15  VHSBETM61         PIC 9(4).
                       15  VHS-NRBANK        PIC 9(12).
                       15  FILLER            PIC X(33).
                   10  FILLER                PIC X(20).
                   10  CODE-GESTRUK-MEDE     PIC X.
                       88  MEDE-101 VALUE "1".
                   10  U-IBAN                PIC X(34).
                   10  U-BIC                 PIC X(11).
                   10  U-BETWYZ              PIC X.
                       88  INHOUDING    VALUE "A".
                       88  BANK         VALUE "B".
                       88  DEBT_MLCD_NA VALUE "C".
                       88  CRED_MLCD_CR VALUE "D".
                       88  DEBT_MLDB_NA VALUE "E".
                       88  CRED_MLDB_CR VALUE "F".
224154             10  TAG-REG-OP            PIC  X(02).
224154             10  TAG-REG-LEG           PIC  X(02).
