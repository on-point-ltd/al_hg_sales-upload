pageextension 71900 "Sales Setup Ext." extends "Sales & Receivables Setup"
{
    layout
    {
        addafter(General)
        {
            group(SalesImport)
            {
                Caption = 'Sales Import';
                field("Brands Dimension"; "Brands Dimension")
                {
                    ApplicationArea = All;
                }
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Sales Upload No. Series"; "Sales Upload No. Series")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addbefore("Payment Registration Setup")
        {
            action(IncomeMapping)
            {
                Caption = 'Income Mapping';
                Image = SetupList;
                trigger OnAction()
                begin
                    page.Run(page::"Income Mapping List");
                end;

            }
        }
    }
}