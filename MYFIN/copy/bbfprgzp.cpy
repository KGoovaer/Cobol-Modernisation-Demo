       01 BBFPRGZP.
      **************************************************************
      *                                                            *
      *  REKORD : B B F P R G Z P                                  *
      *                                                            *
      *  INPUT-REKORD VOOR BTM-PROGRAMMA  : B B F P R G Z 4        *
      *                                                            *
      *  DEZE REKORD DIENT VOOR HET VERWERKEN VAN DE BETALINGEN    *
      *  VIA FINANCIELE WEG, DIE ONS BEREIKEN VIA HET SYSTEEM      *
      *  MAGNEETBANDUITWISSELING-BETFIN VANUIT CASSETTE-VERWER-    *
      *  KING KONTANTE BETALINGEN VOOR HET VERBOND BRUSSEL.        *
      *                                                            *
      *  OMSCHRIJVING :                                            *
      *  BF-LENGTH        : LENGTE VAN DE REKORD = 106 KARAKTERS   *
      *                     BF-LENGTH, BF-CODE EN BF-NUMBER        *
      *                     WORDEN IN DE TOTALE LENGTE VAN DE      *
      *                     REKORD NIET OPGETELD                   *
      *  BF-CODE          : REKORDKODE = 42                        *
      *  BF-NUMBER        : VOLGNUMMER VAN DE REKORD VANAF 1       *
      *  BF-PPR-NAME      : NAAM VAN DE PPR = "PPRBBF"             *
      *  BF-PPR-FED       : VERBOND                                *
      *  BF-PPR-RNR       : RIJKSNUMMER IN BINAIR                  *
      *  BF-DATA          :                                        *
      *                                                            *
      *                                                            *
      *      BF-VBOND         : VERBONDSNUMMER                     *
      *      BF-AFDEL         : AFDELINGSNUMMER                    *
      *      BF-KASSIER       : NUMMER KASSIER                     *
      *      BF-DATZIT-DM     : DATUM ZITTING  DDMM                *
      *      BF-BETWYZ        : RESIDUAIRE BETALINGSWIJZE :        *
      *                         VOOR BRUSSEL : KARAKTER "C" VOOR   *
      *                         CIRCULAIRE CHECK.                  *
      *      BF-RNR           : RIJKSNUMMER                        *
      *      BF-BETKOD        : REDEN VAN BETALING                 *
      *      BF-BEDRAG        : BEDRAG (MAX. 50000 FR)             *
      *      BF-REKNR         : REKENINGNUMMER WAAROP TE BETALEN   *
      *                         (EVENTUEEL 12 NULLEN)              *
      *      BF-VOLGNR-M30    : VOLGNUMMER M30                     *
      *      BF-OMSCHR1       : OMSCHRIJVING 1                     *
      *      BF-OMSCHR2       : OMSCHRIJVING 2                     *
      *                                                            *
      *      TOEVOEGEN NIEUWE ZONES VOOR MAFBETALINGEN VANAF 2005  *
      *      BF-CODE-MAF      : CODE BETALING MAF   PIC X(01)      *
      *      BF-JAAR-MAF      : JAAR BETALING MAF   PIC 9(04)      *
      *                                                            *
      **************************************************************
      * 2010.10.14 JGO SEPA                                        *
      * LENGTH      : 152/140                                      *      
      **************************************************************      
      * 2010.10.24 MIS SEPA                                        *
      * LENGTH      : 192/180                                      *      
      **************************************************************
      * JGO 15/10/2018                                             *
      *     6de staatshervorming                                   *
      * R224154                                                    *
      **************************************************************      
      *    05  BF-LENGTH                 PIC 9(04)  COMP.
           05  BF-LENGTH                 PIC S9(04)  COMP.
           05  BF-CODE                   PIC S9(04) COMP.
           05  BF-NUMBER                 PIC 9(08).
           05  BF-PPR-NAME               PIC X(06).
           05  BF-PPR-FED                PIC 9(03).
      *    05  BF-PPR-RNR                PIC 9(09)  COMP.
           05  BF-PPR-RNR                PIC S9(08)  COMP.
           05  BF-DATA.
               10 BF-VBOND               PIC 9(02).
               10 BF-KONST.
                   20 BF-AFDEL           PIC 9(03).
      *
      *  VVE 26/11/98 : SUPPRESION BVR
      *
      *               88 BRUGGE-BVR VALUE 006 016 026
      *                                   036 046 056
      *                                   066 076 086
      *                                   096.
                   20 BF-KASSIER         PIC 9(03).
                   20 BF-DATZIT-DM       PIC 9(04).
               10 BF-BETWYZ              PIC X(01).
               10 BF-RNR                 PIC X(13).
               10 BF-BETKOD              PIC 9(02).
               10 BF-BEDRAG              PIC 9(05).
               10 BF-BEDRAG-RMG REDEFINES BF-BEDRAG PIC 9(09) COMP.
               10 BF-REKNUM              PIC 9(12).
               10 BF-REKNR REDEFINES BF-REKNUM.
                   20 BF-REKNR-PART1     PIC 9(03).
                   20 BF-REKNR-PART2     PIC 9(07).
                   20 BF-REKNR-PART3     PIC 9(02).
               10 BF-VOLGNR-M30          PIC 9(03).
               10 BF-OMSCHR1             PIC X(14).
               10 BF-OMSCHR1R REDEFINES BF-OMSCHR1.
                  20 BF-GESTRUK-MEDE     PIC X(12).
                  20 FILLER              PIC X(2).
               10 BF-OMSCHR2             PIC X(14).
               10 FILLER                 PIC 9(03).
               10 BF-BEDRAG-EUR          PIC 9(08).
               10 BF-BEDRAG-RMG-EUR REDEFINES
                         BF-BEDRAG-EUR   PIC 9(11) COMP.
               10 BF-BEDRAG-DV           PIC X(01).
               10 BF-BEDRAG-RMG-DV  REDEFINES
                         BF-BEDRAG-DV    PIC X(01).
               10 BF-CODE-MAF            PIC X(01).
               10 BF-JAAR-MAF            PIC 9(04).
               10 BF-JAAR-MAF-X REDEFINES BF-JAAR-MAF
                                         PIC X(04).
               10 BF-IBAN                PIC X(34).
               10 BF-OMSCHR3             PIC X(40).
224154         10  BF-TAGREG-OP          PIC  9(02).
224154         10  BF-TAGREG-LEG         PIC  9(02).                          
