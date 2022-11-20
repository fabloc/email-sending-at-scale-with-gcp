**DISCLAIMER: This page is work in progress**


# Overview of the constraints for sending emails at scale

Companies in the business of email sending for marketing purposes face a big challenge as it requires a lot of energy (and costs) associated with the reliable delivery of emails for the targeted audiences at scale. Indeed, in order to prevent the spreading of spam emails, Inbox Service Providers (ISPs) and Email Sending Providers (ESP - Used by marketers to send bulk emails - Google, Yahoo, etc.) perform verifications to assess the "legitimacy" of an email before delivering it to the recipient.
As part of these checks, different characteristics - or features - of the email will by verified. There are 2 kinds of verifications depending on the feature:
- Formatting features that can be checked without any historical/contextual knowledge (RFC compliance, etc.)
- Reputation features that are checked based on prior deliverability of emails containing similar features (fraudulent URLs, etc.).

Those 2 kinds of feature checks are described in the sections below.

If the ISP evaluates the inbound email as spam, one of the following action can be taken:
- Limited sending rate
- Blocked messages
- Messages marked categorized as spam
(actions depend on the ISP, above actions are from Gmail)

For more in-depth best practices for sending email, you can refer to [this Gmail article](https://support.google.com/mail/answer/81126?hl=en&ref_topic=7279058). It's specific to Gmail, but other big ESPs also generally follow the same best practices.

# Formatting Features

Formatting features correspond to characteristics of the message that can be checked immediately, without any historical data of user behaviour.

Examples of formatting features are the following (extracted from the [Prevent mail to Gmail users from being blocked or sent to spam](https://support.google.com/mail/answer/81126?hl=en&ref_topic=7279058))
- Format messages according to the Internet Format Standard ([RFC 5322](https://www.rfc-editor.org/rfc/rfc5322)).
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

Domain Reputation is a score based on several factors like the following:
- Ratio of spams versus the total amount of emails sent using this domain
- Authentication mechanisms like SPF or DKIM
- Domain age
- How the domain references across the web
- category of the domain (sport, advertising, etc.)
- etc.
Each Inbox Service Provider will weigh the factors using their own specific algorithms.

Tools exists to measure the reputation of a domain, like [Postmaster](https://postmaster.google.com/managedomains)

## IP Reputation

In addition to domain reputation, Inbox Service Providers will also evaluate the IP that is used to send the email.

ISPs generally use a combination of multiple factors which can consist (and not limited to):
- **In-house IP evaluation** based of previous email history received **by this ISP** sent from this IP and recipients evaluations (whether the email was opened, marked as spam, etc.). An IP that has an history of high spam ratio will be more likely to be bounced by an ISP.
- **[DNSBL](https://en.wikipedia.org/wiki/Domain_Name_System-based_blocklist)** mechanism which consists of curated lists of domains flagged as apt to send spams. Each DNSBL list has its own sets of criteria to identify spams and some are more restrictive/aggressive than others. Furthermore, other mechansisms like URI DNSBL can even further check for blacklisted clickable URIs inside the body of the email. DNSBL typical work as a reverse DNS resolution taking into input the sending IP address. If the resolution is successful, it means the IP is blocklisted.

With IP reputation, variables like whether you’re using a brand new IP address, a shared IP, or a dedicated IP can have a big impact.

IP reputation is the most energy-consuming part of the deliverability and requires on-going monitoring. Same as for domains, tools exist to check the reputation of an IP **TODO Provide tools examples**.

Customers considering sending emails at scale have multiple options at hand:
- Either they are using shared public IPs to send emails, which is the cheapest option, but the IP reputation also depends on the behaviour of other customers using the same IP. In the worst case they could send garbage emails or pursue fraudulent behavior, thus hampering the shared IP reputation
- Or they purchase dedicated IPs, which is much more expensive, but gives the customer more control over the IP reputation as they are solely responsible for it

Now, when it comes to Cloud Providers, dedicated IP can by used, but the issue is that public IP addresses that are assigned have an "history" that the customer can't control. More specifically the IP addresses may have a bad reputation score from the ISPs.

In order to work this around, it is recommanded to acquire IP ranges that will be used exclusively for this purpose and that the email sending company will be able to control. It will be able to spread their use of their IPs for example by either using dedicated IP addresses for premium customers or shared IPs for entrey-level customers.

## Domain vs IP Reputation

Using authentication mechanisms like SPF or DKIM, the Domain is linked to IPs used to send emails. This means that Domain reputation is bound to IP reputation. When using low reputation IPs for sending emails, they will be more likely to be marked as spam and thus will reduce the reputation of the Domain.
Changing the low reputation IPs with high-reputation IPs to send emails with a given domain is a good way to improve the deliverability of the emails and reduce reputation damage done on a Domain caused by a bad IP.
Be aware that Domain reputation is much more difficult to correct than an IP, since you just need to change the IP for sending emails!

Given that an IP can be shared and used to send emails from many domains, the domain reputation is pointed than IP reputation. With that in mind, Domain reputation has probably more weight than IP reputation for ISPs (more specifically for Gmail).


# Typical Email sending Stack

In order to send emails at scale, the emailer needs to have a [Mail Transfer Agent](https://en.wikipedia.org/wiki/Message_transfer_agent). MTA in this case will serve as a relay that will take care of the mass-sending of the emails, with observability, high-availability, retries, etc. There are a several different open-source projects that provide MTA features, like Postfix, Exim, Sendmail, etc. Those open source softwares were initially designed to be used as email accounts management, and not to send emails at scale, so it may require a lot of performance tuning, monitoring, etc. to make them work reliably. For information purposes, any business sending more than 300,000 emails per hour should probably consider a professionnal solution like PowerMTA designed specifically for large scale email sending.
However, management of the IPs used to outbound the emails are not part of the scope of MTAs.

In order to manage IP independently of the MTA, it is proposed to decorrelate IP management from MTA. This means that a proxy layer that will be bound to the public IP will relay the emails from the MTA to the destination ESPs.


# References

A good article on domain reputation and ip reputation can be found on [this article](https://www.mailgun.com/blog/deliverability/domain-ip-reputation-gmail-care-more-about/) on mailgun website
