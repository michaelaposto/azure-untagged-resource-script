import smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header

sender_email = "michael.aposto@azenix.com.au"
receiver_email = "michael.aposto@azenix.com.au"

message = MIMEMultipart()
message['From'] = sender_email
message['To'] = receiver_email
message['Subject'] = Header('Azenix Azure PAYG - Untagged resources', 'utf-8').encode()

body = "The following resources are untagged, please either tag or remove them from the subscription. \nRegards, \nAzenix Team"

message_content = MIMEText(body, 'plain', 'utf-8')
message.attach(message_content)

context = ssl.create_default_context()
with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
    server.login(sender_email, password)
    server.sendmail(sender_email, receiver_email, message.as_string())