pageextension 71902 "General Jnl. Ext." extends "General Journal"
{
    actions
    {
        addafter(IncomingDocument)
        {
            action(SIUpload)
            {
                Caption = 'Sales Invoices Upload';
                Image = Process;
                trigger OnAction()
                begin
                    report.run(report::"Sales Invoice Upload");
                    CurrPage.Update();
                    CurrPage.Activate();
                end;
            }
        }
    }
}