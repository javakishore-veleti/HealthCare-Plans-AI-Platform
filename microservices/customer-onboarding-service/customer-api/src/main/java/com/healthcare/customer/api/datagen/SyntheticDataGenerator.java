package com.healthcare.customer.api.datagen;

import com.healthcare.customer.common.constants.*;
import com.healthcare.customer.common.model.*;
import com.healthcare.customer.dao.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Component
@Profile("datagen")
@RequiredArgsConstructor
public class SyntheticDataGenerator implements CommandLineRunner {

    private final CustomerRepository customerRepository;
    private final AddressRepository addressRepository;
    private final DependentRepository dependentRepository;
    private final CustomerDocumentRepository documentRepository;
    private final EligibilityCheckRepository eligibilityRepository;
    private final CustomerPlanEnrollmentRepository enrollmentRepository;

    private static final int NUM_CUSTOMERS = 10_000;

    private final Random random = new Random(42); // Fixed seed for reproducibility

    // Name data
    private static final String[] FIRST_NAMES_MALE = {
            "James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph",
            "Thomas", "Charles", "Christopher", "Daniel", "Matthew", "Anthony", "Mark",
            "Donald", "Steven", "Paul", "Andrew", "Joshua", "Kenneth", "Kevin", "Brian",
            "George", "Timothy", "Ronald", "Edward", "Jason", "Jeffrey", "Ryan",
            "Jacob", "Gary", "Nicholas", "Eric", "Jonathan", "Stephen", "Larry", "Justin",
            "Scott", "Brandon", "Benjamin", "Samuel", "Raymond", "Gregory", "Frank",
            "Alexander", "Patrick", "Jack", "Dennis", "Jerry", "Tyler", "Aaron", "Jose",
            "Adam", "Nathan", "Zachary", "Henry", "Douglas", "Peter", "Kyle"
    };

    private static final String[] FIRST_NAMES_FEMALE = {
            "Mary", "Patricia", "Jennifer", "Linda", "Barbara", "Elizabeth", "Susan", "Jessica",
            "Sarah", "Karen", "Lisa", "Nancy", "Betty", "Margaret", "Sandra", "Ashley",
            "Kimberly", "Emily", "Donna", "Michelle", "Dorothy", "Carol", "Amanda", "Melissa",
            "Deborah", "Stephanie", "Rebecca", "Sharon", "Laura", "Cynthia", "Kathleen",
            "Amy", "Angela", "Shirley", "Anna", "Brenda", "Pamela", "Emma", "Nicole",
            "Helen", "Samantha", "Katherine", "Christine", "Debra", "Rachel", "Carolyn",
            "Janet", "Catherine", "Maria", "Heather", "Diane", "Ruth", "Julie", "Olivia",
            "Joyce", "Virginia", "Victoria", "Kelly", "Lauren", "Christina", "Joan"
    };

    private static final String[] LAST_NAMES = {
            "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
            "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
            "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
            "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
            "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
            "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell",
            "Carter", "Roberts", "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker",
            "Cruz", "Edwards", "Collins", "Reyes", "Stewart", "Morris", "Morales", "Murphy"
    };

    private static final String[] MIDDLE_NAMES = {
            "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "R", "S", "T", "W",
            "Ann", "Marie", "Lee", "Ray", "Lynn", "Jean", "Rose", "Mae", "Grace", "James", "Michael"
    };

    // Address data
    private static final String[] STREET_NAMES = {
            "Main St", "Oak Ave", "Maple Dr", "Cedar Ln", "Pine St", "Elm St", "Washington Ave",
            "Park Blvd", "Lake Dr", "Hill Rd", "Forest Ave", "River Rd", "Spring St", "Church St",
            "School St", "Mill St", "Center St", "North St", "South St", "West Ave", "East Blvd",
            "Highland Ave", "Meadow Ln", "Valley Dr", "Sunset Blvd", "Sunrise Dr", "Mountain Rd"
    };

    private static final String[] APT_TYPES = {
            "Apt", "Suite", "Unit", "#", "Floor"
    };

