$body = @{
    email = "admin@guyub.id"
    password = "Admin@123"
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:8080/api/v1/auth/login" -ContentType "application/json" -Body $body
