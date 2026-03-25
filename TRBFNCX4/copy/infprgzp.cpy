       01 INFPRGZP.
      **************************************************************
      *                                                            *
      *  REKORD : I N F P R G Z P                                  *
      *                                                            *
      *  INPUT-REKORD VOOR BTM-PROGRAMMA  : I N F P R C X 4        *
      **************************************************************
      *  MIS001 221110 : ADAPTATIONS POUR SEPA (IBAN)              *
      **************************************************************
      * JGO 15/10/2018                                             *
      *     6de staatshervorming                                   *
      * R224154                                                    *
      **************************************************************
           05  IN-LENGTH                       PIC S9(04)  COMP.
           05  IN-CODE                         PIC S9(04) COMP.
           05  IN-NUMBER                       PIC 9(08).
           05  IN-PPR-NAME                     PIC X(06).
           05  IN-PPR-FED                      PIC 9(03).
           05  IN-PPR-RNR                      PIC S9(08)  COMP.
           05  IN-DATA.
               10 IN-DATA-BBF.
                  15 IN-VBOND                  PIC 9(02).
                  15 IN-KONST.
                     20 IN-AFDEL               PIC 9(03).
                     20 IN-KASSIER             PIC 9(03).
                     20 IN-DATZIT-DM           PIC 9(04).
                  15 IN-BETWYZ                 PIC X(01).
                  15 IN-RNR                    PIC X(13).
                  15 IN-BETKOD                 PIC 9(02).
                  15 IN-REKNUM                 PIC 9(12).
                  15 IN-REKNR REDEFINES IN-REKNUM.
                     20 IN-REKNR-PART1         PIC 9(03).
                     20 IN-REKNR-PART2         PIC 9(07).
                     20 IN-REKNR-PART3         PIC 9(02).
                  15 IN-VOLGNR-M30             PIC 9(03).
                  15 IN-INFOREK                PIC 9(01).
                  15 IN-AANT-INF               PIC 9(02).
                  15 IN-BEDRAG-EUR             PIC 9(08).
                  15 IN-BEDRAG-RMG-EUR REDEFINES
                            IN-BEDRAG-EUR      PIC 9(11) COMP.
                  15 IN-BEDRAG-DV              PIC X(01).
                  15 IN-BEDRAG-RMG-DV  REDEFINES
                            IN-BEDRAG-DV       PIC X(01).
MIS001            15 IN-REKNUM-IBAN            PIC X(34).                
              10  IN-TABLE-INF.
                  15  IN-DATA-INF OCCURS 14.
                      20  IN-VOL-INF           PIC 9(02).
MIS001                20  IN-PREST             PIC 9(12).
MIS001                20  IN-PREST-R REDEFINES IN-PREST.
MIS001                    25  IN-FILLER-1      PIC 9(01).
MIS001                    25  IN-VERSTR-1      PIC 9(01).
MIS001                    25  IN-VERSTR-2      PIC 9(01).
MIS001                    25  IN-FILLER-2      PIC 9(06).
MIS001                    25  IN-SPEC          PIC 9(03).
IGO                   20  IN-AVR               PIC 9(02).
                      20  IN-AANT-PREST        PIC 9(02).
                      20  IN-LAST-DATE         PIC 9(06).
                      20  IN-HONOR             PIC 9(06).
                      20  IN-RIJKSNR           PIC X(13).
                      20  IN-BEDRAG            PIC 9(08).
MIS001                20  IN-OMSCHR3-AVR       PIC X(40).
JGO                   20  IN-PRESTATIE         PIC  9(06).
224154        10  IN-TAGREG-OP          PIC  9(02).
224154        10  IN-TAGREG-LEG         PIC  9(02).      