    private static final String[][] CITIES_BY_STATE = {
            {"NC", "Charlotte", "Raleigh", "Greensboro", "Durham", "Winston-Salem", "Fayetteville", "Cary", "Wilmington"},
            {"CA", "Los Angeles", "San Francisco", "San Diego", "San Jose", "Sacramento", "Fresno", "Oakland", "Long Beach"},
            {"TX", "Houston", "Dallas", "Austin", "San Antonio", "Fort Worth", "El Paso", "Arlington", "Plano"},
            {"FL", "Miami", "Orlando", "Tampa", "Jacksonville", "Fort Lauderdale", "St. Petersburg", "Tallahassee", "Gainesville"},
            {"NY", "New York", "Buffalo", "Rochester", "Syracuse", "Albany", "Yonkers", "New Rochelle", "Mount Vernon"},
            {"PA", "Philadelphia", "Pittsburgh", "Allentown", "Erie", "Reading", "Scranton", "Bethlehem", "Lancaster"},
            {"IL", "Chicago", "Aurora", "Naperville", "Joliet", "Rockford", "Springfield", "Peoria", "Elgin"},
            {"OH", "Columbus", "Cleveland", "Cincinnati", "Toledo", "Akron", "Dayton", "Parma", "Canton"},
            {"GA", "Atlanta", "Augusta", "Columbus", "Savannah", "Athens", "Macon", "Roswell", "Albany"},
            {"MI", "Detroit", "Grand Rapids", "Warren", "Sterling Heights", "Ann Arbor", "Lansing", "Flint", "Dearborn"},
            {"AZ", "Phoenix", "Tucson", "Mesa", "Chandler", "Scottsdale", "Glendale", "Gilbert", "Tempe"},
            {"WA", "Seattle", "Spokane", "Tacoma", "Vancouver", "Bellevue", "Kent", "Everett", "Renton"},
            {"MA", "Boston", "Worcester", "Springfield", "Cambridge", "Lowell", "Brockton", "Quincy", "Lynn"},
            {"CO", "Denver", "Colorado Springs", "Aurora", "Fort Collins", "Lakewood", "Thornton", "Arvada", "Boulder"},
            {"VA", "Virginia Beach", "Norfolk", "Chesapeake", "Richmond", "Newport News", "Alexandria", "Hampton", "Roanoke"}
    };

    private static final String[] EMAIL_DOMAINS = {
            "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com",
            "aol.com", "mail.com", "protonmail.com", "live.com", "msn.com"
    };

    @Override
    @Transactional
    public void run(String... args) {
        log.info("=".repeat(80));
        log.info("Starting Customer Synthetic Data Generation");
        log.info("=".repeat(80));

        long existingCustomers = customerRepository.count();
        if (existingCustomers > 100) {
            log.info("Database already has {} customers. Skipping data generation.", existingCustomers);
            return;
        }

        List<Customer> customers = generateCustomers();

        log.info("Saving {} customers with related data...", customers.size());

        // Save in batches
        int batchSize = 500;
        for (int i = 0; i < customers.size(); i += batchSize) {
            int end = Math.min(i + batchSize, customers.size());
            List<Customer> batch = customers.subList(i, end);
            customerRepository.saveAll(batch);
            log.info("  Saved {} customers...", end);
        }

        // Generate enrollments for some customers
        generateEnrollments(customers);

        log.info("=".repeat(80));
        log.info("Customer Synthetic Data Generation Complete!");
        log.info("  Customers: {}", customers.size());
        log.info("=".repeat(80));
    }

