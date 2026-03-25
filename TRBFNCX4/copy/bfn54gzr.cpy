      *01  GRBBFN54.
       01  BFN54GZR.
      **************************************************************
      *                                                            *
      *  REKORD : G R B B F N 5 4                                  *
      *                                                            *
      *  INPUT-REKORD VOOR REMOTE         : G 8 G R 5 0 0 4        *
      *                                                            *
      *  DEZE REKORD DIENT VOOR HET AFDRUKKEN VAN DE               *
      *  VERWERPINGEN OPGESPOORD TIJDENS DE BTM.                   *
      *                                                            *
      *  OMSCHRIJVING :                                            *
      *  BBF-N54-LENGTH :                                          *
      *  BBF-N54-CODE   : REKORDKODE = 40                          *
      *  BBF-N54-NUMBER : VOLGNUMMER UIT ADD-LOG                   *
      *  BBF-N54-DEVICE-OUT : 'L'                                  *
      *  BBF-N54-DESTINATION : VERBOND 106                         *
      *  BBF-N54-SWITCHING : BLANK                                 *
      *  BBF-N54-PRIORITY : 'Z'                                    *
      *  BBF-N54-NAME   : NEP-NAME '500004'                        *
      *  BBF-N54-KEY    :                                          *
      *      BBF-N54-VERB : VERBONDSNUMMER VOOR BRUSSEL 106        *
      *      BBF-N54-KONST : KONSTANTE                             *
      *      BBF-N54-VOLGNRA : VOLGNUMMER M30                      *
      *      BBF-N54-TAAL : TAAL LID                               *
      *  BBF-N54-DATA   :                                          *
      *                                                            *
      *      BBF-N54-VBOND : VERBONDSNUMMER                        *
      *      BBF-N54-KONST : KONSTANTE                             *
      *      BBF-N54-AFDEL : AFDELINGSNUMMER                       *
      *      BBF-N54-KASSIER : NUMMER KASSIER                      *
      *      BBF-N54-DATZIT-DM: DATUM ZITTING                      *
      *      BBF-N54-BETWYZ : RESIDUAIRE BETALINGSWIJZE :          *
      *                      VOOR BRUSSEL : KARAKTER "C" VOOR      *
      *                         CIRCULAIRE CHECK.                  *
      *      BBF-N54-RNR : RIJKSNUMMER                             *
      *      BBF-N54-BETKOD : REDEN VAN BETALING : "26"            *
      *      BBF-N54-BEDRAG : BEDRAG (MAX. 50000 FR)               *
      *      BBF-N54-REKNR : REKENINGNUMMER WAAROP TE BETALEN      *
      *                         (EVENTUEEL 12 NULLEN)              *
      *      BBF-N54-VOLGNR-M30:VOLGNUMMER M30                     *
      *      BBF-N54-DIAG  : FOUTDIAGNOSE                          *
      *                                                            *
MTU   * MODIFICATION PROJET : INFOREK                              *
MTU   *                                                            *
      **************************************************************
      **************************************************************
      * JGO 15/10/2018                                             *
      *     6de staatshervorming                                   *
      * R224154                                                    *
      ************************************************************** 
      *    05  BBF-N54-LENGTH            PIC 9(04)  COMP.
           05  BBF-N54-LENGTH            PIC S9(04)  COMP.
           05  BBF-N54-CODE              PIC S9(04) COMP.
           05  BBF-N54-NUMBER            PIC 9(08).
           05  BBF-N54-DEVICE-OUT        PIC X.
           05  BBF-N54-DESTINATION       PIC 9(03).
           05  BBF-N54-SWITCHING         PIC X.
           05  BBF-N54-PRIORITY          PIC X.
           05  BBF-N54-NAME              PIC X(06).
           05  BBF-N54-KEY.
               10  BBF-N54-VERB          PIC 9(03).
               10  BBF-N54-KONSTA        PIC 9(10).
               10  BBF-N54-VOLGNR        PIC 9(04).
               10  BBF-N54-TAAL          PIC 9.
MTU   *        10  FILLER                PIC X(62).
MTU            10  BBF-N54-INF           PIC 9.
MTU            10  BBF-N54-INF-VOL       PIC 9(02).
MTU            10  FILLER                PIC X(59).
           05  BBF-N54-DATA.
               10 BBF-N54-VBOND          PIC 9(02).
               10 BBF-N54-KONST.
                   20 BBF-N54-AFDEL      PIC 9(03).
                   20 BBF-N54-KASSIER    PIC 9(03).
                   20 BBF-N54-DATZIT-DM  PIC 9(04).
               10 BBF-N54-BETWYZ         PIC X(01).
               10 BBF-N54-RNR            PIC X(13).
               10 BBF-N54-BETKOD         PIC 9(02).
               10 BBF-N54-BEDRAG         PIC 9(08).
               10 BBF-N54-REKNUM         PIC 9(12).
               10 BBF-N54-REKNR REDEFINES BBF-N54-REKNUM.
                   20 BBF-N54-REKNR-PART1 PIC 9(03).
                   20 BBF-N54-REKNR-PART2 PIC 9(07).
                   20 BBF-N54-REKNR-PART3 PIC 9(02).
               10 BBF-N54-VOLGNR-M30     PIC 9(03).
           05  BBF-N54-DIAG              PIC X(32).
           05  FILLER                    PIC 9(03).
           05  BBF-N54-DV                PIC X.
           05  BBF-N54-DN                PIC 9.
MTU        05  BBF-N54-INF0.
MTU            10  BBF-N54-PREST         PIC 9.
MTU            10  BBF-N54-SPEC          PIC 9(03).
MTU            10  BBF-N54-AANT          PIC 9(02).
MTU            10  BBF-N54-DATE          PIC 9(06).
MTU            10  BBF-N54-HONOR         PIC 9(06).
MTU            10  BBF-N54-RNR2          PIC X(13).
SEPA       05  BBF-N54-IBAN              PIC  X(34).
224154     05  BBF-N54-TAGREG-OP         PIC  9(02).
