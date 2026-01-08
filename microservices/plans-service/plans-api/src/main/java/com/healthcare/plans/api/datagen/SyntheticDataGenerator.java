package com.healthcare.plans.api.datagen;

import com.healthcare.plans.common.constants.*;
import com.healthcare.plans.common.model.*;
import com.healthcare.plans.dao.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

@Slf4j
@Component
@Profile("datagen")
@RequiredArgsConstructor
public class SyntheticDataGenerator implements CommandLineRunner {

    private final PlanRepository planRepository;
    private final StateRepository stateRepository;
    private final AgeGroupRepository ageGroupRepository;
    private final PlanCategoryRepository categoryRepository;
    private final SpecialtyRepository specialtyRepository;
    private final HealthcareProviderRepository providerRepository;
    private final HealthcareSpecialistRepository specialistRepository;
    private final PlanProviderRepository planProviderRepository;

    private static final int NUM_PLANS = 10_000;
    private static final int NUM_PROVIDERS = 10_000;
    private static final int NUM_SPECIALISTS = 10_000;

    private final Random random = new Random(42); // Fixed seed for reproducibility

    // Plan name components
    private static final String[] PLAN_PREFIXES = {
            "HealthFirst", "CareShield", "MediGuard", "WellCare", "LifePlus",
            "SecureHealth", "PrimeCare", "VitalShield", "HealthyLife", "CarePlus",
            "MediChoice", "WellnessOne", "HealthBridge", "CareConnect", "MediPro",
            "LifeCare", "HealthMax", "SecureMed", "PrimeHealth", "VitalCare"
    };

    private static final String[] PLAN_SUFFIXES = {
            "Essential", "Plus", "Premium", "Select", "Advantage",
            "Complete", "Basic", "Enhanced", "Elite", "Value",
            "Standard", "Preferred", "Choice", "Flex", "Prime"
    };

    // Provider name components
    private static final String[] PROVIDER_PREFIXES = {
            "City", "Metro", "Regional", "Community", "Advanced",
            "Premier", "Central", "Valley", "Mountain", "Coastal",
            "Riverside", "Lakeside", "University", "Memorial", "St. Mary's"
    };

    private static final String[] PROVIDER_TYPES_NAMES = {
            "Medical Center", "Hospital", "Health System", "Clinic",
            "Healthcare", "Medical Group", "Health Partners", "Care Center"
    };

    // Specialist names
    private static final String[] FIRST_NAMES = {
            "James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda",
            "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
            "Thomas", "Sarah", "Charles", "Karen", "Christopher", "Nancy", "Daniel", "Lisa",
            "Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra", "Donald", "Ashley",
            "Steven", "Kimberly", "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle",
            "Raj", "Priya", "Wei", "Li", "Mohammed", "Fatima", "Carlos", "Maria"
    };

    private static final String[] LAST_NAMES = {
            "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
            "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
            "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
            "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
            "Patel", "Shah", "Kim", "Chen", "Wang", "Singh", "Kumar", "Ali", "Khan", "Nguyen"
    };

    private static final String[] CITIES_BY_STATE = {
            "New York,Los Angeles,Chicago,Houston,Phoenix,Philadelphia,San Antonio,San Diego",
            "Dallas,San Jose,Austin,Jacksonville,Fort Worth,Columbus,Indianapolis,Charlotte",
            "Seattle,Denver,Boston,Nashville,Detroit,Portland,Memphis,Louisville"
    };

    @Override
    @Transactional
    public void run(String... args) {
        log.info("=".repeat(80));
        log.info("Starting Synthetic Data Generation");
        log.info("=".repeat(80));

        long existingPlans = planRepository.count();
        if (existingPlans > 100) {
            log.info("Database already has {} plans. Skipping data generation.", existingPlans);
            return;
        }

        List<State> states = stateRepository.findAll();
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();
        List<PlanCategory> categories = categoryRepository.findAll();
        List<Specialty> specialties = specialtyRepository.findAll();

        log.info("Found {} states, {} age groups, {} categories, {} specialties",
                states.size(), ageGroups.size(), categories.size(), specialties.size());

        // Generate data
        List<Plan> plans = generatePlans(states, ageGroups, categories);
        List<HealthcareProvider> providers = generateProviders(states);
        List<HealthcareSpecialist> specialists = generateSpecialists(specialties);

        // Save data
        log.info("Saving {} plans...", plans.size());
        planRepository.saveAll(plans);

        log.info("Saving {} providers...", providers.size());
        providerRepository.saveAll(providers);

        log.info("Saving {} specialists...", specialists.size());
        specialistRepository.saveAll(specialists);

        // Link providers to plans
        linkProvidersToPlans(plans, providers);

        log.info("=".repeat(80));
        log.info("Synthetic Data Generation Complete!");
        log.info("  Plans: {}", plans.size());
        log.info("  Providers: {}", providers.size());
        log.info("  Specialists: {}", specialists.size());
        log.info("=".repeat(80));
    }