    private List<Customer> generateCustomers() {
        log.info("Generating {} customers...", NUM_CUSTOMERS);
        List<Customer> customers = new ArrayList<>();

        for (int i = 0; i < NUM_CUSTOMERS; i++) {
            Gender gender = random.nextBoolean() ? Gender.MALE : Gender.FEMALE;
            String firstName = gender == Gender.MALE
                    ? FIRST_NAMES_MALE[random.nextInt(FIRST_NAMES_MALE.length)]
                    : FIRST_NAMES_FEMALE[random.nextInt(FIRST_NAMES_FEMALE.length)];
            String lastName = LAST_NAMES[random.nextInt(LAST_NAMES.length)];
            String middleName = random.nextDouble() < 0.7 ? MIDDLE_NAMES[random.nextInt(MIDDLE_NAMES.length)] : null;

            LocalDate dob = generateDateOfBirth();
            String email = generateEmail(firstName, lastName, i);
            String customerNumber = generateCustomerNumber(i);

            CustomerStatus status = generateStatus();

            Customer customer = Customer.builder()
                    .customerNumber(customerNumber)
                    .firstName(firstName)
                    .middleName(middleName)
                    .lastName(lastName)
                    .email(email)
                    .phone(generatePhoneNumber())
                    .mobilePhone(random.nextDouble() < 0.8 ? generatePhoneNumber() : null)
                    .dateOfBirth(dob)
                    .gender(gender)
                    .ssnLast4(generateSSNLast4())
                    .status(status)
                    .preferredLanguage(random.nextDouble() < 0.9 ? "en" : "es")
                    .marketingOptIn(random.nextBoolean())
                    .smsOptIn(random.nextBoolean())
                    .emailVerified(status == CustomerStatus.ACTIVE || random.nextDouble() < 0.5)
                    .phoneVerified(random.nextDouble() < 0.3)
                    .build();

            // Add addresses (1-3 per customer)
            int numAddresses = 1 + random.nextInt(3);
            Set<Address> addresses = generateAddresses(customer, numAddresses);
            customer.setAddresses(addresses);

            // Add dependents (0-4 per customer, based on age)
            int age = LocalDate.now().getYear() - dob.getYear();
            if (age >= 25 && random.nextDouble() < 0.6) {
                int numDependents = random.nextInt(5);
                Set<Dependent> dependents = generateDependents(customer, numDependents, lastName);
                customer.setDependents(dependents);
            }

            // Add documents (0-3 per customer)
            if (random.nextDouble() < 0.4) {
                int numDocs = 1 + random.nextInt(3);
                Set<CustomerDocument> documents = generateDocuments(customer, numDocs);
                customer.setDocuments(documents);
            }

            customers.add(customer);

            if ((i + 1) % 1000 == 0) {
                log.info("  Generated {} customers...", i + 1);
            }
        }

        return customers;
    }

    private Set<Address> generateAddresses(Customer customer, int count) {
        Set<Address> addresses = new HashSet<>();
        AddressType[] types = {AddressType.HOME, AddressType.MAILING, AddressType.WORK};

        for (int i = 0; i < count && i < types.length; i++) {
            String[] cityState = CITIES_BY_STATE[random.nextInt(CITIES_BY_STATE.length)];
            String stateCode = cityState[0];
            String city = cityState[1 + random.nextInt(cityState.length - 1)];

            Address address = Address.builder()
                    .customer(customer)
                    .addressType(types[i])
                    .addressLine1(generateStreetAddress())
                    .addressLine2(random.nextDouble() < 0.3 ? generateAptNumber() : null)
                    .city(city)
                    .stateCode(stateCode)
                    .zipCode(generateZipCode())
                    .country("US")
                    .isPrimary(i == 0)
                    .isVerified(random.nextDouble() < 0.7)
                    .build();

            addresses.add(address);
        }

        return addresses;
    }

    private Set<Dependent> generateDependents(Customer customer, int count, String lastName) {
        Set<Dependent> dependents = new HashSet<>();

        // Maybe add spouse
        if (count > 0 && random.nextDouble() < 0.7) {
            Gender spouseGender = customer.getGender() == Gender.MALE ? Gender.FEMALE : Gender.MALE;
            String spouseFirstName = spouseGender == Gender.MALE
                    ? FIRST_NAMES_MALE[random.nextInt(FIRST_NAMES_MALE.length)]
                    : FIRST_NAMES_FEMALE[random.nextInt(FIRST_NAMES_FEMALE.length)];

            Dependent spouse = Dependent.builder()
                    .customer(customer)
                    .firstName(spouseFirstName)
                    .middleName(random.nextDouble() < 0.5 ? MIDDLE_NAMES[random.nextInt(MIDDLE_NAMES.length)] : null)
                    .lastName(lastName)
                    .dateOfBirth(generateSpouseDOB(customer.getDateOfBirth()))
                    .gender(spouseGender)
                    .relationship(RelationshipType.SPOUSE)
                    .ssnLast4(generateSSNLast4())
                    .isDisabled(random.nextDouble() < 0.02)
                    .isStudent(false)
                    .build();

            dependents.add(spouse);
            count--;
        }

        // Add children
        for (int i = 0; i < count; i++) {
            Gender childGender = random.nextBoolean() ? Gender.MALE : Gender.FEMALE;
            String childFirstName = childGender == Gender.MALE
                    ? FIRST_NAMES_MALE[random.nextInt(FIRST_NAMES_MALE.length)]
                    : FIRST_NAMES_FEMALE[random.nextInt(FIRST_NAMES_FEMALE.length)];

            LocalDate childDOB = generateChildDOB();
            int childAge = LocalDate.now().getYear() - childDOB.getYear();

            Dependent child = Dependent.builder()
                    .customer(customer)
                    .firstName(childFirstName)
                    .middleName(random.nextDouble() < 0.3 ? MIDDLE_NAMES[random.nextInt(MIDDLE_NAMES.length)] : null)
                    .lastName(lastName)
                    .dateOfBirth(childDOB)
                    .gender(childGender)
                    .relationship(RelationshipType.CHILD)
                    .ssnLast4(generateSSNLast4())
                    .isDisabled(random.nextDouble() < 0.03)
                    .isStudent(childAge >= 18 && childAge <= 26 && random.nextDouble() < 0.6)
                    .build();

            dependents.add(child);
        }

        return dependents;
    }

