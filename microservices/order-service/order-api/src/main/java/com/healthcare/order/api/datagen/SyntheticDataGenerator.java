package com.healthcare.order.api.datagen;

import com.healthcare.order.common.constants.*;
import com.healthcare.order.common.model.*;
import com.healthcare.order.dao.repository.*;
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
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Component
@Profile("datagen")
@RequiredArgsConstructor
public class SyntheticDataGenerator implements CommandLineRunner {

    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;
    private final InvoiceRepository invoiceRepository;
    private final SavedPaymentMethodRepository savedPaymentMethodRepository;

    private static final int NUM_ORDERS = 10_000;

    private final Random random = new Random(42);

    private int paymentSequence = 0;
    private int invoiceSequence = 0;

    // Customer data simulation (would come from customer-service in production)
    private static final String[] FIRST_NAMES = {
            "James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda",
            "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
            "Thomas", "Sarah", "Charles", "Karen", "Christopher", "Nancy", "Daniel", "Lisa"
    };

    private static final String[] LAST_NAMES = {
            "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
            "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
            "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson"
    };

    private static final String[] EMAIL_DOMAINS = {
            "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com"
    };

    // Plan data simulation (would come from plans-service in production)
    private static final String[] PLAN_PREFIXES = {
            "HealthFirst", "CareShield", "MediGuard", "WellCare", "LifePlus"
    };

    private static final String[] METAL_TIERS = {"BRONZE", "SILVER", "GOLD", "PLATINUM"};

    private static final String[] PLAN_TYPES = {"HMO", "PPO", "EPO", "POS", "HDHP"};

    private static final String[] PROMO_CODES = {
            "SAVE10", "WELCOME15", "NEWUSER20", "HEALTH25", "FAMILY10", null, null, null
    };

    @Override
    @Transactional
    public void run(String... args) {
        log.info("=".repeat(80));
        log.info("Starting Order Synthetic Data Generation");
        log.info("=".repeat(80));

        long existingOrders = orderRepository.count();
        if (existingOrders > 100) {
            log.info("Database already has {} orders. Skipping data generation.", existingOrders);
            return;
        }

        // Generate saved payment methods first
        Map<UUID, List<SavedPaymentMethod>> customerPaymentMethods = generateSavedPaymentMethods();

        // Generate orders
        List<Order> orders = generateOrders(customerPaymentMethods);

        log.info("=".repeat(80));
        log.info("Order Synthetic Data Generation Complete!");
        log.info("  Orders: {}", orders.size());
        log.info("  Saved Payment Methods: {}", customerPaymentMethods.values().stream().mapToInt(List::size).sum());
        log.info("=".repeat(80));
    }

    private Map<UUID, List<SavedPaymentMethod>> generateSavedPaymentMethods() {
        log.info("Generating saved payment methods...");
        Map<UUID, List<SavedPaymentMethod>> customerMethods = new HashMap<>();

        // Generate payment methods for ~3000 unique customers
        int numCustomers = 3000;
        List<SavedPaymentMethod> allMethods = new ArrayList<>();

        for (int i = 0; i < numCustomers; i++) {
            UUID customerId = UUID.randomUUID();
            List<SavedPaymentMethod> methods = new ArrayList<>();

            // 1-3 payment methods per customer
            int numMethods = 1 + random.nextInt(3);
            for (int j = 0; j < numMethods; j++) {
                SavedPaymentMethod method = generatePaymentMethod(customerId, j == 0);
                methods.add(method);
                allMethods.add(method);
            }

            customerMethods.put(customerId, methods);

            if ((i + 1) % 500 == 0) {
                log.info("  Generated payment methods for {} customers...", i + 1);
            }
        }

        // Save in batches
        int batchSize = 500;
        for (int i = 0; i < allMethods.size(); i += batchSize) {
            int end = Math.min(i + batchSize, allMethods.size());
            savedPaymentMethodRepository.saveAll(allMethods.subList(i, end));
        }

        log.info("  Saved {} payment methods for {} customers", allMethods.size(), numCustomers);
        return customerMethods;
    }

