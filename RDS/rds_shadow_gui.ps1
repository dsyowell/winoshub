# This is a PowerShell script with a GUI that lists active RDS user sessions and allows connecting them via Remote Desktop Shadowing.
# It works on all versions of Windows Server above 2012, and the RDSH role is not required.
# Read more: https://woshub.com/rds-shadow-how-to-connect-to-a-user-session-in-windows-server-2012-r2/

Add-Type -AssemblyName System.Windows.Forms

$Header = "SESSIONNAME", "USERNAME", "ID", "STATUS"

$dlgForm = New-Object System.Windows.Forms.Form
$dlgForm.Text = 'Session Connect'
$dlgForm.Width = 420
$dlgForm.AutoSize = $true

$dlgBttn = New-Object System.Windows.Forms.Button
$dlgBttn.Text = 'Control'
$dlgBttn.Location = New-Object System.Drawing.Point(15, 10)
$dlgForm.Controls.Add($dlgBttn)

$dlgList = New-Object System.Windows.Forms.ListView
$dlgList.Location = New-Object System.Drawing.Point(0, 50)
$dlgList.Width = $dlgForm.ClientRectangle.Width
$dlgList.Height = $dlgForm.ClientRectangle.Height
$dlgList.Anchor = "Top, Left, Right, Bottom"
$dlgList.MultiSelect = $false
$dlgList.View = 'Details'
$dlgList.FullRowSelect = $true
$dlgList.GridLines = $true
$dlgList.Scrollable = $true
$dlgForm.Controls.Add($dlgList)

# Add columns to the ListView
foreach ($column in $Header) {
    $dlgList.Columns.Add($column) | Out-Null
}

# Populate ListView items
(qwinsta.exe | findstr "Active") -replace "^[\s>]" , "" -replace "\s+", "," | 
    ConvertFrom-Csv -Header $Header | ForEach-Object {
        $dlgListItem = New-Object System.Windows.Forms.ListViewItem($_.SESSIONNAME)
        $dlgListItem.SubItems.Add($_.USERNAME) | Out-Null
        $dlgListItem.SubItems.Add($_.ID) | Out-Null
        $dlgListItem.SubItems.Add($_.STATUS) | Out-Null
        $dlgList.Items.Add($dlgListItem) | Out-Null
    }

# Button click event handler
$dlgBttn.Add_Click({
    $SelectedItem = $dlgList.SelectedItems[0]
    if ($null -eq $SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Select an RD user session to connect")
    } else {
        $session_id = $SelectedItem.SubItems[2].Text
        mstsc /shadow:$session_id /control
        # To show session id in a message box, uncomment the next line
        # [System.Windows.Forms.MessageBox]::Show($session_id)
    }
})

$dlgForm.ShowDialog()
