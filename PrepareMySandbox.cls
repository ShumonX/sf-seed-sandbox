/**
 * @author ShumonX
 * @link https://www.salesforceben.com/auto-populate-salesforce-sandboxes-with-sample-records/
 * @since 15 November 2021
 * @version 1.1
 * 
 * Code is indented using Allman Style — opening curly brace brackets are on new lines to vertically align with closing curly brace brackets —
 * and not in K&R style as taught in most schools, textbooks, and websites — where the opening brace is on the previous line, and never aligns with the closing brace.
 * 
 * All code is contained within an 80 character right margin, preventing an ugly horizontal scroll bar.
 * Indentations are tabs, not spaces, to reduce the number of characters used as Apex has a limit of 6 MB per org.
 *
 * Single SOQL statments are broken into multiple lines, in a staircase indentation.
 */
global class PrepareMySandbox implements SandboxPostCopy
{
	global void runApexClass(SandboxContext context)
	{
		/*
		 * Insert sample Accounts
		 */
		StaticResource accountStaticResource =
		[
			SELECT Body
				FROM StaticResource
					WHERE Name = 'Account_csv'
		];
		String accountCsv = accountStaticResource.Body.toString();
		Account[] accountList = new Account[] {};
		for (String row : accountCsv.split('\n'))
		{
			String[] column = row.split(',');
			accountList.add(new Account
			(
						Name = column[0],
				BillingState = column[1],
					   Phone = column[2],
						Type = column[3]
			));
		}
		insert accountList;
		
		/*
		 * Use a Map to avoid creating an External ID field on Account
		 */
		Map<String, Id> accountMap = new Map<String, Id>();
		for (Account acc : accountList)
		{
			accountMap.put(acc.Name, acc.Id);
		}
		
		/*
		 * Insert related Contacts
		 */
		StaticResource contactStaticResource =
		[
			SELECT Body
				FROM StaticResource
					WHERE Name = 'Contact_csv'
		];
		String contactCsv = contactStaticResource.Body.toString();
		Contact[] contactList = new Contact[] {};
		for (String row : contactCsv.split('\n'))
		{
			String[] column = row.split(',');
			contactList.add(new Contact
			(
				FirstName = column[0],
				 LastName = column[1],
				AccountId = accountMap.get(column[2]),
					Title = column[3],
					Phone = column[4],
					Email = column[5]
			));
		}
		insert contactList;
	}
}
