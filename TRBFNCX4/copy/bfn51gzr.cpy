      **********************************************************
      *                                                        *
      *  BBF-N51 : REMOTE PRINTING RECORD OUTPUT ** GBBF1 **   *
      *                        INPUT ** GR5001 **              *
      *                                                        *
MTU   * MODIFICATION PROJET : INFOREK                          *
MTU   *                                                        *
      **********************************************************
      **************************************************************
      * JGO 15/10/2018                                             *
      *     6de staatshervorming                                   *
      * R224154                                                    *
      ************************************************************** 
MSA001* MSA001 26/07/2023 JIRA-4334                                *
MSA001*     CORREG BIJVOEGEN                                       *
MSA001**************************************************************
MSA002* MSA002 23/01/2025 JIRA-891                                 *
MSA002*     CORREG BIJVOEGEN                                       *
MSA002**************************************************************
      *01  GUBBFN51.
       01  BFN51GZR.
      *    05  BBF-N51-LENGTH          PIC 9(4)    COMP.
           05  BBF-N51-LENGTH          PIC S9(4)    COMP.
           05  BBF-N51-CODE            PIC S9(4)   COMP.
           05  BBF-N51-NUMBER          PIC 9(8).
           05  BBF-N51-DEVICE-OUT      PIC X.
           05  BBF-N51-DESTINATION     PIC 999.
           05  BBF-N51-SWITCHING       PIC X.
           05  BBF-N51-PRIORITY        PIC X.
           05  BBF-N51-NAME            PIC X(6).
           05  BBF-N51-KEY.
               10  BBF-N51-VERB        PIC 999.
               10  BBF-N51-AFK         PIC 9(01).
                   88  LOKET           VALUE 1.
                   88  PAIFIN-AO       VALUE 2.
                   88  PAIFIN-AL       VALUE 3.
                   88  FRANCHISE       VALUE 4.
EATT               88  EATTEST         VALUE 5.  
MSA001             88  CORREG          VALUE 6.   
MSA002             88  BULK-INPUT      VALUE 7.
               10  BBF-N51-KONST       PIC 9(10).
               10  BBF-N51-VOLGNR      PIC 9(4).
MTU   *        10  FILLER              PIC X(62).
MTU            10  BBF-N51-INFOREK     PIC 9(01).
MTU            10  FILLER              PIC X(61).
           05  BBF-N51-DATA.
               10  BBF-N51-RNR         PIC X(13).
               10  BBF-N51-NAAM        PIC X(18).
               10  BBF-N51-VOORN       PIC X(12).
               10  BBF-N51-LIBEL       PIC 99.
MTU   *        10  BBF-N51-REKNR       PIC 9(14).
MTU            10  BBF-N51-REKNR       PIC X(14).
               10  BBF-N51-BEDRAG      PIC 9(6).
               10  BBF-N51-BANK        PIC 9(01).
                   88  BACCOB          VALUE 1.
                   88  CERA            VALUE 2.
                   88  BVR             VALUE 3.
           05  BBF-N51-DV                PIC X.
           05  BBF-N51-DN                PIC 9.
MTU1       05  BBF-N51-TYPE-COMPTE     PIC X(04).
SEPA       05  BBF-N51-IBAN            PIC  X(34).
SEPA       05  BBF-N51-BETWY           PIC  X(01).
224154     05  BBF-N51-TAGREG-OP       PIC  9(02).
