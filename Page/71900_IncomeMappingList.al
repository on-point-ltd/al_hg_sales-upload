page 71900 "Income Mapping List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Income Mapping";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Brand Code"; "Brand Code")
                {
                    ApplicationArea = All;
                }
                field("Income Type"; "Income Type")
                {
                    ApplicationArea = ALL;
                }
                field("Product Code"; "Product Code")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Bal. A/C No."; "Bal. A/C No.")
                {
                    ApplicationArea = All;
                }
            }
            grid(reserved)
            {
                Caption = 'Use only for generated settings (for test ...)';
                field(AccNo; AccNo)
                {
                    Caption = 'G/L Account No.';
                    TableRelation = "G/L Account" where ("Direct Posting" = const(true));
                }
                field(BalAccNo;BalAccNo)
                {
                    Caption = 'Bal. G/L Account No.';
                    TableRelation = "G/L Account" where ("Direct Posting" = const(true));
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(PreSet)
            {
                // just to generate settings on button click
                // ... helps when reloading extensions
                // populates just those blank
                Caption = 'Initial Pre-settings';
                Image = TestReport;
                trigger OnAction()
                var
                    SalesSetup: Record "Sales & Receivables Setup";
                    DimVal: Record "Dimension Value";
                    iProduct: Integer;
                    iDesc: Integer;
                begin
                    SalesSetup.Get();
                    if SalesSetup."Brands Dimension" = '' then
                        SalesSetup."Brands Dimension" := 'BRAND';
                    if SalesSetup."Journal Template Name" = '' then
                        SalesSetup."Journal Template Name" := 'GENERAL';
                    if SalesSetup."Journal Batch Name" = '' then
                        SalesSetup."Journal Batch Name" := 'SU-TEST';
                    if SalesSetup."Sales Upload No. Series" = '' then
                        SalesSetup."Sales Upload No. Series" := 'SUP';
                    SalesSetup.Modify();

                    if rec.Count() = 0 then
                    begin
                        DimVal.SetRange("Dimension Code", SalesSetup."Brands Dimension");
                        if DimVal.FindSet() then
                            repeat
                                for iProduct := 0 to 2 do begin
                                    for iDesc := 0 to 9 do begin
                                        Init();
                                        rec."Brand Code" := DimVal.Code;
                                        rec."Product Code" := iProduct;
                                        rec."Income Type" := iDesc;
                                        rec."G/L Account No." := AccNo;
                                        rec."Bal. A/C No." := BalAccNo;
                                        Insert();
                                    end;
                                end;
                            until DimVal.Next() = 0;
                    end;
                end;
            }
        }
    }
    var
        AccNo: Code[20];
        BalAccNo: Code[20];
}