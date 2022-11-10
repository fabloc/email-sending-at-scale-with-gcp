# Why is IP management critical for sending emails at scale

Companies in the business of email sending for marketing purposes face a big challenge as it requires a lot of energy (and costs) associated with the effective delivery of emails.

The main challenge is associated with the use of public IPs for sending emails. In order to prevent the spreading of spam emails, Internet Service Providers (ISPs - providing an inbox as part of a paid internet plan) and Email Sending Providers (ESP - Google, Yahoo, etc.) uses various mechanisms to detect the "legitimacy" of the email sender. As part of these mechanisms, they are keeping track of the "reputation" of all IPs sending emails. This reputation is built using various indicators that are gathered from the email itself directly (respect of the vaious RFCs for email formatting), whether the IP is associated with a domain that has been authenticated using SPF and DKIM, etc.

For more information on best practices that should be followed, please refer to (this web page|https://support.google.com/mail/answer/81126?hl=en&ref_topic=7279058) 

As part of these best practices, IP reputation is critical as it is a major indicator for ESPs. Hence, customer willing to conduct a business in the email delivery area will need to spend a lot of time maintaining a good reputation for the IPs they will use to send emails.

Customers considering sending emails at scale have multiple options at hand:
- Either they are using shared public IPs to send emails, which is the cheapest option, but the IP reputation also depends on the bahviour of other customers using the same IP. In the worst case they could send garbage emails or pursue fraudulent behavior, thus hampering the shared IP reputation
- Or they purchase dedicated IPs, which is much more expensive, but gives the customer more control over the IP reputation as they are solely responsible for it

Now, when it comes to Cloud Providers, dedicated IP can by used, but the issue is that public IP addresses that are assigned have an "history" that the can't control. More specifically the IP addresses may have a bad reputation grade from the ISPs.


In order to work this around, it is recommanded to acquire IP ranges that will be used exclusively for this purpose and that the email sending company will be able to control. It will be able to spread their use of their IPs for example by either using dedicated IP addresses for premium customers or shared IPs for entrey-level customers.