    private List<Plan> generatePlans(List<State> states, List<AgeGroup> ageGroups, List<PlanCategory> categories) {
        log.info("Generating {} plans...", NUM_PLANS);
        List<Plan> plans = new ArrayList<>();

        int[] years = {2024, 2025, 2026};
        PlanType[] planTypes = PlanType.values();
        MetalTier[] metalTiers = MetalTier.values();

        for (int i = 0; i < NUM_PLANS; i++) {
            int year = years[random.nextInt(years.length)];
            PlanType planType = planTypes[random.nextInt(planTypes.length)];
            MetalTier metalTier = metalTiers[random.nextInt(metalTiers.length)];
            boolean isNational = random.nextDouble() < 0.1; // 10% national plans

            State state = isNational ? null : states.get(random.nextInt(states.size()));
            String stateCode = isNational ? "NAT" : state.getCode();

            String planName = generatePlanName(planType, metalTier);
            String planCode = generatePlanCode(year, stateCode, metalTier, i);

            BigDecimal basePremium = getBasePremium(metalTier);
            BigDecimal premium = adjustPremium(basePremium, planType, state);

            Plan plan = Plan.builder()
                    .planCode(planCode)
                    .planName(planName)
                    .year(year)
                    .state(state)
                    .isNational(isNational)
                    .planType(planType)
                    .metalTier(metalTier)
                    .monthlyPremium(premium)
                    .annualDeductible(getDeductible(metalTier))
                    .outOfPocketMax(getOutOfPocketMax(metalTier))
                    .copayPrimary(getCopay(metalTier, "primary"))
                    .copaySpecialist(getCopay(metalTier, "specialist"))
                    .copayEmergency(getCopay(metalTier, "emergency"))
                    .outOfNetworkPct(getOutOfNetworkPct(planType))
                    .status(PlanStatus.ACTIVE)
                    .effectiveDate(LocalDate.of(year, 1, 1))
                    .expirationDate(LocalDate.of(year, 12, 31))
                    .ageGroups(getRandomSubset(ageGroups, 2, 4))
                    .categories(getRandomSubset(categories, 1, 3))
                    .build();
            plan.setCreatedAt(LocalDateTime.now());
            plan.setUpdatedAt(LocalDateTime.now());

            // Add inclusions
            addInclusions(plan, metalTier);

            // Add exclusions
            addExclusions(plan);

            plans.add(plan);

            if ((i + 1) % 1000 == 0) {
                log.info("  Generated {} plans...", i + 1);
            }
        }

        return plans;
    }

    private List<HealthcareProvider> generateProviders(List<State> states) {
        log.info("Generating {} providers...", NUM_PROVIDERS);
        List<HealthcareProvider> providers = new ArrayList<>();

        ProviderType[] providerTypes = ProviderType.values();
        NetworkTier[] networkTiers = NetworkTier.values();

        for (int i = 0; i < NUM_PROVIDERS; i++) {
            State state = states.get(random.nextInt(states.size()));
            ProviderType providerType = providerTypes[random.nextInt(providerTypes.length)];

            String name = generateProviderName();
            String code = String.format("PRV-%s-%05d", state.getCode(), i);

            HealthcareProvider provider = HealthcareProvider.builder()
                    .providerCode(code)
                    .name(name)
                    .providerType(providerType)
                    .addressLine1(generateStreetAddress())
                    .city(generateCity())
                    .state(state)
                    .zipCode(generateZipCode())
                    .phone(generatePhoneNumber())
                    .email(generateEmail(name))
                    .latitude(generateLatitude())
                    .longitude(generateLongitude())
                    .networkTier(networkTiers[random.nextInt(networkTiers.length)])
                    .acceptingPatients(random.nextDouble() > 0.1) // 90% accepting
                    .status("active")
                    .build();
            provider.setCreatedAt(LocalDateTime.now());
            provider.setUpdatedAt(LocalDateTime.now());

            providers.add(provider);

            if ((i + 1) % 1000 == 0) {
                log.info("  Generated {} providers...", i + 1);
            }
        }

        return providers;
    }