    private List<Order> generateOrders(Map<UUID, List<SavedPaymentMethod>> customerPaymentMethods) {
        log.info("Generating {} orders...", NUM_ORDERS);
        List<Order> orders = new ArrayList<>();

        List<UUID> customerIds = new ArrayList<>(customerPaymentMethods.keySet());
        // Add more customer IDs for customers without saved payment methods
        for (int i = 0; i < 2000; i++) {
            customerIds.add(UUID.randomUUID());
        }

        for (int i = 0; i < NUM_ORDERS; i++) {
            UUID customerId = customerIds.get(random.nextInt(customerIds.size()));
            Order order = generateOrder(customerId, i);
            orders.add(order);

            // Save order first
            Order savedOrder = orderRepository.save(order);

            // Generate payments for non-draft, non-cancelled orders
            if (savedOrder.getStatus() != OrderStatus.DRAFT &&
                    savedOrder.getStatus() != OrderStatus.CANCELLED) {

                List<SavedPaymentMethod> methods = customerPaymentMethods.get(customerId);
                generatePaymentsForOrder(savedOrder, methods);
            }

            // Generate invoice for confirmed/completed orders
            if (savedOrder.getStatus() == OrderStatus.CONFIRMED ||
                    savedOrder.getStatus() == OrderStatus.COMPLETED ||
                    savedOrder.getStatus() == OrderStatus.PROCESSING) {
                generateInvoiceForOrder(savedOrder);
            }

            if ((i + 1) % 1000 == 0) {
                log.info("  Generated {} orders...", i + 1);
            }
        }

        return orders;
    }

    private Order generateOrder(UUID customerId, int sequence) {
        String firstName = FIRST_NAMES[random.nextInt(FIRST_NAMES.length)];
        String lastName = LAST_NAMES[random.nextInt(LAST_NAMES.length)];
        String email = (firstName.toLowerCase() + "." + lastName.toLowerCase() + sequence + "@" +
                EMAIL_DOMAINS[random.nextInt(EMAIL_DOMAINS.length)]).replaceAll("[^a-z0-9.@]", "");

        OrderType orderType = generateOrderType();
        OrderStatus status = generateOrderStatus();
        BillingFrequency frequency = generateBillingFrequency();

        LocalDate effectiveDate = generateEffectiveDate(status);
        String promoCode = PROMO_CODES[random.nextInt(PROMO_CODES.length)];

        Order order = Order.builder()
                .orderNumber(generateOrderNumber(sequence))
                .customerId(customerId)
                .customerNumber(String.format("CUS%09d", sequence))
                .customerName(firstName + " " + lastName)
                .customerEmail(email)
                .orderType(orderType)
                .status(status)
                .billingFrequency(frequency)
                .effectiveDate(effectiveDate)
                .promoCode(promoCode)
                .notes(random.nextDouble() < 0.2 ? generateNotes() : null)
                .build();

        // Set timestamps based on status
        LocalDateTime createdAt = generateCreatedAt(status);
        order.setSubmittedAt(status != OrderStatus.DRAFT ? createdAt.plusMinutes(random.nextInt(60)) : null);
        order.setCompletedAt(status == OrderStatus.COMPLETED ? createdAt.plusDays(random.nextInt(30)) : null);

        if (status == OrderStatus.CANCELLED) {
            order.setCancelledAt(createdAt.plusDays(random.nextInt(7)));
            order.setCancellationReason(generateCancellationReason());
        }

        // Generate 1-3 order items
        int numItems = 1 + random.nextInt(3);
        for (int j = 0; j < numItems; j++) {
            OrderItem item = generateOrderItem(order);
            order.addItem(item);
        }

        // Apply discount if promo code exists
        if (promoCode != null) {
            BigDecimal discountPct = BigDecimal.valueOf(Integer.parseInt(
                    promoCode.replaceAll("[^0-9]", ""))).divide(BigDecimal.valueOf(100));
            order.setDiscountAmount(order.getSubtotal().multiply(discountPct).setScale(2, RoundingMode.HALF_UP));
        }

        // Add tax (simplified - 5% tax rate)
        order.setTaxAmount(order.getSubtotal().multiply(BigDecimal.valueOf(0.05)).setScale(2, RoundingMode.HALF_UP));

        order.recalculateTotals();

        return order;
    }

