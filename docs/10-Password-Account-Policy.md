# Password and Account Policies

## Objective

Implement and validate domain-wide password and account lockout policies to improve account security across the `ad.nlaur.com` Active Directory environment.

---

## Environment

| Setting | Value |
|---------|-------|
| Domain | `ad.nlaur.com` |
| Domain Controller | `DC01` |
| Client | `CLIENT01` |
| Policy Location | Default Domain Policy |

---

## Design Decisions

### Domain-Wide Password Policy

Password and account lockout settings were configured at the domain level so they apply consistently to all domain user accounts.

Using a centralized policy allows administrators to enforce authentication standards without configuring individual users manually.

### Password History

Password history was configured to prevent users from immediately reusing recently used passwords.

### Minimum Password Age

A minimum password age helps prevent users from rapidly cycling through passwords in order to return to a previously used password.

### Account Lockout

Account lockout settings reduce the effectiveness of repeated password-guessing attempts by temporarily locking an account after a defined number of failed sign-in attempts.

---

## Configuration

The settings were configured through:

```text
Group Policy Management
└── Default Domain Policy
    └── Computer Configuration
        └── Policies
            └── Windows Settings
                └── Security Settings
                    └── Account Policies
```


<img width="1279" height="902" alt="02-passwordpolicy" src="https://github.com/user-attachments/assets/77d887a5-5b48-45b0-8045-4e2bd9d8d798" />



### Password Policy

| Policy | Configured Value |
|--------|------------------|
| Enforce password history | 24 passwords |
| Minimum password age | 30 days |
| Maximum password age | 365 days |
| Minimum password length | 8 characters |
| Password complexity | Enabled |
| Store passwords using reversible encryption | Disabled |

### Account Lockout Policy

| Policy | Configured Value |
|--------|------------------|
| Account lockout threshold | 15 invalid attempts |
| Account lockout duration | 5 minutes |
| Reset account lockout counter after | 5 minutes |



<img width="1280" height="898" alt="03-Accountlockpolicy" src="https://github.com/user-attachments/assets/45150c33-b540-4550-bd21-9d20495f6856" />



---

## Validation

After applying the policy, the effective domain settings were verified from CLIENT01 using:


<img width="1237" height="657" alt="01-passwordpolicyonclient01" src="https://github.com/user-attachments/assets/d5c7aba9-53c5-40ec-a8a6-6193fa3c3c1e" />



- [x] Password history configured
- [x] Minimum and maximum password age configured
- [x] Password complexity enabled and minimum password length tested


<img width="1277" height="962" alt="04-passwordcomplexity" src="https://github.com/user-attachments/assets/b4787d68-bc1f-4cda-83e8-0f9b98a493cf" />



- [x] Reversible encryption disabled
- [x] Account lockout threshold and duration configured
- [x] Account lockout observation window configured
- [x] Verified effective policy using `net accounts /domain`

---

## Lessons Learned

Domain password and account lockout policies provide a centralized method for enforcing authentication standards across Active Directory.

The **Default Domain Policy** is the appropriate location for configuring password and account lockout requirements because these settings apply to all domain user accounts.

Using `net accounts /domain` provides a quick method to verify that password and lockout policies are being enforced from the client perspective rather than relying solely on the Group Policy Management Console.

This exercise also reinforced the importance of validating Group Policy changes after deployment to ensure clients receive the intended configuration.
