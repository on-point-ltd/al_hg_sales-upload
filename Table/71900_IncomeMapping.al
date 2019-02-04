table 71900 "Income Mapping"
{
    fields
    {
        field(71900; "Brand Code"; code[20])
        {

            trigger OnLookup()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                DimVal: Record "Dimension Value";
            begin
                SalesSetup.Get();
                DimVal.SetRange(Blocked, false);
                DimVal.SetRange("Dimension Value Type", DimVal."Dimension Value Type"::Standard);
                DimVal.SetRange("Dimension Code", SalesSetup."Brands Dimension");
                if not DimVal.IsEmpty then begin
                    if page.runmodal(page::"Dimension Values", DimVal) = Action::LookupOK then
                        "Brand Code" := DimVal.Code;
                end else
                    message(NoRecFound);
            end;

        }
        field(71901; "Income Type"; Option)
        {
            OptionMembers =
                "Bonus Bet Amount"
                ,"Bonus Bet Rollback Amount"
                ,"Bonus Bet Net Amount"
                ,"Bonus Win Amount"
                ,"Money Bet Amount"
                ,"Money Bet Rollback Amount"
                ,"Money Bet Net Amount"
                ,"Money Win Amount"
                ,"RM GGR"
                ,"Total GGR";
        }
        field(71902; "Product Code"; Option)
        {
            OptionMembers = "Casino","Sports","Lotto";
        }
        field(71903; "G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account" where ("Account Type" = const ("Posting"), "Direct Posting" = const (true));
        }
        field(71904; "Bal. A/C No."; Code[20])
        {
            TableRelation = "G/L Account" where ("Account Type" = const ("Posting"), "Direct Posting" = const (true));
        }
    }
    keys
    {
        key(PK; "Brand Code", "Income Type", "Product Code")
        {
            Clustered = true;
        }
    }
    var
        NoRecFound: Label 'No record found. Check if ''Brands Dimension'' is set please.';
}