    private OrderItem generateOrderItem(Order order) {
        String metalTier = METAL_TIERS[random.nextInt(METAL_TIERS.length)];
        String planType = PLAN_TYPES[random.nextInt(PLAN_TYPES.length)];
        String planPrefix = PLAN_PREFIXES[random.nextInt(PLAN_PREFIXES.length)];

        UUID planId = UUID.randomUUID();
        BigDecimal unitPrice = generatePremium(metalTier, order.getBillingFrequency());
        BigDecimal subsidyAmount = random.nextDouble() < 0.3 ?
                BigDecimal.valueOf(50 + random.nextInt(150)) : BigDecimal.ZERO;

        int quantity = 1;
        boolean includeDependents = random.nextDouble() < 0.4;
        int dependentCount = includeDependents ? 1 + random.nextInt(4) : 0;

        BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(quantity))
                .subtract(subsidyAmount);
        if (totalPrice.compareTo(BigDecimal.ZERO) < 0) {
            totalPrice = BigDecimal.ZERO;
        }

        return OrderItem.builder()
                .order(order)
                .planId(planId)
                .planCode(metalTier.substring(0, 3) + "-" + LocalDate.now().getYear() + "-" +
                        planId.toString().substring(0, 8).toUpperCase())
                .planName(planPrefix + " " + metalTier + " " + planType)
                .planYear(LocalDate.now().getYear())
                .metalTier(metalTier)
                .description("Healthcare plan premium - " + order.getBillingFrequency().name().toLowerCase())
                .quantity(quantity)
                .unitPrice(unitPrice)
                .discountAmount(BigDecimal.ZERO)
                .subsidyAmount(subsidyAmount)
                .totalPrice(totalPrice)
                .includeDependents(includeDependents)
                .dependentCount(dependentCount)
                .build();
    }

    private void generatePaymentsForOrder(Order order, List<SavedPaymentMethod> savedMethods) {
        // Most orders have 1 payment, some have multiple (partial payments)
        int numPayments = random.nextDouble() < 0.1 ? 2 : 1;
        BigDecimal remainingAmount = order.getTotalAmount();

        for (int i = 0; i < numPayments && remainingAmount.compareTo(BigDecimal.ZERO) > 0; i++) {
            BigDecimal paymentAmount = numPayments == 1 ? remainingAmount :
                    remainingAmount.multiply(BigDecimal.valueOf(0.5 + random.nextDouble() * 0.5))
                            .setScale(2, RoundingMode.HALF_UP);

            Payment payment = generatePayment(order, paymentAmount, savedMethods);
            paymentRepository.save(payment);
            remainingAmount = remainingAmount.subtract(paymentAmount);
        }
    }

    private Payment generatePayment(Order order, BigDecimal amount, List<SavedPaymentMethod> savedMethods) {
        PaymentMethod method = generatePaymentMethodType();
        PaymentStatus status = generatePaymentStatus(order.getStatus());

        Payment payment = Payment.builder()
                .order(order)
                .paymentNumber(generatePaymentNumber())
                .paymentMethod(method)
                .status(status)
                .amount(amount)
                .currency("USD")
                .processingFee(amount.multiply(BigDecimal.valueOf(0.029)).setScale(2, RoundingMode.HALF_UP))
                .build();

        // Set payment details
        if (method == PaymentMethod.CREDIT_CARD || method == PaymentMethod.DEBIT_CARD) {
            CardBrand brand = CardBrand.values()[random.nextInt(CardBrand.values().length - 1)]; // Exclude OTHER
            payment.setCardBrand(brand);
            payment.setCardLast4(String.format("%04d", random.nextInt(10000)));
            payment.setCardExpiryMonth(1 + random.nextInt(12));
            payment.setCardExpiryYear(2026 + random.nextInt(5));
            payment.setBillingName(order.getCustomerName());
            payment.setBillingZip(String.format("%05d", 10000 + random.nextInt(90000)));
        } else if (method == PaymentMethod.ACH || method == PaymentMethod.BANK_TRANSFER) {
            payment.setBankName(generateBankName());
            payment.setAccountLast4(String.format("%04d", random.nextInt(10000)));
            payment.setRoutingLast4(String.format("%04d", random.nextInt(10000)));
        }

        // Set timestamps based on status
        if (status == PaymentStatus.COMPLETED) {
            payment.setTransactionId("TXN-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase());
            payment.setProcessedAt(order.getSubmittedAt() != null ?
                    order.getSubmittedAt().plusMinutes(random.nextInt(30)) : LocalDateTime.now());
        } else if (status == PaymentStatus.FAILED) {
            payment.setFailedAt(order.getSubmittedAt() != null ?
                    order.getSubmittedAt().plusMinutes(random.nextInt(10)) : LocalDateTime.now());
            payment.setFailureReason(generatePaymentFailureReason());
        }

        // Handle refunds
        if (status == PaymentStatus.REFUNDED || status == PaymentStatus.PARTIALLY_REFUNDED) {
            BigDecimal refundAmount = status == PaymentStatus.REFUNDED ? amount :
                    amount.multiply(BigDecimal.valueOf(random.nextDouble() * 0.5)).setScale(2, RoundingMode.HALF_UP);
            payment.setRefundedAmount(refundAmount);
            payment.setRefundReason("Customer requested refund");
        }

        return payment;
    }

    private void generateInvoiceForOrder(Order order) {
        Invoice invoice = Invoice.builder()
                .order(order)
                .invoiceNumber(generateInvoiceNumber())
                .customerId(order.getCustomerId())
                .customerName(order.getCustomerName())
                .customerEmail(order.getCustomerEmail())
                .status(generateInvoiceStatus(order.getStatus()))
                .subtotal(order.getSubtotal())
                .taxAmount(order.getTaxAmount())
                .discountAmount(order.getDiscountAmount())
                .totalAmount(order.getTotalAmount())
                .paidAmount(order.getPaidAmount())
                .issueDate(order.getSubmittedAt() != null ? order.getSubmittedAt().toLocalDate() : LocalDate.now())
                .dueDate(order.getSubmittedAt() != null ?
                        order.getSubmittedAt().toLocalDate().plusDays(30) : LocalDate.now().plusDays(30))
                .periodStart(order.getEffectiveDate())
                .periodEnd(order.getEffectiveDate().plusMonths(
                        order.getBillingFrequency() == BillingFrequency.MONTHLY ? 1 :
                                order.getBillingFrequency() == BillingFrequency.QUARTERLY ? 3 :
                                        order.getBillingFrequency() == BillingFrequency.SEMI_ANNUAL ? 6 : 12).minusDays(1))
                .build();

        if (invoice.getStatus() == InvoiceStatus.SENT || invoice.getStatus() == InvoiceStatus.PAID) {
            invoice.setSentAt(order.getSubmittedAt() != null ?
                    order.getSubmittedAt().plusHours(1) : LocalDateTime.now());
        }

        if (invoice.getStatus() == InvoiceStatus.PAID) {
            invoice.setPaidDate(invoice.getIssueDate().plusDays(random.nextInt(20)));
        }

        // Add line items
        for (OrderItem item : order.getItems()) {
            InvoiceLineItem lineItem = InvoiceLineItem.builder()
                    .invoice(invoice)
                    .description(item.getPlanName() + " - " + item.getDescription())
                    .quantity(item.getQuantity())
                    .unitPrice(item.getUnitPrice())
                    .totalPrice(item.getTotalPrice())
                    .planId(item.getPlanId())
                    .planCode(item.getPlanCode())
                    .build();
            invoice.getLineItems().add(lineItem);
        }

        invoiceRepository.save(invoice);
    }

    private SavedPaymentMethod generatePaymentMethod(UUID customerId, boolean isDefault) {
        PaymentMethod type = random.nextDouble() < 0.8 ? PaymentMethod.CREDIT_CARD : PaymentMethod.ACH;

        SavedPaymentMethod method = SavedPaymentMethod.builder()
                .customerId(customerId)
                .paymentMethod(type)
                .isDefault(isDefault)
                .isActive(true)
                .build();

        if (type == PaymentMethod.CREDIT_CARD || type == PaymentMethod.DEBIT_CARD) {
            CardBrand brand = CardBrand.values()[random.nextInt(CardBrand.values().length - 1)];
            method.setCardBrand(brand);
            method.setCardLast4(String.format("%04d", random.nextInt(10000)));
            method.setCardExpiryMonth(1 + random.nextInt(12));
            method.setCardExpiryYear(2026 + random.nextInt(5));
            method.setCardholderName(FIRST_NAMES[random.nextInt(FIRST_NAMES.length)] + " " +
                    LAST_NAMES[random.nextInt(LAST_NAMES.length)]);
            method.setNickname(brand.name() + " ending in " + method.getCardLast4());
            method.setGatewayToken("tok_" + UUID.randomUUID().toString().replace("-", "").substring(0, 24));
        } else {
            method.setBankName(generateBankName());
            method.setAccountType(random.nextBoolean() ? "CHECKING" : "SAVINGS");
            method.setAccountLast4(String.format("%04d", random.nextInt(10000)));
            method.setRoutingLast4(String.format("%04d", random.nextInt(10000)));
            method.setNickname(method.getBankName() + " " + method.getAccountType());
        }

        method.setBillingZip(String.format("%05d", 10000 + random.nextInt(90000)));

        return method;
    }

    // Helper methods

    private String generateOrderNumber(int sequence) {
        String date = LocalDate.now().minusDays(random.nextInt(365))
                .format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        return String.format("ORD-%s-%05d", date, sequence);
    }

    private String generatePaymentNumber() {
        paymentSequence++;
        return String.format("PAY-%010d", paymentSequence);
    }

    private String generateInvoiceNumber() {
        invoiceSequence++;
        return String.format("INV-%010d", invoiceSequence);
    }

    private OrderType generateOrderType() {
        double r = random.nextDouble();
        if (r < 0.6) return OrderType.NEW_ENROLLMENT;
        if (r < 0.8) return OrderType.RENEWAL;
        if (r < 0.9) return OrderType.PLAN_CHANGE;
        if (r < 0.95) return OrderType.ADD_DEPENDENT;
        return OrderType.REMOVE_DEPENDENT;
    }

    private OrderStatus generateOrderStatus() {
        double r = random.nextDouble();
        if (r < 0.05) return OrderStatus.DRAFT;
        if (r < 0.10) return OrderStatus.PENDING_PAYMENT;
        if (r < 0.12) return OrderStatus.PAYMENT_PROCESSING;
        if (r < 0.15) return OrderStatus.PAYMENT_FAILED;
        if (r < 0.25) return OrderStatus.CONFIRMED;
        if (r < 0.35) return OrderStatus.PROCESSING;
        if (r < 0.85) return OrderStatus.COMPLETED;
        if (r < 0.95) return OrderStatus.CANCELLED;
        return OrderStatus.REFUNDED;
    }

    private BillingFrequency generateBillingFrequency() {
        double r = random.nextDouble();
        if (r < 0.7) return BillingFrequency.MONTHLY;
        if (r < 0.85) return BillingFrequency.QUARTERLY;
        if (r < 0.95) return BillingFrequency.ANNUAL;
        return BillingFrequency.SEMI_ANNUAL;
    }

    private PaymentMethod generatePaymentMethodType() {
        double r = random.nextDouble();
        if (r < 0.6) return PaymentMethod.CREDIT_CARD;
        if (r < 0.8) return PaymentMethod.DEBIT_CARD;
        if (r < 0.95) return PaymentMethod.ACH;
        return PaymentMethod.BANK_TRANSFER;
    }

    private PaymentStatus generatePaymentStatus(OrderStatus orderStatus) {
        if (orderStatus == OrderStatus.PAYMENT_FAILED) return PaymentStatus.FAILED;
        if (orderStatus == OrderStatus.REFUNDED) return PaymentStatus.REFUNDED;
        if (orderStatus == OrderStatus.COMPLETED || orderStatus == OrderStatus.CONFIRMED ||
                orderStatus == OrderStatus.PROCESSING) {
            return random.nextDouble() < 0.95 ? PaymentStatus.COMPLETED : PaymentStatus.PARTIALLY_REFUNDED;
        }
        return PaymentStatus.PENDING;
    }

    private InvoiceStatus generateInvoiceStatus(OrderStatus orderStatus) {
        if (orderStatus == OrderStatus.COMPLETED) return InvoiceStatus.PAID;
        if (orderStatus == OrderStatus.CONFIRMED || orderStatus == OrderStatus.PROCESSING) {
            return random.nextDouble() < 0.7 ? InvoiceStatus.PAID : InvoiceStatus.SENT;
        }
        return InvoiceStatus.DRAFT;
    }

    private LocalDate generateEffectiveDate(OrderStatus status) {
        if (status == OrderStatus.COMPLETED) {
            return LocalDate.now().minusMonths(random.nextInt(12));
        } else if (status == OrderStatus.DRAFT || status == OrderStatus.PENDING_PAYMENT) {
            return LocalDate.now().plusDays(1 + random.nextInt(30));
        }
        return LocalDate.now().plusDays(random.nextInt(60));
    }

    private LocalDateTime generateCreatedAt(OrderStatus status) {
        if (status == OrderStatus.COMPLETED) {
            return LocalDateTime.now().minusDays(30 + random.nextInt(335));
        }
        return LocalDateTime.now().minusDays(random.nextInt(30));
    }

    private BigDecimal generatePremium(String metalTier, BillingFrequency frequency) {
        BigDecimal basePremium = switch (metalTier) {
            case "BRONZE" -> BigDecimal.valueOf(250 + random.nextInt(100));
            case "SILVER" -> BigDecimal.valueOf(350 + random.nextInt(100));
            case "GOLD" -> BigDecimal.valueOf(450 + random.nextInt(100));
            case "PLATINUM" -> BigDecimal.valueOf(550 + random.nextInt(150));
            default -> BigDecimal.valueOf(350);
        };

        // Adjust for billing frequency
        return switch (frequency) {
            case MONTHLY -> basePremium;
            case QUARTERLY -> basePremium.multiply(BigDecimal.valueOf(3)).multiply(BigDecimal.valueOf(0.97));
            case SEMI_ANNUAL -> basePremium.multiply(BigDecimal.valueOf(6)).multiply(BigDecimal.valueOf(0.95));
            case ANNUAL -> basePremium.multiply(BigDecimal.valueOf(12)).multiply(BigDecimal.valueOf(0.90));
        };
    }

    private String generateBankName() {
        String[] banks = {"Chase", "Bank of America", "Wells Fargo", "Citibank", "US Bank",
                "PNC Bank", "Capital One", "TD Bank", "BB&T", "SunTrust"};
        return banks[random.nextInt(banks.length)];
    }

    private String generateNotes() {
        String[] notes = {
                "Customer requested paper statements",
                "Premium customer - priority support",
                "Referred by existing member",
                "Corporate employee discount applied",
                "Family plan - multiple dependents"
        };
        return notes[random.nextInt(notes.length)];
    }

    private String generateCancellationReason() {
        String[] reasons = {
                "Found better coverage elsewhere",
                "Financial hardship",
                "Moving out of coverage area",
                "No longer need coverage",
                "Employer-provided coverage obtained",
                "Customer request - no reason given"
        };
        return reasons[random.nextInt(reasons.length)];
    }

    private String generatePaymentFailureReason() {
        String[] reasons = {
                "Insufficient funds",
                "Card declined",
                "Invalid card number",
                "Expired card",
                "Bank rejected transaction",
                "Suspected fraud"
        };
        return reasons[random.nextInt(reasons.length)];
    }
}