    private Set<CustomerDocument> generateDocuments(Customer customer, int count) {
        Set<CustomerDocument> documents = new HashSet<>();
        DocumentType[] types = DocumentType.values();

        for (int i = 0; i < count; i++) {
            DocumentType docType = types[random.nextInt(types.length)];
            DocumentStatus status = generateDocumentStatus();

            CustomerDocument doc = CustomerDocument.builder()
                    .customer(customer)
                    .documentType(docType)
                    .documentName(docType.name().toLowerCase().replace("_", "-") + "-" + customer.getCustomerNumber() + ".pdf")
                    .filePath("/documents/" + customer.getId() + "/" + UUID.randomUUID() + ".pdf")
                    .fileSize((long) (50000 + random.nextInt(500000)))
                    .mimeType("application/pdf")
                    .status(status)
                    .expirationDate(docType == DocumentType.DRIVERS_LICENSE || docType == DocumentType.PASSPORT
                            ? LocalDate.now().plusYears(1 + random.nextInt(5)) : null)
                    .verifiedBy(status == DocumentStatus.VERIFIED ? "system-auto" : null)
                    .rejectionReason(status == DocumentStatus.REJECTED ? "Document image unclear" : null)
                    .build();

            documents.add(doc);
        }

        return documents;
    }

    private void generateEnrollments(List<Customer> customers) {
        log.info("Generating enrollments for customers...");

        List<CustomerPlanEnrollment> enrollments = new ArrayList<>();
        int enrollmentCount = 0;

        // Only active customers get enrollments
        List<Customer> activeCustomers = customers.stream()
                .filter(c -> c.getStatus() == CustomerStatus.ACTIVE)
                .toList();

        for (Customer customer : activeCustomers) {
            // 60% of active customers have enrollments
            if (random.nextDouble() < 0.6) {
                // 1-2 enrollments per customer
                int numEnrollments = 1 + (random.nextDouble() < 0.2 ? 1 : 0);

                for (int i = 0; i < numEnrollments; i++) {
                    UUID planId = UUID.randomUUID(); // Would be real plan ID in production
                    EnrollmentStatus status = i == 0 ? EnrollmentStatus.ENROLLED : EnrollmentStatus.EXPIRED;

                    BigDecimal premium = BigDecimal.valueOf(250 + random.nextInt(400));
                    BigDecimal subsidy = random.nextDouble() < 0.4
                            ? BigDecimal.valueOf(50 + random.nextInt(150))
                            : BigDecimal.ZERO;

                    LocalDate effectiveDate = i == 0
                            ? LocalDate.now().withDayOfMonth(1)
                            : LocalDate.now().minusYears(1).withDayOfMonth(1);

                    CustomerPlanEnrollment enrollment = CustomerPlanEnrollment.builder()
                            .customer(customer)
                            .planId(planId)
                            .planCode("PLN-" + planId.toString().substring(0, 8).toUpperCase())
                            .planName(generatePlanName())
                            .status(status)
                            .effectiveDate(effectiveDate)
                            .terminationDate(status == EnrollmentStatus.EXPIRED
                                    ? effectiveDate.plusYears(1).minusDays(1) : null)
                            .monthlyPremium(premium)
                            .subsidyAmount(subsidy)
                            .memberId("MBR" + customer.getCustomerNumber() + effectiveDate.getYear())
                            .groupNumber("GRP" + effectiveDate.getYear())
                            .includeDependents(!customer.getDependents().isEmpty() && random.nextBoolean())
                            .autoRenew(status == EnrollmentStatus.ENROLLED)
                            .cancellationReason(status == EnrollmentStatus.EXPIRED ? "Policy year ended" : null)
                            .build();

                    enrollments.add(enrollment);
                    enrollmentCount++;

                    // Also create eligibility check
                    EligibilityCheck eligibility = EligibilityCheck.builder()
                            .customer(customer)
                            .planId(planId)
                            .status(EligibilityStatus.ELIGIBLE)
                            .checkDate(effectiveDate.minusDays(30).atStartOfDay())
                            .expirationDate(effectiveDate.plusDays(30).atStartOfDay())
                            .eligibilityReason("Customer meets all eligibility requirements")
                            .incomeVerified(true)
                            .residenceVerified(true)
                            .ageVerified(true)
                            .checkedBy("system-auto")
                            .build();

                    eligibilityRepository.save(eligibility);
                }
            }
        }

        // Save enrollments in batches
        int batchSize = 500;
        for (int i = 0; i < enrollments.size(); i += batchSize) {
            int end = Math.min(i + batchSize, enrollments.size());
            enrollmentRepository.saveAll(enrollments.subList(i, end));
        }

        log.info("  Created {} enrollments", enrollmentCount);
    }

