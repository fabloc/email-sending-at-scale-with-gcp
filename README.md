
# Overview of the constraints for sending emails at scale

Companies in the business of email sending for marketing purposes face a big challenge as it requires a lot of energy (and costs) associated with the reliable delivery of emails for the targeted audiences at scale. Indeed, in order to prevent the spreading of spam emails, Inbox Service Providers (ISPs) and Email Sending Providers (ESP - Used by marketers to send bulk emails - Google, Yahoo, etc.) perform verifications to assess the "legitimacy" of an email before delivering it to the recipient.
As part of these checks, different characteristics - or features - of the email will by verified. There are 2 kinds of verifications depending on the feature:
- Formatting features that can be checked without any historical/contextual knowledge (RFC compliance, etc.)
- Reputation features that are checked based on prior deliverability of emails containing similar features (fraudulent URLs, etc.).

Those 2 kinds of feature checks are described below.

For more in-depth best practices for sending email, you can refer to [this Gmail article](https://support.google.com/mail/answer/81126?hl=en&ref_topic=7279058)

# Formatting Features

Formatting features correspond to characteristics of the message that can be checked immediately, without any historical data of user behaviour.

Examples of formatting features are the following (extracted from the [Prevent mail to Gmail users from being blocked or sent to spam](https://support.google.com/mail/answer/81126?hl=en&ref_topic=7279058))
- Format messages according to the Internet Format Standard (RFC 5322).
- If your messages are in HTML, format them according to HTML standards.
- Don’t use HTML and CSS to hide content in your messages.
- Message From: headers should include only one email address, as shown in this example:
  From: notifications@solarmora.com 
- Include a valid Message-ID header field in every message (RFC 5322).
- Links in the body messages should be visible and easy to understand. Recipients should know where they go when they click links.
- Sender information should be clear and visible.
- Message subjects should be relevant and not misleading.
- Format international domains according to the Highly Restrictive guidelines in section 5.2 of Unicode Technical Standard #39:
  Authenticating domain
  Envelope from domain
  Payload domain
  Reply-to domain
  Sender domain

# Reputation Features

Reputation represents a comparison with historical data based on historical spam data. It indicates the frequency that a certain feature of a mail appeared in spam messages vs the times it appeared in non-spam messages. ESPs keep track of the reputation for many types of features, not just the sender's domain. For GMail, the reputation number is based solely on mail received, not on any data from external/third-party services.

Examples of feaures that are tracked as part of feature reputation:
- The IP address the mail from
- Sender's domain (but only if the SPF check passed)
- URLs in the body of the mail

Emailers can control the content and formatting of the emails they are sending, making sure they conform to most ESPs checks related to RFCs and other features.

However, there are 2 features which are much more delicate and yet critical for an emailer to control are Domain and IP reputations.

## Domain Reputation

Domain Reputation is a score representing the ratio of spams versus the total amount of emails sent using this domain.
Using authentication mechanisms like SPF or DKIM, the Domain is linked to IPs used to send emails. Authentication mechanisms will improve the chance of delivery of the emails as some ESPs will block emails from Domains with no authentication set up.
This means that Domain reputation is bound to IP reputation. When using low reputation IPs for sending emails, they will be more likely to be marked as spam and thus will reduce the reputation of the Domain.
Changing the low reputation IPs with high-reputation IPs to send emails with a given domain is a good way to improve the deliverability of the emails and reduce reputation damage done on a Domain.
Be aware that Domain reputation is much more difficult to correct than an IP, since you just need to change the IP for sending emails!

## IP Reputation

IP reputation is the most energy-consuming part of the deliverability and requires on-going monitoring 

Customers considering sending emails at scale have multiple options at hand:
- Either they are using shared public IPs to send emails, which is the cheapest option, but the IP reputation also depends on the bahviour of other customers using the same IP. In the worst case they could send garbage emails or pursue fraudulent behavior, thus hampering the shared IP reputation
- Or they purchase dedicated IPs, which is much more expensive, but gives the customer more control over the IP reputation as they are solely responsible for it

Now, when it comes to Cloud Providers, dedicated IP can by used, but the issue is that public IP addresses that are assigned have an "history" that the customer can't control. More specifically the IP addresses may have a bad reputation score from the ISPs.


In order to work this around, it is recommanded to acquire IP ranges that will be used exclusively for this purpose and that the email sending company will be able to control. It will be able to spread their use of their IPs for example by either using dedicated IP addresses for premium customers or shared IPs for entrey-level customers.


# Typical Email sending Stack

In order to send emails at scale, the emailer needs to have a [Mail Transfer Agent](https://en.wikipedia.org/wiki/Message_transfer_agent) and outbound emails using IPs that are strictly controlled so that they maintain good reputation.

The MTA can be done by the emailer himself, or by a third party (like another more advanced emailer like Mailchimp or Mailjet for ex.).

When the emailer wants to have more control over the email sending process, he can deploy a MTA himself. 3rd party MTAs exist like PowerMTA.