    private List<HealthcareSpecialist> generateSpecialists(List<Specialty> specialties) {
        log.info("Generating {} specialists...", NUM_SPECIALISTS);
        List<HealthcareSpecialist> specialists = new ArrayList<>();

        String[] titles = {"MD", "DO", "MD, PhD", "MD, FACP", "DO, FACEP"};

        for (int i = 0; i < NUM_SPECIALISTS; i++) {
            Specialty specialty = specialties.get(random.nextInt(specialties.size()));

            String firstName = FIRST_NAMES[random.nextInt(FIRST_NAMES.length)];
            String lastName = LAST_NAMES[random.nextInt(LAST_NAMES.length)];
            String npi = generateNPI(i);

            HealthcareSpecialist specialist = HealthcareSpecialist.builder()
                    .npiNumber(npi)
                    .firstName(firstName)
                    .lastName(lastName)
                    .title(titles[random.nextInt(titles.length)])
                    .specialty(specialty)
                    .email(generateDoctorEmail(firstName, lastName))
                    .phone(generatePhoneNumber())
                    .yearsExperience(5 + random.nextInt(30))
                    .languages(generateLanguages())
                    .acceptingPatients(random.nextDouble() > 0.15) // 85% accepting
                    .status("active")
                    .build();

            specialist.setCreatedAt(LocalDateTime.now());
            specialist.setUpdatedAt(LocalDateTime.now());

            specialists.add(specialist);

            if ((i + 1) % 1000 == 0) {
                log.info("  Generated {} specialists...", i + 1);
            }
        }

        return specialists;
    }

    private void linkProvidersToPlans(List<Plan> plans, List<HealthcareProvider> providers) {
        log.info("Linking providers to plans...");

        List<PlanProvider> planProviders = new ArrayList<>();
        int linkCount = 0;

        for (Plan plan : plans) {
            // Each plan has 50-200 in-network providers
            int numProviders = 50 + random.nextInt(150);
            Set<Integer> selectedIndices = new HashSet<>();

            while (selectedIndices.size() < numProviders && selectedIndices.size() < providers.size()) {
                selectedIndices.add(random.nextInt(providers.size()));
            }

            for (int idx : selectedIndices) {
                HealthcareProvider provider = providers.get(idx);

                PlanProvider pp = PlanProvider.builder()
                        .id(new PlanProviderId(plan.getId(), provider.getId()))
                        .plan(plan)
                        .provider(provider)
                        .networkStatus(NetworkStatus.IN_NETWORK)
                        .effectiveDate(plan.getEffectiveDate())
                        .build();

                planProviders.add(pp);
                linkCount++;
            }

            if (planProviders.size() >= 10000) {
                planProviderRepository.saveAll(planProviders);
                planProviders.clear();
                log.info("  Saved {} plan-provider links...", linkCount);
            }
        }

        if (!planProviders.isEmpty()) {
            planProviderRepository.saveAll(planProviders);
        }

        log.info("  Total plan-provider links: {}", linkCount);
    }

    // Helper methods

    private String generatePlanName(PlanType planType, MetalTier metalTier) {
        String prefix = PLAN_PREFIXES[random.nextInt(PLAN_PREFIXES.length)];
        String suffix = PLAN_SUFFIXES[random.nextInt(PLAN_SUFFIXES.length)];
        return String.format("%s %s %s %s", prefix, metalTier.name(), planType.name(), suffix);
    }

    private String generatePlanCode(int year, String stateCode, MetalTier tier, int sequence) {
        return String.format("%s-%d-%s-%05d", tier.name().substring(0, 3), year, stateCode, sequence);
    }

    private BigDecimal getBasePremium(MetalTier tier) {
        return switch (tier) {
            case BRONZE -> BigDecimal.valueOf(250 + random.nextInt(100));
            case SILVER -> BigDecimal.valueOf(350 + random.nextInt(100));
            case GOLD -> BigDecimal.valueOf(450 + random.nextInt(100));
            case PLATINUM -> BigDecimal.valueOf(550 + random.nextInt(150));
        };
    }