    // Helper methods

    private String generateCustomerNumber(int sequence) {
        return String.format("CUS%09d", sequence + 1);
    }

    private LocalDate generateDateOfBirth() {
        // Ages between 18 and 85
        int age = 18 + random.nextInt(67);
        int year = LocalDate.now().getYear() - age;
        int dayOfYear = 1 + random.nextInt(365);
        return LocalDate.ofYearDay(year, dayOfYear);
    }

    private LocalDate generateSpouseDOB(LocalDate customerDOB) {
        // Spouse within +/- 10 years of customer
        int offset = random.nextInt(21) - 10;
        return customerDOB.plusYears(offset);
    }

    private LocalDate generateChildDOB() {
        // Children between 0 and 26 years old
        int age = random.nextInt(27);
        int year = LocalDate.now().getYear() - age;
        int dayOfYear = 1 + random.nextInt(365);
        return LocalDate.ofYearDay(year, dayOfYear);
    }

    private String generateEmail(String firstName, String lastName, int sequence) {
        String domain = EMAIL_DOMAINS[random.nextInt(EMAIL_DOMAINS.length)];
        String base = firstName.toLowerCase() + "." + lastName.toLowerCase();

        // Always use sequence to guarantee uniqueness
        return (base + "." + sequence).replaceAll("[^a-z0-9.]", "") + "@" + domain;
    }

    private String generatePhoneNumber() {
        return String.format("(%03d) %03d-%04d",
                200 + random.nextInt(800),
                200 + random.nextInt(800),
                random.nextInt(10000));
    }

    private String generateSSNLast4() {
        return String.format("%04d", random.nextInt(10000));
    }

    private String generateStreetAddress() {
        int number = 1 + random.nextInt(9999);
        String street = STREET_NAMES[random.nextInt(STREET_NAMES.length)];
        return number + " " + street;
    }

    private String generateAptNumber() {
        String type = APT_TYPES[random.nextInt(APT_TYPES.length)];
        String number = String.valueOf(1 + random.nextInt(500));
        if (random.nextBoolean()) {
            number = (char) ('A' + random.nextInt(26)) + number;
        }
        return type + " " + number;
    }

    private String generateZipCode() {
        return String.format("%05d", 10000 + random.nextInt(89999));
    }

    private CustomerStatus generateStatus() {
        double r = random.nextDouble();
        if (r < 0.75) return CustomerStatus.ACTIVE;
        if (r < 0.85) return CustomerStatus.PENDING;
        if (r < 0.92) return CustomerStatus.INACTIVE;
        if (r < 0.97) return CustomerStatus.SUSPENDED;
        return CustomerStatus.TERMINATED;
    }

    private DocumentStatus generateDocumentStatus() {
        double r = random.nextDouble();
        if (r < 0.6) return DocumentStatus.VERIFIED;
        if (r < 0.8) return DocumentStatus.PENDING;
        if (r < 0.95) return DocumentStatus.REJECTED;
        return DocumentStatus.EXPIRED;
    }

    private String generatePlanName() {
        String[] prefixes = {"HealthFirst", "CareShield", "MediGuard", "WellCare", "LifePlus"};
        String[] tiers = {"Bronze", "Silver", "Gold", "Platinum"};
        String[] suffixes = {"Essential", "Plus", "Premium", "Select"};

        return prefixes[random.nextInt(prefixes.length)] + " " +
                tiers[random.nextInt(tiers.length)] + " " +
                suffixes[random.nextInt(suffixes.length)];
    }
}