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

For more in-depth best practices for sending email, you can refer to [this Gmail article](https://support.google.com/mail/answer/81126?hl=en&ref_topic=7279058). It's specific to Gmail, but other big ISPs also generally follow the same best practices.

# Formatting Features

Formatting features correspond to characteristics of the message that can be checked immediately, without any historical data of user behaviour.

Examples of formatting features are the following (extracted from the [Prevent mail to Gmail users from being blocked or sent to spam](https://support.google.com/mail/answer/81126?hl=en&ref_topic=7279058))
- Format messages according to the Internet Format Standard ([RFC 5322](https://www.rfc-editor.org/rfc/rfc5322)).
- If your messages are in HTML, format them according to HTML standards.
- Don’t use HTML and CSS to hide content in your messages.
- Message From: headers should include only one email address, as shown in this example:
    - From: notifications@solarmora.com 
- Include a valid Message-ID header field in every message (RFC 5322).
- Links in the body messages should be visible and easy to understand. Recipients should know where they go when they click links.
- Sender information should be clear and visible.
- Message subjects should be relevant and not misleading.
- Format international domains according to the Highly Restrictive guidelines in section 5.2 of Unicode Technical Standard #39:
    - Authenticating domain
	- Envelope from domain
	- Payload domain
	- Reply-to domain
	- Sender domain

# Reputation Features

Reputation represents a comparison with historical data based on historical spam data. It indicates the frequency that a certain feature of a mail appeared in spam messages vs the times it appeared in non-spam messages. ISPs keep track of the reputation for many types of features, not just the sender's domain. For GMail, the reputation number is based solely on mail received, not on any data from external/third-party services.

Examples of feaures that are tracked as part of feature reputation:
- The IP address the mail from
- Sender's domain (but only if the SPF check passed)
- URLs in the body of the mail

Emailers can control the content and formatting of the emails they are sending, making sure they conform to most ISPs checks related to RFCs and other features.

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

In addition to domain reputation, Inbox Service Providers will also evaluate the IP that is used to send the email. IP reputation is the most energy-consuming part of the deliverability and requires on-going monitoring.

ISPs generally use a combination of multiple factors which can consist (and not limited to):
- **In-house IP evaluation** based of previous email history received **by this ISP** sent from this IP and recipients evaluations (whether the email was opened, marked as spam, etc.). An IP that has an history of high spam ratio will be more likely to be bounced by an ISP.
- **[DNSBL](https://en.wikipedia.org/wiki/Domain_Name_System-based_blocklist)** mechanism which consists of curated lists of domains flagged as apt to send spams. Each DNSBL list has its own sets of criteria to identify spams and some are more restrictive/aggressive than others. Furthermore, other mechansisms like URI DNSBL can even further check for blacklisted clickable URIs inside the body of the email. DNSBL typical work as a reverse DNS resolution taking into input the sending IP address. If the resolution is successful, it means the IP is blocklisted.

### The Different Types of IP Addresses

With IP reputation, variables like whether you’re using a brand new IP address, a shared IP, or a dedicated IP can have a big impact.

**Shared IP address**
Indeed, it's possible to use a single IP address to send emails for many different domains. This is an economic solution (IP address ranges are expensive!), but it may dangerous if your neighbors on the same IP have the bad habit to send junk emails as it will negatively impact the IP reputation, and thus the deliverability of emails for all domains on the same IP.

**Re-purposed IP address**
On the other hand, when using a new IP allocated by a cloud or hosting provider, the IP has an history and its reputation may be low if previous users used IP to send spam. So care must be taken with these kind of IPs as they could have a low reputation or even be blocklisted in one or more of the DNSBL or ISPs, leading to lots of efforts to remove the IP from the various lists. Given this, it may not be the most effective solution for large emailers.

**Owned IP address**
The last option is to purchase IP ranges to send emails. It is the most expensive option as IP become more and more expensive as they are getting scarser with time, but it gives more control over the IP reputation. This way a dedicated IP can be used for only one domain, limiting the impact of 'noisy' neighbors. However, when first using a new IP, its reputation will be blank. Given that the reputation mechanism works by comparing the ratio of spam sent versus the total number of emails, a specific step should be done, called 'IP warm up', described below.

### IP Warm-Up

When using a new IP, its reputation may be blank or low. In case of a blank reputation, every spam message will have a great impact on the reputation, as it is based on the ratio of spam versus the total number of messages sent with this IP. In order to 'prepare' the IP and make it more tolerant to occasionnal spam report, the number of 'legit' emails sent with IP must be increased dramatically. This is the objective of the warm-up phase: sending a large number of legit emails to trusted recipients that will provide a better resilience to accidental spam reports.
Same for low-reputation IPs, the warm-up will decrease the ratio of spam vs legit emails, thus improving the IP reputation.

This warm-up phase must be done carefully, as suddenly sending large amount of emails will arise suspicions from ISPs. The email sending must be done progressively, over a long time (multiple weeks).

After this warm-up period, the IP can be used in production.

### IP Reputation Tools

Same as for domains, tools exist to check the reputation of an IP **TODO Provide tools examples**.


## Domain vs IP Reputation

Using authentication mechanisms like SPF or DKIM, the Domain is linked to IPs used to send emails. This means that Domain reputation is bound to IP reputation. When using low reputation IPs for sending emails, they will be more likely to be marked as spam and thus will reduce the reputation of the Domain.
Changing the low reputation IPs with high-reputation IPs to send emails with a given domain is a good way to improve the deliverability of the emails and reduce reputation damage done on a Domain caused by a bad IP.
Be aware that Domain reputation is much more difficult to correct than an IP, since you just need to change the IP for sending emails!

Given that an IP can be shared and used to send emails from many domains, the domain reputation is pointed than IP reputation. With that in mind, Domain reputation has probably more weight than IP reputation for ISPs (more specifically for Gmail).


# Typical Email sending Stack

In order to send emails at scale, the emailer uses a Mail User Agent to create the emails, then will forward the email details and metadata (recipients, sender, etc.) to a [Mail Transfer Agent](https://en.wikipedia.org/wiki/Message_transfer_agent) using the SMTP protocol. MTA in this case will serve as a relay that will take care of the mass-sending of the emails, with observability, high-availability, retries, etc. For each email's recipient, the MTA sends the emails to the corresponding ISP's Mail Delivery Agent (or other intermediate MTAs in case of network separation for ex.). The MDA stores the emails, waiting for the final recipients to use a MUA using IMAP or POP3 protocol for retrieving the email. **TODO principle diagram**

There are a several different open-source projects that provide MTA features, like Postfix, Exim, Sendmail, etc. Those open source softwares were initially designed to be used as email accounts management, and not to send emails at scale, so it may require a lot of performance tuning, monitoring, etc. to make them work reliably. For information purposes, any business sending more than 300,000 emails per hour should probably consider a professionnal solution like PowerMTA designed specifically for large scale email sending.
However, management of the IPs used to outbound the emails are not part of the scope of MTAs.

## IP Management
In order to manage IP independently of the MTA, it is recommended to decorrelate IP management from MTA. This means that a proxy layer that will be bound to the public IP will relay the emails from the MTA to the destination ISPs.

# References

A good article on domain reputation and ip reputation can be found on [this article](https://www.mailgun.com/blog/deliverability/domain-ip-reputation-gmail-care-more-about/) on mailgun website