    private BigDecimal adjustPremium(BigDecimal base, PlanType type, State state) {
        double multiplier = 1.0;

        // Adjust by plan type
        multiplier *= switch (type) {
            case HMO -> 0.9;
            case PPO -> 1.1;
            case EPO -> 0.95;
            case POS -> 1.0;
            case HDHP -> 0.8;
        };

        // Adjust by state (simplified - high cost states)
        if (state != null) {
            String code = state.getCode();
            if (Set.of("CA", "NY", "MA", "CT", "NJ").contains(code)) {
                multiplier *= 1.2;
            } else if (Set.of("TX", "FL", "AZ", "GA").contains(code)) {
                multiplier *= 0.95;
            }
        }

        return base.multiply(BigDecimal.valueOf(multiplier)).setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal getDeductible(MetalTier tier) {
        return switch (tier) {
            case BRONZE -> BigDecimal.valueOf(6000 + random.nextInt(1500));
            case SILVER -> BigDecimal.valueOf(3000 + random.nextInt(1000));
            case GOLD -> BigDecimal.valueOf(1000 + random.nextInt(500));
            case PLATINUM -> BigDecimal.valueOf(0 + random.nextInt(500));
        };
    }

    private BigDecimal getOutOfPocketMax(MetalTier tier) {
        return switch (tier) {
            case BRONZE -> BigDecimal.valueOf(8000 + random.nextInt(1000));
            case SILVER -> BigDecimal.valueOf(6000 + random.nextInt(1000));
            case GOLD -> BigDecimal.valueOf(4000 + random.nextInt(1000));
            case PLATINUM -> BigDecimal.valueOf(2000 + random.nextInt(1000));
        };
    }

    private BigDecimal getCopay(MetalTier tier, String type) {
        int base = switch (tier) {
            case BRONZE -> 40;
            case SILVER -> 30;
            case GOLD -> 20;
            case PLATINUM -> 10;
        };

        int multiplier = switch (type) {
            case "primary" -> 1;
            case "specialist" -> 2;
            case "emergency" -> 5;
            default -> 1;
        };

        return BigDecimal.valueOf(base * multiplier + random.nextInt(10));
    }

    private Integer getOutOfNetworkPct(PlanType type) {
        return switch (type) {
            case HMO -> 0;
            case EPO -> 0;
            case PPO -> 60 + random.nextInt(20);
            case POS -> 50 + random.nextInt(20);
            case HDHP -> 50 + random.nextInt(30);
        };
    }

    private void addInclusions(Plan plan, MetalTier tier) {
        String[][] inclusions = {
                {"PREV_CARE", "Preventive Care", "Annual physicals, screenings, immunizations"},
                {"HOSP_STAY", "Hospital Stay", "Inpatient hospital services"},
                {"SURG", "Surgery", "Inpatient and outpatient surgical procedures"},
                {"EMER", "Emergency Services", "Emergency room visits"},
                {"MENTAL", "Mental Health", "Mental health and substance abuse services"},
                {"MATERNITY", "Maternity Care", "Prenatal, delivery, and postnatal care"},
                {"PEDS", "Pediatric Services", "Services for children under 19"},
                {"RX", "Prescription Drugs", "Generic and brand-name medications"},
                {"LAB", "Lab Services", "Diagnostic tests and laboratory work"},
                {"REHAB", "Rehabilitation", "Physical, occupational, and speech therapy"}
        };

        Set<PlanInclusion> planInclusions = new HashSet<>();
        int numInclusions = 5 + random.nextInt(5);

        for (int i = 0; i < Math.min(numInclusions, inclusions.length); i++) {
            String[] inc = inclusions[i];
            PlanInclusion inclusion = PlanInclusion.builder()
                    .plan(plan)
                    .coverageItem(inc[0])
                    .coverageName(inc[1])
                    .description(inc[2])
                    .copayAmount(getCopay(tier, "primary"))
                    .coveragePercentage(tier.getCoveragePercentage())
                    .priorAuthRequired(random.nextDouble() < 0.3)
                    .build();
            inclusion.setCreatedAt(LocalDateTime.now());
            inclusion.setUpdatedAt(LocalDateTime.now());
            planInclusions.add(inclusion);
        }

        plan.setInclusions(planInclusions);
    }

    private void addExclusions(Plan plan) {
        String[][] exclusions = {
                {"COSMETIC", "Cosmetic Surgery", "Elective cosmetic procedures"},
                {"WEIGHT_LOSS", "Weight Loss Surgery", "Bariatric surgery (unless medically necessary)"},
                {"FERTILITY", "Fertility Treatments", "IVF and fertility treatments"},
                {"DENTAL_ADULT", "Adult Dental", "Routine dental care for adults"},
                {"VISION_ADULT", "Adult Vision", "Routine vision care for adults"},
                {"EXPERIMENTAL", "Experimental Treatments", "Experimental or investigational procedures"}
        };

        Set<PlanExclusion> planExclusions = new HashSet<>();
        int numExclusions = 2 + random.nextInt(3);

        List<String[]> shuffled = new ArrayList<>(Arrays.asList(exclusions));
        Collections.shuffle(shuffled, random);

        for (int i = 0; i < Math.min(numExclusions, shuffled.size()); i++) {
            String[] exc = shuffled.get(i);
            PlanExclusion exclusion = PlanExclusion.builder()
                    .plan(plan)
                    .exclusionItem(exc[0])
                    .exclusionName(exc[1])
                    .description(exc[2])
                    .build();
            exclusion.setCreatedAt(LocalDateTime.now());
            exclusion.setUpdatedAt(LocalDateTime.now());
            planExclusions.add(exclusion);
        }

        plan.setExclusions(planExclusions);
    }

    private <T> Set<T> getRandomSubset(List<T> list, int min, int max) {
        int count = min + random.nextInt(max - min + 1);
        Set<T> result = new HashSet<>();
        List<T> shuffled = new ArrayList<>(list);
        Collections.shuffle(shuffled, random);
        for (int i = 0; i < Math.min(count, shuffled.size()); i++) {
            result.add(shuffled.get(i));
        }
        return result;
    }

    private String generateProviderName() {
        String prefix = PROVIDER_PREFIXES[random.nextInt(PROVIDER_PREFIXES.length)];
        String type = PROVIDER_TYPES_NAMES[random.nextInt(PROVIDER_TYPES_NAMES.length)];
        return prefix + " " + type;
    }

    private String generateStreetAddress() {
        int number = 100 + random.nextInt(9900);
        String[] streets = {"Main St", "Oak Ave", "Park Blvd", "Medical Dr", "Health Way", "Center St", "Hospital Rd"};
        return number + " " + streets[random.nextInt(streets.length)];
    }

    private String generateCity() {
        String[] cities = {"Springfield", "Riverside", "Franklin", "Clinton", "Madison", "Georgetown", "Salem", "Bristol"};
        return cities[random.nextInt(cities.length)];
    }

    private String generateZipCode() {
        return String.format("%05d", 10000 + random.nextInt(89999));
    }

    private String generatePhoneNumber() {
        return String.format("(%03d) %03d-%04d",
                200 + random.nextInt(800),
                200 + random.nextInt(800),
                random.nextInt(10000));
    }

    private String generateEmail(String name) {
        String clean = name.toLowerCase().replaceAll("[^a-z0-9]", "");
        return clean + "@healthcare.example.com";
    }

    private String generateDoctorEmail(String firstName, String lastName) {
        return firstName.toLowerCase() + "." + lastName.toLowerCase() + "@medical.example.com";
    }

    private BigDecimal generateLatitude() {
        // Continental US roughly: 25 to 49
        double lat = 25.0 + random.nextDouble() * 24.0;
        return BigDecimal.valueOf(lat).setScale(6, RoundingMode.HALF_UP);
    }

    private BigDecimal generateLongitude() {
        // Continental US roughly: -125 to -70
        double lon = -125.0 + random.nextDouble() * 55.0;
        return BigDecimal.valueOf(lon).setScale(6, RoundingMode.HALF_UP);
    }

    private String generateNPI(int sequence) {
        // NPI is 10 digits
        return String.format("1%09d", sequence);
    }

    private String generateLanguages() {
        String[][] languageSets = {
                {"English"},
                {"English", "Spanish"},
                {"English", "Mandarin"},
                {"English", "Spanish", "French"},
                {"English", "Hindi"},
                {"English", "Arabic"},
                {"English", "Vietnamese"},
                {"English", "Korean"}
        };
        String[] langs = languageSets[random.nextInt(languageSets.length)];
        return String.join(", ", langs);
    }
}