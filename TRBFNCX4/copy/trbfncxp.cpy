      ******************************************************************
      *    TRBFNCXP : RECORD PPR CREE PAR TRBFNCXB                     *
      *    --------                                                    *
      *                                                                *
      *                                                                *
      *   LENGTH : 152/140                                             * 
      *       SEPA: + IBAN  186/174                                    *
      *   CODE   : 42                                                  *
      *   NAME   : GIRBET                                              *
      *                                                                *
SEPA  *  WIJZIGING TGV PROJECT SEPA                                    *
      ******************************************************************
       01 TRBFNCXP.
          05 TRBFN-LENGTH                 PIC S9(04)  COMP.
          05 TRBFN-CODE                   PIC S9(04) COMP.
          05 TRBFN-NUMBER                 PIC 9(08).
          05 TRBFN-PPR-NAME               PIC X(06).
          05 TRBFN-PPR-FED                PIC 9(03).
          05 TRBFN-PPR-RNR                PIC S9(08)  COMP.
          05 TRBFN-DATA.
             10 TRBFN-DEST                 PIC 9(3).
             10 TRBFN-DATMEMO              PIC 9(8).
             10 TRBFN-DATMEMO2 REDEFINES TRBFN-DATMEMO.
                15 TRBFN-DATMEMO-CC        PIC 9(02).
                15 TRBFN-DATMEMO-YMD       PIC 9(6).
                15 TRBFN-DATMEMO-YMD2 REDEFINES TRBFN-DATMEMO-YMD.
                   20 TRBFN-DATMEMO-YY     PIC 9(2).
                   20 TRBFN-DATMEMO-MM     PIC 9(2).
                   20 TRBFN-DATMEMO-DD     PIC 9(2).
             10 TRBFN-TYPE-COMPTA          PIC 9.
             10 TRBFN-CONSTANTE            PIC 9(10).
             10 TRBFN-NO-SUITE             PIC 9(4).
             10 TRBFN-RNR                  PIC X(13).
             10 TRBFN-MONTANT              PIC S9(8).
             10 TRBFN-CODE-LIBEL           PIC 9(2).
             10 TRBFN-LIBELLE1             PIC X(14).
             10 TRBFN-LIBELLE2             PIC X(14).
             10 TRBFN-REKNR                PIC 9(12).
             10 TRBFN-REKNR-RED REDEFINES TRBFN-REKNR.
                15 TRBFN-REKNR-TEN         PIC 9(10).
                15 TRBFN-REKNR-TEN2 REDEFINES TRBFN-REKNR-TEN.
                   20 TRBFN-REKNR-FIN      PIC 9(03).
                   20 TRBFN-REKNR-7        PIC 9(07).
                15 TRBFN-REKNR-TST         PIC 9(02).
             10 TRBFN-COMPTE-MEMBRE        PIC 9(1).
             10 TRBFN-MONTANT-DV           PIC X.
             10 TRBFN-FILLER-DETAIL        PIC  X(12).
             10 TRBFN-FILLER-DET-RED REDEFINES 
                                           TRBFN-FILLER-DETAIL.
SEPA            20 TRBFN-BETWYZ            PIC  X(01).
SEPA            20 TRBFN-REST              PIC  X(11).             
SEPA         10 TRBFN-IBAN                 PIC  X(34).
